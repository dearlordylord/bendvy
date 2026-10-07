import Base
import provider.bend as P
import gameplay.bend as G
import context.bend as Ctx
import marker.bend as Marker
import observe.bend as O
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/schedule.bend as Sch

type Owner<S: Data,-runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.Operation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>> is Type:
  Owner{registry: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,runner>,operation: G.Operation}

def dispatched(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.Operation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,operation: G.Operation,result: Sys.RunResult<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,runner>) -> Owner<S,runner> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match result:
    case Sys.Completed{registry,outcome}: (Owner{registry,operation},outcome)
    case Sys.RegistrationRejected{registry,world,_}: (Owner{registry,operation},Sys.Failed{world,"RegistrationRejected"})

def dispatch(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.Operation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,owners: Owner<S,runner>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,_: U32) -> Owner<S,runner> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match owners:
    case Owner{registry,+operation}: dispatched(~S,~runner,operation,Sys.run(~S,~P.Store<S>,~P.Resources<S>,~Unit,~G.Operation,~String,~Unit,~runner,registry,world,operation))

def condition(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,_: U32) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & Bool:
  (world,True{})

def completed(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.Operation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,result: Sch.RunResult<S,P.Store<S>,P.Resources<S>,Unit,Owner<S,runner>,String>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & String:
  match result:
    case Sch.Finished{_,world,_}: (world,"ok")
    case Sch.Failed{_,world,error,_}: (world,"failed:" ++ error)
    case Sch.Rejected{_,world}: (world,"schedule-rejected")

def built(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.Operation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,result: Sch.Build<S,P.Store<S>,P.Resources<S>,Unit,Owner<S,runner>>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & String:
  match result:
    case Sch.Invalid{_}: (world,"schedule-invalid")
    case Sch.Built{schedule}:
      completed(~S,~runner,Sch.run(~S,~P.Store<S>,~P.Resources<S>,~Unit,~Owner<S,runner>,~String,~(registry => world => id => dispatch(~S,~runner,registry,world,id)),~(world => id => condition(~S,world,id)),schedule,world))

def registered_named(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.Operation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,operation: G.Operation,registry: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,runner>,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & U32) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & String:
  (world,namespace)=pair
  built(~S,~runner,world,Sch.build(~S,~P.Store<S>,~P.Resources<S>,~Unit,~Owner<S,runner>,namespace,"machine-probe",[Sch.System{1,0}],[1],Owner{registry,operation}))

def registered(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.Operation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,operation: G.Operation,result: Sys.RegistrationResult<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,runner>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & String:
  match result:
    case Sys.Registered{world,registry}: registered_named(~S,~runner,operation,registry,W.namespace(~S,~P.Store<S>,~P.Resources<S>,~Unit,world))
    case Sys.RegistrationFailed{world}: (world,"registration-failed")

def execute(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,+operation: G.Operation) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & String:
  registered(~S,~(world => operation => Ctx.runner(~S,world,operation)),operation,Sys.register(~S,~P.Store<S>,~P.Resources<S>,~Unit,~G.Operation,~String,~Unit,~(world => operation => Ctx.runner(~S,world,operation)),P.frame(~S,world),"machine-work",["machine.Flow.next","machine.Level.next","component.cells.write","resource.owned.write","commands.spawn"]))

def observed(~S: Data,label: String,rows: List<&2,String>,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & String) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & List<&2,String>:
  (world,view)=pair
  (world,List.append(&2,String,rows,[label ++ "|" ++ view]))
def checkpoint(~S: Data,label: String,rows: List<&2,String>,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & String) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & List<&2,String>:
  (world,status)=pair
  observed(~S,label ++ ":" ++ status,rows,O.world(~S,world))

def after_last(~S: Data,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & List<&2,String>) -> String:
  (_,rows)=pair
  List.show(&2,String,O.text,rows)
def after_exception(~S: Data,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & List<&2,String>) -> String:
  (world,rows)=pair
  after_last(~S,checkpoint(~S,"next-marker",rows,(Marker.run(~S,P.frame(~S,world),True{}),"ok")))
def after_marker_queues(~S: Data,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & List<&2,String>) -> String:
  (world,rows)=pair
  after_exception(~S,checkpoint(~S,"marker-exception",rows,(Marker.run(~S,P.frame(~S,world),True{}),"ok")))
def after_failure(~S: Data,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & List<&2,String>) -> String:
  (world,rows)=pair
  after_marker_queues(~S,checkpoint(~S,"marker-queued",rows,execute(~S,world,G.MarkerQueues{})))
def after_old(~S: Data,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & List<&2,String>) -> String:
  (world,rows)=pair
  after_failure(~S,checkpoint(~S,"publisher-failed",rows,execute(~S,world,G.FailingPublisher{"Boom"})))
def after_committed(~S: Data,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & List<&2,String>) -> String:
  (world,rows)=pair
  after_old(~S,checkpoint(~S,"old-pending",rows,execute(~S,world,G.OldPending{})))
def after_deferred(~S: Data,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & List<&2,String>) -> String:
  (world,rows)=pair
  after_committed(~S,checkpoint(~S,"committed",rows,(Marker.run(~S,P.frame(~S,world),False{}),"ok")))
def after_queue(~S: Data,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & List<&2,String>) -> String:
  (world,rows)=pair
  after_deferred(~S,checkpoint(~S,"deferred-only",rows,(P.pulse(~S,W.barrier(~S,~P.Store<S>,~P.Resources<S>,~Unit,P.frame(~S,world))),"ok")))
def after_initial(~S: Data,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & List<&2,String>) -> String:
  (world,rows)=pair
  after_queue(~S,checkpoint(~S,"queued",rows,execute(~S,world,G.Queue{})))
def seeded(~S: Data,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & String) -> String:
  (world,status)=pair
  after_initial(~S,checkpoint(~S,"initial",[],(P.pulse(~S,W.barrier(~S,~P.Store<S>,~P.Resources<S>,~Unit,world)),status)))
def created(~S: Data,result: W.Creation<S,P.Store<S>,P.Resources<S>,Unit>) -> String:
  match result:
    case W.Created{_,world}: seeded(~S,execute(~S,world,G.Seed{}))
    case W.CreateRejected{_,_}: "create-rejected"
def scenario(~S: Data) -> String:
  created(~S,W.create(~S,~P.Store<S>,~P.Resources<S>,~Unit,~(unit => P.empty_store(~S,unit)),W.factory(),P.initial_resources(~S)))
def main() -> IO(Unit):
  IO.print("A=" ++ scenario(~P.SchemaA) ++ "\nB=" ++ scenario(~P.SchemaB))
