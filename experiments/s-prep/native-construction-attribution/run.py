#!/usr/bin/env python3
"""Source-callsite counters in a private diagnostic C copy; never elapsed acceptance."""
import argparse, bisect, hashlib, importlib.util, json, os, re, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'))
import supervisor
p=argparse.ArgumentParser(); p.add_argument('--source',type=Path,required=True); p.add_argument('--reference',type=Path,required=True); p.add_argument('--output',type=Path,required=True); p.add_argument('--expected-source-sha256',default='01683bcb4ca6691a31603f26bbe444fb1b02ad0ad59c93ebaf5edfaf2d7957c4'); p.add_argument('--source-root',type=Path); a=p.parse_args()
a.output.mkdir(exist_ok=False); os.sched_setaffinity(0,{11})
sha=lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','commands':[],'sourceSHA256':sha(a.source),'referenceSHA256':sha(a.reference),'scope':'Diagnostic source callsite executions and RFC origins; no stack/inlining attribution or speed acceptance'}
def run(argv,limit):
 c,o=supervisor.execute(list(map(str,argv)),limit); r['commands'].append({'argv':list(map(str,argv)),'limitSeconds':limit,'exit':c,'outputSHA256':hashlib.sha256(o.encode()).hexdigest()}); assert c==0,o[-2000:]; return o
