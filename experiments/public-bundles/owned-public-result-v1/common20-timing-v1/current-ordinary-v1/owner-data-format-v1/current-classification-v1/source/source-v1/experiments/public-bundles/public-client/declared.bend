import Base
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/owner-data-format-v1/current-classification-v1/source/source-v1/experiments/public-bundles/public.bend as P
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/owner-data-format-v1/current-classification-v1/source/source-v1/experiments/public-bundles/public-client/trusted.bend as T
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/owner-data-format-v1/current-classification-v1/source/source-v1/experiments/public-bundles/public-client/gameplay.bend as G
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/owner-data-format-v1/current-classification-v1/source/source-v1/experiments/public-bundles/combined-control.bend as A
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/owner-data-format-v1/current-classification-v1/source/source-v1/experiments/public-bundles/constructor-control.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/bundle-pack.bend as PackPack
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as SF

type AToken is Data:
  AToken{}
type BToken is Data:
  BToken{}
type TagToken is Data:
  TagToken{}
type ValueToken is Data:
  ValueToken{}
type SpawnToken is Data:
  SpawnToken{}
def a() -> SF.Descriptor<A.Schema,AToken,Array<U32>>:
  SF.Descriptor{SF.Component{},"a","a"}
def b() -> SF.Descriptor<A.Schema,BToken,Array<U32>>:
  SF.Descriptor{SF.Component{},"b","b"}
def tag() -> SF.Descriptor<A.Schema,TagToken,K.Tag>:
  SF.Descriptor{SF.Component{},"tag","tag"}
def value() -> SF.Descriptor<A.Schema,ValueToken,U32>:
  SF.Descriptor{SF.Component{},"value","value"}
def spawn() -> SF.Descriptor<A.Schema,SpawnToken,Unit>:
  SF.Descriptor{SF.Service{},"bundle.spawn","bundle.spawn"}
def a_entry() -> SF.Entry<A.Schema>:
  SF.entry(~A.Schema,~AToken,~Array<U32>,a())
def b_entry() -> SF.Entry<A.Schema>:
  SF.entry(~A.Schema,~BToken,~Array<U32>,b())
def tag_entry() -> SF.Entry<A.Schema>:
  SF.entry(~A.Schema,~TagToken,~K.Tag,tag())
def value_entry() -> SF.Entry<A.Schema>:
  SF.entry(~A.Schema,~ValueToken,~U32,value())
def spawn_entry() -> SF.Entry<A.Schema>:
  SF.entry(~A.Schema,~SpawnToken,~Unit,spawn())
def required() -> List<&2,SF.Entry<A.Schema>>:
  [a_entry(),a_entry(),b_entry(),tag_entry(),value_entry(),spawn_entry()]
def available() -> List<&2,SF.Entry<A.Schema>>:
  [a_entry(),b_entry(),tag_entry(),value_entry(),spawn_entry()]
def finished(observed:W.World<A.Schema,A.Store,A.Mail,U32> & Unit) -> Sys.Outcome<W.World<A.Schema,A.Store,A.Mail,U32>,Unit,Unit>:
  match observed:
    case (world,Unit{}): Sys.Succeeded{world,Unit{}}
def runner(world:W.World<A.Schema,A.Store,A.Mail,U32>,payload:PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>) -> Sys.Outcome<W.World<A.Schema,A.Store,A.Mail,U32>,Unit,Unit>:
  finished(P.provide(~W.World<A.Schema,A.Store,A.Mail,U32>,~PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,~T.Observation,~T.request,~G.run,payload,world))
type Launched is Type:
  Launched{result:Sys.RunResult<A.Schema,A.Store,A.Mail,U32,PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,Unit,Unit,runner>}
  RegistrationFailed{world:W.World<A.Schema,A.Store,A.Mail,U32>,payload:PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>}
def registered(payload:PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,observed:Sys.RegistrationResult<A.Schema,A.Store,A.Mail,U32,PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,Unit,Unit,runner>) -> Launched:
  match observed:
    case Sys.Registered{world,registry}: Launched{Sys.run(~A.Schema,~A.Store,~A.Mail,~U32,~PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,~Unit,~Unit,~runner,registry,world,payload)}
    case Sys.RegistrationFailed{world}: RegistrationFailed{world,payload}
def launch(owners:W.World<A.Schema,A.Store,A.Mail,U32> & PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>) -> Launched:
  match owners:
    case (world,payload): registered(payload,Sys.register(~A.Schema,~A.Store,~A.Mail,~U32,~PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,~Unit,~Unit,~runner,world,"bundle",["write:a","write:front","write:b","write:tag","write:value","spawn"]))
def provision(+entries:List<&2,SF.Entry<A.Schema>>,world:W.World<A.Schema,A.Store,A.Mail,U32>,payload:PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>) -> SF.Bound<A.Schema,W.World<A.Schema,A.Store,A.Mail,U32> & PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,Launched>:
  P.provision_declared(~A.Schema,~(W.World<A.Schema,A.Store,A.Mail,U32> & PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>),~Launched,~launch,SF.Fragment{entries,(world,payload)},required())
