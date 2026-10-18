import Base
import ../../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../../src/ecs/deferred-command.bend as Deferred
import ../../../../../../../src/ecs/trace-facts.bend as Trace

type Sample is Data:
  Sample{kind:String,undo:Nat,commands:Nat,events:Nat}
  NoTx{reason:String}
def count_join(~A:Type,head:A,result:List<A> & Nat) -> List<A> & Nat:
  match result:
    case (tail,count):(head <> tail,1n+count)
def count(~A:Type,values:List<A>) -> List<A> & Nat:
  match values:
    case []:([],0n)
    case head <> tail:count_join(~A,head,count(~A,tail))
def joined(~World:Type,~E:Data,kind:String,+events:List<&2,E>,trace:Trace.State,world:World,undo:List<(World->World)> & Nat,commands:List<Deferred.Command<World>> & Nat) -> Tx.Tx<World,E> & Sample:
  (undo,nu)=undo
  (commands,nc)=commands
  (Tx.Tx{world,undo,commands,events,trace},Sample{kind,nu,nc,List.length(&2,E,events)})
def observe(~World:Type,~E:Data,kind:String,tx:Tx.Tx<World,E>) -> Tx.Tx<World,E> & Sample:
  match tx:
    case Tx.Tx{world,undo,commands,events,trace}:joined(~World,~E,kind,events,trace,world,count(~(World->World),undo),count(~Deferred.Command<World>,commands))
def render(sample:Sample) -> String:
  match sample:
    case Sample{kind,undo,commands,events}:"{\"kind\":\"" ++ kind ++ "\",\"undo\":" ++ Nat.show(1n+undo) ++ ",\"commands\":" ++ Nat.show(commands) ++ ",\"events\":" ++ Nat.show(events) ++ "}"
    case NoTx{reason}:"{\"kind\":\"no-tx\",\"reason\":\"" ++ reason ++ "\"}"
def render_tail(samples:List<&2,Sample>) -> String:
  match samples:
    case []:"]"
    case head <> tail:"," ++ render(head) ++ render_tail(tail)
def render_list(samples:List<&2,Sample>) -> String:
  match samples:
    case []:"[]"
    case head <> tail:"[" ++ render(head) ++ render_tail(tail)
def report(samples:List<&2,Sample>) -> String:"{\"samples\":" ++ render_list(samples) ++ "}\n"
