#!/usr/bin/env python3
"""One size-layout hypothesis, exact unchanged joined C and pinned Clang19."""
import argparse,pathlib,hashlib,json,subprocess,signal,time,os,re
p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--flag',choices=['Os','O2'],default='Os');p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{10})
HERE=pathlib.Path(__file__).resolve().parent;overlay=pathlib.Path('/tmp/bendvy-joined-flatjournal-ledger-v1');build=pathlib.Path('/tmp/bendvy-joined-flatjournal-ledger-'+a.schema.lower()+'-build-v1');clang=pathlib.Path('/tmp/bendvy-clang19-diagnostic/clang19');sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest();pins=json.loads((overlay/'overlay.json').read_text())['sources'];assert len(pins)==29 and all(sha(overlay/n)==v for n,v in pins.items());baseline=json.loads((build/'build.json').read_text());assert baseline['status']=='BUILD_PASS' and baseline['sourcePins']==pins
source=build/'batch.c';binary=build/'batch-native';assert sha(source)==baseline['artifacts']['batch.c'] and sha(binary)==baseline['artifacts']['batch-native'];assert any('-O3' in c['argv'] for c in baseline['commands']);copy=a.output/'batch.c';copy.write_bytes(source.read_bytes())
r={'status':'INCOMPLETE','hypothesis':'Size-oriented optimization may reduce generated helper expansion/code footprint or static stack traffic without changing operations, source algorithms, calling-convention attributes or musttail requirements; no PMU/cache-miss claim','schema':a.schema,'flag':'-'+a.flag,'CPU':10,'sourcePins':pins,'sourceClosureSHA256':hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest(),'sameC':{'path':str(source),'SHA256':sha(source),'copiedSHA256':sha(copy)},'baselineBinary':{'path':str(binary),'SHA256':sha(binary)},'baselineBuildReceiptSHA256':sha(build/'build.json'),'clangWrapperSHA256':sha(clang),'recipeSHA256':sha(pathlib.Path(__file__)),'compileLimitSeconds':120,'runtimePolicy':{'workers':1,'GPU':'off','limitSeconds':5},'commands':[],'performanceAcceptance':False}
def save():(a.output/'build.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,cap):
 argv=list(map(str,argv));env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';start=time.monotonic();c=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env);timed=False
 try:out=c.communicate(timeout=cap)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(c.pid,signal.SIGKILL);out=c.communicate()[0]
 r['commands'].append({'argv':argv,'limitSeconds':cap,'seconds':time.monotonic()-start,'exit':c.returncode,'timeout':timed,'output':out if argv[0]!='objdump' else None,'outputSHA256':hashlib.sha256(out.encode()).hexdigest()});save();assert c.returncode==0 and not timed,r['commands'][-1];return out
try:
 r['clangVersion']=run([clang,'--version'],5);run([clang,'-'+a.flag,copy,'-o',a.output/'batch-native','-lm','-pthread'],120)
 for role,path in [('O3',binary),(a.flag,a.output/'batch-native')]:
  symbols=run(['objdump','-t',path],5);(a.output/(role+'-symbols.txt')).write_text(symbols);disasm=run(['objdump','-d',path],5);(a.output/(role+'-disassembly.txt')).write_text(disasm);sizes=run(['size',path],5);(a.output/(role+'-size.txt')).write_text(sizes)
  funcs={};matches=list(re.finditer(r'^([0-9a-f]+) <([^>]+)>:\n',disasm,re.M))
  for i,m in enumerate(matches):
   body=disasm[m.end():matches[i+1].start() if i+1<len(matches) else len(disasm)]
   if ('JOURNALLEDGER_HEALTH' in m[2] or 'FLATFOLD_MOTION' in m[2] or 'MOTION_BODY' in m[2] or 'HEALTH_BODY' in m[2] or m[2] in ('rfc_wrap','term_drop','heap_alloc','spin_92')):
    funcs[m[2]]={'instructionLines':len(re.findall(r'^\s+[0-9a-f]+:\s',body,re.M)),'staticStackMemoryInstructions':len([x for x in body.splitlines() if re.search(r'\b(?:str|ldr|stp|ldp|stur|ldur)\b',x) and '[sp' in x]),'staticCallInstructions':len(re.findall(r'\bbl\b',body)),'stackFrameInstructions':[x.strip() for x in body.splitlines() if re.search(r'\bsub\s+sp,\s*sp',x) or re.search(r'\bstp\b.*\[sp,.*\]!',x)]};(a.output/(role+'-'+m[2]+'.asm')).write_text(body)
  r.setdefault('layout',{})[role]={'sizeOutput':sizes,'selectedFunctions':funcs}
 r['candidateBinarySHA256']=sha(a.output/'batch-native');assert sha(source)==r['sameC']['SHA256'];r['status']='SAME_C_LAYOUT_BUILD_PASS'
except Exception as e:r.update(status='FAIL',error=repr(e));raise
finally:save()
