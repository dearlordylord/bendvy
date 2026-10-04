#!/usr/bin/env python3
"""Fresh full-reference gates for the aligned adapter; no ratio sampling."""
import collections,hashlib,importlib.util,json,os,pathlib,sys,tempfile
HERE=pathlib.Path(__file__).resolve().parent
OLD=HERE.parent/'s-integrate'
spec=importlib.util.spec_from_file_location('existing_readers',OLD/'measurement-samples-readers-run.py')
V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def validate(text,schema,n,ref):
 result=V.checked('TS',text,schema,n,ref)
 observed=json.loads(text)
 for world in [observed['warmup'],observed['sample']]:
  declarations=world['descriptorAudit']
  assert collections.Counter(x['name'] for x in declarations)==collections.Counter(['Seed','Spawn','Update','Dispose','Fast','Slow','Dump']),'descriptor identity/construction count changed'
  assert all(x['timed'] is False for x in declarations),'descriptor constructed inside timed interval'
  assert world['rawTransientRange']==ref['rawTransientRange'],'actual reservation range changed'
  assert world['retainedLiveCount']==ref['retainedLiveCount']
  assert world['occupancy']['status']=='unavailable','unmeasured occupancy must not become an invented number'
 result.update(fullRowsCompared=sum(len(a[k]) for w in [observed['warmup'],observed['sample']] for a in w['audit'] for k in ['rows','added','changed']),descriptorAudit=observed['sample']['descriptorAudit'],auditSha256=hashlib.sha256(json.dumps(observed['sample']['audit'],sort_keys=True).encode()).hexdigest())
 return result

def recreated_update(source):
 start=source.index("  const Update=define('Update'");end=source.index("  const Dispose=",start)
 definition=source[start:end];without=source[:start]+source[end:]
 return without.replace("    phase='read';","    phase='read';\n"+definition,1)
def main():
 os.sched_setaffinity(0,{5})
 source=HERE/'readers-reference.mjs'
 result={'scope':'aligned TS Readers descriptor construction and complete finite observations; no Bend candidate gate or seven-sample ratio claim','cpuAffinity':sorted(os.sched_getaffinity(0)),'node':V.B.command(['node','--version']).strip(),'referenceCommit':V.B.command(['git','-C','/workspace/formal-proofs/bendvy/.references/bevy-ts','rev-parse','HEAD']).strip(),'sources':{str(p.relative_to(HERE.parent)):sha(p) for p in [source,pathlib.Path(__file__),OLD/'measurement-reference.mjs',OLD/'measurement-samples-readers-run.py',OLD/'measurement-readers-run.py',OLD/'measurement-samples-readers.bend',OLD/'measurement-readers.bend']},'limits':{'syntaxCheck':5,'runtime':5},'cases':[],'controls':[]}
 def save():(HERE/'readers-evidence.json').write_text(json.dumps(result,indent=2)+'\n')
 references={}
 with tempfile.TemporaryDirectory(prefix='readers-alignment-') as temporary:
  folder=pathlib.Path(temporary)
  V.B.command(['node','--check',source])
  for schema in ['Motion','Health']:
   for n in [64,256,1024]:
    # Authoritative reference is freshly executed before each aligned case.
    ref=json.loads(V.B.command(['node',OLD/'measurement-reference.mjs',schema,'readers',str(n)]));references[schema,n]=ref
    meta,text=V.child(['node',source,schema,str(n)],folder);meta.pop('contaminatedWait4RssKiB',None)
    if text is not None:
     try:meta['validation']=validate(text,schema,n,ref)
     except (AssertionError,json.JSONDecodeError) as e:meta.update(status='FAILED',error=str(e))
    result['cases'].append({'schema':schema,'count':n,**meta});save();print(schema,n,meta['status'],flush=True)
  original=source.read_text()
  mutations=[('recreate-update-in-loop',recreated_update(original)),('wrong-main-slot3',original.replace('const next=[xs[0]+1,xs[1],xs[2],xs[3]]','const next=[xs[0]+1,xs[1],xs[2],0]')),('wrong-ping',original.replace('events.ping.emit({code:iteration})','events.ping.emit({code:iteration+1})')),('slow-every-iteration',original.replace('iteration%4===3?[Slow]:[]','true?[Slow]:[]')),('drop-slow-diagnostic',original.replace("['Fast','Slow'].includes(event.system)","['Fast'].includes(event.system)"))]
  for name,mutated in mutations:
   assert mutated!=original,name
   with tempfile.NamedTemporaryFile(mode='w',suffix='.mjs',prefix='readers-mutant-',dir=HERE,delete=False) as f:f.write(mutated);path=pathlib.Path(f.name)
   try:
    V.B.command(['node','--check',path])
    for schema in ['Motion','Health']:
     meta,text=V.child(['node',path,schema,'64'],folder);rejected=False;reason=meta.get('error','')
     if text is not None:
      try:validate(text,schema,64,references[schema,64])
      except (AssertionError,json.JSONDecodeError) as e:rejected=True;reason=str(e)
     else:
      # A finite assertion rejection is a control; timeout never counts as detection.
      rejected=meta['exitCode']!=0 and 'AssertionError' in reason and 'deadline' not in reason
     result['controls'].append({'name':name,'schema':schema,'syntaxChecked':True,'sourceSha256':hashlib.sha256(mutated.encode()).hexdigest(),'rejected':rejected,'reason':reason[-1500:]});save();assert rejected,(name,schema,reason)
   finally:path.unlink()
 result['status']='PASS' if all(c['status']=='PASS' for c in result['cases']) and all(c['rejected'] for c in result['controls']) else 'FAILED';save();print(result['status']);return int(result['status']!='PASS')
if __name__=='__main__':sys.exit(main())
