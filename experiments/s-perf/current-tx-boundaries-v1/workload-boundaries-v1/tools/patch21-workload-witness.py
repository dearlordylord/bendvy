from pathlib import Path
D=Path('/tmp/bendvy-workload-tx-boundaries/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1');p=D/'meter.bend';s=p.read_text().replace('type Report is Data:','type Witness is Data:\n  Witness{namespace:U32,tick:U32,pending:U32,events:Nat}\ntype Report is Data:').replace('Report{boundaries:List<&2,Boundary>,terminal:Counts,consistent:Bool,namespace:Maybe<&2,U32>,beginTick:Maybe<&2,U32>,endTick:Maybe<&2,U32>}','Report{boundaries:List<&2,Boundary>,terminal:Counts,consistent:Bool,namespace:Maybe<&2,U32>,beginTick:Maybe<&2,U32>,endTick:Maybe<&2,U32>,returned:Maybe<&2,Witness>}')
s=s.replace('namespace,beginTick,endTick}\ndef started','namespace,beginTick,endTick,None{}}\ndef started')
s=s.replace('case Report{boundaries,terminal,consistent,namespace,beginTick,endTick}:','case Report{boundaries,terminal,consistent,namespace,beginTick,endTick,returned}:')
s=s.replace('++ boolean(consistent) ++ "}"','++ boolean(consistent) ++ ",\\\"returnedWorld\\\":" ++ witness(returned) ++ "}"')
a=s.index('def render(kind:')
s=s[:a]+'''def witness(value:Maybe<&2,Witness>) -> String:
  match value:
    case None{}:"null"
    case Some{Witness{namespace,tick,pending,events}}:"{\\\"namespace\\\":" ++ U32.show(namespace) ++ ",\\\"tick\\\":" ++ U32.show(tick) ++ ",\\\"pending\\\":" ++ U32.show(pending) ++ ",\\\"events\\\":" ++ Nat.show(events) ++ "}"
def settled(report:Report,value:Witness) -> Report:
  match report:
    case Report{boundaries,terminal,consistent,namespace,beginTick,endTick,_}:Report{boundaries,terminal,consistent,namespace,beginTick,endTick,Some{value}}
'''+s[a:];p.write_text(s)
p=D/'private/src/ecs/commands.bend';s=p.read_text();a=s.index('def tx_finish(');b=s.index('def spawned(',a)
s=s[:a]+'''def meter_begin_clock(~S:Data,~C:Type,~R:Type,~E:Data,namespace:U32,observed:W.World<S,C,R,E> & U32) -> T.Tx<W.World<S,C,R,E>,E>:
  match observed:
    case (world,tick):T.Tx{world,[],[],[],TraceFacts.Off{},Meter.started(Meter.empty(Unit{}),namespace,tick)}
def meter_begin_namespace(~S:Data,~C:Type,~R:Type,~E:Data,observed:W.World<S,C,R,E> & U32) -> T.Tx<W.World<S,C,R,E>,E>:
  match observed:
    case (world,namespace):meter_begin_clock(~S,~C,~R,~E,namespace,W.clock(~S,~C,~R,~E,world))
def tx_begin(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>) -> T.Tx<W.World<S,C,R,E>,E>:meter_begin_namespace(~S,~C,~R,~E,W.namespace(~S,~C,~R,~E,world))
def meter_end_clock(~S:Data,~C:Type,~R:Type,~E:Data,undo:List<(W.World<S,C,R,E>->W.World<S,C,R,E>)>,commands:List<Deferred.Command<W.World<S,C,R,E>>>,events:List<&2,E>,trace:TraceFacts.State,meter:Meter.State,observed:W.World<S,C,R,E> & U32) -> T.Tx<W.World<S,C,R,E>,E>:
  match observed:
    case (world,tick):T.Tx{world,undo,commands,events,trace,Meter.ended(meter,tick)}
def meter_end(~S:Data,~C:Type,~R:Type,~E:Data,tx:T.Tx<W.World<S,C,R,E>,E>) -> T.Tx<W.World<S,C,R,E>,E>:
  match tx:
    case T.Tx{world,undo,commands,events,trace,meter}:meter_end_clock(~S,~C,~R,~E,undo,commands,events,trace,meter,W.clock(~S,~C,~R,~E,world))
def meter_returned_events(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,outcome:T.Outcome<Error>,report:Meter.Report,namespace:U32,tick:U32,pending:U32,observed:W.World<S,C,R,E> & List<&2,E>) -> T.Returned<W.World<S,C,R,E>,Error>:
  match observed:
    case (world,events):T.Returned{world,outcome,Meter.settled(report,Meter.Witness{namespace,tick,pending,List.length(&2,E,events)})}
def meter_returned_pending(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,outcome:T.Outcome<Error>,report:Meter.Report,namespace:U32,tick:U32,observed:W.World<S,C,R,E> & U32) -> T.Returned<W.World<S,C,R,E>,Error>:
  match observed:
    case (world,pending):meter_returned_events(~S,~C,~R,~E,~Error,outcome,report,namespace,tick,pending,W.events_view(~S,~C,~R,~E,world))
def meter_returned_clock(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,outcome:T.Outcome<Error>,report:Meter.Report,namespace:U32,observed:W.World<S,C,R,E> & U32) -> T.Returned<W.World<S,C,R,E>,Error>:
  match observed:
    case (world,tick):meter_returned_pending(~S,~C,~R,~E,~Error,outcome,report,namespace,tick,W.pending_count(~S,~C,~R,~E,world))
def meter_returned_namespace(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,outcome:T.Outcome<Error>,report:Meter.Report,observed:W.World<S,C,R,E> & U32) -> T.Returned<W.World<S,C,R,E>,Error>:
  match observed:
    case (world,namespace):meter_returned_clock(~S,~C,~R,~E,~Error,outcome,report,namespace,W.clock(~S,~C,~R,~E,world))
def meter_returned(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,result:T.Returned<W.World<S,C,R,E>,Error>) -> T.Returned<W.World<S,C,R,E>,Error>:
  match result:
    case T.Returned{world,outcome,report}:meter_returned_namespace(~S,~C,~R,~E,~Error,outcome,report,W.namespace(~S,~C,~R,~E,world))
def tx_finish(~S: Data,~C: Type,~R: Type,~E: Data,~Error: Data,tx: T.Tx<W.World<S,C,R,E>,E>,outcome: T.Outcome<Error>) -> T.Returned<W.World<S,C,R,E>,Error>:
  meter_returned(~S,~C,~R,~E,~Error,T.finish(~W.World<S,C,R,E>,~E,~Error,~enqueue(~S,~C,~R,~E),~publish(~S,~C,~R,~E),meter_end(~S,~C,~R,~E,tx),outcome))

'''+s[b:];p.write_text(s)
