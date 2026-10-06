#!/usr/bin/env python3
import argparse,hashlib,json,pathlib,os,signal,subprocess,time,re
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{10});HERE=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');catalog=json.loads((HERE/'input-pins.json').read_text());sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest();r={'status':'INCOMPLETE','cpu':10,'runtimeLimitSeconds':5,'cases':[],'witnesses':[],'commands':[],'directTxGate':False}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv):
 child=subprocess.Popen(list(map(str,argv)),stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True);start=time.monotonic();timed=False
 try:out=child.communicate(timeout=5)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(child.pid,signal.SIGKILL);out=child.communicate()[0]
 receipt={'argv':list(map(str,argv)),'limitSeconds':5,'exit':child.returncode,'timeout':timed,'seconds':time.monotonic()-start,'output':out};r['commands'].append(receipt);save();assert child.returncode==0,receipt;return out
try:
 for digest,pin in catalog.items():
  source=pathlib.Path(pin['inputPath']);assert sha(source)==digest;target=a.output/(pin['label']+'.js');run(['node','--expose-internals',HERE/'rewrite.cjs',source,target]);record={'label':pin['label'],'inputSHA256':digest,'outputSHA256':sha(target),'recipeSHA256':sha(str(target)+'.recipe.json')};r['cases'].append(record);save()
  if pin['label'] not in ['baseline','baseline-health']:
   original=pathlib.Path(pin['originalInputPath']);assert sha(original)==pin['pipelineInputSHA256'];outputs=[]
   for role,program in [('original',original),('store-elided',source),('raw-reused',target)]:
    raw=run(['node',program]);records=[json.loads(x) for x in raw.splitlines()];assert len(records)==72;(a.output/(pin['label']+'-'+role+'.jsonl')).write_text(raw);outputs.append(raw)
   assert outputs[0]==outputs[1]==outputs[2];record.update(records=72,threeWayFullRecordsEqual=True,actualVariant='legacy *_swapped, original array_rmw retained');save()
  if pin['label'] in ['baseline','baseline-health']:
   out=a.output/('direct-retained-'+pin['schema']+'.js');run(['node','--expose-internals',ROOT/'experiments/s-prep/js-owner-store-elision/witnesses/held-cache.cjs',target,out,pin['schema']]);text=out.read_text()
   # Existing witness emitter uses replacement-string semantics; restore exact absolute emitted identifiers.
   for name in re.findall(r'^function ([$\w]+)\(',target.read_text(),re.M):
    damaged=name.replace('$$','$');
    if damaged!=name:text=re.sub(r'(?<![$\w])'+re.escape(damaged)+r'(?![$\w])',lambda _:name,text)
   # Strengthen full raw metadata assertions; original frozen Data and journal checks remain.
   needle='console.log(JSON.stringify({schema,status:';assert text.count(needle)==1
   checks='assert.equal(writtenLedger.main.raw.$,tags.raw);assert.equal(writtenLedger.ledger.raw.$,tags.ledgerRaw);assert.equal(writtenLedger.ledger.raw.epoch,4);if(schema==="motion"){assert.equal(writtenLedger.main.raw.frame,7)}else{assert.equal(writtenLedger.main.raw.reserve,9);assert.equal(writtenLedger.main.raw.class,2)};\n'
   text=text.replace(needle,checks+needle);recipe=json.loads(pathlib.Path(str(target)+'.recipe.json').read_text());counts={x['kind']:0 for x in recipe['catalog']}
   for item in recipe['catalog']:
    function=item['derivedReceiver'];start=text.index('function '+function+'(');body=text.index('{',start);text=text[:body+1]+'__raw_calls['+json.dumps(item['kind'])+']++;'+text[body+1:]
   text='const __raw_calls='+json.dumps(counts)+';\n'+text+'\nconsole.log("RAW-CALLS:"+JSON.stringify(__raw_calls));\n';out.write_text(text);raw=run(['node',out]);(out.with_suffix('.txt')).write_text(raw);lines=raw.splitlines();observed=json.loads(lines[0]);actual=json.loads(lines[1].split(':',1)[1]);assert all(x>0 for x in actual.values());r['witnesses'].append({'schema':pin['schema'],'programSHA256':sha(out),'observed':observed,'actualReachedDerivedReceiverCalls':actual,'variant':'actual direct-product edge'});save()
 assert sum(x.get('records',0) for x in r['cases'])==576;assert len(r['witnesses'])==2
 r['status']='TEN_REWRITES_LEGACY_TX576_FOUR_DIRECT_RAW_RETAINED_VIEWS_PASS';save()
except Exception as error:r.update(status='FAILED',error=repr(error));save();raise
print(r['status'])
