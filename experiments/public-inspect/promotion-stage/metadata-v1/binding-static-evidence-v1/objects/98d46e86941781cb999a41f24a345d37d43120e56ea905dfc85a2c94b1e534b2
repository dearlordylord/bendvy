"""Freeze guarded static controls; collection is not diagnostic acceptance."""
from pathlib import Path
import argparse,contextlib,hashlib,io,json,types
HERE=Path(__file__).resolve().parent
S=types.ModuleType('static_control');S.__file__=str(HERE/'binding-static-control-positive.py')
exec((HERE/'binding-static-control-positive.py').read_text().rsplit('p=argparse.ArgumentParser();',1)[0],S.__dict__)
B=S.B
GROUPS={'one':['wrong-descriptor','cross-schema','undeclared'],'two':['write-authority','duplicate-owner','escape-owner']}
REASONS={'wrong-descriptor':'same schema and grant shape, differently named closed descriptor State index','cross-schema':'Workshop State returned as Garden nominal State','undeclared':'fixed actual Reads returned as ExtraReads with fourth undeclared grant','write-authority':'actual read capability returned as ValueWrite','duplicate-owner':'same affine indexed State used twice','escape-owner':'indexed affine State returned as String'}
def prepare(native,group):
 receipt=B.ROOT/'.artifacts/inspect54-metadata-source-1791420042922977582/receipt.json';r=json.loads(receipt.read_text());pp=receipt.parent/'plan.json';prior=json.loads(pp.read_text());assert r['planSHA256']==B.sha(pp);assert r['commands']==[{'label':'binding-static-matched-positive-source','exit':0,'failure':None}]
 index=Path(prior['sourceArchive']);assert B.sha(index)==prior['sourceArchiveSHA256'];old=json.loads(index.read_text());qualified=set();B.closure(HERE/'binding-static-controls/positive.bend',qualified)
 for f in qualified:assert B.sha(f)==old[str(f)]['sha256'];assert B.sha(old[str(f)]['object'])==old[str(f)]['sha256']
 for name,digest in r['logs'].items():assert B.sha(receipt.parent/name)==digest
 capture=io.StringIO()
 with contextlib.redirect_stdout(capture):S.prepare(native)
 path=Path(capture.getvalue().splitlines()[0]);p=json.loads(path.read_text());out=path.parent;files=set(map(Path,p['files']));files.update([receipt,pp,index,*[receipt.parent/name for name in r['logs']],*[Path(old[str(f)]['object']) for f in qualified],Path(__file__).resolve()]);sources=set()
 targets=[HERE/'binding-static-controls'/(name+'.bend') for name in GROUPS[group]]
 for target in targets:B.closure(target,sources)
 files.update(sources);records=json.loads(Path(p['sourceArchive']).read_text())
 for f in sources|{Path(__file__).resolve()}:
  digest=B.sha(f);obj=out/'frozen-source'/digest;obj.write_bytes(f.read_bytes());records[str(f)]={'sha256':digest,'object':str(obj)}
 newindex=Path(p['sourceArchive']);newindex.write_text(json.dumps(records,indent=2)+'\n')
 p.update(kind='negatives',status='PREPARED_UNADMITTED_STATIC_NEGATIVE_DIAGNOSTICS',commands=[{'label':t.stem,'argv':['/usr/bin/taskset','-c','5','/home/node/.bend/bin/bend',str(t),'--check-only'],'seconds':5,'intended':REASONS[t.stem]} for t in targets],sourceArchiveSHA256=B.sha(newindex),matchedPositive={'plan':str(pp),'planSHA256':B.sha(pp),'receipt':str(receipt),'receiptSHA256':B.sha(receipt),'sourceArchive':str(index),'sourceArchiveSHA256':B.sha(index),'qualifiedClosure':{str(f):old[str(f)]['sha256'] for f in sorted(qualified)}},scope='Three static source refusals diagnostic collection only. Raw status UNCLASSIFIED; actual single-location independent review required. No generic exit1 acceptance/proof/runtime/trusted canonical truth.')
 p['files']=sorted(map(str,files));p['inputs']=B.task_runner.Inputs(files=files,directories=map(Path,p['directories'])).expected;path.write_text(json.dumps(p,indent=2)+'\n');print(path);print(B.sha(path))
def run(path):
 # Keep raw collection separate from reviewer classification.
 source=(HERE.parent/'control-development.py').read_text().split('p=argparse.ArgumentParser();')[0]
 source=source.replace("if p['kind']=='negatives':assert result['exit']!=0,'negative unexpectedly compiled'","if p['kind']=='negatives':\n    receipt['commands'][-1]['classification']='UNCLASSIFIED'\n    assert result['exit']==1 and result['failure'] is None,'unexpected refusal outcome'")
 exec(source,B.__dict__);B.run(path)
p=argparse.ArgumentParser();p.add_argument('--prepare',choices=GROUPS);p.add_argument('--native');p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare(a.native,a.prepare)
else:run(a.run)
