#!/usr/bin/env python3
"""Count unchanged runtime destruction branches on a private C copy, not time."""
import argparse,hashlib,importlib.util,json,os,sys
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy')
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'))
import supervisor
p=argparse.ArgumentParser();p.add_argument('--source',type=Path,required=True);p.add_argument('--reference',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--expected-source-sha256',required=True);p.add_argument('--source-root',type=Path,required=True);a=p.parse_args()
a.output=a.output.absolute();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8})
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','scope':'Iterative runtime branch executions, not time or universal sharing diagnosis','sourceSHA256':sha(a.source),'referenceSHA256':sha(a.reference),'recipeSHA256':sha(Path(__file__)),'commands':[]}
def execute(argv,limit,name):
 code,out=supervisor.execute(list(map(str,argv)),limit);(a.output/name).write_text(out);r['commands'].append({'argv':list(map(str,argv)),'limitSeconds':limit,'exit':code,'outputSHA256':hashlib.sha256(out.encode()).hexdigest()});assert code==0,out[-1000:];return out
try:
 assert r['sourceSHA256']==a.expected_source_sha256
 r['runtimeSources']=json.loads((a.source_root/'overlay.json').read_text())['sources'];assert len(r['runtimeSources'])==29
 for rel,h in r['runtimeSources'].items():assert sha(a.source_root/rel)==h
 r['sourceRoot']=str(a.source_root);r['upstreamBuildSHA256']=sha(a.source.parent/'build.json');r['entrySHA256']=sha(a.source.parent/'batch.bend')
 s=a.source.read_text()
 counters=['drop_entry','drop_outer','drop_rfc','drop_deferred','drop_last','drop_nontrivial','drop_buf','drop_object','drop_inner','drop_child','drop_descend','drop_free','rfc_view','rfc_bump','wrap','seal','keep','peek']
 decl='static unsigned diagnostic_clocks, diagnostic_active;\nstatic unsigned long long diagnostic_counts['+str(len(counters))+'], diagnostic_cids[65536];\n'
 decl+='#define DCOUNT(i) do { if(diagnostic_active) diagnostic_counts[i]++; } while(0)\n'
 assert s.count('OUTLINE Term rfc_wrap(Env e, Term t, u32 cnt) {')==1
 s=s.replace('OUTLINE Term rfc_wrap(Env e, Term t, u32 cnt) {',decl+'OUTLINE Term rfc_wrap(Env e, Term t, u32 cnt) {\n DCOUNT(14);',1)
 for old,new in [('INLINE u64 rfc_view(DEV u64* H, u64 r) {','\n DCOUNT(12);'),('INLINE void rfc_bump(Env e, u64 r, u32 k) {','\n DCOUNT(13);'),('INLINE Term rfc_seal(Env e, Term t) {','\n DCOUNT(15);'),('INLINE Term term_keep(Env e, Term t, u32 k) {','\n DCOUNT(16);'),('INLINE u64 term_peek(DEV u64* H, Term t) {','\n DCOUNT(17);')]:
  assert s.count(old)==1;s=s.replace(old,old+new,1)
 beg=s.index('FAR void term_drop(Env e, Term t) {');end=s.index('\nINLINE void term_sink',beg);body=s[beg:end]
 replacements=[('FAR void term_drop(Env e, Term t) {','FAR void term_drop(Env e, Term t) {\n DCOUNT(0);'),('\n  for (;;) {','\n  for (;;) {\n DCOUNT(1);'),('    if (!term_triv(t) && term_rfc(t)) {','    if (!term_triv(t) && term_rfc(t)) {\n DCOUNT(2);'),('        t = 0;','        DCOUNT(3); t = 0;'),('        a32_acq(p);','        DCOUNT(4); a32_acq(p);'),('    if (!term_triv(t)) {','    if (!term_triv(t)) {\n DCOUNT(5);'),('      if (tag == TAG_BUF) {','      if (tag == TAG_BUF) {\n DCOUNT(6);'),('        u32 aux = (u32)term_aux(t);','        DCOUNT(7); u32 aux = (u32)term_aux(t);\n if(diagnostic_active && tag==TAG_CTR) diagnostic_cids[aux]++;'),('    for (;;) {','    for (;;) {\n DCOUNT(8);'),('      if (j < n) {','      if (j < n) {\n DCOUNT(9);'),('        if (!term_triv(c)) {','        if (!term_triv(c)) {\n DCOUNT(10);'),('        u64 up = H[loc];','        DCOUNT(11); u64 up = H[loc];')]
 for old,new in replacements:
  assert body.count(old)==1,(old,body.count(old));body=body.replace(old,new,1)
 s=s[:beg]+body+s[end:]
 old='Term io_now_run(Env e, Term* f, IoWork* w) {\n  return (Term)(io_tick() / 1000000);\n}'
 assert s.count(old)==1
 emit='\n'.join('fprintf(stderr,"'+k+':%llu\\n",diagnostic_counts['+str(i)+']);' for i,k in enumerate(counters))
 new='Term io_now_run(Env e, Term* f, IoWork* w) {\n unsigned n=++diagnostic_clocks; if(n==3) {diagnostic_active=1;fprintf(stderr,"DROP-PHASE:START\\n");} if(n==4) {diagnostic_active=0;fprintf(stderr,"DROP-PHASE:END\\n");'+emit+'for(unsigned i=0;i<65536;i++)if(diagnostic_cids[i])fprintf(stderr,"CID:%u,%llu\\n",i,diagnostic_cids[i]);}\n return (Term)(io_tick()/1000000);\n}'
 s=s.replace(old,new,1);c=a.output/'counted.c';c.write_text(s);r['derivedSHA256']=sha(c)
 execute(['env','BENDVY_CLANG19_ROOT=/tmp/bendvy-clang19-diagnostic/root','/tmp/bendvy-clang19-diagnostic/clang19','-O3',c,'-pthread','-lm','-o',a.output/'counted-native'],120,'compile.txt')
 ts=execute(['node',a.reference],5,'TS.raw.txt')
 launch='import os,sys;fd=os.open(sys.argv[1],os.O_WRONLY|os.O_CREAT|os.O_EXCL,0o600);os.dup2(fd,2);os.close(fd);os.execv(sys.argv[2],sys.argv[2:])'
 native=execute([sys.executable,'-c',launch,a.output/'counts.txt',a.output/'counted-native','--threads','1','--gpu','off'],5,'Native.raw.txt')
 counts=(a.output/'counts.txt').read_text();assert counts.startswith('DROP-PHASE:START\nDROP-PHASE:END\n')
 ref=json.loads(ts);records=[x for x in native.splitlines() if x.startswith('{')];assert len(records)==65 and len(ref['samples'])==64
 spec=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
 for line,world in zip(records,[ref['warmup'],*ref['samples']]):v.validate(line,'Motion',False,256,world);assert v.normalized(json.loads(line),'Motion')==world['final']
 assert sha(a.source)==r['sourceSHA256'];r.update(status='DROP_BRANCHES_FULL65_FIELDS_PASS',allFullFieldsEqual=True,phaseClocks=[3,4],counts=counts)
except Exception as e:r.update(status='FAILED',error=repr(e))
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps({'status':r['status'],'error':r.get('error')}));sys.exit(0 if r['status']=='DROP_BRANCHES_FULL65_FIELDS_PASS' else 1)
