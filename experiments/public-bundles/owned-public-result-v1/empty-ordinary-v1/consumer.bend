import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-bundle.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as CS
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/bundle-insert-adapter.bend as AD
import /workspace/formal-proofs/bendvy/src/ecs/bundle-provider.bend as Provider
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as BT
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys

type Store is Type:
  Store{first:Array<U32>,second:Array<U32>}
type Resources is Type:
  Resources{first:Array<U32>,second:Array<U32>}
type Packet is Type:
  Packet{cooked:Unit,undo:Unit -> Unit}
def World(~S:Data) -> Type:W.World<S,Store,Resources,U32>
def Owner(~S:Data) -> Type:AD.Owner<S,Store,Resources,U32,Packet,Array<U32>>
def Input(~S:Data) -> Type:Cmd.Input<S,Unit>
def Output(~S:Data) -> Type:Cmd.Output<S,Unit,String>
def construct(context:Array<U32>,raw:Unit) -> CS.Staged<Array<U32>,Unit,Unit,String>:CS.terminal(~Array<U32>,~String,context,raw)
def pack(cooked:Unit,undo:Unit -> Unit) -> Packet:Packet{cooked,undo}
def unpack(packet:Packet) -> Unit:
  match packet:
    case Packet{cooked,undo}:undo(cooked)
def request(~S:Data,owner:Owner(S),input:Input(S)) -> Owner(S) & Output(S):
  Ordinary.request(~S,~Store,~Resources,~U32,~Packet,~Array<U32>,~Unit,~Unit,~String,~construct,~pack,~unpack,Ordinary.terminal(~S),owner,input)
def body(~S:Data,~H:Type,~cap:Cap.OwnedRequest<H,Input(S),Output(S)>,input:Input(S),owner:H) -> H & Output(S):Cap.owned_request(~H,~Input(S),~Output(S),~cap,owner,input)
def attempt(~S:Data,world:World(S),handle:W.Handle<S>,packet:Packet) -> D.Delivery<World(S),Packet>:
  match packet:
    case Packet{cooked,undo}:D.Delivered{world}
def recover(~S:Data,world:World(S),packet:Packet,error:W.WorldError) -> World(S):world
type RunOutput<S:Data> is Type:
  RunOutput{context:Array<U32>,output:Output(S)}
def completed(~S:Data,context:Array<U32>,output:Output(S),result:BT.Finished<S,Store,Resources,U32,Packet,String>) -> Sys.Outcome<World(S),String,RunOutput<S>>:
  match result:
    case BT.Committed{world}:Sys.Succeeded{world,RunOutput{context,output}}
    case BT.Failed{world,packets,error}:Sys.Failed{world,error}
def finished(~S:Data,result:Owner(S) & Output(S)) -> Sys.Outcome<World(S),String,RunOutput<S>>:
  match result:
    case (AD.Owner{batch,context},output):completed(~S,context,output,BT.finish(~S,~Store,~Resources,~U32,~Packet,~String,~(world => handle => packet => attempt(~S,world,handle,packet)),~(world => packet => error => recover(~S,world,packet,error)),batch,T.Success{}))
def runner(~S:Data,world:World(S),args:Array<U32> & Input(S)) -> Sys.Outcome<World(S),String,RunOutput<S>>:
  match args:
    case (context,input):finished(~S,Provider.provide_owned(~Owner(S),~Input(S),~Output(S),~Input(S),~Output(S),~(owner => input => request(~S,owner,input)),~(H => cap => input => owner => body(~S,~H,~cap,input,owner)),input,AD.Owner{BT.begin(~S,~Store,~Resources,~U32,~Packet,T.begin(~World(S),~U32,world)),context}))
def Registry(~S:Data) -> Type:Sys.Registry<S,Store,Resources,U32,Array<U32> & Input(S),String,RunOutput<S>,(world => args => runner(~S,world,args))>
type Session<S:Data> is Type:
  Session{world:World(S),registry:Registry(S),context:Array<U32>}
def array_join(left:Array<U32> & String,right:Array<U32> & String) -> Array<U32> & String:
  match left right:
    case (a,x), (b,y):(ANode{a,b},"node(" ++ x ++ "," ++ y ++ ")")
def array(owner:Array<U32>) -> Array<U32> & String:
  match owner:
    case ALeaf{+value}:(ALeaf{value},"leaf:" ++ U32.show(value))
    case ANode{a,b}:array_join(array(a),array(b))
def live_join(left:Array<Bool> & String,right:Array<Bool> & String) -> Array<Bool> & String:
  match left right:
    case (a,x), (b,y):(ANode{a,b},"node(" ++ x ++ "," ++ y ++ ")")
