import Base
import OVERLAY/experiments/s-integrate/held-adapter.bend as HA
import OVERLAY/experiments/s-integrate/transaction.bend as X
import OVERLAY/experiments/s-integrate/storage.bend as S

type World is Type:
  World{owned:Array<U32>,main:U32,ledger:U32,log:String}
def restore_main(world:World,handle:S.Handle<Unit>,old:U32) -> World:
  match world handle:
    case World{owned,_,ledger,log} S.Handle{_,_}:
      +old = old
      World{owned,old,ledger,log ++ "M" ++ U32.show(old) ++ ";"}
def restore_ledger(world:World,old:U32) -> World:
  match world:
    case World{owned,main,_,log}:
      +old = old
      World{owned,main,old,log ++ "L" ++ U32.show(old) ++ ";"}
def inverse_text(values:List<&2,X.Inverse<S.Handle<Unit>>>) -> String:
  match values:
    case Nil{}: ""
    case Con{X.MainInverse{S.Handle{+space,+id},old},tail}: "M" ++ U32.show(space) ++ "/" ++ U32.show(id) ++ ":" ++ U32.show(old) ++ ";" ++ inverse_text(tail)
    case Con{X.LedgerInverse{old},tail}: "L:" ++ U32.show(old) ++ ";" ++ inverse_text(tail)
def print_owned(prefix:String,main:U32,ledger:U32,log:String,result:Array<U32> & U32) -> IO(Unit):
  match result:
    case (_,owned): IO.print(prefix ++ "|" ++ U32.show(main) ++ "|" ++ U32.show(ledger) ++ "|" ++ log ++ "|" ++ U32.show(owned))
def print_world(prefix:String,world:World) -> IO(Unit):
  match world:
    case World{owned,main,ledger,log}: print_owned(prefix,main,ledger,log,Array.get(U32,owned,0))
def report(+label:String,+undo:X.PrototypeFlatInverse<Unit>) -> IO(Unit):
  do IO<Unit>:
    print_world(label ++ "|flat|" ++ inverse_text(X.prototype_flat_inverse_unpack(~Unit,undo)),X.prototype_flat_unwind(~Unit,~World,~restore_main,~restore_ledger,undo,World{[7:U32^2n],999,888,""}))
    print_world(label ++ "|generic|" ++ inverse_text(X.prototype_flat_inverse_unpack(~Unit,undo)),X.unwind(~World,~S.Handle<Unit>,~restore_main,~restore_ledger,X.prototype_flat_inverse_unpack(~Unit,undo),World{[7:U32^2n],999,888,""}))
def start() -> HA.PrototypePendingUndo<Unit>:
  HA.PrototypePendingUndo{False{},0,0,0,X.PrototypeFlatLedger{77,X.PrototypeFlatEnd{}}}
def main() -> IO(Unit):
  do IO<Unit>:
    report("none",HA.prototype_pending_flush(~Unit,start()))
    report("main",HA.prototype_pending_flush(~Unit,HA.prototype_pending_main(~Unit,7,1,10,start())))
    report("pair",HA.prototype_pending_flush(~Unit,HA.prototype_pending_ledger(~Unit,100,HA.prototype_pending_main(~Unit,7,1,10,start()))))
    report("mm",HA.prototype_pending_flush(~Unit,HA.prototype_pending_main(~Unit,7,1,20,HA.prototype_pending_main(~Unit,7,1,10,start()))))
    report("ll",HA.prototype_pending_flush(~Unit,HA.prototype_pending_ledger(~Unit,200,HA.prototype_pending_ledger(~Unit,100,start()))))
    report("lm",HA.prototype_pending_flush(~Unit,HA.prototype_pending_main(~Unit,7,1,10,HA.prototype_pending_ledger(~Unit,100,start()))))
    report("mlm",HA.prototype_pending_flush(~Unit,HA.prototype_pending_main(~Unit,7,1,20,HA.prototype_pending_ledger(~Unit,100,HA.prototype_pending_main(~Unit,7,1,10,start())))))
