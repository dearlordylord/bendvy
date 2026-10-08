import Base
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/system.bend as Sy
import logs.bend as Logs
import frame.bend as Frames
import component.bend as Lookup
import ../despawn-publication.bend as Despawn
import ../query-consumer.bend as A
import ../../../../src/ecs/inspector.bend as I
import ../joint.bend as J
import ../../../../src/ecs/inspector-query-projection.bend as Q
import ../removal-log.bend as L
import ../removal-frame.bend as F
import ../removal-transport.bend as T
import ../removal-publication.bend as P
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/component.bend as C
import ../../../../src/ecs/removals.bend as Rm
import ../../../../src/ecs/reader-domains.bend as D
import ../../../../src/ecs/event-runtime.bend as Ev
import ../../../../src/ecs/capabilities.bend as Cap

type Family is Data:
  Stock{}
type Message is Data:
  Ordinary{value:U32}
  Removal{notice:P.Notice<A.Schema,Family>}
def retaining_runner(world:W.World<A.Schema,A.Store,A.Resource,Message>,args:Bool) -> Sy.Outcome<W.World<A.Schema,A.Store,A.Resource,Message>,U32,Unit>:
  match args:
    case True{}:Sy.Failed{world,71}
    case False{}:Sy.Succeeded{world,Unit{}}
type Holders is Type:
  Holders{removed:Sy.Registry<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>,despawned:Sy.Registry<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>}
type Lifecycle is Data:
  Lifecycle{removed:L.Reading<A.Schema,Family>,despawned:L.Reading<A.Schema,Family>}
type Reads<-H:Type> is Type:
  Reads{lookup:I.Lookup<H,A.Schema,List<&2,U32>>,rows:Cap.ValueRead<H,List<&2,Q.Row<A.Schema,List<&2,U32>>>>,score:Cap.ValueRead<H,List<&2,U32>>,events:Cap.ValueRead<H,Ev.Reading<Message>>,removed:Cap.ValueRead<H,Lifecycle>}
type Snapshot is Data:
  Snapshot{lookup:I.Value<List<&2,U32>>,rows:List<&2,Q.Row<A.Schema,List<&2,U32>>>,score:List<&2,U32>,events:Ev.Reading<Message>,removed:Lifecycle}
type State is Type:
  State{target:W.Handle<A.Schema>,world:W.World<A.Schema,A.Store,A.Resource,Message>,events:D.Events<A.Schema,Message>,log:Logs.Streams<A.Schema,Family,Holders>,instance:J.Instance<A.Schema>}
def encode(notice:P.Notice<A.Schema,Family>) -> Message:
  Removal{notice}
def clear_done(+handle:W.Handle<A.Schema>,result:Col.SwapOutcome<A.Schema,A.Payload>) -> A.Store & List<&2,Rm.Record<A.Schema,Family>>:
  match result:
    case Col.Accepted{column,None{}}:(A.Store{column},[])
    case Col.Accepted{column,Some{_}}:(A.Store{column},[Rm.Removed{handle,Stock{}}])
    case Col.Rejected{column,_}:(A.Store{column},[])
def clear(store:A.Store,handle:W.Handle<A.Schema>) -> A.Store & List<&2,Rm.Record<A.Schema,Family>>:
  match store handle:
    case A.Store{column},W.Handle{_,+id}:clear_done(handle,Col.clear(~A.Schema,~A.Payload,column,id))
def read_despawned(removed:L.Reading<A.Schema,Family>,result:Logs.Streams<A.Schema,Family,Holders> & L.Reading<A.Schema,Family>) -> Logs.Streams<A.Schema,Family,Holders> & Lifecycle:
  (logs,despawned)=result
  (logs,Lifecycle{removed,despawned})
def read_removed(+cursor:U32,+registered:U32,result:Logs.Streams<A.Schema,Family,Holders> & L.Reading<A.Schema,Family>) -> Logs.Streams<A.Schema,Family,Holders> & Lifecycle:
  (logs,removed)=result
  read_despawned(removed,Logs.read_despawned(~A.Schema,~Family,~Holders,logs,cursor,registered))
def read_log(logs:Logs.Streams<A.Schema,Family,Holders>,+cursor:U32,+registered:U32) -> Logs.Streams<A.Schema,Family,Holders> & Lifecycle:
  read_removed(cursor,registered,Logs.read_removed(~A.Schema,~Family,~Holders,logs,cursor,registered))