try:
 text=a.source.read_text(); original=text
 # Expand the four invocations exactly as the unchanged runtime macro would.
 macro='  u64 n = heap_alloc(e, w); \\\n  if (err_seen(e.mem)) { \\\n    return term_buf(0, n); \\\n  }'
 assert macro in text
 expansions=0
 def expand(m):
  global expansions
  expansions+=1; n,w=m.group(1),m.group(2)
  return f'  u64 {n} = heap_alloc(e, {w});\n  if (err_seen(e.mem)) {{\n    return term_buf(0, {n});\n  }}'
 text=re.sub(r'^  BLK_ALLOC\((\w+), (.*?)\)$',expand,text,flags=re.M); assert expansions==4
 # Balanced call parsing. Definitions are excluded; no argument expression changes.
 names=['heap_alloc','heap_alloc_miss','bank_pop','rfc_wrap','rfc_seal','term_keep','term_drop','span_fade','ctr_take','blk_copy','blk_node','blk_half','blk_make','malloc','mmap','mprotect','corpus_grow']
 sites=[]; edits=[]
 contexts=list(re.finditer(r"^(?:INLINE|OUTLINE|FAR|static)\s+[^;\n]*?\b(\w+)\([^;\n]*\)\s*\{|^\s*WL_CASE\(([^)]+)\)",text,re.M)); positions=[m.start() for m in contexts]
 for m in re.finditer(r'\b('+ '|'.join(names)+r')\(',text):
  start=m.start(); name=m.group(1); line_start=text.rfind('\n',0,start)+1
  prefix=text[line_start:start]
  if re.match(r'\s*(?:INLINE|OUTLINE|FAR|static)\b',prefix): continue
  if prefix.lstrip().startswith('#define') and name not in ('rfc_seal','term_keep'): continue
  depth=1; end=m.end()
  while depth:
   if text[end]=='(': depth+=1
   elif text[end]==')': depth-=1
   end+=1
  # A forward prototype has no runtime execution.
  call=text[start:end]
  if re.search(r'\b(?:Env|Term|u64|void|u32)\s',call): continue
  ci=bisect.bisect_right(positions,start)-1
  owner=(contexts[ci].group(1) or contexts[ci].group(2)) if ci>=0 else 'macro-or-global'
  if prefix.lstrip().startswith('#define'): owner='macro:'+prefix.split()[1]
  sid=len(sites)
  sites.append({'id':sid,'operation':name,'expandedSourceLine':text.count('\n',0,start)+1,'owner':owner,'expression':call,'following':text[end:end+180]})
  edits.append((start,start,f'(DIAG_HIT({sid}), '))
  edits.append((end,end,')'))
  if name in ('term_keep','rfc_seal'):
   edits.append((end-1,end-1,f', {sid}'))
  elif name=='rfc_wrap':
   origin='diagnostic_origin' if owner in ('term_keep','rfc_seal') else str(sid)
   edits.append((end-1,end-1,f', {origin}'))
 for start,end,new in sorted(edits,reverse=True): text=text[:start]+new+text[end:]
 for old,new in [('INLINE Term term_keep(Env e, Term t, u32 k) {','INLINE Term term_keep(Env e, Term t, u32 k, unsigned diagnostic_origin) {'),('INLINE Term rfc_seal(Env e, Term t) {','INLINE Term rfc_seal(Env e, Term t, unsigned diagnostic_origin) {'),('OUTLINE Term rfc_wrap(Env e, Term t, u32 cnt) {','OUTLINE Term rfc_wrap(Env e, Term t, u32 cnt, unsigned diagnostic_origin) {\n  if (diagnostic_active) diagnostic_rfc[diagnostic_origin]++;')]:
  assert text.count(old)==1,old; text=text.replace(old,new)
 # Source macro body has one allocator call; no runtime invocation remains after exact expansion.
 decl=f'''static unsigned diagnostic_active, diagnostic_clocks;
static unsigned long long diagnostic_sites[{len(sites)}], diagnostic_rfc[{len(sites)}], diagnostic_words, diagnostic_heap_entries;
#define DIAG_HIT(i) (diagnostic_active ? (++diagnostic_sites[i], 0) : 0)
'''
 assert text.count('// Dialect\n')==1; text=text.replace('// Dialect\n',decl+'// Dialect\n',1)
 hook='INLINE u64 heap_alloc(Env e, u32 cls) {'; assert text.count(hook)==1
 text=text.replace(hook,hook+'\n  if (diagnostic_active) { diagnostic_heap_entries++; diagnostic_words += 1ull << cls; }')
 old='Term io_now_run(Env e, Term* f, IoWork* w) {\n  return (Term)(io_tick() / 1000000);\n}'
 new='''Term io_now_run(Env e, Term* f, IoWork* w) {
 unsigned n = ++diagnostic_clocks;
 if (n == 3) diagnostic_active = 1;
 if (n == 4) {
  diagnostic_active = 0;
  fprintf(stderr, "TOTAL:%llu,%llu\\n", diagnostic_heap_entries, diagnostic_words);
  for (unsigned i=0; i<DIAGNOSTIC_NSITES; ++i) if (diagnostic_sites[i] || diagnostic_rfc[i]) fprintf(stderr,"SITE:%u,%llu,%llu\\n",i,diagnostic_sites[i],diagnostic_rfc[i]);
 }
 fprintf(stderr,"CLOCK:%u\\n",n);
 return (Term)(io_tick() / 1000000);
}'''.replace('DIAGNOSTIC_NSITES',str(len(sites)))
 assert text.count(old)==1; text=text.replace(old,new)
 derived=a.output/'counted.c'; derived.write_text(text)
 (a.output/'sites.json').write_text(json.dumps(sites,indent=2)+'\n')
 envroot='/tmp/bendvy-clang19-diagnostic/root'; compiler='/tmp/bendvy-clang19-diagnostic/clang19'
 os.environ['BENDVY_CLANG19_ROOT']=envroot
 r['compilerWrapperSHA256']=sha(Path(compiler)); r['compilerELFSHA256']=sha(Path(envroot+'/usr/lib/llvm-19/bin/clang')); r['derivedSHA256']=sha(derived)
 assert r['sourceSHA256']==a.expected_source_sha256
 assert r['compilerWrapperSHA256']=='3e171a978d6c1decae4e6645e9bfb771cf5af21ff699ea119fdb058936b0af2d'
 assert r['compilerELFSHA256']=='c50213cae902a10db8c1ff172df4798b0a5a94f569a81270b834cd8a7d3afb5d'
 manifest=a.source.parent/'build.json'; r['upstreamBuildSHA256']=sha(manifest); upstream=json.loads(manifest.read_text())
 if a.source_root:
  source_root=a.source_root; mapping=source_root/'overlay.json';r['sourceMapSHA256']=sha(mapping);r['runtimeSources']=json.loads(mapping.read_text())['sources']
 else:
  source_root=Path(upstream['overlay']);r['runtimeSources']=upstream['runtimeSources']
 assert len(r['runtimeSources'])==29
 for name,pin in r['runtimeSources'].items(): assert sha(source_root/name)==pin,name
 r['sourceRoot']=str(source_root);r['entrySHA256']=sha(a.source.parent/'batch.bend');r['recipeSHA256']=sha(Path(__file__))
 run([compiler,'-O3',derived,'-pthread','-lm','-o',a.output/'counted-native'],120)
 reference=run(['node',a.reference],5)
 redirect='import os,sys; fd=os.open(sys.argv[1],os.O_WRONLY|os.O_CREAT|os.O_EXCL,0o600); os.dup2(fd,2); os.close(fd); os.execv(sys.argv[2],sys.argv[2:])'
 native=run([sys.executable,'-c',redirect,a.output/'counts.txt',a.output/'counted-native','--threads','1','--gpu','off'],5)
 (a.output/'TS.raw.txt').write_text(reference); (a.output/'Native.raw.txt').write_text(native)
 observed=json.loads(reference); assert (observed['schema'],observed['count'],observed['iterations'],observed['batch'])==('Motion',256,64,64)
 spec=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py'); v=importlib.util.module_from_spec(spec); spec.loader.exec_module(v)
 records=[line for line in native.splitlines() if line.startswith('{')]; assert len(records)==65
 for line,world in zip(records,[observed['warmup'],*observed['samples']]):
  v.validate(line,'Motion',False,256,world); assert v.normalized(json.loads(line),'Motion')==world['final']
 logs=(a.output/'counts.txt').read_text().splitlines(); assert [l for l in logs if l.startswith('CLOCK:')]==['CLOCK:'+str(i) for i in range(1,5)]
 totals=[l for l in logs if l.startswith('TOTAL:')]; assert len(totals)==1
 heap,words=map(int,totals[0][6:].split(','))
 for line in logs:
  if line.startswith('SITE:'):
   sid,count,rfc=map(int,line[5:].split(',')); sites[sid].update(entries=count,rfcCreated=rfc)
 for site in sites: site.setdefault('entries',0); site.setdefault('rfcCreated',0)
 assert sum(s['entries'] for s in sites if s['operation']=='heap_alloc')==heap
 assert sum(s['rfcCreated'] for s in sites)==sum(s['entries'] for s in sites if s['operation']=='rfc_wrap')
 assert sum(s['entries'] for s in sites if s['operation']=='heap_alloc' and s['owner']=='rfc_wrap')==sum(s['rfcCreated'] for s in sites)
 r.update(status='CALLSITE_COUNTS_FULL65_FIELDS_PASS',allFullFieldsEqual=True,fullWorlds=65,updates=1048576,heapEntries=heap,requestedWords=words,rfcCreated=sum(s['rfcCreated'] for s in sites),macroExpansions=expansions,siteCount=len(sites),sourceAfterSHA256=sha(a.source)); assert r['sourceSHA256']==r['sourceAfterSHA256']
 (a.output/'sites.json').write_text(json.dumps(sites,indent=2)+'\n')
 r['artifacts']={n:sha(a.output/n) for n in ['counted.c','counted-native','counts.txt','TS.raw.txt','Native.raw.txt','sites.json']}
except Exception as e: r.update(status='FAIL',error=repr(e))
finally: (a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r)); sys.exit(0 if r['status']=='CALLSITE_COUNTS_FULL65_FIELDS_PASS' else 1)
