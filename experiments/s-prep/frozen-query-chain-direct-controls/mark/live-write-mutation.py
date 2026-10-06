#!/usr/bin/env python3
"""Finite generated-JS mutation at the new reached scalar-loop write only."""
import argparse,pathlib,json,subprocess,hashlib,importlib.util,sys,copy,os
p=argparse.ArgumentParser();p.add_argument('--marked',type=pathlib.Path,required=True);p.add_argument('--manifest',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();os.sched_setaffinity(0,{8});a.output.mkdir(exist_ok=False);root=pathlib.Path('/workspace/formal-proofs/bendvy');base=root/'experiments/s-prep/fivehour-connected-gates';sys.path.insert(0,str(base));manifest=json.load(open(a.manifest));ps=manifest['programs'];sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest();anchor='if (__mark_scalar_current) { __mark_scalar_changed_arg[__mark_scalar_index_arg % __mark_scalar_changed_arg.length] = __mark_scalar_tick_arg; }';e={'cpu':[8],'runtimeLimitSeconds':5,'scope':'Generated-JS finite mutation at reached new scalar loop, not source/full22/proof acceptance','cases':[]};groups={};baseline={}
for name,digest in manifest['sharedSourcePins'].items():assert sha(name)==digest,'protected shared source '+name
admission=json.load(open(a.marked/'admission.json'));assert len(admission)==8 and all(c['accepted'] for c in admission)
def run(args):
 v=subprocess.run(list(map(str,args)),capture_output=True,text=True,timeout=5);assert v.returncode==0,v.stderr;return v
for i,c in enumerate(ps):
 inp=a.marked/f'{i}-payload.js';assert sha(inp)==admission[i]['outputSHA256'];core=pathlib.Path(c['source']).parent
 for name,digest in c['source29Pins'].items():assert sha(core/name)==digest
 for name,digest in c['fixtureExtraPins'].items():assert sha(core/name)==digest
 s=inp.read_text();assert s.count(anchor)==1 and 'function $transaction$058prototype_storage_mark_loop$__mark_scalar_loop(' in s
 mutant=a.output/f'{i}-omit-live-write.js';mutant.write_text(s.replace(anchor,'if (__mark_scalar_current) { void (__mark_scalar_index_arg % __mark_scalar_changed_arg.length); void (__mark_scalar_tick_arg); }'));run(['node','--check',mutant]);v=run(['node',mutant]);mutated=[json.loads(x) for x in v.stdout.splitlines() if x.startswith('{')];original=[json.loads(x) for x in (a.marked/f'{i}-chain.jsonl').read_text().splitlines() if x.startswith('{')];assert len(mutated)==len(original)==72;assert mutated!=original
 def strip(rows):
  rows=copy.deepcopy(rows)
  for row in rows:
   for entity in row['world']['rows']:entity.pop('changed')
  return rows
 assert strip(mutated)==strip(original),'mutation changed fields other than changed stamp';(a.output/f'{i}-mutant.jsonl').write_text(v.stdout)
 counter=a.output/f'{i}-positive-live-write.js';counter.write_text('globalThis.__live_write_calls=0;process.on("exit",()=>process.stderr.write(String(globalThis.__live_write_calls)));\n'+s.replace(anchor,anchor.replace('{ ','{ globalThis.__live_write_calls++; ')));v=run(['node',counter]);assert [json.loads(x) for x in v.stdout.splitlines() if x.startswith('{')]==original;calls=int(v.stderr);assert calls>0
 key=('suppressed' if 'suppressed' in c['source'] else 'normal','raw' if '/raw/' in c['source'] else 'cached',c['schema']);groups[key]=mutated;baseline[key]=original;e['cases'].append({'case':i,'schema':c['schema'],'markedInputSHA256':sha(inp),'mutantSHA256':sha(mutant),'positiveWriteInstrumentSHA256':sha(counter),'liveWriteCalls':calls,'records':72,'compiledJS':True,'onlyChangedStampFieldsDiffer':True})
mods=[];paths=[root/'experiments/s-prep/owned-write-query-integration/controls-run.py',base/'suppressed-owner.py']
for i,path in enumerate(paths):
 s=importlib.util.spec_from_file_location('m'+str(i),path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);mods.append(m)
I,S=mods
combine=lambda a,b:[v for scenario in range(9) for rows in [a,b] for v in rows[scenario*8:scenario*8+8]]
for g in ['cached','raw']:
 normals=combine(groups['normal',g,'motion'],groups['normal',g,'health']);normalBase=combine(baseline['normal',g,'motion'],baseline['normal',g,'health']);suppressed=combine(groups['suppressed',g,'motion'],groups['suppressed',g,'health']);detected=False
 try:I.independent(normals)
 except AssertionError:detected=True
 assert detected,'unchanged independent Tx oracle did not detect normal live-write omission';assert suppressed!=S.expected_noop(normalBase),'unchanged mandatory suppression oracle did not detect live-write omission'
e.update(status='REACHED_SCALAR_LIVE_WRITE_OMISSION_COMPILES_AND_PROTECTED_ORACLES_DETECT',mutantPrograms=8,normalMutantRecords=288,suppressedMutantRecords=288,sourceMutationsExecuted=0,oraclePins={str(p):sha(p) for p in paths},performanceAcceptance=False);(a.output/'evidence.json').write_text(json.dumps(e,indent=2)+'\n');print(e['status'])