def query_join(events:D.Events<A.Schema,Message>,log:Logs.Streams<A.Schema,Family,Holders>,cursor:U32,registered:U32,ec:Nat,er:Nat,result:I.Frame<A.Schema,A.Store,A.Resource,Message> & List<&2,Q.Row<A.Schema,List<&2,U32>>>) -> J.Frame<A.Schema,A.Store,A.Resource,Message,Logs.Streams<A.Schema,Family,Holders>> & List<&2,Q.Row<A.Schema,List<&2,U32>>>:
  match result:
    case (I.Frame{world,_},rows):(J.Frame{world,events,log,cursor,registered,ec,er},rows)
def read_query(frame:J.Frame<A.Schema,A.Store,A.Resource,Message,Logs.Streams<A.Schema,Family,Holders>>) -> J.Frame<A.Schema,A.Store,A.Resource,Message,Logs.Streams<A.Schema,Family,Holders>> & List<&2,Q.Row<A.Schema,List<&2,U32>>>:
  match frame:
    case J.Frame{world,events,log,+cursor,registered,ec,er}:query_join(events,log,cursor,registered,ec,er,Q.scan(~A.Schema,~A.Store,~A.Resource,~Message,~Unit,~A.Payload,~List<&2,U32>,~A.Token,~A.take,~A.put,~A.project,~A.family(),~Q.Required{},I.Frame{world,cursor}))
def score_join(events:D.Events<A.Schema,Message>,log:Logs.Streams<A.Schema,Family,Holders>,cursor:U32,registered:U32,ec:Nat,er:Nat,result:W.World<A.Schema,A.Store,A.Resource,Message> & List<&2,U32>) -> J.Frame<A.Schema,A.Store,A.Resource,Message,Logs.Streams<A.Schema,Family,Holders>> & List<&2,U32>:
  (world,cells)=result
  (J.Frame{world,events,log,cursor,registered,ec,er},cells)
def read_score(frame:J.Frame<A.Schema,A.Store,A.Resource,Message,Logs.Streams<A.Schema,Family,Holders>>) -> J.Frame<A.Schema,A.Store,A.Resource,Message,Logs.Streams<A.Schema,Family,Holders>> & List<&2,U32>:
  match frame:
    case J.Frame{world,events,log,cursor,registered,ec,er}:score_join(events,log,cursor,registered,ec,er,W.observe_resource(~A.Schema,~A.Store,~A.Resource,~Message,~List<&2,U32>,~A.project_resource,world))
def Ops(H:Type) -> Type:
  Reads<H>
def plan() -> J.Plan<A.Schema,A.Store,A.Resource,Message,Logs.Streams<A.Schema,Family,Holders>,Ops>:
  J.Plan{Reads{Lookup.grant(~A.Schema,~A.Store,~A.Resource,~Message,~Logs.Streams<A.Schema,Family,Holders>,~Unit,~A.Payload,~List<&2,U32>,~A.Token,~A.take,~A.put,~A.project,~A.family()),Cap.ValueRead{frame => read_query(frame)},Cap.ValueRead{frame => read_score(frame)},J.event_grant(~A.Schema,~A.Store,~A.Resource,~Message,~Logs.Streams<A.Schema,Family,Holders>),J.logs_grant(~A.Schema,~A.Store,~A.Resource,~Message,~Logs.Streams<A.Schema,Family,Holders>,~Lifecycle,~(logs => cursor => registered => read_log(logs,cursor,registered)))}}
def rows_cap(~H:Type,caps:Reads<H>) -> Cap.ValueRead<H,List<&2,Q.Row<A.Schema,List<&2,U32>>>>:
  match caps:
    case Reads{_,rows,_,_,_}:rows
def score_cap(~H:Type,caps:Reads<H>) -> Cap.ValueRead<H,List<&2,U32>>:
  match caps:
    case Reads{_,_,score,_,_}:score
def events_cap(~H:Type,caps:Reads<H>) -> Cap.ValueRead<H,Ev.Reading<Message>>:
  match caps:
    case Reads{_,_,_,events,_}:events
def removed_cap(~H:Type,caps:Reads<H>) -> Cap.ValueRead<H,Lifecycle>:
  match caps:
    case Reads{_,_,_,_,removed}:removed
def conclude(~H:Type,fail:Bool,lookup:I.Value<List<&2,U32>>,rows:List<&2,Q.Row<A.Schema,List<&2,U32>>>,score:List<&2,U32>,events:Ev.Reading<Message>,result:H & Lifecycle) -> H & Result<&2,&2,Snapshot,Snapshot>:
  match fail result:
    case True{},(ctx,removed):(ctx,Fail{Snapshot{lookup,rows,score,events,removed}})
    case False{},(ctx,removed):(ctx,Done{Snapshot{lookup,rows,score,events,removed}})
