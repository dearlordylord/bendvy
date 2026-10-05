#!/usr/bin/env python3
"""Actual integrated cached command boundary; no prototype inheritance."""
import argparse,hashlib,json,os,signal,subprocess,re
from pathlib import Path
HERE=Path(__file__).resolve().parent

def check(source,cpu):
 command=['taskset','-c',str(cpu),'bend',str(source),'--check-only']
 process=subprocess.Popen(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
 try:output,_=process.communicate(timeout=int(os.environ.get("BENDVY_CHECKER_SECONDS", "5")))
 except subprocess.TimeoutExpired:
  os.killpg(process.pid,signal.SIGKILL);process.communicate();raise RuntimeError('Checker deadline: '+str(source))
 return process.returncode,output

def main():
 parser=argparse.ArgumentParser();parser.add_argument('--overlay',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);parser.add_argument('--cache-module',default='cache');parser.add_argument('--cpu',type=int,default=9);args=parser.parse_args()
 args.output.mkdir(exist_ok=False);result={'status':'INCOMPLETE','scope':'Actual cached-command Type staging positive/negative; no runtime/cache-coherence acceptance','controls':[]}
 try:
  assert re.fullmatch(r'[A-Za-z_][A-Za-z0-9_-]*',args.cache_module),'Invalid cache module name'
  manifest=json.loads((args.overlay/'overlay.json').read_text())['sources']
  sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
  assert all(sha(args.overlay/n)==v for n,v in manifest.items()),'Input overlay differs from manifest'
  core=args.overlay/'experiments/s-integrate'
  for source in core.glob('*.bend'):
   assert not source.is_symlink(),'Core import symlink'
   for relative in re.findall(r'^import (\./\S+\.bend)',source.read_text(),re.M):
    dependency=(source.parent/relative).resolve();assert dependency.is_relative_to(core.resolve()) and dependency.is_file(),'Core import escapes source closure'
  cache=core/(args.cache_module+'.bend');assert str(cache.relative_to(args.overlay)) in manifest,'Cache module absent from actual source manifest'
  assert 'type Cache<-Raw:Type,-View:Data> is Type:' in cache.read_text(),'Unexpected actual cache representation'
  result['inputManifestSHA256']=sha(args.overlay/'overlay.json');result['cacheSHA256']=sha(cache)
  # Fixture files reside beside actual modules in a fresh overlay copy, never the input.
  import shutil
  copied=args.output/'core';shutil.copytree(core,copied)
  for schema,main,view,aux,flag,ledger,mode in [('Motion','Position','PositionView','Velocity','Selected','MotionLedger','MotionMode'),('Health','Vitals','VitalsView','Armor','Tracked','HealthLedger','HealthMode')]:
   cm=f'C.Cache<T.{main},T.{view}>';world=f'S.World<T.{schema}Schema,{cm},T.{aux},T.{flag},C.Cache<T.{ledger},T.LedgerView>,T.{mode}>';handle=f'S.Handle<T.{schema}Schema>';command=f'S.Command<{cm},T.{aux},T.{flag}>';tx=f'X.Tx<{world},{handle},{command}>'
   header=f'import Base\nimport ./types.bend as T\nimport ./storage.bend as S\nimport ./transaction.bend as X\nimport ./{args.cache_module}.bend as C\n'
   for name,owner_type in [('wrapped-positive',cm),('raw-negative',f'T.{main}')]:
    source=copied/(schema.lower()+'-'+name+'.bend');source.write_text(header+f'def stage(owner:{tx},main:{owner_type}) -> {tx}:\n  X.tx_stage_command({world},{handle},{command},owner,S.InsertMain{{1,main}})\n')
    code,output=check(source,args.cpu);(args.output/(source.stem+'.txt')).write_text(output)
    if name=='wrapped-positive':assert code==0 and 'ALL PROOFS CHECK' in output,output
    else:
     assert code!=0 and 'SOME PROOFS FAIL' in output and 'Location: stage' in output,output
     assert f'- expected : C.Cache<T.{main}, T.{view}>\n- observed : T.{main}\n' in output,output
    result['controls'].append({'schema':schema,'kind':name,'status':'PASS','checkerExit':code,'fixtureSHA256':sha(source),'diagnosticSHA256':hashlib.sha256(output.encode()).hexdigest()})
  assert all(sha(args.overlay/n)==v for n,v in manifest.items())
  result['status']='PASS_BOUNDED_STAGING_TYPE_BOUNDARY'
 except Exception as error:result.update(status='FAIL',error=repr(error));raise
 finally:(args.output/'evidence.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