def identity(text:String) -> String:
  text
def kind_text(kind:SF.RegistryKind) -> String:
  match kind:
    case SF.Component{}: "component"
    case SF.Resource{}: "resource"
    case SF.Event{}: "event"
    case SF.Relation{}: "relation"
    case SF.Service{}: "service"
def entry_text_bare(entry:SF.Entry<A.Schema>) -> String:
  match entry:
    case SF.Entry{kind,key,name}: kind_text(kind) ++ ":" ++ key ++ ":" ++ name
    case SF.Classified{kind,key,name,_}: kind_text(kind) ++ ":" ++ key ++ ":" ++ name
def entry_text(entry:SF.Entry<A.Schema>) -> String:
  entry_text_bare(SF.bare_entry(~A.Schema,entry))
def registry_meta(entry:W.RegistrationMeta) -> String:
  match entry:
    case W.RegistrationMeta{id,name,access}: U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,identity,access)
def world_text(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,mail,events,commands,+regs,+system,clock}: "world-regs=" ++ List.show(&2,W.RegistrationMeta,registry_meta,regs) ++ "|next-system=" ++ U32.show(system) ++ "|" ++ A.snapshot(W.World{ns,next,high,live,cap,depth,store,mail,events,commands,regs,system,clock})
def reg_text(registry:Sys.Registry<A.Schema,A.Store,A.Mail,U32,PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,Unit,Unit,runner>) -> String:
  match registry:
    case Sys.Registry{ns,id,name,access,cursor}: U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,identity,access) ++ ":" ++ U32.show(cursor)
def run_text(result:Sys.RunResult<A.Schema,A.Store,A.Mail,U32,PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,Unit,Unit,runner>) -> String:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,Unit{}}}: "registry=" ++ reg_text(registry) ++ "|" ++ world_text(world)
    case Sys.Completed{registry,Sys.Failed{world,error}}: "FAILED|registry=" ++ reg_text(registry) ++ "|" ++ world_text(world)
    case Sys.RegistrationRejected{registry,world,payload}: "REJECTED|registry=" ++ reg_text(registry) ++ "|" ++ world_text(world) ++ "|input=" ++ K.raw_0(payload)
def output_text(output:Launched) -> String:
  match output:
    case Launched{result}: run_text(result)
    case RegistrationFailed{world,payload}: "REGISTRATION_FAILED|" ++ world_text(world) ++ "|input=" ++ K.raw_0(payload)
def bound_text(bound:SF.Bound<A.Schema,W.World<A.Schema,A.Store,A.Mail,U32> & PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,Launched>) -> String:
  match bound:
    case SF.Built{output}: output_text(output)
    case SF.BindRejected{SF.UndeclaredDescriptor{kind,key,name},SF.Fragment{entries,(world,payload)}}: "missing=" ++ kind_text(kind) ++ ":" ++ key ++ ":" ++ name ++ "|catalog=" ++ List.show(&2,SF.Entry<A.Schema>,entry_text,entries) ++ "|" ++ world_text(world) ++ "|input=" ++ K.raw_0(payload)
    case SF.BindRejected{error,fragment}: "UNEXPECTED_ERROR"
def missing_b() -> List<&2,SF.Entry<A.Schema>>:
  [a_entry(),tag_entry(),value_entry(),spawn_entry()]
def missing_spawn() -> List<&2,SF.Entry<A.Schema>>:
  [a_entry(),b_entry(),tag_entry(),value_entry()]
def wrong_b() -> List<&2,SF.Entry<A.Schema>>:
  [a_entry(),SF.Entry{SF.Resource{},"b","b"},tag_entry(),value_entry(),spawn_entry()]
def retry(bound:SF.Bound<A.Schema,W.World<A.Schema,A.Store,A.Mail,U32> & PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,Launched>) -> SF.Bound<A.Schema,W.World<A.Schema,A.Store,A.Mail,U32> & PackPack.Pack<K.Raw<Array<U32>>,PackPack.Pack<K.Raw<U32>,PackPack.Pack<K.Raw<K.Tag>,PackPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,Launched>:
  match bound:
    case SF.BindRejected{error,SF.Fragment{entries,(world,payload)}}: provision(available(),world,payload)
    case bound: bound
def main() -> IO(Unit):
  IO.print("missing-b=" ++ bound_text(provision(missing_b(),A.fresh(20),K.input(True{},True{}))) ++ "\nmissing-spawn=" ++ bound_text(provision(missing_spawn(),A.fresh(20),K.input(True{},True{}))) ++ "\nwrong-b=" ++ bound_text(provision(wrong_b(),A.fresh(20),K.input(True{},True{}))) ++ "\nvalid=" ++ bound_text(provision(available(),A.fresh(20),K.input(True{},True{}))) ++ "\ninvalid=" ++ bound_text(provision(available(),A.fresh(20),K.input(False{},False{}))) ++ "\nretry=" ++ bound_text(retry(provision(missing_b(),A.fresh(20),K.input(True{},True{})))))
