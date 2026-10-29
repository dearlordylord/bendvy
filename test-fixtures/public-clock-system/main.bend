import Base
import ../../src/ecs/compose.bend as Q
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/world.bend as W
import ../../src/ecs/component.bend as C
import ../../src/ecs/component-legacy.bend as CLegacy
import ../../src/ecs/column.bend as Col
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/transaction.bend as Tx
import ../../src/ecs/commands.bend as Cmd
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/trace-facts.bend as Facts

type S is Data:S{}
type Token is Data:Token{}
def Store() -> Type:Col.Column<S,Array<U32>>
def World() -> Type:W.World<S,Store(),Unit,Unit>
def take(column:Store()) -> Unit & Store():(Unit{},column)
def put(_:Unit,column:Store()) -> Store():column
def projected(first:U32,result:Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  match result:
    case (array,second):(array,[first,second])
def projecting(result:Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  match result:
    case (array,first):projected(first,Array.get(U32,array,1))
def project(array:Array<U32>) -> Array<U32> & List<&2,U32>:projecting(Array.get(U32,array,0))
def family() -> C.Family<S,Store(),Unit,Array<U32>,List<&2,U32>,Token,take,put,project>:C.Family{"payload"}
type Args is Data:Args{handle:W.Handle<S>,fail:Bool}
def finish(result:Tx.Returned<World(),String>) -> Sys.Outcome<World(),String,Unit>:
  match result:
    case Tx.Returned{world,Tx.Success{}}:Sys.Succeeded{world,Unit{}}
    case Tx.Returned{world,Tx.Failure{error}}:Sys.Failed{world,error}
def decide(fail:Bool) -> Tx.Outcome<String>:
  match fail:
    case False{}:Tx.Success{}
    case True{}:Tx.Failure{"planned"}
def second(fail:Bool,result:C.SetResult<Tx.Tx<World(),Unit>,Array<U32>>) -> Sys.Outcome<World(),String,Unit>:
  match result:
    case C.Written{tx}:finish(Cmd.tx_finish(~S,~Store(),~Unit,~Unit,~String,tx,decide(fail)))
    case C.WriteRejected{tx,_,_}:finish(Cmd.tx_finish(~S,~Store(),~Unit,~Unit,~String,tx,Tx.Failure{"write-rejected"}))
    case C.WriteFailure{tx,_}:finish(Cmd.tx_finish(~S,~Store(),~Unit,~Unit,~String,tx,Tx.Failure{"write-failed"}))
def first(handle:W.Handle<S>,fail:Bool,result:C.SetResult<Tx.Tx<World(),Unit>,Array<U32>>) -> Sys.Outcome<World(),String,Unit>:
  match result:
    case C.Written{tx}:second(fail,CLegacy.tx_set(~S,~Store(),~Unit,~Unit,~Unit,~Array<U32>,~List<&2,U32>,~Token,~take,~put,~project,family(),tx,handle,ANode{ALeaf{30},ALeaf{31}}))
    case C.WriteRejected{tx,_,_}:finish(Cmd.tx_finish(~S,~Store(),~Unit,~Unit,~String,tx,Tx.Failure{"write-rejected"}))
    case C.WriteFailure{tx,_}:finish(Cmd.tx_finish(~S,~Store(),~Unit,~Unit,~String,tx,Tx.Failure{"write-failed"}))
def runner(world:World(),args:Args) -> Sys.Outcome<World(),String,Unit>:
  match args:
    case Args{+handle,fail}:first(handle,fail,CLegacy.tx_set(~S,~Store(),~Unit,~Unit,~Unit,~Array<U32>,~List<&2,U32>,~Token,~take,~put,~project,family(),Tx.begin(~World(),~Unit,world),handle,ANode{ALeaf{20},ALeaf{21}}))
def Registry() -> Type:Sys.Registry<S,Store(),Unit,Unit,Args,String,Unit,runner>
def RunResultType() -> Type:Sys.RunResult<S,Store(),Unit,Unit,Args,String,Unit,runner>
def observed(trace:Facts.State,world:World(),args:Args) -> Sys.Outcome<World(),String,Unit> & Facts.State:(runner(world,args),trace)
# Custom finish exposes the already-updated cursor; it does not set one itself.
def custom(registry:Registry(),outcome:Sys.Outcome<World(),String,Unit>) -> RunResultType():Sys.Completed{registry,outcome}

def tick(t:Tick.Tick) -> String:
  match t:
    case Tick.Tick{epoch,low}:Nat.show(epoch)++":"++U32.show(low)
def maybe_tick(t:Maybe<&2,Tick.Tick>) -> String:
  match t:
    case None{}:"none"
    case Some{t}:tick(t)
def stamp(s:Life.Stamp) -> String:
  match s:
    case Life.Stamp{added,changed}:maybe_tick(added)++"/"++maybe_tick(changed)
def stamp_returned(value:String,result:World() & Life.Stamp) -> World() & String:
  match result:
    case (world,s):(world,value++":stamp="++stamp(s))
def read_returned(handle:W.Handle<S>,result:World() & C.Access<List<&2,U32>>) -> World() & String:
  match result:
    case (world,C.Found{v}):stamp_returned("value="++List.show(&2,U32,U32.show,v),C.lifecycle(~S,~Store(),~Unit,~Unit,~Unit,~Array<U32>,~List<&2,U32>,~Token,~take,~put,~project,family(),world,handle))
    case (world,_):(world,"missing")
def view(world:World(),+handle:W.Handle<S>) -> World() & String:
  read_returned(handle,C.get(~S,~Store(),~Unit,~Unit,~Unit,~Array<U32>,~List<&2,U32>,~Token,~take,~put,~project,family(),world,handle))
def clocked(result:World() & String) -> World() & String:
  match result:
    case (W.World{namespace,allocator,store,resource,events,pending,registrations,next,Clock.State{+now,+scopes},lifecycle},text):(W.World{namespace,allocator,store,resource,events,pending,registrations,next,Clock.State{now,scopes},lifecycle},text++":now="++tick(now)++":scopes="++List.show(&2,Tick.Tick,tick,scopes))
type Returned is Type:Returned{world:World(),registry:Registry(),text:String}
def described(label:String,registry:Registry(),result:World() & String) -> Returned:
  match registry result:
    case Sys.Registry{ns,id,name,access,+cursor},(world,text):Returned{world,Sys.Registry{ns,id,name,access,cursor},label++":cursor="++maybe_tick(cursor)++":"++text}
def describe(label:String,handle:W.Handle<S>,registry:Registry(),world:World()) -> Returned:
  described(label,registry,clocked(view(world,handle)))
def outcome(label:String,handle:W.Handle<S>,registry:Registry(),result:Sys.Outcome<World(),String,Unit>) -> Returned:
  match result:
    case Sys.Succeeded{world,_}:describe(label++"=success",handle,registry,world)
    case Sys.Failed{world,error}:describe(label++"=failure:"++error,handle,registry,world)
def completed(label:String,handle:W.Handle<S>,result:RunResultType()) -> Returned:
  match result:
    case Sys.Completed{registry,result}:outcome(label,handle,registry,result)
    case Sys.RegistrationRejected{registry,world,Args{_,fail}}:describe(label++"=rejected:argsFail="++Bool.show(fail),handle,registry,world)
def untraced(result:RunResultType() & Facts.State) -> RunResultType():
  match result:
    case (result,_):result

def failed_done(prior:String,result:Returned) -> String:
  match result:
    case Returned{_,_,text}:prior++"\n"++text
def success_done(+handle:W.Handle<S>,result:Returned) -> String:
  match result:
    case Returned{world,registry,text}:failed_done(text,completed("second",handle,Sys.run(~S,~Store(),~Unit,~Unit,~Args,~String,~Unit,~runner,registry,world,Args{handle,True{}})))
# Trusted administrative seed isolates actual wrap execution without billions of runs.
def seed(world:World()) -> World():
  match world:
    case W.World{ns,a,s,r,e,p,g,n,_,lifecycle}:W.World{ns,a,s,r,e,p,g,n,Clock.State{Tick.Tick{0n,4294967295},[]},lifecycle}
def foreign_created(+handle:W.Handle<S>,registry:Registry(),result:W.Creation<S,Store(),Unit,Unit>) -> String:
  match result:
    case W.CreateRejected{_,_}:"foreign-create-failed"
    case W.Created{_,world}:failed_done("foreign-world",completed("foreign",handle,Sys.run(~S,~Store(),~Unit,~Unit,~Args,~String,~Unit,~runner,registry,world,Args{handle,True{}})))
def independent_after(+handle:W.Handle<S>,readerB:Registry(),result:Returned) -> String:
  match result:
    case Returned{world,_,text}:failed_done(text,completed("readerB",handle,Sys.run(~S,~Store(),~Unit,~Unit,~Args,~String,~Unit,~runner,readerB,world,Args{handle,True{}})))
def independent_registered(+handle:W.Handle<S>,readerA:Registry(),result:Sys.RegistrationResult<S,Store(),Unit,Unit,Args,String,Unit,runner>) -> String:
  match result:
    case Sys.RegistrationFailed{_}:"second-registration-failed"
    case Sys.Registered{world,readerB}:independent_after(handle,readerB,completed("readerA",handle,Sys.run(~S,~Store(),~Unit,~Unit,~Args,~String,~Unit,~runner,readerA,world,Args{handle,False{}})))
def dispatch(mode:U32,+handle:W.Handle<S>,registry:Registry(),world:World()) -> String:
  match mode:
    case 0:success_done(handle,completed("first",handle,Sys.run(~S,~Store(),~Unit,~Unit,~Args,~String,~Unit,~runner,registry,world,Args{handle,False{}})))
    case 1:failed_done("fresh-failure",completed("failed",handle,Sys.run(~S,~Store(),~Unit,~Unit,~Args,~String,~Unit,~runner,registry,world,Args{handle,True{}})))
    case 2:failed_done("observed",completed("observed",handle,untraced(Sys.run_observed(~S,~Store(),~Unit,~Unit,~Args,~String,~Unit,~runner,~observed,registry,Facts.Off{},world,Args{handle,False{}}))))
    case 3:failed_done("custom-finish",completed("custom",handle,untraced(Sys.run_observed_with(~S,~Store(),~Unit,~Unit,~Args,~String,~Unit,~runner,~observed,~custom,registry,Facts.Off{},world,Args{handle,True{}}))))
    case 4:foreign_created(handle,registry,W.create(~S,~Store(),~Unit,~Unit,~(unit => Col.empty_indexed(~S,~Array<U32>)),W.Factory{901},Unit{}))
    case 6:independent_registered(handle,registry,Sys.register(~S,~Store(),~Unit,~Unit,~Args,~String,~Unit,~runner,world,"readerB",["write:payload"]))
    case _:failed_done("trusted-wrap-seed",completed("wrapped",handle,Sys.run(~S,~Store(),~Unit,~Unit,~Args,~String,~Unit,~runner,registry,seed(world),Args{handle,False{}})))
def registered(mode:U32,handle:W.Handle<S>,result:Sys.RegistrationResult<S,Store(),Unit,Unit,Args,String,Unit,runner>) -> String:
  match result:
    case Sys.RegistrationFailed{_}:"registration-failed"
    case Sys.Registered{world,registry}:dispatch(mode,handle,registry,world)
def installed(mode:U32,handle:W.Handle<S>,result:C.Replacement<World(),Array<U32>>) -> String:
  match result:
    case C.ReplaceRejected{_,_,_}:"install-failed"
    case C.Replaced{world,_}:registered(mode,handle,Sys.register(~S,~Store(),~Unit,~Unit,~Args,~String,~Unit,~runner,world,"writer",["write:payload"]))
def activated(mode:U32,+handle:W.Handle<S>,result:World() & W.Status) -> String:
  match result:
    case (world,W.Rejected{_}):"activation-failed"
    case (world,W.Accepted{}):installed(mode,handle,C.structural_replace(~S,~Store(),~Unit,~Unit,~Unit,~Array<U32>,~List<&2,U32>,~Token,~take,~put,~project,family(),world,handle,Some{ANode{ALeaf{10},ALeaf{11}}}))
def reserved(mode:U32,result:World() & W.Reservation<S>) -> String:
  match result:
    case (world,W.ReservationRejected{_}):"reservation-failed"
    case (world,W.Reserved{+handle}):activated(mode,handle,W.activate(~S,~Store(),~Unit,~Unit,world,handle))
def created(mode:U32,result:W.Creation<S,Store(),Unit,Unit>) -> String:
  match result:
    case W.CreateRejected{_,_}:"create-failed"
    case W.Created{_,world}:reserved(mode,W.reserve_id(~S,~Store(),~Unit,~Unit,world))
def scenario(mode:U32) -> String:
  created(mode,W.create(~S,~Store(),~Unit,~Unit,~(unit => Col.empty_indexed(~S,~Array<U32>)),W.Factory{100},Unit{}))
# Direct Compose owns one query scope only when no System scope already exists.
def Ops(H:Type) -> Type:Cap.Write<H,Array<U32>,List<&2,U32>>
def query_body(~H:Type,~caps:Ops(H),_:Unit,ctx:H) -> H & (Tx.Outcome<String> & Unit):
  (Cap.set(~H,~Array<U32>,~List<&2,U32>,~caps,ctx,ANode{ALeaf{40},ALeaf{41}}),(Tx.Success{},Unit{}))
def query_plan() -> Q.Plan<S,Store(),Unit,Unit,Ops>:
  Q.Plan{Q.write_family(~S,~Store(),~Unit,~Unit,~Unit,~Array<U32>,~List<&2,U32>,~Token,~take,~put,~project,~family()),Q.all(~S,~Store(),~Unit,~Unit)}
def query(world:World()) -> Q.Executed<World(),Q.Error<String>,Unit>:
  Q.each(~S,~Store(),~Unit,~Unit,~Ops,~Unit,~String,~Unit,~query_plan(),~query_body,Unit{},world)
def query_outcome(result:Q.Executed<World(),Q.Error<String>,Unit>) -> Sys.Outcome<World(),String,Unit>:
  match result:
    case Q.Executed{world,Tx.Success{},_}:Sys.Succeeded{world,Unit{}}
    case Q.Executed{world,Tx.Failure{_},_}:Sys.Failed{world,"query-failed"}
def query_runner(world:World(),_:Unit) -> Sys.Outcome<World(),String,Unit>:query_outcome(query(world))
def query_described(prefix:String,result:World() & String) -> String:
  match result:
    case (_,text):prefix++text

def query_first(second:W.Handle<S>,prefix:String,result:World() & String) -> String:
  match result:
    case (world,text):query_described(prefix++text++";second:",clocked(view(world,second)))
def query_report(prefix:String,first:W.Handle<S>,second:W.Handle<S>,world:World()) -> String:
  query_first(second,prefix++":first:",clocked(view(world,first)))
def direct_done(first:W.Handle<S>,second:W.Handle<S>,result:Q.Executed<World(),Q.Error<String>,Unit>) -> String:
  match result:
    case Q.Executed{world,Tx.Success{},_}:query_report("direct-query",first,second,world)
    case _:"direct-query-failed"
def nested_done(first:W.Handle<S>,second:W.Handle<S>,result:Sys.RunResult<S,Store(),Unit,Unit,Unit,String,Unit,query_runner>) -> String:
  match result:
    case Sys.Completed{Sys.Registry{_,_,_,_,cursor},Sys.Succeeded{world,_}}:query_report("system-query:cursor="++maybe_tick(cursor),first,second,world)
    case _:"system-query-failed"
def nested_registered(first:W.Handle<S>,second:W.Handle<S>,result:Sys.RegistrationResult<S,Store(),Unit,Unit,Unit,String,Unit,query_runner>) -> String:
  match result:
    case Sys.Registered{world,registry}:nested_done(first,second,Sys.run(~S,~Store(),~Unit,~Unit,~Unit,~String,~Unit,~query_runner,registry,world,Unit{}))
    case _:"query-registration-failed"
def query_ready(nested:Bool,first:W.Handle<S>,second:W.Handle<S>,world:World()) -> String:
  match nested:
    case False{}:direct_done(first,second,query(world))
    case True{}:nested_registered(first,second,Sys.register(~S,~Store(),~Unit,~Unit,~Unit,~String,~Unit,~query_runner,world,"query",["write:payload"]))
def query_second_installed(nested:Bool,first:W.Handle<S>,second:W.Handle<S>,result:C.Replacement<World(),Array<U32>>) -> String:
  match result:
    case C.Replaced{world,_}:query_ready(nested,first,second,world)
    case _:"query-install-failed"
def query_second_active(nested:Bool,first:W.Handle<S>,+second:W.Handle<S>,result:World() & W.Status) -> String:
  match result:
    case (world,W.Accepted{}):query_second_installed(nested,first,second,C.structural_replace(~S,~Store(),~Unit,~Unit,~Unit,~Array<U32>,~List<&2,U32>,~Token,~take,~put,~project,family(),world,second,Some{ANode{ALeaf{12},ALeaf{13}}}))
    case _:"query-activate-failed"
def query_second_reserved(nested:Bool,first:W.Handle<S>,result:World() & W.Reservation<S>) -> String:
  match result:
    case (world,W.Reserved{+handle}):query_second_active(nested,first,handle,W.activate(~S,~Store(),~Unit,~Unit,world,handle))
    case _:"query-reserve-failed"
def query_first_installed(nested:Bool,handle:W.Handle<S>,result:C.Replacement<World(),Array<U32>>) -> String:
  match result:
    case C.Replaced{world,_}:query_second_reserved(nested,handle,W.reserve_id(~S,~Store(),~Unit,~Unit,world))
    case _:"query-first-install-failed"
def query_first_active(nested:Bool,+handle:W.Handle<S>,result:World() & W.Status) -> String:
  match result:
    case (world,W.Accepted{}):query_first_installed(nested,handle,C.structural_replace(~S,~Store(),~Unit,~Unit,~Unit,~Array<U32>,~List<&2,U32>,~Token,~take,~put,~project,family(),world,handle,Some{ANode{ALeaf{10},ALeaf{11}}}))
    case _:"query-first-activate-failed"
def query_first_reserved(nested:Bool,result:World() & W.Reservation<S>) -> String:
  match result:
    case (world,W.Reserved{+handle}):query_first_active(nested,handle,W.activate(~S,~Store(),~Unit,~Unit,world,handle))
    case _:"query-first-reserve-failed"
def query_created(nested:Bool,result:W.Creation<S,Store(),Unit,Unit>) -> String:
  match result:
    case W.Created{_,world}:query_first_reserved(nested,W.reserve_id(~S,~Store(),~Unit,~Unit,world))
    case _:"query-create-failed"
def query_scenario(nested:Bool) -> String:
  query_created(nested,W.create(~S,~Store(),~Unit,~Unit,~(unit => Col.empty_indexed(~S,~Array<U32>)),W.Factory{500},Unit{}))

def main() -> IO(Unit):
  IO.print(scenario(0)++"\n"++scenario(1)++"\n"++scenario(2)++"\n"++scenario(3)++"\n"++scenario(4)++"\n"++scenario(5)++"\n"++scenario(6)++"\n"++query_scenario(False{})++"\n"++query_scenario(True{}))
