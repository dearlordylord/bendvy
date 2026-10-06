#!/usr/bin/env python3
import pathlib,json,hashlib,sys,os,argparse,importlib.util
H=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{7});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','cpu':7,'cases':[]}
try:
 spec=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
 for schema in ['motion','health']:
  source=pathlib.Path('/tmp/bendvy-descending-generated-frozen-v1/'+schema+'-tuple.js');s=source.read_text();receipt=json.load(open('/tmp/bendvy-unused-row-'+schema+'.js.recipe.json'));assert receipt['inputSHA256']==sha(source);sites=receipt['removed'];edits=[]
  for i,site in enumerate(sites):
   start=s.index('function '+site['helper']+'(');end=s.index('\nfunction ',start+1);body=s[start:end];needle='const '+site['binding']+' = _owner_0['+json.dumps(site['field'])+'];';assert body.count(needle)==1;index=s.index(needle,start,end);replacement='const '+site['binding']+' = (__read_active && __read_counts['+str(i)+']++, _owner_0['+json.dumps(site['field'])+']);';edits.append((index,index+len(needle),replacement))
  for start,end,replacement in sorted(edits,reverse=True):s=s[:start]+replacement+s[end:]
  entry='return $'+schema+'_batch$(256, 64);';assert s.count(entry)==1;s=s.replace(entry,entry.replace('64','8'));start=s.index('function $'+schema+'_timed$(');end=s.index('\nfunction ',start+1);body=s[start:end];assert body.count('$IO$now$(_x_1)')==1 and body.count('$IO$now$(_x_6)')==1;body=body.replace('$IO$now$(_x_1)','(__read_active=true, $IO$now$(_x_1))').replace('$IO$now$(_x_6)','(__read_active=false, console.error("UNUSED-READ-COUNTS:"+JSON.stringify(Array.from(__read_counts))), $IO$now$(_x_6))');s='let __read_active=false;const __read_counts=new Float64Array('+str(len(sites))+');\n'+s[:start]+body+s[end:];out=a.output/(schema+'.js');out.write_text(s);code,raw=execute(['node',str(out)],5);(a.output/(schema+'.txt')).write_text(raw);assert code==0,raw[-1000:];counts=json.loads(next(x.split(':',1)[1] for x in raw.splitlines() if x.startswith('UNUSED-READ-COUNTS:')));assert len(counts)==len(sites) and set(counts)=={131072};ts=json.load(open('/tmp/bendvy-unused-row-controls/'+schema.title()+'-ts.txt'));records=[x for x in raw.splitlines() if x.startswith('{')];assert len(records)==9
  for line,world in zip(records,[ts['warmup'],*ts['samples']]):v.validate(line,schema.title(),False,256,world);assert v.normalized(json.loads(line),schema.title())==world['final']
  r['cases'].append({'schema':schema,'originalSHA256':sha(source),'instrumentedSHA256':sha(out),'freshFullWorlds':9,'countedReadExecutions':sum(counts),'perSiteExecutions':counts,'capSeconds':5})
 r['status']='ACTUAL_UNUSED_READ_EXECUTIONS_NINE_FIELDS_PASS_BOTH_SCHEMAS'
except Exception as e:r.update(status='FAILED',error=repr(e))
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r));sys.exit(0 if r['status'].endswith('SCHEMAS') else 1)
