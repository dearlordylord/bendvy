#!/usr/bin/env python3
"""Fresh final legacy Tx records plus reached direct four-Raw helper witnesses."""
import argparse,hashlib,json,os,subprocess,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--pipeline',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();os.sched_setaffinity(0,{8});a.output.mkdir(exist_ok=False);h=Path(__file__).resolve().parent;config=json.load(open(h/'pipeline-pins.json'));payload=json.load(open(h/'payload/input-pins.json'));bypin={v['label']:v for v in payload.values()};sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest();r={'scope':'Finite final-chain semantics; legacy Tx controllers do not exercise direct-product payload receivers','cpu':[8],'runtimeLimitSeconds':5,'directTxGate':False,'cases':[],'witnesses':[]}
def run(cmd):
 p=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=5);assert p.returncode==0,p.stderr;return p.stdout
for c in config['cases']:
 target=a.pipeline/(c['label']+'.js');assert sha(target)==c['outputSHA256'];pin=bypin[c['label']];record={'label':c['label'],'inputSHA256':c['inputSHA256'],'outputSHA256':sha(target),'actualPayloadVariant':json.load(open(str(target)+'.recipe.json'))['catalog'][0]['variant']};r['cases'].append(record)
 if not c['label'].startswith('baseline'):
  original=Path(pin['originalInputPath']);assert sha(original)==pin['pipelineInputSHA256'];texts=[]
  for role,program in [('original',original),('read-swap',Path(c['input'])),('final',target)]:
   raw=run(['node',program]);assert len([json.loads(x) for x in raw.splitlines()])==72;(a.output/(c['label']+'-'+role+'.jsonl')).write_text(raw);texts.append(raw)
  assert texts[0]==texts[1]==texts[2];record.update(records=72,threeWayFullRecordEqual=True)
 if c['label'].startswith('baseline'):
  out=a.output/('direct-retained-'+c['schema']+'.js');run(['node','--expose-internals',h/'witnesses/held-cache.cjs',target,out,c['schema']]);text=out.read_text();needle='console.log(JSON.stringify({schema,status:';assert text.count(needle)==1;checks='assert.equal(writtenLedger.main.raw.$,tags.raw);assert.equal(writtenLedger.ledger.raw.$,tags.ledgerRaw);assert.equal(writtenLedger.ledger.raw.epoch,4);if(schema==="motion"){assert.equal(writtenLedger.main.raw.frame,7)}else{assert.equal(writtenLedger.main.raw.reserve,9);assert.equal(writtenLedger.main.raw.class,2)};\n';text=text.replace('const owner={$:tags.held','const rawMainOwner=main.raw,rawLedgerOwner=ledger.raw;\nconst owner={$:tags.held');checks+='assert.equal(writtenLedger.main.raw,rawMainOwner);assert.equal(writtenLedger.ledger.raw,rawLedgerOwner);\n';text=text.replace(needle,checks+needle);recipe=json.load(open(str(target)+'.recipe.json'));counts={x['kind']:0 for x in recipe['catalog']}
  for item in recipe['catalog']:
   name=item['derivedReceiver'];start=text.index('function '+name+'(');body=text.index('{',start);text=text[:body+1]+'__raw_calls['+json.dumps(item['kind'])+']++;'+text[body+1:]
  text='const __raw_calls='+json.dumps(counts)+';\n'+text+'\nconsole.log("RAW-CALLS:"+JSON.stringify(__raw_calls));\n';out.write_text(text);raw=run(['node',out]);out.with_suffix('.txt').write_text(raw);lines=raw.splitlines();actual=json.loads(lines[1].split(':',1)[1]);assert all(v>0 for v in actual.values());r['witnesses'].append({'scope':'reached direct four-Type Raw helper witness; not direct Tx acceptance','schema':c['schema'],'observed':json.loads(lines[0]),'actualReachedDerivedReceiverCalls':actual,'programSHA256':sha(out)})
assert sum(x.get('records',0) for x in r['cases'])==576 and len(r['witnesses'])==2;r['status']='TEN_FINAL_INPUTS_LEGACY_TX576_FOUR_DIRECT_RAW_FULL_METADATA_PASS';(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
