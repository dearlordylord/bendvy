#!/usr/bin/env python3
"""Fresh finite query controls on exact root fold+noAux join; no Tx transfer."""
import argparse,pathlib,hashlib,json,subprocess,shutil
HERE=pathlib.Path(__file__).resolve().parent;SOURCE=HERE.parent
EXPECTED='49614f72311af5b03123d536ff301115d28b8886bf516b0d7057a8c52e68ad38'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False)
pins={str(p.relative_to(a.overlay)):sha(p) for p in a.overlay.rglob('*.bend')};digest=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();manifest=json.loads((a.overlay/'overlay.json').read_text());cache=json.loads((a.overlay/'cache-specialization.json').read_text());assert len(pins)==29 and digest==EXPECTED and pins==manifest['sources']==cache['runtimeClosure']==cache['specializedClosure'] and cache==manifest['cacheSpecialization']
r={'status':'INCOMPLETE','scope':'Fresh noAux query/general getter/authority/provider/factory controls only; fold direct Tx requires separate recognizer and is not claimed','sourcePins':pins,'sourceClosureSHA256':digest,'commands':[],'recipePins':{n:sha(SOURCE/n) for n in ['getter-noaux-run.py','getter-control-noaux.bend','getter-noaux-expected.txt','owner-threading-cont-run.py','getter-control-cont.bend','authority-cont-run.py','provider-run.py','protected-run.py','frozen-authority/run.py']},'proofAcceptance':False,'performanceAcceptance':False,'directTxAcceptance':False}
def run(label,args):
 item={'label':label,'argv':list(map(str,args))};r['commands'].append(item)
 (a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');v=subprocess.run(list(map(str,args)),capture_output=True,text=True);item.update(exit=v.returncode,out=v.stdout,err=v.stderr);(a.output/(label+'.log')).write_text(v.stdout+v.stderr);(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');assert v.returncode==0,item
stage=a.output/'query-source'
try:
 run('version',['bend','version']);run('guide',['bend','guide'])
 for backend in ['JS','Native']:shutil.copytree(a.overlay,stage/backend)
 run('selection',['env','BENDVY_CHECKER_SECONDS=15','python3',SOURCE/'getter-noaux-run.py','--candidate-root',stage,'--output',a.output/'selection.json'])
 run('general-getters',['python3',SOURCE/'owner-threading-cont-run.py','--overlay',a.overlay,'--output',a.output/'general-getters'])
 run('private-authority',['python3',SOURCE/'authority-cont-run.py','--overlay',a.overlay,'--output',a.output/'private-authority'])
 run('public-authority',['python3',SOURCE/'frozen-authority/run.py','--overlay',a.overlay,'--output',a.output/'public-authority.json'])
 run('provider',['python3',SOURCE/'provider-run.py','--overlay',a.overlay,'--output',a.output/'provider.json'])
 run('factory',['python3',SOURCE/'protected-run.py','--kind','factory','--overlay',a.overlay,'--output',a.output/'factory'])
 r['status']='FRESH_JOIN_FINITE_QUERY_GETTER_AUTHORITY_PROVIDER_FACTORY_PASS_NO_TX_TRANSFER'
except Exception as e:r.update(status='FAILED_PRESERVED_SUBJECT',error=repr(e));raise
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