def got_events(~H:Type,~caps:Reads<H>,fail:Bool,lookup:I.Value<List<&2,U32>>,rows:List<&2,Q.Row<A.Schema,List<&2,U32>>>,score:List<&2,U32>,result:H & Ev.Reading<Message>) -> H & Result<&2,&2,Snapshot,Snapshot>:
  (ctx,events)=result
  conclude(~H,fail,lookup,rows,score,events,Cap.value_read(~H,~Lifecycle,~removed_cap(~H,caps),ctx))
def got_score(~H:Type,~caps:Reads<H>,fail:Bool,lookup:I.Value<List<&2,U32>>,rows:List<&2,Q.Row<A.Schema,List<&2,U32>>>,result:H & List<&2,U32>) -> H & Result<&2,&2,Snapshot,Snapshot>:
  (ctx,score)=result
  got_events(~H,~caps,fail,lookup,rows,score,Cap.value_read(~H,~Ev.Reading<Message>,~events_cap(~H,caps),ctx))
def got_rows(~H:Type,~caps:Reads<H>,fail:Bool,lookup:I.Value<List<&2,U32>>,result:H & List<&2,Q.Row<A.Schema,List<&2,U32>>>) -> H & Result<&2,&2,Snapshot,Snapshot>:
  (ctx,rows)=result
  got_score(~H,~caps,fail,lookup,rows,Cap.value_read(~H,~List<&2,U32>,~score_cap(~H,caps),ctx))
type Args is Data:
  Args{target:W.Handle<A.Schema>,fail:Bool}
def lookup_cap(~H:Type,caps:Reads<H>) -> I.Lookup<H,A.Schema,List<&2,U32>>:
  match caps:
    case Reads{lookup,_,_,_,_}:lookup
def got_lookup(~H:Type,~caps:Reads<H>,fail:Bool,result:H & I.Value<List<&2,U32>>) -> H & Result<&2,&2,Snapshot,Snapshot>:
  (ctx,lookup)=result
  got_rows(~H,~caps,fail,lookup,Cap.value_read(~H,~List<&2,Q.Row<A.Schema,List<&2,U32>>>,~rows_cap(~H,caps),ctx))
def observe(~H:Type,~caps:Reads<H>,args:Args,ctx:H) -> H & Result<&2,&2,Snapshot,Snapshot>:
  match args:
    case Args{target,fail}:got_lookup(~H,~caps,fail,I.lookup(~H,~A.Schema,~List<&2,U32>,~lookup_cap(~H,caps),ctx,target))
def shown_row(row:Q.Row<A.Schema,List<&2,U32>>) -> String:
  match row:
    case Q.Row{W.Handle{_,id},I.Value{value,added,changed}}:U32.show(id) ++ ":" ++ A.access(value) ++ "/" ++ Bool.show(added) ++ "/" ++ Bool.show(changed)
def shown_event(value:Message) -> String:
  match value:
    case Ordinary{value}:U32.show(value)
    case Removal{P.Notice{tick,_}}:"unexpected-removal:" ++ U32.show(tick)
def shown_removed(record:Rm.Record<A.Schema,Family>) -> String:
  match record:
    case Rm.Removed{W.Handle{_,id},_}:U32.show(id)
    case Rm.Despawned{W.Handle{_,id}}:"despawn:" ++ U32.show(id)
def lookup_text(value:I.Value<List<&2,U32>>) -> String:
  match value:
    case I.Value{access,added,changed}:A.access(access) ++ "/" ++ Bool.show(added) ++ "/" ++ Bool.show(changed)
def snapshot(value:Snapshot) -> String:
  match value:
    case Snapshot{lookup,rows,score,Ev.Reading{events,eventLag},Lifecycle{L.Reading{removed,removalLag},L.Reading{despawned,despawnLag}}}:"lookup=" ++ lookup_text(lookup) ++ "|rows=" ++ List.show(&2,Q.Row<A.Schema,List<&2,U32>>,shown_row,rows) ++ "|score=" ++ List.show(&2,U32,U32.show,score) ++ "|events=" ++ List.show(&2,Message,shown_event,events) ++ "/" ++ Bool.show(eventLag) ++ "|removed=" ++ List.show(&2,Rm.Record<A.Schema,Family>,shown_removed,removed) ++ "/" ++ Bool.show(removalLag) ++ "|despawned=" ++ List.show(&2,Rm.Record<A.Schema,Family>,shown_removed,despawned) ++ "/" ++ Bool.show(despawnLag)
