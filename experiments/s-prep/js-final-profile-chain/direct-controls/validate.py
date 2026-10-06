import importlib.util,pathlib,json,subprocess,hashlib,sys
sys.path.insert(0,"/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates")
r=pathlib.Path('/tmp/bendvy-final-direct-admission');root=pathlib.Path('/workspace/formal-proofs/bendvy');paths=[root/'experiments/s-prep/owned-write-query-integration/controls-run.py',root/'experiments/s-prep/fivehour-connected-gates/suppressed-owner.py'];mods=[]
for i,p in enumerate(paths):
 s=importlib.util.spec_from_file_location('m'+str(i),p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);mods.append(m)
I,S=mods;ps=json.load(open('/tmp/bendvy-direct-payload-tx-original-v2/probe-evidence.json'))['programs'];groups={}
for i,p in enumerate(ps):
 key=('suppressed' if 'suppressed' in p['source'] else 'normal','raw' if '/raw/' in p['source'] else 'cached',p['schema']);groups[key]=[json.loads(x) for x in (r/f'{i}-combined.jsonl').read_text().splitlines() if x.startswith('{')]
def combine(a,b):return [v for scenario in range(9) for rows in [a,b] for v in rows[scenario*8:scenario*8+8]]
normal={g:combine(groups['normal',g,'motion'],groups['normal',g,'health']) for g in ['cached','raw']};suppressed={g:combine(groups['suppressed',g,'motion'],groups['suppressed',g,'health']) for g in ['cached','raw']}
for g in normal:
 I.independent(normal[g]);assert not I.differences(normal[g]);assert suppressed[g]==S.expected_noop(normal[g]);assert suppressed[g]!=normal[g]
assert normal['cached']==normal['raw'];assert suppressed['cached']==suppressed['raw']
for lines in normal.values():
 for block in range(36):assert lines[block*4]['value']==(46 if block//4==0 else 3606 if block//4==8 else 4294967295),(block,lines[block*4])
mutants=[];d=pathlib.Path('/tmp/bendvy-final-direct-inverse-order');mp=json.load(open('/tmp/bendvy-direct-payload-tx-inverse-order/probe-evidence.json'))['programs'];mg={}
for i,p in enumerate(mp):
 v=subprocess.run(['taskset','-c','8','timeout','5s','node',str(d/f'{i}-payload.js')],capture_output=True,text=True,timeout=6);assert v.returncode==0;lines=[json.loads(x) for x in v.stdout.splitlines() if x.startswith('{')];assert len(lines)==72;(d/f'{i}-combined.jsonl').write_text(v.stdout);g='raw' if '/raw/' in p['source'] else 'cached';mg[g,p['schema']]=lines
for g in ['cached','raw']:
 lines=combine(mg[g,'motion'],mg[g,'health']);diff=I.differences(lines);assert diff;mutants.append({'getter':g,'differences':diff})
ev={'cpu':[8],'runtimeLimitSeconds':5,'status':'ACTUAL_DIRECT_COMBINED_INDEPENDENT_AND_MANDATORY_SUPPRESSION_PASS','validatorPins':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},'normalRecords':288,'suppressedRecords':288,'cachedRawEqual':True,'inverseOrderCombinedRuntimeDetected':mutants,'lostMark':'All four unchanged store guards refuse only selected same slot; no combined runtime claim'};(r/'independent-evidence.json').write_text(json.dumps(ev,indent=2)+'\n');print(ev['status'])
