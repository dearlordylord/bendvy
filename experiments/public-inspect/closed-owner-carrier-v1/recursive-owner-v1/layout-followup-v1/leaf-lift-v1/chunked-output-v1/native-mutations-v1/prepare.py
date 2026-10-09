from pathlib import Path
import json,hashlib
h=Path(__file__).resolve().parent.parent;o=Path(__file__).resolve().parent
root=Path('/tmp/bendvy-inspect54-chunk-native-mutations01');root.mkdir()
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
index=[]
for name in ['drop','reorder']:
 old=Path('/tmp/bendvy-inspect54-chunk-backend02')/(name+'-js')/'plan.json';p=json.loads(old.read_bytes());jsReceipt=old.parent/'receipt.json';jr=json.loads(jsReceipt.read_bytes());assert jr['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'and jr['wholeBaselineRejected']and jr['wholeOracleSHA256']==p['oracleSHA256']
 out=root/name;out.mkdir();generated=out/'scenario.c';native=out/'scenario.native';p['role']='native';p['scope']='Reached complete '+name+' assembly Native correctness control, copied outlined compiler/O0; no performance/stock/adoption qualification';p['generated']=str(generated);p['native']=str(native)
 t=p['tools'];entry=p['entrypoint'];p['commands']=[{'label':'emit','argv':[t['taskset'],'-c','5',t['node'],str(Path(p['compilerAssets'])/'emit.mts'),entry,str(generated)],'capSeconds':30},{'label':'build','argv':[t['taskset'],'-c','5',t['clangWrapper'],'-O0',str(generated),'-o',str(native),'-pthread','-lm'],'capSeconds':120},{'label':'consumer','argv':[t['taskset'],'-c','5',str(native),'--threads','1','--gpu','off'],'capSeconds':5}]
 prior=Path('/tmp/bendvy-inspect54-chunk-o0-native01/plan.json');priorReceipt=prior.parent/'receipt.json';nr=json.loads(priorReceipt.read_bytes());assert nr['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'and nr['wholeOracleSHA256']=='810259f78227f2b3d158c02644978b6c7ecf58b40a4b2fb398a816005b2867e2'
 extra=[Path(__file__),old,jsReceipt,prior,priorReceipt,*[Path(x['path'])for x in jr['guards']],*[Path(c[k]['path'])for c in jr['commands']for k in ['stdout','stderr']],*[Path(x['path'])for x in nr['guards']],*[Path(c[k]['path'])for c in nr['commands']for k in ['stdout','stderr']]]
 p['pins'].update({str(x):sha(x)for x in extra});p['priorCompleteJS']={'plan':str(old),'planSHA256':sha(old),'receipt':str(jsReceipt),'receiptSHA256':sha(jsReceipt)};p['priorCompleteNormalNative']={'plan':str(prior),'planSHA256':sha(prior),'receipt':str(priorReceipt),'receiptSHA256':sha(priorReceipt)}
 path=out/'plan.json';path.write_text(json.dumps(p,indent=2)+'\n');assert all(sha(k)==v for k,v in p['pins'].items());assert not generated.exists()and not native.exists()and not(out/'receipt.json').exists();index.append({'name':name,'plan':str(path),'sha256':sha(path),'launchArgv':[t['python'],str(h/'development.py'),str(path),sha(path)]})
(o/'PREPARED.json').write_text(json.dumps({'status':'UNADMITTED_UNEXECUTED','plans':index},indent=2)+'\n');print([(r['name'],r['sha256'])for r in index])
