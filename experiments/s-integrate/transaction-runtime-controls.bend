import Base
import ./types.bend as T
import ./transaction.bend as X

type World is Type:
  World{main: Array<U32>, ledger: Array<U32>, next: U32}
type Command is Type:
  Command{payload: Array<U32>}
def main_old(result: Array<U32> & U32,ledger: Array<U32>,next: U32,value: U32) -> World & T.Access<U32>:
  match result:
    case (main,old): (World{Array.set(U32,main,0,value),ledger,next},T.Found{old})
def write_main(w: World,handle: U32,value: U32) -> World & T.Access<U32>:
  match w:
    case World{main,ledger,next}: main_old(Array.get(U32,main,0),ledger,next,value)
def ledger_old(main: Array<U32>,result: Array<U32> & U32,next: U32,value: U32) -> World & Maybe<&2,U32>:
  match result:
    case (ledger,old): (World{main,Array.set(U32,ledger,0,value),next},Some{old})
def write_ledger(w: World,value: U32) -> World & Maybe<&2,U32>:
  match w:
    case World{main,ledger,next}: ledger_old(main,Array.get(U32,ledger,0),next,value)
def restore_main(w: World,handle: U32,old: U32) -> World:
  match w:
    case World{main,ledger,next}: World{Array.set(U32,main,0,old),ledger,next}
def restore_ledger(w: World,old: U32) -> World:
  match w:
    case World{main,ledger,next}: World{main,Array.set(U32,ledger,0,old),next}
def world() -> World:
  World{Array.set(U32,Array.set(U32,Array.set(U32,[20:U32^2n],1,21),2,22),3,23),Array.set(U32,Array.set(U32,Array.set(U32,[101:U32^2n],1,101),2,102),3,103),6}
def observed_ledger(main: Array<U32>,next: U32,result: Array<U32> & U32) -> String:
  match result:
    case (_,old): U32.show(old) ++ ":" ++ U32.show(next)
def observed_main(ledger: Array<U32>,next: U32,result: Array<U32> & U32) -> String:
  match result:
    case (main,old): U32.show(old) ++ ":" ++ observed_ledger(main,next,Array.get(U32,ledger,0))
def observe(result: X.Finished<World,Command,U32>) -> String:
  match result:
    case X.Reverted{World{main,ledger,next}}: observed_main(ledger,next,Array.get(U32,main,0))
    case X.Committed{_,_,_,_}: "unexpectedcommit"
def main() -> String:
  observe(X.tx_finish_failure(World,U32,Command,restore_main,restore_ledger,X.tx_stage_ping(World,U32,Command,X.tx_stage_command(World,U32,Command,X.tx_set_ledger0(World,U32,Command,write_ledger,X.tx_set_main0(World,U32,Command,write_main,X.tx_set_main0(World,U32,Command,write_main,X.tx_begin(World,U32,Command,world(),2),30),50),201),Command{[9:U32^2n]}),9)))
