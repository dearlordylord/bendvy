import Base
import application.bend as A
import provider.bend as P
import gameplay.bend as G
import context.bend as Ctx
import readers.bend as R
import hooks.bend as H
import catalog.bend as Cat
import slots.bend as Slots
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/machine-stream.bend as St
import observe.bend as O
import conditions.bend as C
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/world.bend as W
import ../../src/ecs/world-io.bend as WIO
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/system.bend as Sys

def user_entry(~S: Data,entry: Cat.Entry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>) -> Cat.Entry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))> & String:
  match entry:
    case Cat.Entry{+key,Sys.Registry{+ns,+id,+name,+access,+cursor}}:
      (Cat.Entry{key,Sys.Registry{ns,id,name,access,cursor}},U32.show(key) ++ ":" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,O.text,access) ++ ":" ++ U32.show(cursor))
def users_join(~S: Data,head: Cat.Entry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))> & String,rest: List<&1,Cat.Entry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>> & List<&2,String>) -> List<&1,Cat.Entry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>> & List<&2,String>:
  (entry,text)=head
  (rest,rows)=rest
  (entry <> rest,text <> rows)
def users(~S: Data,entries: List<&1,Cat.Entry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>>) -> List<&1,Cat.Entry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>> & List<&2,String>:
  match entries:
    case Nil{}: ([],[])
    case Con{head,rest}: users_join(~S,user_entry(~S,head),users(~S,rest))
def user_catalog(~S: Data,pair: List<&1,Cat.Entry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>> & List<&2,String>) -> Cat.Catalog<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))> & String:
  (entries,rows)=pair
  (Cat.Catalog{entries},List.show(&2,String,O.text,rows))
def catalog(~S: Data,value: Cat.Catalog<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>) -> Cat.Catalog<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))> & String:
  match value:
    case Cat.Catalog{entries}: user_catalog(~S,users(~S,entries))

def reader(~S: Data,entry: Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>) -> Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>> & String:
  match entry:
    case Slots.Entry{+key,R.Instance{Sys.Registry{+ns,+id,+name,+access,+cursor},St.Reader{+a,+ai},St.Reader{+b,+bi}}}:
      (Slots.Entry{key,R.Instance{Sys.Registry{ns,id,name,access,cursor},St.Reader{a,ai},St.Reader{b,bi}}},U32.show(key) ++ ":" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,O.text,access) ++ ":" ++ U32.show(cursor) ++ ":flow=" ++ U32.show(a) ++ ":" ++ U32.show(ai) ++ ":level=" ++ U32.show(b) ++ ":" ++ U32.show(bi))
def readers_join(~S: Data,head: Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>> & String,rest: List<&1,Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>> & List<&2,String>) -> List<&1,Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>> & List<&2,String>:
  (entry,text)=head
  (rest,rows)=rest
  (entry <> rest,text <> rows)
def readers(~S: Data,entries: List<&1,Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>>) -> List<&1,Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>> & List<&2,String>:
  match entries:
    case Nil{}: ([],[])
    case Con{head,rest}: readers_join(~S,reader(~S,head),readers(~S,rest))

def hook_registry(~S: Data,value: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,G.HookOperation,String,Unit,(world => operation => Ctx.hook_runner(~S,world,operation))>) -> Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,G.HookOperation,String,Unit,(world => operation => Ctx.hook_runner(~S,world,operation))> & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}: (Sys.Registry{ns,id,name,access,cursor},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,O.text,access) ++ ":" ++ U32.show(cursor))
def hook_join(~S: Data,a: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,G.HookOperation,String,Unit,(world => operation => Ctx.hook_runner(~S,world,operation))> & String,b: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,G.HookOperation,String,Unit,(world => operation => Ctx.hook_runner(~S,world,operation))> & String) -> H.Owners<S,(world => operation => Ctx.hook_runner(~S,world,operation))> & String:
  (flow,a)=a
  (level,b)=b
  (H.Owners{flow,level},a ++ "|" ++ b)
def hooks(~S: Data,owners: H.Owners<S,(world => operation => Ctx.hook_runner(~S,world,operation))>) -> H.Owners<S,(world => operation => Ctx.hook_runner(~S,world,operation))> & String:
  match owners:
    case H.Owners{flow,level}: hook_join(~S,hook_registry(~S,flow),hook_registry(~S,level))
