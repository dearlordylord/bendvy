import private/src/ecs/world.bend as W
import meter.bend as Meter
import Base
import private/src/ecs/transaction.bend as Tx
import private/src/ecs/deferred-command.bend as Deferred
import private/src/ecs/trace-facts.bend as Trace

type Sample is Data:
  Sample{kind:String,report:Meter.Report,iteration:Maybe<&2,Nat>,completion:Maybe<&2,Bool>}
  NoTx{reason:String}
def count_join(~A:Type,head:A,result:List<A> & Nat) -> List<A> & Nat:
  match result:
    case (tail,count):(head <> tail,1n+count)
def count(~A:Type,values:List<A>) -> List<A> & Nat:
  match values:
    case []:([],0n)
    case head <> tail:count_join(~A,head,count(~A,tail))
def joined(~World:Type,~E:Data,kind:String,+events:List<&2,E>,trace:Trace.State,+meter:Meter.State,world:World,undo:List<(World->World)> & Nat,commands:List<Deferred.Command<World>> & Nat) -> Tx.Tx<World,E> & Sample:
  (undo,nu)=undo
  (commands,nc)=commands
  (Tx.Tx{world,undo,commands,events,trace,meter},Sample{kind,Meter.report(meter,nu,nc,List.length(&2,E,events)),None{},None{}})
def observe(~World:Type,~E:Data,kind:String,tx:Tx.Tx<World,E>) -> Tx.Tx<World,E> & Sample:
  match tx:
    case Tx.Tx{world,undo,commands,events,trace,meter}:joined(~World,~E,kind,events,trace,meter,world,count(~(World->World),undo),count(~Deferred.Command<World>,commands))

def begin_clock(~S:Data,~C:Type,~R:Type,~E:Data,namespace:U32,observed:W.World<S,C,R,E> & U32) -> Tx.Tx<W.World<S,C,R,E>,E>:
  match observed:
    case (world,tick):Tx.Tx{world,[],[],[],Trace.Off{},Meter.started(Meter.empty(Unit{}),namespace,tick)}
def begin_namespace(~S:Data,~C:Type,~R:Type,~E:Data,observed:W.World<S,C,R,E> & U32) -> Tx.Tx<W.World<S,C,R,E>,E>:
  match observed:
    case (world,namespace):begin_clock(~S,~C,~R,~E,namespace,W.clock(~S,~C,~R,~E,world))
def begin(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>) -> Tx.Tx<W.World<S,C,R,E>,E>:begin_namespace(~S,~C,~R,~E,W.namespace(~S,~C,~R,~E,world))
def end_clock(~S:Data,~C:Type,~R:Type,~E:Data,kind:String,undo:List<(W.World<S,C,R,E>->W.World<S,C,R,E>)>,commands:List<Deferred.Command<W.World<S,C,R,E>>>,events:List<&2,E>,trace:Trace.State,meter:Meter.State,observed:W.World<S,C,R,E> & U32) -> Tx.Tx<W.World<S,C,R,E>,E> & Sample:
  match observed:
    case (world,tick):observe(~W.World<S,C,R,E>,~E,kind,Tx.Tx{world,undo,commands,events,trace,Meter.ended(meter,tick)})
def observe_world(~S:Data,~C:Type,~R:Type,~E:Data,kind:String,tx:Tx.Tx<W.World<S,C,R,E>,E>) -> Tx.Tx<W.World<S,C,R,E>,E> & Sample:
  match tx:
    case Tx.Tx{world,undo,commands,events,trace,meter}:end_clock(~S,~C,~R,~E,kind,undo,commands,events,trace,meter,W.clock(~S,~C,~R,~E,world))
def at_iteration(sample:Sample,iteration:Nat) -> Sample:
  match sample:
    case Sample{kind,report,_,completion}:Sample{kind,report,Some{iteration},completion}
    case sample:sample
def finished(sample:Sample,success:Bool) -> Sample:
  match sample:
    case Sample{kind,report,iteration,_}:Sample{kind,report,iteration,Some{success}}
    case sample:sample
def ordinal(value:Maybe<&2,Nat>) -> String:
  match value:
    case None{}:"null"
    case Some{value}:Nat.show(value)
def completion(value:Maybe<&2,Bool>) -> String:
  match value:
    case None{}:"null"
    case Some{True{}}:"\"committed\""
    case Some{False{}}:"\"discarded\""
def render(sample:Sample) -> String:
  match sample:
    case Sample{kind,report,iteration,done}:"{\"iteration\":" ++ ordinal(iteration) ++ ",\"completion\":" ++ completion(done) ++ ",\"tx\":" ++ Meter.render(kind,report) ++ "}"
    case NoTx{reason}:"{\"kind\":\"no-tx\",\"reason\":\"" ++ reason ++ "\"}"
def render_tail(samples:List<&2,Sample>) -> String:
  match samples:
    case []:"]"
    case head <> tail:"," ++ render(head) ++ render_tail(tail)
def render_list(samples:List<&2,Sample>) -> String:
  match samples:
    case []:"[]"
    case head <> tail:"[" ++ render(head) ++ render_tail(tail)
def report(count:U32,iterations:U32,samples:List<&2,Sample>) -> String:"{\"schema\":\"Motion\",\"workloadCount\":" ++ U32.show(count) ++ ",\"iterations\":" ++ U32.show(iterations) ++ ",\"frame\":null,\"reports\":" ++ render_list(samples) ++ "}\n"
