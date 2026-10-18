from pathlib import Path
D=Path('/tmp/bendvy-workload-tx-boundaries/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1');p=D/'private/src/ecs/transaction.bend';s=p.read_text()
s=s.replace('Returned{world: W, outcome: Outcome<Error>}','Returned{world: W, outcome: Outcome<Error>,report:Meter.Report}')
a=s.index('def finish_world(')
helpers='''def counted_join(~A:Type,head:A,result:List<A> & Nat) -> List<A> & Nat:
  match result:
    case (tail,count):(head <> tail,1n+count)
def counted(~A:Type,values:List<A>) -> List<A> & Nat:
  match values:
    case []:([],0n)
    case head <> tail:counted_join(~A,head,counted(~A,tail))
def actual_joined(~W:Type,~E:Data,world:W,+events:List<&2,E>,trace:TraceFacts.State,+meter:Meter.State,undo:List<(W->W)> & Nat,commands:List<Deferred.Command<W>> & Nat) -> Tx<W,E> & Meter.Report:
  (undo,nu)=undo
  (commands,nc)=commands
  (Tx{world,undo,commands,events,trace,meter},Meter.report(meter,nu,nc,List.length(&2,E,events)))
def actual(~W:Type,~E:Data,tx:Tx<W,E>) -> Tx<W,E> & Meter.Report:
  match tx:
    case Tx{world,undo,commands,events,trace,meter}:actual_joined(~W,~E,world,events,trace,meter,counted(~(W->W),undo),counted(~Deferred.Command<W>,commands))

'''
s=s[:a]+helpers+s[a:]
s=s.replace('events: List<&2, E>, outcome: Outcome<Error>','events: List<&2, E>, report:Meter.Report,outcome: Outcome<Error>')
s=s.replace('Returned{publish(committed, List.reverse(&2, E, events)), Success{}}','Returned{publish(committed, List.reverse(&2, E, events)), Success{},report}')
s=s.replace('Returned{rollback(~W, undo, world), Failure{error}}','Returned{rollback(~W, undo, world), Failure{error},report}')
a=s.index('def finish(');b=s.index('def begin_observed',a)
s=s[:a]+'''def finish_actual(~W: Type, ~E: Data, ~Error: Data,
  ~enqueue: W -> List<&1,Deferred.Command<W>> -> W,
  ~publish: W -> List<&2, E> -> W,
  observed:Tx<W,E> & Meter.Report,outcome:Outcome<Error>
) -> Returned<W,Error>:
  match observed:
    case (Tx{world,undo,commands,events,trace,meter},report):finish_world(~W,~E,~Error,~enqueue,~publish,world,undo,commands,events,report,outcome)
def finish(~W: Type, ~E: Data, ~Error: Data,
  ~enqueue: W -> List<&1,Deferred.Command<W>> -> W,
  ~publish: W -> List<&2, E> -> W,
  tx: Tx<W, E>, outcome: Outcome<Error>
) -> Returned<W, Error>:finish_actual(~W,~E,~Error,~enqueue,~publish,actual(~W,~E,tx),outcome)

'''+s[b:]
a=s.index('def finish_observed(');b=s.index('def begin_with_trace',a)
s=s[:a]+'''def finish_observed_actual(~W:Type,~E:Data,~Error:Data,~enqueue:W -> List<&1,Deferred.Command<W>> -> W,~publish:W -> List<&2,E> -> W,observed:Tx<W,E> & Meter.Report,+outcome:Outcome<Error>) -> Returned<W,Error> & TraceFacts.State:
  match observed:
    case (Tx{world,undo,commands,events,trace,meter},report):(finish_world(~W,~E,~Error,~enqueue,~publish,world,undo,commands,events,report,outcome),TraceFacts.settle(trace,committed(~Error,outcome)))
def finish_observed(~W:Type,~E:Data,~Error:Data,~enqueue:W -> List<&1,Deferred.Command<W>> -> W,~publish:W -> List<&2,E> -> W,tx:Tx<W,E>,outcome:Outcome<Error>) -> Returned<W,Error> & TraceFacts.State:finish_observed_actual(~W,~E,~Error,~enqueue,~publish,actual(~W,~E,tx),outcome)

'''+s[b:]
p.write_text(s)