def owners_join(~S: Data,a: Cat.Catalog<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))> & String,b: H.Owners<S,(world => operation => Ctx.hook_runner(~S,world,operation))> & String,c: List<&1,Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>> & List<&2,String>,+attempts: List<&2,String>,+deliveries: List<&2,String>,+conditions: List<&2,String>,+active: List<&2,A.Action<S>>) -> A.Owners<S> & String:
  (users,a)=a
  (hooks,b)=b
  (readers,c)=c
  (A.Owners{users,hooks,readers,attempts,deliveries,conditions,active},"users=" ++ a ++ ";hookOwners=" ++ b ++ ";readerOwners=" ++ List.show(&2,String,O.text,c) ++ ";attempts=" ++ List.show(&2,String,O.text,attempts) ++ ";deliveries=" ++ List.show(&2,String,O.text,deliveries) ++ ";conditions=" ++ List.show(&2,String,O.text,conditions) ++ ";active=" ++ List.show(&2,A.Action<S>,(item => A.action_view(~S,item)),active))
def owners(~S: Data,value: A.Owners<S>) -> A.Owners<S> & String:
  match value:
    case A.Owners{userCatalog,hookOwners,readerEntries,attempts,deliveries,conditions,active}: owners_join(~S,catalog(~S,userCatalog),hooks(~S,hookOwners),readers(~S,readerEntries),attempts,deliveries,conditions,active)

type Observed<S: Data> is Type:
  Observed{owners: A.Owners<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,rows: List<&2,String>}
def observed(~S: Data,label: String,status: String,rows: List<&2,String>,a: A.Owners<S> & String,b: W.World<S,P.Store<S>,P.Resources<S>,Unit> & String) -> Observed<S>:
  (owners,a)=a
  (world,b)=b
  Observed{owners,world,List.append(&2,String,rows,[label ++ "|" ++ status ++ "|" ++ b ++ ";" ++ a])}
def checkpoint(~S: Data,label: String,rows: List<&2,String>,result: A.FrameResult<S>) -> Observed<S>:
  match result:
    case A.FrameResult{owned,world,status}: observed(~S,label,status,rows,owners(~S,owned),O.world(~S,world))
def frames(~S: Data,plans: List<&2,A.FramePlan<S>>,current: Observed<S>) -> Observed<S>:
  match plans current:
    case Nil{}, current: current
    case Con{A.FramePlan{+label,actions},rest}, Observed{owners,world,rows}:
      frames(~S,rest,checkpoint(~S,label,rows,A.frame(~S,owners,world,label,actions)))

def gate_plans(~S: Data) -> List<&2,A.Action<S>>:
  [A.Gate{30,"inPause",C.Leaf{P.InFlow{P.Pause{}}}},
   A.Gate{31,"changed",C.Leaf{P.FlowChanged{}}},
   A.Gate{32,"notBoot",C.Negate{C.Leaf{P.InFlow{P.Boot{}}}}},
   A.Gate{33,"and",C.Both{C.Leaf{P.InFlow{P.Pause{}}},C.Negate{C.Leaf{P.InLevel{P.Low{}}}}}},
   A.Gate{34,"or",C.Either{C.Leaf{P.InFlow{P.Boot{}}},C.Leaf{P.InLevel{P.Middle{}}}}},
   A.Gate{35,"emptyAnd",C.all(~P.Atom<S>,[])},
   A.Gate{36,"emptyOr",C.any(~P.Atom<S>,[])}]