def shown_result(result:Result<&2,&2,Snapshot,Snapshot>) -> String:
  match result:
    case Fail{value}:"fail:" ++ snapshot(value)
    case Done{value}:"success:" ++ snapshot(value)
def show_instance(value:J.Instance<A.Schema>) -> J.Instance<A.Schema> & String:
  match value:
    case J.Fresh{}:(J.Fresh{},"fresh")
    case J.Active{+cursor,+registered,+ec,+er}:(J.Active{cursor,registered,ec,er},U32.show(cursor) ++ "/" ++ U32.show(registered) ++ "/" ++ Nat.show(ec) ++ "/" ++ Nat.show(er))
def instanced(+target:W.Handle<A.Schema>,world:W.World<A.Schema,A.Store,A.Resource,Message>,events:D.Events<A.Schema,Message>,log:Logs.Streams<A.Schema,Family,Holders>,text:String,result:J.Instance<A.Schema> & String) -> State & String:
  (instance,cursor)=result
  (State{target,world,events,log,instance},text ++ "|cursor=" ++ cursor ++ "\n")
def holder_despawned(removed:Sy.Registry<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>,cursor:U32,result:Sy.Registry<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner> & U32) -> Holders & Logs.Positions:
  (despawned,despawnCursor)=result
  (Holders{removed,despawned},Logs.Positions{[cursor],[despawnCursor]})
def holder_removed(despawned:Sy.Registry<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>,result:Sy.Registry<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner> & U32) -> Holders & Logs.Positions:
  (removed,cursor)=result
  holder_despawned(removed,cursor,Sy.cursor(~A.Schema,~A.Store,~A.Resource,~Message,~Bool,~U32,~Unit,~retaining_runner,despawned))
def no_positions(holders:Holders) -> Holders & Logs.Positions:
  match holders:
    case Holders{removed,despawned}:holder_removed(despawned,Sy.cursor(~A.Schema,~A.Store,~A.Resource,~Message,~Bool,~U32,~Unit,~retaining_runner,removed))
def retained_positions(removed:L.Log<A.Schema,Family,Unit>,despawned:L.Log<A.Schema,Family,Unit>,result:Holders & Logs.Positions) -> Logs.Streams<A.Schema,Family,Holders> & String:
  match result:
    case (holders,Logs.Positions{removedCursors,despawnedCursors}):(Logs.Streams{holders,removed,despawned},"|retainers=" ++ List.show(&2,U32,U32.show,removedCursors) ++ "/" ++ List.show(&2,U32,U32.show,despawnedCursors))
def retaining_snapshot(logs:Logs.Streams<A.Schema,Family,Holders>) -> Logs.Streams<A.Schema,Family,Holders> & String:
  match logs:
    case Logs.Streams{holders,removed,despawned}:retained_positions(removed,despawned,no_positions(holders))
def observed_logs(+target:W.Handle<A.Schema>,world:W.World<A.Schema,A.Store,A.Resource,Message>,events:D.Events<A.Schema,Message>,instance:J.Instance<A.Schema>,value:Result<&2,&2,Snapshot,Snapshot>,result:Logs.Streams<A.Schema,Family,Holders> & String) -> State & String:
  (log,holders)=result
  instanced(target,world,events,log,shown_result(value) ++ holders,show_instance(instance))
def observed(+target:W.Handle<A.Schema>,result:J.Observed<A.Schema,A.Store,A.Resource,Message,Logs.Streams<A.Schema,Family,Holders>,Snapshot,Snapshot>) -> State & String:
  match result:
    case J.Observed{world,events,log,instance,value}:observed_logs(target,world,events,instance,value,retaining_snapshot(log))
def is_event(value:Message) -> Bool:
  match value:
    case Ordinary{_}:True{}
    case Removal{_}:False{}
def select(value:Message) -> Maybe<&2,P.Notice<A.Schema,Family>>:
  match value:
    case Ordinary{_}:None{}
    case Removal{notice}:Some{notice}
def absorb(log:Logs.Streams<A.Schema,Family,Holders>,values:List<&2,Message>) -> Logs.Streams<A.Schema,Family,Holders>:
  Logs.append(~A.Schema,~Family,~Holders,log,T.notices(~A.Schema,~Family,~Message,~select,values))
def last(lines:String,result:State & String) -> String:
  (_,text)=result
  lines ++ text
def repeated(lines:String,result:State & String) -> String:
  match result:
    case (State{+target,world,events,log,instance},text):last(lines ++ text,observed(target,J.run(~A.Schema,~A.Store,~A.Resource,~Message,~Logs.Streams<A.Schema,Family,Holders>,~Ops,~Args,~Snapshot,~Snapshot,~plan(),~observe,instance,Args{target,False{}},world,events,log)))
