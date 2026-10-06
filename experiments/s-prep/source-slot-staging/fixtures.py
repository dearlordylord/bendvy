"""Generate finite controls, with a Python oracle independent of Bend output."""
def runtime(schema):
 slot='CP.Prototype'+schema+'MainSlot';raw='Position' if schema=='Motion' else 'Vitals';stem='position' if schema=='Motion' else 'vitals';ns='T.'+schema+'Schema';W=f'S.World<{ns},{slot},Unit,Unit,Unit,Unit>';C=f'S.Command<{slot},Unit,Unit>';H=f'S.Handle<{ns}>';AR=f'C.CheckedApply<{ns},{slot},Unit,Unit,Unit,Unit>';CR=lambda P:f'T.CommandResult<{W},{P}>'
 rawfields='owner,frame' if schema=='Motion' else 'owner,reserve,class'
 fields='owner,rawframe,a,b,c,d,cachedframe' if schema=='Motion' else 'owner,rawreserve,rawclass,a,b,c,d,cachedreserve,cachedclass'
 nonarr=fields.split(',')[1:];show=' ++ ":" ++ '.join('U32.show('+f+')' for f in nonarr)
 initraw='T.Position{arr(depth,seed),17}' if schema=='Motion' else 'T.Vitals{arr(depth,seed),17,23}'
 src='''import Base
import ./types.bend as T
import ./storage.bend as S
import ./commands.bend as C
import ./identity.bend as I
import ./cached-payload.bend as CP
import ./transaction.bend as X

def filled(n:Nat,+i:U32,owner:Array<U32>,+seed:U32) -> Array<U32>:
  match n:
    case Zero{}: owner
    case Succ{tail}: filled(tail,(i + 1 : U32),Array.set(U32,owner,i,(seed + i : U32)),seed)
def arr(+depth:Nat,seed:U32) -> Array<U32>:
  filled(U32.to_nat(U32.pow(2,depth)),0,[0:U32^depth],seed)
def arr_text_next(text:String,result:Array<U32> & U32,continue_owner:Array<U32> -> String -> Array<U32> & String) -> Array<U32> & String:
  match result:
    case (owner,value): continue_owner(owner,text ++ U32.show(value) ++ ",")
def arr_text(n:Nat,+i:U32,text:String,owner:Array<U32>) -> Array<U32> & String:
  match n:
    case Zero{}: (owner,text)
    case Succ{tail}: arr_text_next(text,Array.get(U32,owner,i), a => t => arr_text(tail,(i + 1 : U32),t,a))
'''
 src+=f'''def make_slot(depth:Nat,seed:U32) -> {slot}:
  CP.prototype_slot_{stem}_new({initraw})
def slot_done({','.join(f'+{v}:U32' for v in nonarr)},result:Array<U32> & String) -> {slot} & String:
  match result:
    case (owner,text): ({slot}{{{fields}}},"[" ++ text ++ "]:" ++ {show})
def slot_text(+depth:Nat,main:{slot}) -> {slot} & String:
  match main:
    case {slot}{{{fields}}}: slot_done({','.join(nonarr)},arr_text(U32.to_nat(U32.pow(2,depth)),0,"",owner))
def main_text_done(pair:{slot} & String) -> Maybe<{slot}> & String:
  match pair:
    case (owner,text): (Some{{owner}},text)
def main_text(depth:Nat,main:Maybe<{slot}>) -> Maybe<{slot}> & String:
  match main:
    case None{{}}: (None{{}},"none")
    case Some{{owner}}: main_text_done(slot_text(depth,owner))
def bundle_done(aux:Maybe<Unit>,flag:Maybe<&2,Unit>,pair:Maybe<{slot}> & String) -> S.Bundle<{slot},Unit,Unit> & String:
  match pair:
    case (main,text): (S.Bundle{{main,aux,flag}},text)
def bundle_text(depth:Nat,bundle:S.Bundle<{slot},Unit,Unit>) -> S.Bundle<{slot},Unit,Unit> & String:
  match bundle:
    case S.Bundle{{main,aux,flag}}: bundle_done(aux,flag,main_text(depth,main))
def spawn_done(+id:U32,pair:S.Bundle<{slot},Unit,Unit> & String) -> {C} & String:
  match pair:
    case (bundle,text): (S.Spawn{{id,bundle}},"spawn:" ++ U32.show(id) ++ ":" ++ text)
def insert_done(+id:U32,pair:{slot} & String) -> {C} & String:
  match pair:
    case (main,text): (S.InsertMain{{id,main}},"insert:" ++ U32.show(id) ++ ":" ++ text)
def command_text(depth:Nat,command:{C}) -> {C} & String:
  match command:
    case S.Spawn{{id,bundle}}: spawn_done(id,bundle_text(depth,bundle))
    case S.InsertMain{{id,main}}: insert_done(id,slot_text(depth,main))
    case S.InsertFlag{{+id,flag}}: (S.InsertFlag{{id,flag}},"flag:" ++ U32.show(id))
    case S.RemoveMain{{+id}}: (S.RemoveMain{{id}},"removeMain:" ++ U32.show(id))
    case S.RemoveFlag{{+id}}: (S.RemoveFlag{{id}},"removeFlag:" ++ U32.show(id))
    case S.Despawn{{+id}}: (S.Despawn{{id}},"despawn:" ++ U32.show(id))
def queue_next(restored:List<{C}>,text:String,pair:{C} & String,continue_owner:List<{C}> -> String -> List<{C}> & String) -> List<{C}> & String:
  match pair:
    case (command,one): continue_owner(command <> restored,text ++ one ++ ";")
def queue_text(+depth:Nat,pending:List<{C}>,restored:List<{C}>,text:String) -> List<{C}> & String:
  match pending:
    case Nil{{}}: (List.reverse(&1,{C},restored),text)
    case Con{{command,tail}}: queue_next(restored,text,command_text(depth,command), a => t => queue_text(depth,tail,a,t))
def snapshot_done(+ns:U32,+next:U32,rows:S.Rows<{slot},Unit,Unit>,ledger:Maybe<Unit>,mode:Unit,pair:List<{C}> & String) -> {W} & String:
  match pair:
    case (pending,text): (S.World{{ns,next,rows,pending,ledger,mode}},"world:" ++ U32.show(ns) ++ ":" ++ U32.show(next) ++ "|" ++ text)
def snapshot_pending(depth:Nat,prefix:String,world:{W}) -> {W} & String:
  match world:
    case S.World{{ns,next,rows,pending,ledger,mode}}: snapshot_done(ns,next,rows,ledger,mode,queue_text(depth,pending,[],prefix))
def snapshot_access(depth:Nat,result:{W} & T.Access<String>) -> {W} & String:
  match result:
    case (world,T.Found{{text}}): snapshot_pending(depth,"live:" ++ text ++ "|",world)
    case (world,_): (world,"BAD_LIVE_LOOKUP")
def snapshot(+depth:Nat,world:{W}) -> {W} & String:
  match world:
    case S.World{{+ns,next,rows,pending,ledger,mode}}: snapshot_access(depth,S.with_main({ns},{slot},Unit,Unit,Unit,Unit,String,S.World{{ns,next,rows,pending,ledger,mode}},S.Handle{{ns,1}}, m => slot_text(depth,m)))
def local_snapshot(prefix:String,result:{W} & String) -> String:
  match result:
    case (world,text): prefix ++ "|local:" ++ text
def local_done(depth:Nat,prefix:String,result:{CR(slot)}) -> String:
  match result:
    case T.CommandQueued{{world}}: local_snapshot(prefix,snapshot(depth,world))
    case T.CommandMissing{{world,payload}}: "BAD_LOCAL_MISSING"
def local_queue(+depth:Nat,local:{H},prefix:String,world:{W}) -> String:
  local_done(depth,prefix,C.insert_main({ns},{slot},Unit,Unit,Unit,Unit,world,local,make_slot(depth,70)))
def finish_payload(+depth:Nat,local:{H},prior:String,payload:{slot} & String,current:{W} & String) -> String:
  match payload current:
    case Tuple{{owner,full}} Tuple{{world,+now}}: local_queue(depth,local,Bool.show(String.eq(prior,now)) ++ "|" ++ full ++ "|" ++ now,world)
def finish_slot(+depth:Nat,local:{H},prior:String,result:{CR(slot)}) -> String:
  match result:
    case T.CommandMissing{{world,payload}}: finish_payload(depth,local,prior,slot_text(depth,payload),snapshot(depth,world))
    case T.CommandQueued{{world}}: "BAD_QUEUED"
'''
 # Sequence foreign Unit-returning command operations, each must refuse; preserve actual receiving owner.
 for name,nextname in [('despawn','finish_slot'),('remove_flag','foreign_despawn'),('remove_main','foreign_remove_flag'),('insert_flag','foreign_remove_main')]:
  fname='foreign_'+name
  invoke=(f'C.{name}({ns},{slot},Unit,Unit,Unit,Unit,world,foreign'+(',Unit{}' if name=='insert_flag' else '')+')')
  if name=='despawn': continuation=f'finish_slot(depth,local,prior,C.insert_main({ns},{slot},Unit,Unit,Unit,Unit,world,foreign,make_slot(depth,90)))'
  else: continuation=f'{nextname}(depth,local,prior,world,foreign)'
  src+=f'''def {fname}_result(+depth:Nat,local:{H},prior:String,+foreign:{H},result:{CR('Unit')}) -> String:
  match result:
    case T.CommandMissing{{world,payload}}: {continuation}
    case T.CommandQueued{{world}}: "BAD_QUEUED"
def {fname}(+depth:Nat,local:{H},prior:String,+world:{W},+foreign:{H}) -> String:
  {fname}_result(depth,local,prior,foreign,{invoke})
'''.replace('+world:', 'world:')
 src+=f'''def prepared(depth:Nat,local:{H},+foreign:{H},pair:{W} & String) -> String:
  match pair:
    case (world,prior): foreign_insert_flag(depth,local,prior,world,foreign)
def seeded_result(-P:Type,result:{CR('P')},continue_world:{W} -> String) -> String:
  match result:
    case T.CommandQueued{{world}}: continue_world(world)
    case T.CommandMissing{{world,payload}}: "BAD_SEED_MISSING"
def seeded_main(+depth:Nat,+local:{H},foreign:{H},world:{W}) -> String:
  seeded_result({slot},C.insert_main({ns},{slot},Unit,Unit,Unit,Unit,world,local,make_slot(depth,30)), w => prepared(depth,local,foreign,snapshot(depth,w)))
def seeded_flag(depth:Nat,+local:{H},foreign:{H},world:{W}) -> String:
  seeded_result(Unit,C.insert_flag({ns},{slot},Unit,Unit,Unit,Unit,world,local,Unit{{}}), w => seeded_main(depth,local,foreign,w))
def seeded_remove_main(depth:Nat,+local:{H},foreign:{H},world:{W}) -> String:
  seeded_result(Unit,C.remove_main({ns},{slot},Unit,Unit,Unit,Unit,world,local), w => seeded_flag(depth,local,foreign,w))
def seeded_remove_flag(depth:Nat,+local:{H},foreign:{H},world:{W}) -> String:
  seeded_result(Unit,C.remove_flag({ns},{slot},Unit,Unit,Unit,Unit,world,local), w => seeded_remove_main(depth,local,foreign,w))
def seeded_despawn(depth:Nat,+local:{H},foreign:{H},world:{W}) -> String:
  seeded_result(Unit,C.despawn({ns},{slot},Unit,Unit,Unit,Unit,world,local), w => seeded_remove_flag(depth,local,foreign,w))
def initial_reserved(depth:Nat,local:{H},foreign:{H},result:T.Reservation<{W},{H},S.Bundle<{slot},Unit,Unit>>) -> String:
  match result:
    case T.Reserved{{world,handle}}: seeded_despawn(depth,local,foreign,world)
    case _: "BAD_SEED_RESERVE"
def initial(+depth:Nat,world:{W},local:{H},foreign:{H}) -> String:
  initial_reserved(depth,local,foreign,C.reserve({ns},{slot},Unit,Unit,Unit,Unit,world,S.Bundle{{Some{{make_slot(depth,50)}},None{{}},None{{}}}}))
def b_applied(+depth:Nat,a:{W},local:{H},+foreign:{H},result:{AR}) -> String:
  match result:
    case C.Applied{{world,changes}}: initial(depth,a,local,foreign)
    case _: "BAD_APPLY_B"
def b_reserved(+depth:Nat,a:{W},local:{H},result:T.Reservation<{W},{H},S.Bundle<{slot},Unit,Unit>>) -> String:
  match result:
    case T.Reserved{{world,+handle}}: b_applied(depth,a,local,handle,C.apply_checked({ns},{slot},Unit,Unit,Unit,Unit,world,1))
    case _: "BAD_RESERVE_B"
def b_created(+depth:Nat,a:{W},local:{H},result:T.Creation<S.Factory,{W}>) -> String:
  match result:
    case T.Created{{factory,world}}: b_reserved(depth,a,local,C.reserve({ns},{slot},Unit,Unit,Unit,Unit,world,S.Bundle{{Some{{make_slot(depth,20)}},None{{}},None{{}}}}))
    case _: "BAD_CREATE_B"
def a_applied(+depth:Nat,factory:S.Factory,local:{H},result:{AR}) -> String:
  match result:
    case C.Applied{{world,changes}}: b_created(depth,world,local,I.create(~{ns},~{slot},~Unit,~Unit,~Unit,~Unit,~(u => Unit{{}}),factory,Unit{{}}))
    case _: "BAD_APPLY_A"
def a_reserved(+depth:Nat,factory:S.Factory,result:T.Reservation<{W},{H},S.Bundle<{slot},Unit,Unit>>) -> String:
  match result:
    case T.Reserved{{world,handle}}: a_applied(depth,factory,handle,C.apply_checked({ns},{slot},Unit,Unit,Unit,Unit,world,1))
    case _: "BAD_RESERVE_A"
def a_created(+depth:Nat,result:T.Creation<S.Factory,{W}>) -> String:
  match result:
    case T.Created{{factory,world}}: a_reserved(depth,factory,C.reserve({ns},{slot},Unit,Unit,Unit,Unit,world,S.Bundle{{Some{{make_slot(depth,10)}},None{{}},None{{}}}}))
    case _: "BAD_CREATE_A"
def one(depth:Nat) -> String:
  a_created(depth,I.create(~{ns},~{slot},~Unit,~Unit,~Unit,~Unit,~(u => Unit{{}}),I.factory(),Unit{{}}))
def tx_loop(n:Nat,+depth:Nat,+id:U32,owner:X.Tx<{W},{H},{C}>) -> X.Tx<{W},{H},{C}>:
  match n:
    case Zero{{}}: owner
    case Succ{{tail}}: tx_loop(tail,depth,(id + 1 : U32),X.tx_stage_command({W},{H},{C},owner,S.InsertMain{{id,make_slot(depth,(100 + id : U32))}}))
def ping_text(values:List<&2,U32>,text:String) -> String:
  match values:
    case Nil{{}}: text
    case Con{{value,tail}}: ping_text(tail,text ++ U32.show(value) ++ ",")
def tx_text_done(pings:List<&2,U32>,pair:List<{C}> & String) -> String:
  match pair:
    case (commands,text): "tx:" ++ text ++ "|pings:" ++ ping_text(pings,"")
def tx_text(depth:Nat,result:X.Finished<{W},{C},{H}>) -> String:
  match result:
    case X.Committed{{world,commands,pings,marks}}: tx_text_done(pings,queue_text(depth,commands,[],""))
    case X.Reverted{{world}}: "BAD_TX_REVERTED"
def tx_reserved(+depth:Nat,pair:{W} & Maybe<&2,{H}>) -> String:
  match pair:
    case (world,Some{{handle}}): tx_text(depth,X.tx_finish_success({W},{H},{C},X.tx_stage_ping({W},{H},{C},X.tx_stage_ping({W},{H},{C},tx_loop(32n,depth,1,X.tx_begin({W},{H},{C},world,handle)),81),82)))
    case (world,None{{}}): "BAD_TX_RESERVE"
def tx_created(depth:Nat,result:T.Creation<S.Factory,{W}>) -> String:
  match result:
    case T.Created{{factory,world}}: tx_reserved(depth,I.reserve_id({ns},{slot},Unit,Unit,Unit,Unit,world))
    case _: "BAD_TX_CREATE"
def tx_one(depth:Nat) -> String:
  tx_created(depth,I.create(~{ns},~{slot},~Unit,~Unit,~Unit,~Unit,~(u => Unit{{}}),I.factory(),Unit{{}}))
def main() -> IO(Unit):
  do IO<Unit>:
'''
 for depth in range(5):src+=f'    IO.print(one({depth}n))\n'
 for depth in range(5):src+=f'    IO.print(tx_one({depth}n))\n'
 return src

def expected(schema):
 def slot(depth,seed):
  arr=[seed+i for i in range(2**depth)];cached=[arr[i%len(arr)] for i in range(4)];meta=[17] if schema=='Motion' else [17,23]
  return '['+''.join(str(i)+',' for i in arr)+']:'+':'.join(map(str,meta+cached+meta))
 lines=[]
 for depth in range(5):
  # Actual C.reserve then despawn/removeFlag/removeMain/insertFlag/insertMain enqueue these six commands newest first.
  queue='world:1:3|live:'+slot(depth,10)+'|insert:1:'+slot(depth,30)+';flag:1;removeMain:1;removeFlag:1;despawn:1;spawn:2:'+slot(depth,50)+';'
  lines.append('True|'+slot(depth,90)+'|'+queue+'|local:world:1:3|live:'+slot(depth,10)+'|insert:1:'+slot(depth,70)+';'+queue.split('|',2)[2])
 for depth in range(5):lines.append('tx:'+''.join('insert:'+str(i)+':'+slot(depth,100+i)+';' for i in range(1,33))+'|pings:81,82,')
 return '\n'.join(lines)+'\n'
