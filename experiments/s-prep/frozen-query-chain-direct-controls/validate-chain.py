#!/usr/bin/env python3
"""Fresh frozen-source direct Tx chain; exact observations and protected oracles."""
import argparse,pathlib,json,subprocess,hashlib,importlib.util,sys,os
p=argparse.ArgumentParser();p.add_argument('--manifest',type=pathlib.Path,required=True);p.add_argument('--chain',type=pathlib.Path,required=True);p.add_argument('--mark-last',action='store_true');a=p.parse_args();os.sched_setaffinity(0,{8});root=pathlib.Path('/workspace/formal-proofs/bendvy');base=root/'experiments/s-prep/fivehour-connected-gates';sys.path.insert(0,str(base));ps=json.load(open(a.manifest))['programs'];sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest();counter=root/'experiments/s-prep/direct-payload-tx-controls/counter.cjs';e={'status':'INCOMPLETE','cpu':[8],'runtimeLimitSeconds':5,'fixtureManifestSHA256':sha(a.manifest),'cases':[]};groups={}
def command(args):
 v=subprocess.run(list(map(str,args)),capture_output=True,text=True,timeout=5);assert v.returncode==0,v.stderr;return v.stdout
for i,c in enumerate(ps):
 out=a.chain/f'{i}-payload.js';rows=[]
 for label,path in [('original',c['originalJS']),('standalone',c['derivedJS']),('chain',out)]:
  raw=command(['node',path]);lines=[json.loads(x) for x in raw.splitlines() if x.startswith('{')];assert len(lines)==72;rows.append(lines);(a.chain/f'{i}-{label}.jsonl').write_text(raw)
 assert rows[0]==rows[1]==rows[2],i;counted=a.chain/f'{i}-reached-counted-mark-last.js' if a.mark_last else a.chain/f'{i}-reached-counted.js';command(['node','--expose-internals',counter,out,counted]);raw=command(['node',counted]);markers=[x for x in raw.splitlines() if x.startswith('DIRECT-RAW-CALLS:')];assert len(markers)==1;counts=json.loads(markers[0].split(':',1)[1]);assert len(counts)==2 and all(n>0 for n in counts.values());assert [json.loads(x) for x in raw.splitlines() if x.startswith('{')]==rows[2];key=('suppressed' if 'suppressed' in c['source'] else 'normal','raw' if '/raw/' in c['source'] else 'cached',c['schema']);groups[key]=rows[2];e['cases'].append({'case':i,'schema':c['schema'],'source':c['source'],'sourceSHA256':sha(c['source']),'chainSHA256':sha(out),'records':72,'threeWaySameSourceFullRecordsEqual':True,'derivedReceiverCalls':counts})
mods=[];paths=[root/'experiments/s-prep/owned-write-query-integration/controls-run.py',base/'suppressed-owner.py']
for i,path in enumerate(paths):
 s=importlib.util.spec_from_file_location('v'+str(i),path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);mods.append(m)
I,S=mods
def combine(a,b):return [v for scenario in range(9) for rows in [a,b] for v in rows[scenario*8:scenario*8+8]]
normal={g:combine(groups['normal',g,'motion'],groups['normal',g,'health']) for g in ['cached','raw']};suppressed={g:combine(groups['suppressed',g,'motion'],groups['suppressed',g,'health']) for g in ['cached','raw']}
for g in normal:
 I.independent(normal[g]);assert not I.differences(normal[g]);assert suppressed[g]==S.expected_noop(normal[g]);assert suppressed[g]!=normal[g]
 for block in range(36):assert normal[g][block*4]['value']==(46 if block//4==0 else 3606 if block//4==8 else 4294967295)
assert normal['cached']==normal['raw'];assert suppressed['cached']==suppressed['raw'];e.update(status=('MARK_LAST_FROZEN_SOURCE_DIRECT_TX576_AND_SUPPRESSION_PASS' if a.mark_last else 'FRESH_FROZEN_SOURCE_EIGHT_STAGE_DIRECT_TX576_AND_SUPPRESSION_PASS'),normalRecords=288,suppressedRecords=288,oraclePins={str(path):sha(path) for path in paths+[base/'provider_controls.py',counter]},mutationsExecuted=0,markStageIncluded=a.mark_last,performanceAcceptance=False);(a.chain/'combined-evidence.json').write_text(json.dumps(e,indent=2)+'\n');print(e['status'])
