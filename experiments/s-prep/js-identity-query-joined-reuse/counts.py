#!/usr/bin/env python3
"""Count executed construction expressions in two existing source-pinned profile workloads."""
import argparse,hashlib,importlib.util,json,os,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{11})
r={'status':'INCOMPLETE','scope':'Executed construction expressions only; no build status, physical allocation, timing or adoption claim','CPU':11,'commands':[],'recipeSHA256':sha(Path(__file__))}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(args,label):
 c={'argv':list(map(str,args)),'limitSeconds':5};r['commands'].append(c);save();x=subprocess.run(c['argv'],capture_output=True,text=True,timeout=5);f=a.output/(label+'.txt');f.write_text(x.stdout+x.stderr);c.update(exit=x.returncode,outputSHA256=sha(f));save();assert x.returncode==0;return x.stdout+x.stderr
try:
 candidate=Path('/tmp/bendvy-js-identity-query-health-pool-v3.js');token=HERE/'token-pool';tr=Path(str(candidate)+'.recipe.json');m=json.loads(tr.read_text());pin=json.loads((token/'input-pins.json').read_text())[m['inputSHA256']];intermediate=Path(pin['inputPath']);rr=Path(str(intermediate)+'.recipe.json');row=json.loads(rr.read_text());baseline=Path('/tmp/bendvy-identity-query-health-v3/batch.js')
 assert m['outputSHA256']==sha(candidate) and m['recipeSHA256']==sha(token/'rewrite.cjs') and m['catalogSHA256']==sha(token/'input-pins.json') and m['sourceFactsSHA256']==sha(token/'source-facts.json')
 assert sha(rr)==pin['rowRecipeSHA256'] and row['outputSHA256']==sha(intermediate)==m['inputSHA256'] and row['inputSHA256']==sha(baseline)
 assert row['recipeSHA256']==sha(HERE/'rewrite.cjs') and row['catalogSHA256']==sha(HERE/'input-pins.json')
 for n,h in row['sourcePins'].items():assert sha(Path(row['sourceRoot'])/n)==h
 r['chain']={'baselineSHA256':sha(baseline),'candidateSHA256':sha(candidate),'rowReceiptSHA256':sha(rr),'tokenReceiptSHA256':sha(tr),'sourcePins':row['sourcePins']}
 spec=importlib.util.spec_from_file_location('V',ROOT/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
 profile=a.output/'candidate-nine';profile.mkdir();js=candidate.read_text();old='return $health_batch$(256, 64);';assert js.count(old)==1;js=js.replace(old,'return $health_batch$(256, 8);',1)
 begin=js.index('function $health_timed$(');end=js.index('\nfunction ',begin+1);body=js[begin:end]
 for needle,phase in [('$IO$now$(_x_1)','start'),('$IO$now$(_x_6)','end')]:
  assert body.count(needle)==1;body=body.replace(needle,'(__allocation_phase_if_present("'+phase+'"), '+needle+')')
 marker=Path('/tmp/bendvy-identity-query-health-counts-v3/candidate/bend.js').read_text().splitlines()[0].replace('__profile_mark','__allocation_phase_if_present');assert marker.startswith('function __allocation_phase_if_present');js=marker+'\n'+js[:begin]+body+js[end:];(profile/'bend.js').write_text(js)
 tsout=run(['node','/tmp/bendvy-identity-query-health-counts-v3/candidate/reference.mjs'],'fresh-ts');tsline=[x for x in tsout.splitlines() if x.startswith('{')];assert len(tsline)==1;(profile/'TS.observed.txt').write_text(tsline[0]);quiet=run(['node',profile/'bend.js'],'candidate-quiet');ts=json.loads(tsline[0]);records=[x for x in quiet.splitlines() if x.startswith('{')];assert len(records)==9
 for line,world in zip(records,[ts['warmup'],*ts['samples']]):V.validate(line,'Health',False,256,world);assert V.normalized(json.loads(line),'Health')==world['final']
 (profile/'evidence.json').write_text(json.dumps({'status':'DERIVED_NINE_FULL_WORLDS_PASS_NO_PROFILE_OR_BUILD_CLAIM','generatedOriginalSHA256':sha(candidate),'driverSHA256':sha(profile/'bend.js')}))
 totals={};kinds={}
 for role,profile,original in [('baseline',Path('/tmp/bendvy-identity-query-health-counts-v3/candidate'),baseline),('candidate',a.output/'candidate-nine',candidate)]:
  evidence=json.loads((profile/'evidence.json').read_text());assert evidence['status'] in ['PROFILE_AND_NINE_FULL_WORLDS_PASS','DERIVED_NINE_FULL_WORLDS_PASS_NO_PROFILE_OR_BUILD_CLAIM'] and evidence['generatedOriginalSHA256']==sha(original)
  source=profile/'bend.js';counted=a.output/(role+'.js');run(['node','--expose-internals',ROOT/'experiments/s-prep/js-allocation-map/instrument.cjs',source,counted],role+'-instrument');out=run(['node',counted],role+'-counted');values=[json.loads(x.split(':',1)[1]) for x in out.splitlines() if x.startswith('ALLOCATION-COUNTS:')];assert len(values)==1
  ts=json.loads((profile/'TS.observed.txt').read_text());records=[x for x in out.splitlines() if x.startswith('{')];assert len(records)==9 and len(ts['samples'])==8
  for line,world in zip(records,[ts['warmup'],*ts['samples']]):V.validate(line,'Health',False,256,world);assert V.normalized(json.loads(line),'Health')==world['final']
  sites=json.loads(Path(str(counted)+'.sites.json').read_text())['sites'];assert len(sites)==len(values[0]);by={}
  for site,n in zip(sites,values[0]):by[site['kind']]=by.get(site['kind'],0)+n
  kinds[role]=by;totals[role]=sum(values[0]);r.setdefault('profiles',{})[role]={'evidenceSHA256':sha(profile/'evidence.json'),'profileWorkloadSHA256':sha(source),'countedSHA256':sha(counted),'sitesSHA256':sha(Path(str(counted)+'.sites.json')),'nineFieldsEqual':True}
 r.update(status='CHAIN_VALIDATED_NINE_WORLD_CONSTRUCTION_COUNTS_PASS',totals=totals,difference=totals['candidate']-totals['baseline'],kinds=kinds,kindDelta={k:kinds['candidate'].get(k,0)-kinds['baseline'].get(k,0) for k in sorted(set(kinds['candidate'])|set(kinds['baseline'])) if kinds['candidate'].get(k,0)!=kinds['baseline'].get(k,0)})
except Exception as e:r.update(status='FAILED',error=repr(e));raise
finally:save()
print(json.dumps({'status':r['status'],'totals':r.get('totals'),'difference':r.get('difference')}))