def live(owner:Array<Bool>) -> Array<Bool> & String:
  match owner:
    case ALeaf{+value}:(ALeaf{value},Bool.show(value))
    case ANode{a,b}:live_join(live(a),live(b))
def pending_join(~S:Data,head:World(S) -> World(S),rest:List<(World(S) -> World(S))> & Nat) -> List<(World(S) -> World(S))> & Nat:
  match rest:
    case (tail,n):(head <> tail,1n+n)
def pending(~S:Data,commands:List<(World(S) -> World(S))>) -> List<(World(S) -> World(S))> & Nat:
  match commands:
    case []:([],0n)
    case head <> tail:pending_join(~S,head,pending(~S,tail))
def meta(entry:W.RegistrationMeta) -> String:
  match entry:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,(x => x),access)
def world_view(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,U32>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,al:Array<Bool> & String,ap:Array<U32> & String,bp:Array<U32> & String,cp:Array<U32> & String,dp:Array<U32> & String,pendingPair:List<(World(S) -> World(S))> & Nat) -> World(S) & String:
  match al ap bp cp dp pendingPair:
    case (alive,l), (a,at), (b,bt), (c,ct), (d,dt), (commands,n):(W.World{ns,next,high,alive,capacity,depth,Store{a,b},Resources{c,d},events,commands,registrations,nextSystem,clock},"World{ns=" ++ U32.show(ns) ++ ",next=" ++ U32.show(next) ++ ",high=" ++ U32.show(high) ++ ",live=" ++ l ++ ",capacity=" ++ U32.show(capacity) ++ ",depth=" ++ Nat.show(depth) ++ ",store=" ++ at ++ "/" ++ bt ++ ",resources=" ++ ct ++ "/" ++ dt ++ ",events=" ++ List.show(&2,U32,U32.show,events) ++ ",pending=" ++ Nat.show(n) ++ ",registrations=" ++ List.show(&2,W.RegistrationMeta,meta,registrations) ++ ",nextSystem=" ++ U32.show(nextSystem) ++ ",clock=" ++ U32.show(clock) ++ "}")
def observe_world(~S:Data,world:World(S)) -> World(S) & String:
  match world:
    case W.World{+ns,+next,+high,alive,+capacity,+depth,Store{a,b},Resources{c,d},+events,commands,+registrations,+nextSystem,+clock}:world_view(~S,ns,next,high,capacity,depth,events,registrations,nextSystem,clock,live(alive),array(a),array(b),array(c),array(d),pending(~S,commands))
def session_view(~S:Data,registry:Registry(S),observed:World(S) & String,contextPair:Array<U32> & String) -> Session<S> & String:
  match registry observed contextPair:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}, (world,w), (context,c):(Session{world,Sys.Registry{ns,id,name,access,cursor},context},w ++ "|Registry{" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,(x => x),access) ++ ":" ++ U32.show(cursor) ++ "}|context=" ++ c)
def observe(~S:Data,session:Session<S>) -> Session<S> & String:
  match session:
    case Session{world,registry,context}:session_view(~S,registry,observe_world(~S,world),array(context))
def run_result(~S:Data,result:Sys.RunResult<S,Store,Resources,U32,Array<U32> & Input(S),String,RunOutput<S>,(world => args => runner(~S,world,args))>) -> Session<S> & Output(S):
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,RunOutput{context,output}}}:(Session{world,registry,context},output)
    case Sys.Completed{registry,Sys.Failed{world,error}}:(Session{world,registry,ALeaf{0}},Cmd.Refused{Unit{},AD.ConstructionRefused{[Some{error}]}})
    case Sys.RegistrationRejected{registry,world,(context,input)}:(Session{world,registry,context},Cmd.Refused{Unit{},AD.EntityRefused{W.MissingEntity{}}})
def run(~S:Data,session:Session<S>,operation:Cmd.Operation<S>) -> Session<S> & Output(S):
  match session:
    case Session{world,registry,context}:run_result(~S,Sys.run_tracked(~S,~Store,~Resources,~U32,~(Array<U32> & Input(S)),~String,~RunOutput<S>,~(world => args => runner(~S,world,args)),registry,world,(context,Cmd.Input{operation,Unit{}})))
def barrier(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,registry,context}:Session{W.barrier(~S,~Store,~Resources,~U32,world),registry,context}
def missing_view(~S:Data,rows:List<&2,String>,prefix:String,observed:Session<S> & String) -> List<&2,String>:
  match observed:
    case (session,view):List.append(&2,String,rows,[prefix ++ view])