def disposed_logs(lines:String,removed:L.Log<A.Schema,Family,Unit>,despawned:L.Log<A.Schema,Family,Unit>) -> String:
  match removed despawned:
    case L.Log{_,removed,rd,_} L.Log{_,despawned,dd,_}:lines ++ "disposed|counts=" ++ Nat.show(L.count(~A.Schema,~Family,removed)) ++ "/" ++ Nat.show(L.count(~A.Schema,~Family,despawned)) ++ "|drops=" ++ U32.show(rd) ++ "/" ++ U32.show(dd) ++ "\n"
# Actual successful system execution and disposal, never fixture cursor edits.
def shown_logs(label:String,result:Logs.Streams<A.Schema,Family,Holders>) -> Logs.Streams<A.Schema,Family,Holders> & String:
  match result:
    case Logs.Streams{holders,L.Log{owner,+removed,+rd,+rc},L.Log{dholder,+despawned,+dd,+dc}}:(Logs.Streams{holders,L.Log{owner,removed,rd,rc},L.Log{dholder,despawned,dd,dc}},label ++ "|counts=" ++ Nat.show(L.count(~A.Schema,~Family,removed)) ++ "/" ++ Nat.show(L.count(~A.Schema,~Family,despawned)) ++ "|drops=" ++ U32.show(rd) ++ "/" ++ U32.show(dd) ++ "\n")
def disposed_two(lines:String,removed:L.Log<A.Schema,Family,Unit>,despawned:L.Log<A.Schema,Family,Unit>,result:Sy.Disposal<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>) -> String:
  match result:
    case Sy.Disposed{_}:disposed_logs(lines,Logs.trim_log(~A.Schema,~Family,[],100,removed),Logs.trim_log(~A.Schema,~Family,[],100,despawned))
    case Sy.DisposalRejected{_,_}:"disposal rejected"
def disposed_one(lines:String,removed:L.Log<A.Schema,Family,Unit>,despawned:L.Log<A.Schema,Family,Unit>,second:Sy.Registry<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>,result:Sy.Disposal<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>) -> String:
  match result:
    case Sy.Disposed{world}:disposed_two(lines,removed,despawned,Sy.dispose(~A.Schema,~A.Store,~A.Resource,~Message,~Bool,~U32,~Unit,~retaining_runner,second,world))
    case Sy.DisposalRejected{_,_}:"disposal rejected"
def dispose_state(lines:String,world:W.World<A.Schema,A.Store,A.Resource,Message>,result:Logs.Streams<A.Schema,Family,Holders> & String) -> String:
  match result:
    case (Logs.Streams{Holders{removedHolder,despawnedHolder},removed,despawned},text):disposed_one(lines ++ text,removed,despawned,despawnedHolder,Sy.dispose(~A.Schema,~A.Store,~A.Resource,~Message,~Bool,~U32,~Unit,~retaining_runner,removedHolder,world))
def advanced_removed(lines:String,despawned:Sy.Registry<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>,removed:L.Log<A.Schema,Family,Unit>,dlog:L.Log<A.Schema,Family,Unit>,result:Sy.RunResult<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>) -> String:
  match result:
    case Sy.Completed{registry,Sy.Succeeded{world,_}}:dispose_state(lines,world,shown_logs("advanced-removed",Logs.trim(~A.Schema,~Family,~Holders,~no_positions,100,Logs.Streams{Holders{registry,despawned},removed,dlog})))
    case Sy.Completed{_,Sy.Failed{_,_}}:"retainer failed"
    case Sy.RegistrationRejected{_,_,_}:"retainer rejected"
def advance_retainer(lines:String,world:W.World<A.Schema,A.Store,A.Resource,Message>,result:Logs.Streams<A.Schema,Family,Holders> & String) -> String:
  match result:
    case (Logs.Streams{Holders{removedHolder,despawnedHolder},removed,despawned},text):advanced_removed(lines ++ text,despawnedHolder,removed,despawned,Sy.run_tracked(~A.Schema,~A.Store,~A.Resource,~Message,~Bool,~U32,~Unit,~retaining_runner,removedHolder,world,False{}))
def control_positions(label:String,result:Logs.Streams<A.Schema,Family,Holders> & String) -> Logs.Streams<A.Schema,Family,Holders> & String:
  (logs,text)=result
  (logs,label ++ text ++ "\n")
