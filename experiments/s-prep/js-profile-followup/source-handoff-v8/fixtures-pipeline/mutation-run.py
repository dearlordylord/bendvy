#!/usr/bin/env python3
import pathlib,json,hashlib,sys,os,argparse
H=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--pipeline',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{7});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','CPU':7,'scope':'Fresh executed derived-receiver cached-field and true-old omission negatives only','cases':[],'commands':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,label):
 code,text=execute(list(map(str,argv)),5);f=a.output/(label+'.txt');f.write_text(text);r['commands'].append({'argv':list(map(str,argv)),'exit':code,'capSeconds':5,'outputSHA256':sha(f)});save();return code,text
try:
 cat=json.loads((H/'row-input-pins.json').read_text());programs=json.loads((a.pipeline/'evidence.json').read_text())['programs']
 for schema in ['motion','health']:
  for kind in ['cached-main','cached-ledger','trueold-main']:
   label=('one-raw-' if kind=='trueold-main' else 'one-')+schema;rec=next(x for x in programs if x['label']==label);pin=cat[rec['sourceSHA256']];source=pathlib.Path(rec['finalPath']);assert sha(source)==rec['finalSHA256'];out=a.output/(schema+'-'+kind+'.js');code,text=run(['node','--expose-internals',H/'mutate.cjs',source,out,schema,kind],schema+'-'+kind+'-derive');assert code==0,text;code,text=run(['node',out],schema+'-'+kind+'-run');lines=text.splitlines();markers=[x for x in lines if x.startswith('BENDVY_MUTATION_HITS ')];assert len(markers)==1;hits=int(markers[0].split(' ',1)[1]);assert hits>0;observed='\n'.join(x for x in lines if not x.startswith('BENDVY_MUTATION_HITS '))+'\n';assert code!=0 or observed!=pathlib.Path(pin['storedOutput']).read_text(),'live mutation survived'
   r['cases'].append({'schema':schema,'kind':kind,'sourceSHA256':sha(source),'mutantSHA256':sha(out),'liveHits':hits,'killed':True,'anchor':json.loads(pathlib.Path(str(out)+'.anchor.json').read_text())});save()
 r.update(status='SIX_FRESH_LIVE_DERIVED_RECEIVER_MUTANTS_KILLED',recipeSHA256=sha(H/'mutate.cjs'))
except Exception as e:r.update(status='FAILED',error=repr(e))
save();print(json.dumps({'status':r['status'],'cases':len(r['cases']),'error':r.get('error')}));sys.exit(0 if r['status']=='SIX_FRESH_LIVE_DERIVED_RECEIVER_MUTANTS_KILLED' else 1)
