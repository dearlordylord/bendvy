#!/usr/bin/env python3
"""Read-only frontier and unchanged guard refusal, not optimized-candidate validation."""
import argparse,pathlib,json,hashlib,shutil,os,sys
H=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',required=True,type=pathlib.Path);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{7});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();expected=json.loads((H/'pins.json').read_text());r={'status':'INCOMPLETE','cpu':7,'commands':[],'schemas':[],'scope':'Exact graph and structural old-guard rejection only; no candidate implementation or approved new enrollment'}
for file,digest in expected['files'].items():assert sha(pathlib.Path(file))==digest,('changed input',file)
for file,digest in expected['ownedRecipes'].items():assert sha(H/file)==digest,('changed recipe',file)
old=pathlib.Path(expected['oldCatalog']);catalog=json.loads(old.read_text());newcat={}
def run(argv,label,wanted=0):
 code,text=execute(list(map(str,argv)),5);log=a.output/(label+'.txt');log.write_text(text);r['commands'].append({'argv':list(map(str,argv)),'capSeconds':5,'exit':code,'outputSHA256':sha(log)});assert code==wanted,text[-800:];return text
try:
 for schema in ['motion','health']:
  pin=expected['schemas'][schema];build=json.loads(pathlib.Path(pin['build']).read_text());assert build['status']=='BUILD_PASS' and len(build['sourcePins'])==29 and build['sourceClosure']==expected['sourceClosure'];source=pathlib.Path(build['sourceRoot'])
  for file,digest in build['sourcePins'].items():assert sha(source/file)==digest
  inp=pathlib.Path(pin['input']);assert sha(inp)==pin['inputSHA256'];parent=json.loads(pathlib.Path(str(inp)+'.recipe.json').read_text());assert parent['outputSHA256']==sha(inp) and parent['sourcePins']==build['sourcePins']
  graph=a.output/(schema+'-graph.json');run(['node','--expose-internals',H/'analyze.cjs',inp,schema,old,graph],schema+'-analyze');g=json.loads(graph.read_text());base=next(v for v in catalog.values() if v['schema']==schema)
  # Pin fresh actual bodies for a structural compatibility trial. This catalog is NOT accepted provenance enrollment.
  functions={f['name']:f for f in g['functions']};mapping={n:next(f['name'] for f in g['oldFamilyFrontier'] if f['name'].endswith(n[n.index('$058'):])) for n in base['family']}
  # Obtain exact old-family/confinement bodies through the read-only parser in a bounded command.
  prepare=a.output/(schema+'-catalog.json');run(['node','--expose-internals',H/'catalog.cjs',inp,schema,old,source,prepare],schema+'-catalog');newcat.update(json.loads(prepare.read_text()));r['schemas'].append({'schema':schema,'inputSHA256':sha(inp),'graphSHA256':sha(graph),'graphPath':str(graph),'sourcePins':build['sourcePins'],'sourceRoot':str(source),'offendingOldFunctions':len(g['offendingOldFrontier'])})
 for name in ['rewrite.cjs','transport.cjs']:shutil.copy2(H/name,a.output/name)
 (a.output/'input-pins.json').write_text(json.dumps(newcat,indent=2)+'\n')
 for schema in ['motion','health']:
  output=a.output/(schema+'-refused.js');msg=run(['node','--expose-internals',a.output/'rewrite.cjs',expected['schemas'][schema]['input'],output],schema+'-refusal',1);assert 'Error: unknown incoming edge' in msg and not output.exists() and not pathlib.Path(str(output)+'.recipe.json').exists()
 r.update(status='BOTH_SCHEMAS_UNCHANGED_SELECTIVE_GUARD_REFUSED_NO_CANDIDATE',sourceClosure=expected['sourceClosure'],noCandidateImplemented=True,noPriorGatesTransferred=True,recipePins=expected['ownedRecipes'])
except Exception as e:r.update(status='FAILED',error=repr(e))
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'status':r['status'],'error':r.get('error')}));sys.exit(0 if r['status']=='BOTH_SCHEMAS_UNCHANGED_SELECTIVE_GUARD_REFUSED_NO_CANDIDATE' else 1)
