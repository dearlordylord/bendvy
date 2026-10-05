#!/usr/bin/env python3
"""One diagnostic comparison; no autoresearch packet, keep or product acceptance."""
import argparse,hashlib,importlib.util,json,os,statistics,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
G=ROOT/'experiments/s-prep/fivehour-connected-gates';sys.path.insert(0,str(G));import supervisor
H=ROOT/'experiments/s-prep/fivehour-measurement'
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--js',type=Path,required=True);p.add_argument('--native',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{11})
r={'status':'INCOMPLETE','scope':'Diagnostic focused dense comparison; full22 gates incomplete; no keep/product acceptance','checkerSeconds':15,'cpu':11,'batch':64,'ticks':64,'entities':256,'native':'O3, one thread, GPU off','commands':[],'cells':{}}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def command(args,limit):
 log=a.output/f'command-{len(r["commands"]):03d}.txt';entry={'argv':list(map(str,args)),'limitSeconds':limit};r['commands'].append(entry)
 try:
  code,text=supervisor.execute(list(map(str,args)),limit);log.write_text(text);entry.update(exit=code,outputSHA256=sha(log));assert code==0,text[-1000:];return text
 except Exception as e:entry['error']=repr(e);raise
 finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
spec=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
try:
 artifacts={}
 for schema in ['Motion','Health']:
  ts=a.output/(schema+'.mjs');command([sys.executable,H/'prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',ts,'--schema',schema],5);artifacts[schema]={'TS':ts}
  for backend,overlay in [('JS',a.js),('Native',a.native)]:
   pins=json.loads((overlay/'overlay.json').read_text())['sources'];assert all(sha(overlay/n)==v for n,v in pins.items());r.setdefault('runtimePins',{})[backend]=pins
   folder=a.output/(schema+'-'+backend);command([sys.executable,H/'prepare-bend.py','--core',overlay/'experiments/s-integrate','--output',folder,'--schema',schema],5)
   entry=folder/'batch.bend';assert 'ALL PROOFS CHECK' in command(['bend',entry,'--check-only'],15)
   generated=folder/('batch.js' if backend=='JS' else 'batch.c');command(['bend',entry,'-o',generated],30)
   binary=generated
   if backend=='Native':
    binary=folder/'batch-native';command(['clang','-O3',generated,'-pthread','-lm','-o',binary],120)
   artifacts[schema][backend]=binary;r.setdefault('artifactPins',{})[str(binary)]=sha(binary)
 for schema in ['Motion','Health']:
  values={b:[] for b in ['TS','JS','Native']}
  for sample in range(14):
   outputs={};order=['Native','TS','JS'];order=order[sample%3:]+order[:sample%3]
   for backend in order:
    binary=artifacts[schema][backend];args=[binary,'--threads','1','--gpu','off'] if backend=='Native' else ['node',binary];text=command(args,5);raw=a.output/f'{schema}-{sample}-{backend}.txt';raw.write_text(text);outputs[backend]=text
   ts=json.loads(outputs['TS']);assert ts['batch']==64 and len(ts['samples'])==64;values['TS'].append(ts['batchMilliseconds'])
   for backend in ['JS','Native']:
    lines=outputs[backend].splitlines();clock=[x for x in lines if x.startswith('BATCH-MILLISECONDS:')];records=[x for x in lines if not x.startswith('BATCH-MILLISECONDS:')];assert len(clock)==1 and len(records)==65
    for line,world in zip(records,[ts['warmup'],*ts['samples']]):
     V.validate(line,schema,False,256,world);assert V.normalized(json.loads(line),schema)==world['final']
    values[backend].append(float(clock[0].split(':')[1]))
  for backend in ['JS','Native']:
   ratio=statistics.median(values[backend])/statistics.median(values['TS']);r['cells'][backend+'/'+schema]={'candidateMilliseconds':values[backend],'tsMilliseconds':values['TS'],'medianElapsedRatio':ratio,'speedup':1/ratio,'all65WorldsPerSampleFullFieldsEqual':True}
 r['status']='DIAGNOSTIC_COMPARISON_COMPLETE'
except Exception as e:r.update(status='FAILED_NO_COMPARISON',error=repr(e))
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps({'status':r['status'],'error':r.get('error'),'cells':r['cells']}));sys.exit(0 if r['status']=='DIAGNOSTIC_COMPARISON_COMPLETE' else 1)
