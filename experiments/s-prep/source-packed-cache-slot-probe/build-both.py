#!/usr/bin/env python3
import argparse,hashlib,json,os,re,subprocess,time,signal
from pathlib import Path
H=Path(__file__).resolve().parent;ROOT=H.parents[2];p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();lane=a.schema.lower();os.sched_setaffinity(0,{9});os.environ['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';r={'status':'INCOMPLETE','CPU':9,'scope':'Private persistent schema-slot feasibility; no performance/full capability acceptance','commands':[]};sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def save():
 if a.output.exists():(a.output/'build.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,cap):
 argv=list(map(str,argv));rec={'argv':argv,'limitSeconds':cap};r['commands'].append(rec);x=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
 try:out=x.communicate(timeout=cap)[0]
 except subprocess.TimeoutExpired:os.killpg(x.pid,signal.SIGKILL);out=x.communicate()[0];rec['timeout']=True
 rec.update(exit=x.returncode,output=out);save();print(x.returncode,out[-1500:],flush=True);assert x.returncode==0
try:
 assert not a.output.exists();run(['python3',ROOT/'experiments/s-prep/fivehour-measurement/prepare-bend.py','--core',a.overlay/'experiments/s-integrate','--output',a.output,'--schema',a.schema,'--batch','64'],5);run(['python3',ROOT/'experiments/s-prep/static-schema-driver/materialize.py','--driver',a.output/'batch.bend','--schema',a.schema],5)
 module=a.output/'measurement-bend.bend';module_text=module.read_text();fresh=re.search(r'^def '+lane+r'_fresh\(.*?(?=\ndef |\Z)',module_text,re.M|re.S);assert fresh;clone=fresh[0]
 suffix='.health-selection.json' if a.schema=='Health' else '.selection.json';names=json.loads((H/('measurement-bend.bend'+suffix)).read_text())+[lane+'_fresh']
 for n in sorted(names,key=len,reverse=True):clone=re.sub(r'(?<![\w])'+re.escape(n)+r'(?![\w])','prototype_packed_'+n,clone)
 for alias,file in [('RB','raw-boundaries.bend'),('H','host.bend'),('A','transaction-dispatch-adapters.bend'),('HA','held-adapter.bend')]:
  for n in json.loads((H/(file+suffix)).read_text()):clone=re.sub(r'\b'+alias+r'\.'+re.escape(n)+r'\b',alias+'.prototype_packed_'+n,clone)
 clone=clone.replace('CC.Cache<T.Position,T.PositionView>','CP.PrototypeMotionMainSlot').replace('CC.Cache<T.Vitals,T.VitalsView>','CP.PrototypeHealthMainSlot');module.write_text(module_text+'\n'+clone+'\n');r['preparedModuleSHA256']=sha(module)
 p=a.output/'batch.bend';s=p.read_text();r['staticDriverOriginalSHA256']=sha(p)
 for n in sorted(names,key=len,reverse=True):s=re.sub(r'\bM\.'+re.escape(n)+r'\b','M.prototype_packed_'+n,s)
 p.write_text(s);r['driverSHA256']=sha(p);r['sourcePins']=json.loads((a.overlay/'overlay.json').read_text())['sources']
 run(['bend',p,'--check-only'],15);run(['bend',p,'-o',a.output/'batch.c'],30);run(['bend',p,'-o',a.output/'batch.js'],30);run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',a.output/'batch.c','-pthread','-lm','-o',a.output/'batch.native'],120)
 r.update(status='PRIVATE_PACKED_'+a.schema.upper()+'_SOURCE_BUILD_PASS',generatedPins={n:sha(a.output/n) for n in ['batch.bend','batch.c','batch.js','batch.native']});save()
except Exception as e:r.update(status='FAILED',error=repr(e));save();raise