def control_log(label:String,logs:Logs.Streams<A.Schema,Family,Holders>) -> Logs.Streams<A.Schema,Family,Holders> & String:
  control_positions(label,retaining_snapshot(logs))
def combined_control(text:String,result:Logs.Streams<A.Schema,Family,Holders> & String) -> Logs.Streams<A.Schema,Family,Holders> & String:
  (logs,cursors)=result
  (logs,text ++ cursors)
def controlled(result:Logs.Streams<A.Schema,Family,Holders> & String) -> Logs.Streams<A.Schema,Family,Holders> & String:
  (logs,text)=result
  combined_control(text,control_log("control-cursors",logs))
# A false schedule condition returns the actual affine registered owner untouched.
def skip_owner(holders:Holders,world:W.World<A.Schema,A.Store,A.Resource,Message>,id:U32) -> Holders & W.World<A.Schema,A.Store,A.Resource,Message>:
  (holders,world)
def fail_dispatch_result(despawned:Sy.Registry<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>,result:Sy.RunResult<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>) -> Holders & Sy.Outcome<W.World<A.Schema,A.Store,A.Resource,Message>,U32,Unit>:
  match result:
    case Sy.Completed{removed,outcome}:(Holders{removed,despawned},outcome)
    case Sy.RegistrationRejected{removed,world,_}:(Holders{removed,despawned},Sy.Failed{world,99})
def fail_dispatch(holders:Holders,world:W.World<A.Schema,A.Store,A.Resource,Message>,id:U32) -> Holders & Sy.Outcome<W.World<A.Schema,A.Store,A.Resource,Message>,U32,Unit>:
  match holders:
    case Holders{removed,despawned}:fail_dispatch_result(despawned,Sy.run_tracked(~A.Schema,~A.Store,~A.Resource,~Message,~Bool,~U32,~Unit,~retaining_runner,removed,world,True{}))
def false_condition(world:W.World<A.Schema,A.Store,A.Resource,Message>,slot:U32) -> W.World<A.Schema,A.Store,A.Resource,Message> & Bool:
  (world,False{})
def skipped(lines:String,removed:L.Log<A.Schema,Family,Unit>,despawned:L.Log<A.Schema,Family,Unit>,result:Sch.RunResult<A.Schema,A.Store,A.Resource,Message,Holders,U32>) -> String:
  match result:
    case Sch.Finished{Sch.Schedule{_,_,_,holders},world,[Sch.Skipped{_}]}:advance_retainer(lines,world,controlled(shown_logs("actual-skipped",Logs.trim(~A.Schema,~Family,~Holders,~no_positions,100,Logs.Streams{holders,removed,despawned}))))
    case _:"schedule skip did not execute"
def built_skip(lines:String,removed:L.Log<A.Schema,Family,Unit>,despawned:L.Log<A.Schema,Family,Unit>,world:W.World<A.Schema,A.Store,A.Resource,Message>,result:Sch.Build<A.Schema,A.Store,A.Resource,Message,Holders>) -> String:
  match result:
    case Sch.Built{schedule}:skipped(lines,removed,despawned,Sch.run_with_skip(~A.Schema,~A.Store,~A.Resource,~Message,~Holders,~U32,~skip_owner,~fail_dispatch,~false_condition,schedule,world))
    case _:"schedule build rejected"
def named_skip(lines:String,removed:L.Log<A.Schema,Family,Unit>,despawned:L.Log<A.Schema,Family,Unit>,holders:Holders,+id:U32,result:W.World<A.Schema,A.Store,A.Resource,Message> & U32) -> String:
  (world,namespace)=result
  built_skip(lines,removed,despawned,world,Sch.build(~A.Schema,~A.Store,~A.Resource,~Message,~Holders,namespace,"ActualSkip",[Sch.System{id,0}],[id],holders))
def identified_skip(lines:String,removed:L.Log<A.Schema,Family,Unit>,despawned:L.Log<A.Schema,Family,Unit>,despawnedHolder:Sy.Registry<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>,world:W.World<A.Schema,A.Store,A.Resource,Message>,result:Sy.Registry<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner> & U32) -> String:
  (removedHolder,id)=result
  named_skip(lines,removed,despawned,Holders{removedHolder,despawnedHolder},id,W.namespace(~A.Schema,~A.Store,~A.Resource,~Message,world))
def skip_retainer(lines:String,world:W.World<A.Schema,A.Store,A.Resource,Message>,result:Logs.Streams<A.Schema,Family,Holders> & String) -> String:
  match result:
    case (Logs.Streams{Holders{removedHolder,despawnedHolder},removed,despawned},text):identified_skip(lines ++ text,removed,despawned,despawnedHolder,world,Sy.identity(~A.Schema,~A.Store,~A.Resource,~Message,~Bool,~U32,~Unit,~retaining_runner,removedHolder))
