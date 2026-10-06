#!/usr/bin/env python3
"""Fresh exact current packed+paired row→Data token→direct Tuple controller chain."""
import argparse,pathlib,json,hashlib,sys,os,copy
H=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{7});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','cpu':7,'scope':'Fresh exact current-source generated-controller576 full-record equality; no inherited mutation/authority or universal alias proof','commands':[],'cases':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,label):
 code,out=execute(list(map(str,argv)),5);f=a.output/(label+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,argv)),'capSeconds':5,'exit':code,'outputSHA256':sha(f)});save();assert code==0,out[-1000:];return out
try:
 rowcat=json.loads((H/'row-input-pins.json').read_text());tx=[(digest,pin) for digest,pin in rowcat.items() if pin['mode'].startswith('actual-')];assert len(tx)==8
 # Stage1's catalog is frozen before any derived controller is executed.
 stages=[]
 for digest,pin in tx:
  inp=pathlib.Path(pin['inputPath']);assert sha(inp)==digest;label=pin['label'];row=a.output/(label+'-row.js');run(['node','--expose-internals',H/'row-rewrite.cjs',inp,row],label+'-row-derive');stages.append((digest,pin,inp,row))
 token=H/'token-pool';poolcat=json.loads((token/'input-pins.json').read_text());facts=json.loads((token/'source-facts.json').read_text())
 for digest,pin,inp,row in stages:
  tags=['types.'+n for n in (['PositionToken','MotionLedgerToken'] if pin['schema']=='motion' else ['VitalsToken','HealthLedgerToken'])];poolcat[sha(row)]={'schema':pin['schema'],'mode':pin['mode'],'sourceRoot':pin['sourceRoot'],'sourcePins':pin['sourcePins'],'inputPath':str(row),'typesSHA256':facts['typesSHA256'],'tags':tags}
 (token/'input-pins.json').write_text(json.dumps(poolcat,indent=2)+'\n');poolstages=[]
 for digest,pin,inp,row in stages:
  pool=a.output/(pin['label']+'-pool.js');run(['node','--expose-internals',token/'rewrite.cjs',row,pool],pin['label']+'-pool-derive');poolstages.append((digest,pin,inp,row,pool))
 cat=json.loads((H/'input-pins.json').read_text())
 for digest,pin,inp,row,pool in poolstages:
  analysis=a.output/(pin['label']+'-analysis.json');run(['node','--expose-internals',H/'analyze.cjs',pool,analysis],pin['label']+'-analyze');d=json.loads(analysis.read_text());prov=dict(pin['provenancePins']);prov.update({str(p):sha(p) for p in [row,pathlib.Path(str(row)+'.recipe.json'),H/'row-rewrite.cjs',H/'row-input-pins.json',pathlib.Path(str(pool)+'.recipe.json'),token/'rewrite.cjs',token/'input-pins.json',token/'source-facts.json',token/'types-source.bend.gz']});cat[sha(pool)]={'schema':pin['schema'],'mode':pin['mode'],'getter':pin['getter'],'label':pin['label'],'inputPath':str(pool),'sourceRoot':pin['sourceRoot'],'sourcePins':pin['sourcePins'],'provenancePins':prov,'expectedEligible':len(d['eligibleSites']),'expectedReceivers':len({(s['receiver'],s['pairIndex']) for s in d['eligibleSites']})}
 (H/'input-pins.json').write_text(json.dumps(cat,indent=2)+'\n')
 for digest,pin,inp,row,pool in poolstages:
  label=pin['label'];final=a.output/(label+'-tuple.js');run(['node','--expose-internals',H/'rewrite.cjs',pool,final],label+'-tuple-derive');before=run(['node',inp],label+'-before');after=run(['node',final],label+'-after');records=[json.loads(x) for x in before.splitlines()];assert len(records)==72 and before==after;stored=pathlib.Path('/tmp/bendvy-packed-paired-tx-controls-v3')/(label+'-js-run.stdout');assert before==stored.read_text();r['cases'].append({'label':label,'originalSHA256':digest,'rowSHA256':sha(row),'poolSHA256':sha(pool),'finalSHA256':sha(final),'fullRecords':72,'storedActualIndependentBaselineCompared':True});save()
 assert len(r['cases'])==8;r.update(status='FRESH_CURRENT_PACKED_PAIRED_CHAIN_EIGHT_CONTROLLERS_576_RECORDS_EQUAL',records=576,recipes={str(p):sha(p) for p in [H/'row-rewrite.cjs',H/'rewrite.cjs',token/'rewrite.cjs']},catalogs={str(p):sha(p) for p in [H/'row-input-pins.json',H/'input-pins.json',token/'input-pins.json']})
except Exception as e:r.update(status='FAILED',error=repr(e))
save();print(json.dumps({'status':r['status'],'cases':len(r['cases']),'error':r.get('error')}));sys.exit(0 if r['status']=='FRESH_CURRENT_PACKED_PAIRED_CHAIN_EIGHT_CONTROLLERS_576_RECORDS_EQUAL' else 1)
