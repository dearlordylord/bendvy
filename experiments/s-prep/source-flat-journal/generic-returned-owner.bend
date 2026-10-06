import Base
import OVERLAY/experiments/s-integrate/storage.bend as S
import OVERLAY/experiments/s-integrate/transaction.bend as X

type OwnedWorld is Type:
  OwnedWorld{main:Array<U32>,aux:Array<U32>,ledger:Array<U32>}
type OwnedCommand is Type:
  OwnedCommand{cells:Array<U32>}
def last(prefix:String,result:Array<U32> & U32) -> String:
  match result:
    case (_,n): prefix ++ U32.show(n)
def third(prefix:String,result:Array<U32> & U32) -> String:
  match result:
    case (array,n): last(prefix ++ U32.show(n) ++ ",",Array.get(U32,array,3))
def second(prefix:String,result:Array<U32> & U32) -> String:
  match result:
    case (array,n): third(prefix ++ U32.show(n) ++ ",",Array.get(U32,array,2))
def first(result:Array<U32> & U32) -> String:
  match result:
    case (array,n): second(U32.show(n) ++ ",",Array.get(U32,array,1))
def array_text(array:Array<U32>) -> String:
  first(Array.get(U32,array,0))
def world_text(world:OwnedWorld) -> String:
  match world:
    case OwnedWorld{main,aux,ledger}: array_text(main) ++ "|" ++ array_text(aux) ++ "|" ++ array_text(ledger)
def command_text(values:List<OwnedCommand>) -> String:
  match values:
    case Nil{}: ""
    case Con{OwnedCommand{cells},rest}: "[" ++ array_text(cells) ++ "]" ++ command_text(rest)
def handle_text(handle:S.Handle<Unit>) -> String:
  match handle:
    case S.Handle{ns,id}: U32.show(ns) ++ "/" ++ U32.show(id)
def marks_text(values:List<&2,S.Handle<Unit>>) -> String:
  match values:
    case Nil{}: ""
    case Con{head,rest}: handle_text(head) ++ "," ++ marks_text(rest)
def pings_text(values:List<&2,U32>) -> String:
  match values:
    case Nil{}: ""
    case Con{head,rest}: U32.show(head) ++ "," ++ pings_text(rest)
def inverse_text(values:List<&2,X.Inverse<S.Handle<Unit>>>) -> String:
  match values:
    case Nil{}: ""
    case Con{X.MainInverse{h,n},rest}: "M" ++ handle_text(h) ++ ":" ++ U32.show(n) ++ ";" ++ inverse_text(rest)
    case Con{X.LedgerInverse{n},rest}: "L:" ++ U32.show(n) ++ ";" ++ inverse_text(rest)
def initial() -> X.Tx<OwnedWorld,S.Handle<Unit>,OwnedCommand>:
  X.Tx{OwnedWorld{[7:U32^2n],[8:U32^2n],[9:U32^2n]},S.Handle{7,1},[X.LedgerInverse{77}],[OwnedCommand{[11:U32^2n]}],[12,11],[S.Handle{7,2}]}
# Fixture-owned concrete transformer, not a rank2 callback authority grant.
def callback(owner:X.Tx<OwnedWorld,S.Handle<Unit>,OwnedCommand>) -> X.Tx<OwnedWorld,S.Handle<Unit>,OwnedCommand>:
  match owner:
    case X.Tx{OwnedWorld{main,aux,ledger},_,undo,commands,pings,marks}:
      X.Tx{OwnedWorld{Array.set(U32,main,0,30),Array.set(U32,aux,0,40),Array.set(U32,ledger,0,50)},S.Handle{8,3},X.MainInverse{S.Handle{7,1},7} <> X.LedgerInverse{9} <> undo,OwnedCommand{[66:U32^2n]} <> commands,9 <> pings,S.Handle{8,2} <> S.Handle{7,1} <> marks}
def restore_main(world:OwnedWorld,handle:S.Handle<Unit>,old:U32) -> OwnedWorld:
  match world handle:
    case OwnedWorld{main,aux,ledger} S.Handle{7,1}: OwnedWorld{Array.set(U32,main,0,old),aux,ledger}
    case world _: world
def restore_ledger(world:OwnedWorld,old:U32) -> OwnedWorld:
  match world:
    case OwnedWorld{main,aux,ledger}: OwnedWorld{main,aux,Array.set(U32,ledger,0,old)}
def normalize(result:X.PrototypeFlatFinished<Unit,OwnedWorld,OwnedCommand>) -> X.Finished<OwnedWorld,OwnedCommand,S.Handle<Unit>>:
  match result:
    case X.PrototypeFlatCommitted{world,commands,pings,marks}: X.Committed{world,commands,pings,X.prototype_flat_mark_unpack(~Unit,marks)}
    case X.PrototypeFlatReverted{world}: X.Reverted{world}
def print_done(prefix:String,result:X.Finished<OwnedWorld,OwnedCommand,S.Handle<Unit>>) -> IO(Unit):
  match result:
    case X.Committed{world,commands,pings,marks}: IO.print(prefix ++ "=" ++ world_text(world) ++ "|" ++ command_text(commands) ++ "|" ++ pings_text(pings) ++ "|" ++ marks_text(marks))
    case X.Reverted{world}: IO.print(prefix ++ "=" ++ world_text(world) ++ "|reverted")
def finish_context(fail:Bool,private:Bool,prefix:String,owner:X.Tx<OwnedWorld,S.Handle<Unit>,OwnedCommand>) -> IO(Unit):
  match fail private:
    case False{} False{}: print_done(prefix,X.tx_finish_success(OwnedWorld,S.Handle<Unit>,OwnedCommand,owner))
    case True{} False{}: print_done(prefix,X.tx_finish_failure(~OwnedWorld,~S.Handle<Unit>,~OwnedCommand,~restore_main,~restore_ledger,owner))
    case False{} True{}: print_done(prefix,normalize(X.prototype_flat_finish_success(~Unit,~OwnedWorld,~OwnedCommand,X.prototype_flat_pack(~Unit,~OwnedWorld,~OwnedCommand,owner))))
    case True{} True{}: print_done(prefix,normalize(X.prototype_flat_finish_failure(~Unit,~OwnedWorld,~OwnedCommand,~restore_main,~restore_ledger,X.prototype_flat_pack(~Unit,~OwnedWorld,~OwnedCommand,owner))))
def finish(+fail:Bool,private:Bool,owner:X.Tx<OwnedWorld,S.Handle<Unit>,OwnedCommand>) -> IO(Unit):
  match owner:
    case X.Tx{world,+selected,+undo,commands,+pings,+marks}:
      finish_context(fail,private,handle_text(selected) ++ "|" ++ inverse_text(undo),X.Tx{world,selected,undo,commands,pings,marks})
def actual() -> X.Tx<OwnedWorld,S.Handle<Unit>,OwnedCommand>:
  X.prototype_flat_unpack(~Unit,~OwnedWorld,~OwnedCommand,X.prototype_flat_pack(~Unit,~OwnedWorld,~OwnedCommand,callback(initial())))
def main() -> IO(Unit):
  do IO<Unit>:
    finish(False{},False{},callback(initial()))
    finish(False{},True{},actual())
    finish(True{},False{},callback(initial()))
    finish(True{},True{},actual())
