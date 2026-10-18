from pathlib import Path
D=Path('/tmp/bendvy-current-tx-boundaries/experiments/s-perf/current-tx-boundaries-v1');p=D/'meter.bend';s=p.read_text();s=s.replace('State{current:Counts,peak:Counts,reverseBoundaries:List<&2,Boundary>}','State{current:Counts,peak:Counts,reverseBoundaries:List<&2,Boundary>,namespace:Maybe<&2,U32>,beginTick:Maybe<&2,U32>,endTick:Maybe<&2,U32>}');s=s.replace('Report{boundaries:List<&2,Boundary>,terminal:Counts,consistent:Bool}','Report{boundaries:List<&2,Boundary>,terminal:Counts,consistent:Bool,namespace:Maybe<&2,U32>,beginTick:Maybe<&2,U32>,endTick:Maybe<&2,U32>}');s=s.replace('Counts{0n,0n,0n},[]}', 'Counts{0n,0n,0n},[],None{},None{},None{}}');s=s.replace('rows:List<&2,Boundary>,+peak:Counts)', 'rows:List<&2,Boundary>,namespace:Maybe<&2,U32>,beginTick:Maybe<&2,U32>,endTick:Maybe<&2,U32>,+peak:Counts)');s=s.replace('State{current,peak,Boundary{site,delta,current,peak} <> rows}', 'State{current,peak,Boundary{site,delta,current,peak} <> rows,namespace,beginTick,endTick}');s=s.replace('prior:Counts,rows:List<&2,Boundary>)','prior:Counts,rows:List<&2,Boundary>,namespace:Maybe<&2,U32>,beginTick:Maybe<&2,U32>,endTick:Maybe<&2,U32>)');s=s.replace('recorded_peak(site,delta,current,rows,maxima(current,prior))','recorded_peak(site,delta,current,rows,namespace,beginTick,endTick,maxima(current,prior))');s=s.replace('State{Counts{u,c,e},peak,rows}', 'State{Counts{u,c,e},peak,rows,namespace,beginTick,endTick}');s=s.replace('},peak,rows)', '},peak,rows,namespace,beginTick,endTick)');s=s.replace('State{Counts{u,c,e},_,rows}', 'State{Counts{u,c,e},_,rows,namespace,beginTick,endTick}');s=s.replace('Nat.is_eq(e,ne)))}','Nat.is_eq(e,ne))),namespace,beginTick,endTick}');s=s.replace('def counts(value:', '''def started(state:State,namespace:U32,tick:U32) -> State:
  match state:
    case State{current,peak,rows,_,_,_}:State{current,peak,rows,Some{namespace},Some{tick},None{}}
def ended(state:State,tick:U32) -> State:
  match state:
    case State{current,peak,rows,namespace,beginTick,_}:State{current,peak,rows,namespace,beginTick,Some{tick}}
def optional(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"null"
    case Some{value}:U32.show(value)
def counts(value:''');s=s.replace('case Report{boundaries,terminal,consistent}:', 'case Report{boundaries,terminal,consistent,namespace,beginTick,endTick}:');s=s.replace('"{\\\"kind\\\":\\\"" ++ kind ++ "\\\",\\\"boundaries\\\":', '"{\\\"kind\\\":\\\"" ++ kind ++ "\\\",\\\"namespace\\\":" ++ optional(namespace) ++ ",\\\"beginTick\\\":" ++ optional(beginTick) ++ ",\\\"endTick\\\":" ++ optional(endTick) ++ ",\\\"appendTick\\\":null,\\\"boundaries\\\":');p.write_text(s)
p=D/'subject/tx-metrics.bend';s=p.read_text();s='import ../private/src/ecs/world.bend as W\n'+s;add='''
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
''';at=s.index('def render(sample:');s=s[:at]+add+s[at:];p.write_text(s)
p=D/'subject/motion.bend';s=p.read_text().replace('Tx.begin(~World(),~Nat,world)','Metrics.begin(~T.MotionSchema,~Store(),~Resources(),~Nat,world)').replace('Metrics.observe(~World(),~Nat,','Metrics.observe_world(~T.MotionSchema,~Store(),~Resources(),~Nat,');p.write_text(s)
