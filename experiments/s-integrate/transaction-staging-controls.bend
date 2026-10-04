import Base
import ./transaction.bend as X

type World is Type:
  World{owner: Array<U32>}
type Command is Type:
  Command{owner: Array<U32>,meta: U32}
def command(+value:U32) -> Command:
  Command{Array.set(U32,Array.set(U32,Array.set(U32,[value:U32^2n],1,(value + 1 : U32)),2,(value + 2 : U32)),3,(value + 3 : U32)),(value + 5 : U32)}
def stage_commands(n:Nat,t:X.Tx<World,U32,Command>,+value:U32) -> X.Tx<World,U32,Command>:
  match n:
    case Zero{}: t
    case Succ{tail}: stage_commands(tail,X.tx_stage_command(World,U32,Command,t,command(value)),(value + 1 : U32))
def stage_pings(n:Nat,t:X.Tx<World,U32,Command>,+value:U32) -> X.Tx<World,U32,Command>:
  match n:
    case Zero{}: t
    case Succ{tail}: stage_pings(tail,X.tx_stage_ping(World,U32,Command,t,value),(value + 1 : U32))
def checked_step(+expected:U32,+index:U32,result:Array<U32> & U32,continue_owner:Array<U32> -> Bool) -> Bool:
  match result:
    case (owner,value): Bool.and(U32.is_eq(value,(expected + index : U32)),continue_owner(owner))
def checked_tail(n:Nat,+expected:U32,+index:U32,owner:Array<U32>) -> Bool:
  match n:
    case Zero{}: True{}
    case Succ{tail}: checked_step(expected,index,Array.get(U32,owner,index), a => checked_tail(tail,expected,(index + 1 : U32),a))
def validate_commands(commands:List<Command>,+expected:U32,valid:Bool) -> Bool:
  match commands:
    case Nil{}: Bool.and(valid,U32.is_eq(expected,1024))
    case Con{Command{owner,meta},tail}: validate_commands(tail,(expected + 1 : U32),Bool.and(valid,Bool.and(U32.is_eq(meta,(expected + 5 : U32)),checked_tail(4n,expected,0,owner))))
def validate_pings(pings:List<&2,U32>,+expected:U32,valid:Bool) -> Bool:
  match pings:
    case Nil{}: Bool.and(valid,U32.is_eq(expected,65536))
    case Con{value,tail}: validate_pings(tail,(expected + 1 : U32),Bool.and(valid,U32.is_eq(value,expected)))
def finish(result:X.Finished<World,Command,U32>) -> String:
  match result:
    case X.Committed{World{owner},commands,pings,marks}: Bool.show(Bool.and(validate_commands(commands,0,True{}),validate_pings(pings,0,True{})))
    case X.Reverted{world}: "reverted"
def main() -> String:
  finish(X.tx_finish_success(World,U32,Command,stage_pings(65536n,stage_commands(1024n,X.tx_begin(World,U32,Command,World{[7:U32^2n]},1),0),0)))