def failed_retainer(lines:String,despawnedHolder:Sy.Registry<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>,removed:L.Log<A.Schema,Family,Unit>,despawned:L.Log<A.Schema,Family,Unit>,result:Sy.RunResult<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>) -> String:
  match result:
    case Sy.Completed{registry,Sy.Failed{world,71}}:skip_retainer(lines,world,controlled(shown_logs("actual-failed",Logs.trim(~A.Schema,~Family,~Holders,~no_positions,100,Logs.Streams{Holders{registry,despawnedHolder},removed,despawned}))))
    case _:"actual failure missing"
def fail_retainer(lines:String,world:W.World<A.Schema,A.Store,A.Resource,Message>,result:Logs.Streams<A.Schema,Family,Holders> & String) -> String:
  match result:
    case (Logs.Streams{Holders{removedHolder,despawnedHolder},removed,despawned},text):failed_retainer(lines ++ text,despawnedHolder,removed,despawned,Sy.run_tracked(~A.Schema,~A.Store,~A.Resource,~Message,~Bool,~U32,~Unit,~retaining_runner,removedHolder,world,True{}))
def after_frames(+target:W.Handle<A.Schema>,instance:J.Instance<A.Schema>,lines:String,result:T.Collected<A.Schema,A.Store,A.Resource,Message,Logs.Streams<A.Schema,Family,Holders>>) -> String:
  match result:
    case T.Collected{world,events,log}:fail_retainer(lines,world,shown_logs("before-run",Logs.trim(~A.Schema,~Family,~Holders,~no_positions,100,log)))
def frame_removed(continue:F.FrameWindow -> T.Collected<A.Schema,A.Store,A.Resource,Message,Logs.Streams<A.Schema,Family,Holders>> -> String,events:D.Events<A.Schema,Message>,result:Frames.Framed<A.Schema,A.Store,A.Resource,Message,Family,Holders>) -> String:
  match result:
    case Frames.Framed{world,window,log}:continue(window,T.recover(~A.Schema,~A.Store,~A.Resource,~Message,~Logs.Streams<A.Schema,Family,Holders>,~is_event,~absorb,Ev.frame(~A.Schema,~A.Store,~A.Resource,~Message,D.attach(~A.Schema,~A.Store,~A.Resource,~Message,events,world)),log))
def framed_events(remaining:Nat,+target:W.Handle<A.Schema>,instance:J.Instance<A.Schema>,lines:String,window:F.FrameWindow,result:T.Collected<A.Schema,A.Store,A.Resource,Message,Logs.Streams<A.Schema,Family,Holders>>) -> String:
  match remaining result:
    case 0n,result:after_frames(target,instance,lines,result)
    case 1n+p,T.Collected{world,events,log}:frame_removed(window => result => framed_events(p,target,instance,lines,window,result),events,Frames.frame(~A.Schema,~A.Store,~A.Resource,~Message,~Family,~Holders,~no_positions,window,log,world))
def failure_next(lines:String,result:State & String) -> String:
  match result:
    case (State{+target,world,events,log,instance},text):frame_removed(window => result => framed_events(1n,target,instance,lines ++ text,window,result),events,Frames.frame(~A.Schema,~A.Store,~A.Resource,~Message,~Family,~Holders,~no_positions,F.start(),log,world))
def published(+target:W.Handle<A.Schema>,instance:J.Instance<A.Schema>,lines:String,result:T.Collected<A.Schema,A.Store,A.Resource,Message,Logs.Streams<A.Schema,Family,Holders>>) -> String:
  match result:
    case T.Collected{world,events,log}:failure_next(lines,observed(target,J.run(~A.Schema,~A.Store,~A.Resource,~Message,~Logs.Streams<A.Schema,Family,Holders>,~Ops,~Args,~Snapshot,~Snapshot,~plan(),~observe,instance,Args{target,True{}},world,events,log)))
def queued(world:W.World<A.Schema,A.Store,A.Resource,Message>) -> W.World<A.Schema,A.Store,A.Resource,Message>:
  W.enqueue(~A.Schema,~A.Store,~A.Resource,~Message,world,w => W.event_publish(~A.Schema,~A.Store,~A.Resource,~Message,w,[Ordinary{31},Ordinary{32}]))