def plan(~S: Data) -> List<&2,A.FramePlan<S>>:
  [A.FramePlan{"initial",[A.Body{1,"seed",G.Seed{}},A.Deferred{}]},
   A.FramePlan{"queued",[A.Body{2,"overwrite",G.Queue{}}]},
   A.FramePlan{"deferred-only",[A.Deferred{}]},
   A.FramePlan{"committed",[A.Marker{False{}}]},
   A.FramePlan{"readers-register",[A.Read{10,"fast",False{}},A.Read{11,"slow",False{}}]},
   A.FramePlan{"same-set-and-conditions",List.append(&2,A.Action<S>,[A.Body{3,"same-set",G.SameSet{}},A.Marker{False{}}],List.append(&2,A.Action<S>,gate_plans(~S),[A.Read{10,"fast",False{}}]))},
   A.FramePlan{"same-skip-and-conditions",List.append(&2,A.Action<S>,[A.Body{4,"same-skip",G.SameSkip{}},A.Marker{False{}}],List.append(&2,A.Action<S>,gate_plans(~S),[A.Read{10,"fast",False{}}]))},
   A.FramePlan{"overwrite-skip-flag",[A.Body{5,"skip-overwrite",G.OverwriteSkip{}},A.Marker{False{}},A.Read{10,"fast",False{}}]},
   A.FramePlan{"reset",[A.Body{6,"reset",G.Reset{}},A.Marker{False{}},A.Read{10,"fast",False{}}]},
   A.FramePlan{"old-pending",[A.Body{7,"old-pending",G.OldPending{}}]},
   A.FramePlan{"publisher-failed",[A.Body{8,"failed-publisher",G.FailingPublisher{"publish-failed"}},A.Marker{False{}}]},
   A.FramePlan{"failure-retry-marker",[A.Marker{False{}},A.Read{10,"fast",False{}}]},
   A.FramePlan{"reader-failed",[A.Read{12,"retry-reader",True{}}]},
   A.FramePlan{"reader-failed-repeat",[A.Read{12,"retry-reader",True{}}]},
   A.FramePlan{"slow-backlog",[A.Read{11,"slow",False{}}]},
   A.FramePlan{"skip-reader",[A.Body{9,"pause",G.PauseRequest{}},A.Marker{False{}},A.GatedRead{11,"slow",C.Leaf{P.InFlow{P.Play{}}}}]},
   A.FramePlan{"skip-reader-no-backlog",[A.Body{13,"play",G.PlayRequest{}},A.Marker{False{}},A.Read{11,"slow",False{}}]},
   A.FramePlan{"marker-generated-and-definition-order",[A.Body{14,"definition-order",G.MarkerQueues{}},A.Marker{True{}}]},
   A.FramePlan{"next-marker",[A.Marker{False{}},A.Read{10,"fast",False{}},A.Read{11,"slow",False{}}]},
   A.FramePlan{"empty-frame",[]},A.FramePlan{"empty-frame-2",[]},
   A.FramePlan{"retained-failed-reader",[A.Read{12,"retry-reader",True{}}]},
   A.FramePlan{"failed-reader-retry-success",[A.Read{12,"retry-reader",False{}}]},
   A.FramePlan{"reader-repeat-empty",[A.Read{12,"retry-reader",False{}}]}]
def finish(~S: Data,value: Observed<S>) -> String:
  match value:
    case Observed{_,_,rows}: String.join(rows,"\n")
def provisioned(~S: Data,result: H.Provision<S,(world => operation => Ctx.hook_runner(~S,world,operation))>) -> String:
  match result:
    case H.Provisioned{world,hooks}: finish(~S,frames(~S,plan(~S),Observed{A.Owners{Cat.Catalog{[]},hooks,[],[],[],[],[]},world,[]}))
    case H.ProvisionFailed{_}: "HOOK_PROVISION_REJECTED"
def created(~S: Data,result: WIO.Creation<S,P.Store<S>,P.Resources<S>,Unit>) -> IO(String):
  match result:
    case WIO.Created{world}: IO.pure(String,provisioned(~S,H.provision(~S,~(world => operation => Ctx.hook_runner(~S,world,operation)),world)))
    case WIO.Refused{_}: IO.pure(String,"WORLD_CREATE_REFUSED")
def scenario(~S: Data) -> IO(String):
  IO.bind(WIO.Creation<S,P.Store<S>,P.Resources<S>,Unit>,String,WIO.create(~S,~P.Store<S>,~P.Resources<S>,~Unit,~(unit => P.empty_store(~S,unit)),P.initial_resources(~S)),value => created(~S,value))
def second(first: String,second: String) -> IO(Unit):
  IO.print("SCHEMA=A\n" ++ first ++ "\nSCHEMA=B\n" ++ second)
def main() -> IO(Unit):
  IO.bind(String,Unit,scenario(~P.SchemaA),first => IO.bind(String,Unit,scenario(~P.SchemaB),value => second(first,value)))
