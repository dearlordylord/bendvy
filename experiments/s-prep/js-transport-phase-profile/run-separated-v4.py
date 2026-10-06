#!/usr/bin/env python3
"""Bounded V8 diagnostic; 64 worlds, no performance acceptance or compiler edits."""
import argparse,hashlib,importlib.util,json,os,re,sys
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy')
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
H=ROOT/'experiments/s-prep/fivehour-measurement'
p=argparse.ArgumentParser();p.add_argument('--generated-js',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--cpu',type=int,default=11);p.add_argument("--baseline",action="store_true");p.add_argument("--recipe-directory",type=Path,required=True);p.add_argument("--no-gc",action="store_true",help="Disable GC tracing when only constructor counts are needed");p.add_argument("--capture-ts-json",action="store_true",help="Retain the full TS JSON in a separate file outside the phase to prevent GC output interleaving");a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{a.cpu})
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','scope':'CPU/GC diagnosis with equal64 fresh worlds; no timing acceptance','batch':64,'ticks':64,'entities':256,'cpu':a.cpu,'gcTracing':not a.no_gc,'generatedOriginalSHA256':sha(a.generated_js),'commands':[]}
def command(args,limit=5):
 code,text=supervisor.execute(list(map(str,args)),limit);r['commands'].append({'argv':list(map(str,args)),'limit':limit,'exit':code});assert code==0,text[-1000:];return text
try:
 receipt=Path(str(a.generated_js)+'.recipe.json');m=json.loads(receipt.read_text());d=a.recipe_directory
 nested=m['status']=='PINNED_NESTED_DIRECT_LITERAL_SCALAR_EDGES_DERIVED'
 assert (nested or m['status']=='PINNED_DIRECT_TUPLE_SCALAR_RECEIVERS_DERIVED') and m['schema']=='health' and m['mode'] in ['normal','packed-paired-raw','cursor-normal']
 analysis=d.parent/'analyze.cjs' if nested else d/'analyze.cjs'
 assert m['outputSHA256']==sha(a.generated_js) and m['recipeSHA256']==sha(d/'rewrite.cjs') and m['analysisSHA256']==sha(analysis) and m['catalogSHA256']==sha(d/'input-pins.json')
 pin=json.loads((d/'input-pins.json').read_text())[m['inputSHA256']];baseline=Path(pin['inputPath']);assert sha(baseline)==m['inputSHA256']
 assert pin['sourcePins']==m['sourcePins'] and pin['sourceRoot']==m['sourceRoot'] and len(m['sourcePins'])==29
 for n,h in m['sourcePins'].items():assert sha(Path(m['sourceRoot'])/n)==h
 for n,h in m['provenancePins'].items():assert sha(Path(n))==h
 r['provenance']={'candidateSHA256':sha(a.generated_js),'baselineSHA256':sha(baseline),'actualDerivationReceiptSHA256':sha(receipt),'sourcePins':m['sourcePins'],'producerPins':m['provenancePins']}
 if a.baseline:a.generated_js=baseline
 r['role']='baseline' if a.baseline else 'candidate';r['generatedOriginalSHA256']=sha(a.generated_js);r['recipeSHA256']=sha(Path(__file__))
 js=a.generated_js.read_text()
 entries=[('return $choose$(1, 256, 64);','return $choose$(1, 256, 8);'),('return $health_batch$(256, 64);','return $health_batch$(256, 8);'),('return $prototype_packed_health_batch$(256, 64);','return $prototype_packed_health_batch$(256, 8);')]
 selected=[(old,new) for old,new in entries if js.count(old)==1]
 assert len(selected)==1 and sum(js.count(old) for old,_ in entries)==1,'Ambiguous or unsupported full64 Health entry'
 old,_=selected[0];new=old;r['entryAdaptation']={'original':old,'derived':new}
 timed='$prototype_packed_health_timed$' if 'prototype_packed' in old else '$health_timed$'
 begin=js.index('function '+timed+'(');end=js.index('\nfunction ',begin+1);body=js[begin:end]
 clocks=re.findall(r'\$IO\$now\$\([^()]*\)',body);assert len(clocks)==2 and len(set(clocks))==2
 for needle,phase in zip(clocks,['start','end']):
  assert body.count(needle)==1;body=body.replace(needle,'(__profile_mark("'+phase+'"), '+needle+')')
 js=js[:begin]+body+js[end:]
 marker='function __profile_mark(phase) { if(typeof __allocation_phase === "function") __allocation_phase(phase); console.error("PROFILE-MARK:" + JSON.stringify({phase, micro:Number(process.hrtime.bigint()/1000n), uptimeMS:process.uptime()*1000})); }\n'
 # V8 writes GC traces directly to stdout. A pending asynchronous large JSON
 # write can be split by those traces; synchronously serialize outside the phase.
 transport='if (!process.stdout._handle || typeof process.stdout._handle.setBlocking !== "function") throw Error("Unsupported diagnostic stdout transport"); process.stdout._handle.setBlocking(true);\n'
 r['outputTransport']='Both roles use blocking stdout to prevent GC trace/JSON interleaving; setup/output remain outside the measured phase'
 js=marker+transport+'console.error("PROFILE-READY");\n'+js
 (a.output/'bend.js').write_text(js)
 command([sys.executable,H/'prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',a.output/'reference.mjs','--schema','Health','--batch','64'])
 ts=(a.output/'reference.mjs').read_text();needle='const start=performance.now();for(const owner of prepared)owner.run();const end=performance.now();';assert ts.count(needle)==1;ts=ts.replace(needle,'__profile_mark("start");'+needle+'__profile_mark("end");');(a.output/'reference.mjs').write_text(marker+transport+'console.error("PROFILE-READY");\n'+ts)
 if a.capture_ts_json:
  ts=(a.output/'reference.mjs').read_text();assert ts.count('console.log(JSON.stringify(')==1
  ts=ts.replace('console.log(JSON.stringify(', '__profile_json_write(JSON.stringify(')
  transport2='import {writeFileSync as __profile_writeFile} from "node:fs";\nfunction __profile_json_write(text){__profile_writeFile('+json.dumps(str(a.output/'TS.final.json'))+',text+"\\n");}\n'
  (a.output/'reference.mjs').write_text(transport2+ts);r['TSJSONTransport']='Full unchanged JSON stringify retained; write to separate file outside phase; GC and marker stdout preserved'
 r['derivedPins']={name:sha(a.output/name) for name in ['bend.js','reference.mjs']}
 outputs={}
 for role,entry in [('TS','reference.mjs'),('JS','bend.js')]:
  text=command(['node','--cpu-prof','--cpu-prof-interval=100','--cpu-prof-dir='+str(a.output),'--cpu-prof-name='+role+'.cpuprofile',*([] if a.no_gc else ['--trace-gc-nvp']),a.output/entry]);(a.output/(role+'.raw.txt')).write_text(text)
  lines=text.splitlines();marks=[json.loads(x.split('PROFILE-MARK:',1)[1]) for x in lines if x.startswith('PROFILE-MARK:')];assert [x['phase'] for x in marks]==['start','end'];r.setdefault('marks',{})[role]=marks
  clean=[x for x in lines if x.startswith('BATCH-MILLISECONDS:') or x.startswith('{')];outputs[role]=(a.output/'TS.final.json').read_text() if role=='TS' and a.capture_ts_json else '\n'.join(clean);(a.output/(role+'.observed.txt')).write_text(outputs[role]);assert (a.output/(role+'.cpuprofile')).exists()
 spec=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
 ts=json.loads(outputs['TS']);records=[x for x in outputs['JS'].splitlines() if x.startswith('{')];assert len(records)==65 and len(ts['samples'])==64
 for line,world in zip(records,[ts['warmup'],*ts['samples']]):V.validate(line,'Health',False,256,world);assert V.normalized(json.loads(line),'Health')==world['final']
 r.update(status='PROFILE_AND_FULL65_WORLDS_PASS',allFullFieldsEqual=True)
except Exception as e:r.update(status='FAILED',error=repr(e))
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r));sys.exit(0 if r['status']=='PROFILE_AND_FULL65_WORLDS_PASS' else 1)