def enqueue_despawn(world:W.World<A.Schema,A.Store,A.Resource,Message>,+target:W.Handle<A.Schema>) -> W.World<A.Schema,A.Store,A.Resource,Message>:
  W.enqueue(~A.Schema,~A.Store,~A.Resource,~Message,world,w => Despawn.despawn(~A.Schema,~A.Store,~A.Resource,~Message,~Family,~clear,~encode,w,target))
def warm_next(result:State & String) -> String:
  match result:
    case (State{+target,world,events,log,instance},lines):published(target,instance,lines,T.collect(~A.Schema,~A.Store,~A.Resource,~Message,~Logs.Streams<A.Schema,Family,Holders>,~is_event,~absorb,events,log,P.barrier(~A.Schema,~A.Store,~A.Resource,~Message,queued(enqueue_despawn(world,target)))))
def collected(+target:W.Handle<A.Schema>,result:T.Collected<A.Schema,A.Store,A.Resource,Message,Logs.Streams<A.Schema,Family,Holders>>) -> String:
  match result:
    case T.Collected{world,events,log}:warm_next(observed(target,J.run(~A.Schema,~A.Store,~A.Resource,~Message,~Logs.Streams<A.Schema,Family,Holders>,~Ops,~Args,~Snapshot,~Snapshot,~plan(),~observe,J.Fresh{},Args{target,True{}},world,events,log)))
def detached(holders:Holders,+target:W.Handle<A.Schema>,result:D.Detached<A.Schema,A.Store,A.Resource,Message>) -> String:
  match result:
    case D.Detached{world,events}:collected(target,T.collect(~A.Schema,~A.Store,~A.Resource,~Message,~Logs.Streams<A.Schema,Family,Holders>,~is_event,~absorb,events,Logs.start(~A.Schema,~Family,~Holders,holders,16n),world))
def registered_despawned(removed:Sy.Registry<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>,+target:W.Handle<A.Schema>,result:Sy.RegistrationResult<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>) -> String:
  match result:
    case Sy.Registered{world,despawned}:detached(Holders{removed,despawned},target,D.detach(~A.Schema,~A.Store,~A.Resource,~Message,Ev.start(~A.Schema,~A.Store,~A.Resource,~Message,world,16n),[]))
    case Sy.RegistrationFailed{_}:"despawn reader registration failed"
def registered_removed(+target:W.Handle<A.Schema>,result:Sy.RegistrationResult<A.Schema,A.Store,A.Resource,Message,Bool,U32,Unit,retaining_runner>) -> String:
  match result:
    case Sy.Registered{world,removed}:registered_despawned(removed,target,Sy.register(~A.Schema,~A.Store,~A.Resource,~Message,~Bool,~U32,~Unit,~retaining_runner,world,"RetainingDespawn",["despawn:read"]))
    case Sy.RegistrationFailed{_}:"removed reader registration failed"
def seeded(+target:W.Handle<A.Schema>,result:C.Replacement<W.World<A.Schema,A.Store,A.Resource,Message>,A.Payload>) -> String:
  match result:
    case C.Replaced{world,_}:registered_removed(target,Sy.register(~A.Schema,~A.Store,~A.Resource,~Message,~Bool,~U32,~Unit,~retaining_runner,world,"RetainingRemoved",["removed:Stock:read"]))
    case C.ReplaceRejected{_,_,_}:"setup replacement rejected"
def activated(+target:W.Handle<A.Schema>,result:W.World<A.Schema,A.Store,A.Resource,Message> & W.Status) -> String:
  (world,_)=result
  seeded(target,C.replace(~A.Schema,~A.Store,~A.Resource,~Message,~Unit,~A.Payload,~List<&2,U32>,~A.Token,~A.take,~A.put,~A.project,A.family(),world,target,Some{A.Payload{Array.set(U32,Array.new(U32,2n,11),3,14)}}))
def reserved(result:W.World<A.Schema,A.Store,A.Resource,Message> & W.Reservation<A.Schema>) -> String:
  match result:
    case (world,W.Reserved{+target}):activated(target,W.activate(~A.Schema,~A.Store,~A.Resource,~Message,world,target))
    case (_,W.ReservationRejected{_}):"setup reservation rejected"
def created(result:W.Creation<A.Schema,A.Store,A.Resource,Message>) -> String:
  match result:
    case W.Created{_,world}:reserved(W.reserve_id(~A.Schema,~A.Store,~A.Resource,~Message,world))
    case W.CreateRejected{_,_}:"setup creation rejected"
def main() -> String:
  created(W.create(~A.Schema,~A.Store,~A.Resource,~Message,~A.empty,W.factory(),A.Resource{Array.set(U32,Array.new(U32,2n,21),3,24)}))
