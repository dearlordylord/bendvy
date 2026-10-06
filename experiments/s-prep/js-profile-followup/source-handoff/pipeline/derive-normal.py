#!/usr/bin/env python3
"""Freeze exact normal+actual-controller intermediate catalogs without guard changes."""
import pathlib,json,hashlib,sys,os,argparse
H=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--source-root',type=pathlib.Path,required=True);p.add_argument('--cpu',type=int,default=7);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{a.cpu});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','cpu':a.cpu,'scope':'Exact frozen derivation and own-byte-equality bindings; no source/compiler/Native/gate transfer','commands':[],'programs':[]};save=lambda:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,label):
 code,out=execute(list(map(str,argv)),5);f=a.output/(label+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,argv)),'capSeconds':5,'exit':code,'outputSHA256':sha(f)});save();assert code==0,out[-1000:];return out
try:
 rowcat=json.loads((H/'row-input-pins.json').read_text());assert len(rowcat)==2;stages=[]
 for digest,pin in rowcat.items():
  label=pin.get('label',pin['schema']);inp=pathlib.Path(pin['inputPath']);assert sha(inp)==digest;row=a.output/(label+'-row.js');run(['node','--expose-internals',H/'row-rewrite.cjs',inp,row],label+'-row-derive');stages.append((digest,pin,label,inp,row))
 token=H/'token-pool';facts=json.loads((token/'source-facts.json').read_text());poolcat={}
 for digest,pin,label,inp,row in stages:
  qualified=not pin['mode'].startswith('actual-');prefix='../'+a.source_root.name+'/experiments/s-integrate/' if qualified else '';names=['PositionToken','MotionLedgerToken'] if pin['schema']=='motion' else ['VitalsToken','HealthLedgerToken'];poolcat[sha(row)]={'schema':pin['schema'],'mode':pin['mode'],'sourceRoot':pin['sourceRoot'],'sourcePins':pin['sourcePins'],'inputPath':str(row),'typesSHA256':facts['typesSHA256'],'tags':[prefix+'types.'+n for n in names]}
 (token/'input-pins.json').write_text(json.dumps(poolcat,indent=2)+'\n');pooled=[]
 for digest,pin,label,inp,row in stages:
  pool=a.output/(label+'-pool.js');run(['node','--expose-internals',token/'rewrite.cjs',row,pool],label+'-pool-derive');pooled.append((digest,pin,label,inp,row,pool))
 cat={}
 for digest,pin,label,inp,row,pool in pooled:
  analysis=a.output/(label+'-analysis.json');run(['node','--expose-internals',H/'analyze.cjs',pool,analysis],label+'-analysis');d=json.loads(analysis.read_text());prov=dict(pin['provenancePins']);prov.update({str(p):sha(p) for p in [row,pathlib.Path(str(row)+'.recipe.json'),H/'row-rewrite.cjs',H/'row-input-pins.json',pathlib.Path(str(pool)+'.recipe.json'),token/'rewrite.cjs',token/'input-pins.json',token/'source-facts.json',token/'types-source.bend.gz']});cat[sha(pool)]={'schema':pin['schema'],'mode':pin['mode'],'label':label,'inputPath':str(pool),'sourceRoot':pin['sourceRoot'],'sourcePins':pin['sourcePins'],'provenancePins':prov,'expectedEligible':len(d['eligibleSites']),'expectedReceivers':len({(s['receiver'],s['pairIndex']) for s in d['eligibleSites']})}
 (H/'input-pins.json').write_text(json.dumps(cat,indent=2)+'\n')
 for digest,pin,label,inp,row,pool in pooled:
  final=a.output/(label+'-tuple.js');run(['node','--expose-internals',H/'rewrite.cjs',pool,final],label+'-tuple-derive')
  assert not pin['mode'].startswith('actual-'),'normal-only runner refuses fixture admission'
  assert len(json.loads(pathlib.Path(str(final)+'.recipe.json').read_text())['sourcePins'])==29
  r['programs'].append({'label':label,'sourceSHA256':digest,'rowSHA256':sha(row),'poolSHA256':sha(pool),'finalSHA256':sha(final),'finalPath':str(final),'freshControllerRecords':72 if pin['mode'].startswith('actual-') else None,'normalFull65AndNineWorldValidationPending':not pin['mode'].startswith('actual-')});save()
 r.update(status='FROZEN_TWO_EXACT_HANDOFF_CHAIN_PROGRAMS_PASS',recipes={str(p):sha(p) for p in [H/'row-rewrite.cjs',H/'rewrite.cjs',H/'analyze.cjs',token/'rewrite.cjs']},catalogs={str(p):sha(p) for p in [H/'row-input-pins.json',H/'input-pins.json',token/'input-pins.json']},actualControllerRecords=0)
except Exception as e:r.update(status='FAILED',error=repr(e))
save();print(json.dumps({'status':r['status'],'programs':len(r['programs']),'error':r.get('error')}));sys.exit(0 if r['status']=='FROZEN_TWO_EXACT_HANDOFF_CHAIN_PROGRAMS_PASS' else 1)