def missing_done(~S:Data,rows:List<&2,String>,result:Session<S> & Output(S)) -> List<&2,String>:
  match result:
    case (session,Cmd.Refused{Unit{},AD.EntityRefused{W.MissingEntity{}}}):missing_view(~S,rows,"missing=MissingEntity,raw=Unit|",observe(~S,session))
    case (session,output):missing_view(~S,rows,"unexpected-missing|",observe(~S,session))
def insert_again(~S:Data,rows:List<&2,String>,observed:Session<S> & String) -> List<&2,String>:
  match observed:
    case (session,view):missing_done(~S,List.append(&2,String,rows,["insert-empty-barrier|" ++ view]),run(~S,session,Cmd.Insert{W.Handle{0,0}}))
def insert_after(~S:Data,rows:List<&2,String>,observed:Session<S> & String) -> List<&2,String>:
  match observed:
    case (session,view):insert_again(~S,List.append(&2,String,rows,["insert-barrier|" ++ view]),observe(~S,barrier(~S,session)))
def insert_queued(~S:Data,rows:List<&2,String>,observed:Session<S> & String) -> List<&2,String>:
  match observed:
    case (session,view):insert_after(~S,List.append(&2,String,rows,["insert-queued|" ++ view]),observe(~S,barrier(~S,session)))
def insert_done(~S:Data,rows:List<&2,String>,result:Session<S> & Output(S)) -> List<&2,String>:
  match result:
    case (session,Cmd.Accepted{_,False{}}):insert_queued(~S,rows,observe(~S,session))
    case (session,output):missing_view(~S,rows,"unexpected-insert|",observe(~S,session))
def spawn_again(~S:Data,target:W.Handle<S>,rows:List<&2,String>,observed:Session<S> & String) -> List<&2,String>:
  match observed:
    case (session,view):insert_done(~S,List.append(&2,String,rows,["spawn-empty-barrier|" ++ view]),run(~S,session,Cmd.Insert{target}))
def spawn_after(~S:Data,target:W.Handle<S>,rows:List<&2,String>,observed:Session<S> & String) -> List<&2,String>:
  match observed:
    case (session,view):spawn_again(~S,target,List.append(&2,String,rows,["spawn-barrier|" ++ view]),observe(~S,barrier(~S,session)))
def spawn_queued(~S:Data,target:W.Handle<S>,rows:List<&2,String>,observed:Session<S> & String) -> List<&2,String>:
  match observed:
    case (session,view):spawn_after(~S,target,List.append(&2,String,rows,["spawn-queued|" ++ view]),observe(~S,barrier(~S,session)))
def spawn_done(~S:Data,rows:List<&2,String>,result:Session<S> & Output(S)) -> List<&2,String>:
  match result:
    case (session,Cmd.Accepted{target,True{}}):spawn_queued(~S,target,rows,observe(~S,session))
    case (session,output):missing_view(~S,rows,"unexpected-spawn|",observe(~S,session))
def initial(~S:Data,observed:Session<S> & String) -> List<&2,String>:
  match observed:
    case (session,view):spawn_done(~S,["before|" ++ view],run(~S,session,Cmd.Spawn{}))
def missing_world(~S:Data,observed:World(S) & String) -> List<&2,String>:
  match observed:
    case (world,view):["unexpected-registration|" ++ view]
def registered(~S:Data,result:Sys.RegistrationResult<S,Store,Resources,U32,Array<U32> & Input(S),String,RunOutput<S>,(world => args => runner(~S,world,args))>) -> List<&2,String>:
  match result:
    case Sys.Registered{world,registry}:initial(~S,observe(~S,Session{world,registry,ANode{ALeaf{51},ALeaf{52}}}))
    case Sys.RegistrationFailed{world}:missing_world(~S,observe_world(~S,world))
def empty(unit:Unit) -> Store:Store{ANode{ALeaf{11},ALeaf{12}},ANode{ALeaf{21},ALeaf{22}}}
def created(~S:Data,result:W.Creation<S,Store,Resources,U32>) -> W.Factory & List<&2,String>:
  match result:
    case W.Created{factory,world}:(factory,registered(~S,Sys.register(~S,~Store,~Resources,~U32,~(Array<U32> & Input(S)),~String,~RunOutput<S>,~(world => args => runner(~S,world,args)),world,"empty-bundle",["bundle:write"])))
    case W.CreateRejected{factory,resource}:(factory,["unexpected-creation"])
def begin(~S:Data,factory:W.Factory) -> W.Factory & List<&2,String>:created(~S,W.create(~S,~Store,~Resources,~U32,~empty,factory,Resources{ANode{ALeaf{31},ALeaf{32}},ANode{ALeaf{41},ALeaf{42}}}))
