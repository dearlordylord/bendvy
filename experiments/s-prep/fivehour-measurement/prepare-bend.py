#!/usr/bin/env python3
"""Generate one-bracket batch driver without editing actual callback bodies."""
import argparse,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--core',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--batch',type=int,default=16);a=p.parse_args();a.output.mkdir(exist_ok=False)
source=a.core/'measurement-bend.bend';text=source.read_text()
# Expose setup through an added wrapper using actual creation/registration.
extra='\n'
for lane,sc,main,aux,flag,ledger,mode in [('motion','Motion','Position','Velocity','Selected','MotionLedger','MotionMode'),('health','Health','Vitals','Armor','Tracked','HealthLedger','HealthMode')]:
 world=f'S.World<T.{sc}Schema,T.{main},T.{aux},T.{flag},T.{ledger},T.{mode}>';runtime=f'D.Runtime<{sc}Bench,S.Handle<T.{sc}Schema>>';pair=runtime+f' & K.System'
 extra+=f'''def {lane}_fresh(count:U32) -> IO({pair}):
  {lane}_created(count,False{{}},I.create(T.{sc}Schema,T.{main},T.{aux},T.{flag},T.{ledger},T.{mode},{lane}_ledger,I.factory(),T.{sc}On{{}}))
'''
(a.output/'measurement-bend.bend').write_text(text+extra)
# Imports point at the exact copied core except self module.
module=a.output/'measurement-bend.bend';s=module.read_text();s=re.sub(r'^import (\./\S+\.bend)',lambda m:'import '+str((a.core/m[1]).resolve()),s,flags=re.M);module.write_text(s)
driver='import Base\nimport ./measurement-bend.bend as M\nimport '+str((a.core/'types.bend').resolve())+' as T\nimport '+str((a.core/'storage.bend').resolve())+' as S\nimport '+str((a.core/'dispatcher.bend').resolve())+' as D\nimport '+str((a.core/'schedule.bend').resolve())+' as K\n'
# Correct actual schedule module name is derived from M alias K import.
k=re.search(r'^import (\./\S+\.bend) as K$',text,re.M);assert k;driver=driver.replace(str((a.core/'schedule.bend').resolve()),str((a.core/k[1]).resolve()))
for lane,sc in [('motion','Motion'),('health','Health')]:
 rt=f'D.Runtime<M.{sc}Bench,S.Handle<T.{sc}Schema>>';pair='('+rt+' & K.System)'
 driver+=f'''\ndef {lane}_prepared(fuel:Nat,+count:U32,owners:List<{pair}>) -> IO(List<{pair}>):
  match fuel:
    case 0n: IO.pure(List<{pair}>,List.reverse(&1,{pair},owners))
    case 1n+rest: IO.bind({pair},List<{pair}>,M.{lane}_fresh(count),owner => {lane}_prepared(rest,count,owner <> owners))
def {lane}_ran(rest:List<{pair}>,system:K.System,done:List<{rt}>,owner:{rt}) -> IO(List<{rt}>):
  {lane}_execute(rest,owner <> done)
'''
 # Avoid forward reference: pass recursion as continuation.
 driver=driver[:driver.rfind(f'def {lane}_ran')]+f'''def {lane}_returned(next:List<{rt}> -> IO(List<{rt}>),done:List<{rt}>,owner:{rt}) -> IO(List<{rt}>):
  next(owner <> done)
def {lane}_execute(owners:List<{pair}>,done:List<{rt}>) -> IO(List<{rt}>):
  match owners:
    case Nil{{}}: IO.pure(List<{rt}>,List.reverse(&1,{rt},done))
    case Con{{Tuple{{owner,system}},rest}}: IO.bind({rt},List<{rt}>,M.{lane}_loops(64n,system,owner),value => {lane}_returned(values => {lane}_execute(rest,values),done,value))
def {lane}_dump(owners:List<{rt}>) -> IO(Unit):
  match owners:
    case Nil{{}}: IO.pure(Unit,Unit{{}})
    case Con{{owner,rest}}:
      do IO<Unit>:
        M.{lane}_dump(0n,owner)
        {lane}_dump(rest)
def {lane}_timed(owners:List<{pair}>) -> IO(Unit):
  do IO<Unit>:
    start:Nat <- IO.now()
    returned:List<{rt}> <- {lane}_execute(owners,[])
    end:Nat <- IO.now()
    IO.print("BATCH-MILLISECONDS:" ++ Nat.show(Nat.sub(end,start)))
    {lane}_dump(returned)
def {lane}_batch(+count:U32,batch:U32) -> IO(Unit):
  do IO<Unit>:
    M.{lane}_start(count,False{{}})
    prepared:List<{pair}> <- {lane}_prepared(U32.to_nat(batch),count,[])
    {lane}_timed(prepared)
'''
driver+='''def choose(schema:U32,count:U32,batch:U32) -> IO(Unit):
  match schema:
    case 0: motion_batch(count,batch)
    case _: health_batch(count,batch)
def main() -> IO(Unit):
  choose(1,256,BATCH_VALUE)
'''
driver=driver.replace('BATCH_VALUE',str(a.batch))
(a.output/'batch.bend').write_text(driver)
(a.output/'recipe.json').write_text(json.dumps({'batch':a.batch,'count':256,'sourceSHA256':hashlib.sha256(source.read_bytes()).hexdigest(),'derivedSHA256':hashlib.sha256(module.read_bytes()).hexdigest(),'driverSHA256':hashlib.sha256(driver.encode()).hexdigest(),'scope':'One clock around execution of pre-created distinct affine worlds; setup/output excluded'},indent=2)+'\n')
