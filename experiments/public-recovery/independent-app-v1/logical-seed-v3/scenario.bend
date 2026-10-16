import Base
import ../successor-v2/application.bend as Game
import ../successor-v2/observe.bend as O
import ../../heterogeneous-v1/schema.bend as Schema
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/lifecycle.bend as Life
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/ordinary-recovery-system.bend as System
import ../../../../src/ecs/transaction.bend as T
type Scene is Data:Scene{}
# Trusted World setup; component placement uses logical IDs through Column operations.
# This fixture isolates recovery; creation/foreign authority has separate acceptance.
def two(a:U32,b:U32) -> Array<U32>:ANode{ALeaf{a},ALeaf{b}}
def original() -> Array<Array<U32>>:ANode{ALeaf{two(41,97)},ALeaf{ALeaf{203}}}
def sibling() -> Array<Array<U32>>:ALeaf{ANode{two(5,8),two(13,21)}}
def resource_before() -> Array<Array<U32>>:ANode{ALeaf{ALeaf{77}},ALeaf{two(88,99)}}
def capture_before() -> Array<Array<U32>>:ALeaf{ANode{two(102,103),two(104,105)}}
def resource_attempt() -> Array<Array<U32>>:ALeaf{ANode{two(301,302),two(303,304)}}
def capture_attempt() -> Array<Array<U32>>:ANode{ALeaf{two(401,402)},ALeaf{ALeaf{403}}}
def resource_commit() -> Array<Array<U32>>:ANode{ALeaf{ALeaf{501}},ALeaf{two(502,503)}}
def capture_commit() -> Array<Array<U32>>:ALeaf{two(601,602)}
def release(~P:Type,owner:P) -> Unit:Unit{}
def seed_inserted(~P:Type,result:Col.SwapOutcome<Scene,P>) -> Col.Column<Scene,P> & Bool:
  match result:
    case Col.Accepted{column,previous}:
      match previous:
        case None{}:(column,True{})
        case Some{displaced}:
          discarded = release(~P,displaced)
          (column,False{})
    case Col.Rejected{column,incoming}:
      discarded = release(~Maybe<&1,P>,incoming)
      (column,False{})
def seed_column(~P:Type,first:P,second:P,stamp1:Life.Stamp,stamp2:Life.Stamp) -> Col.Column<Scene,P> & Bool:
  O.bind(~Col.Column<Scene,P>,~Bool,~(Col.Column<Scene,P> & Bool),seed_inserted(~P,Col.swap(~Scene,~P,Col.ensure(~Scene,~P,Col.empty(~Scene,~P),4),1,Some{first})),column => first_ok => (
    O.bind(~Col.Column<Scene,P>,~Bool,~(Col.Column<Scene,P> & Bool),seed_inserted(~P,Col.swap(~Scene,~P,column,2,Some{second})),column => second_ok => (
      (Col.restore_stamp(~Scene,~P,Col.restore_stamp(~Scene,~P,column,2,stamp2),1,stamp1),Bool.and(first_ok,second_ok))
    ))
  ))
def bootstrap() -> Game.World(~Scene) & Bool:
  O.bind(~Col.Column<Scene,Array<Array<U32>>>,~Bool,~(Game.World(~Scene) & Bool),seed_column(~Array<Array<U32>>,original(),sibling(),Life.Stamp{3,8},Life.Stamp{4,9}),first => first_ok => (
    O.bind(~Col.Column<Scene,Array<U32>>,~Bool,~(Game.World(~Scene) & Bool),seed_column(~Array<U32>,two(17,19),ALeaf{23},Life.Stamp{2,5},Life.Stamp{6,10}),second => second_ok => (
      (W.World{7,3,2,ANode{ANode{ALeaf{False{}},ALeaf{True{}}},ANode{ALeaf{True{}},ALeaf{False{}}}},4,2n,Product.Owner{first,second},resource_before(),[],[],[],1,11},Bool.and(first_ok,second_ok))
    ))
  ))
def release_result(~S:Data,recovery:Game.Recovery(~S),output:Game.Output,text:String) -> String:
  discarded_recovery = release(~Game.Recovery(~S),recovery)
  discarded_output = release(~Game.Output,output)
  text
def snapshot_result(~S:Data,world:Game.World(~S),owner:Game.Instance(~S),+outcome:T.Outcome<Game.Error>,output:Game.Output,recovery:Game.Recovery(~S)) -> Game.World(~S) & (Game.Instance(~S) & String):
  O.bind(~Game.World(~S),~String,~(Game.World(~S) & (Game.Instance(~S) & String)),O.world(~S,world),world => w => (
    O.bind(~Game.Instance(~S),~String,~(Game.World(~S) & (Game.Instance(~S) & String)),O.owner(~S,owner),owner => o => (
      O.bind(~Game.Output,~String,~(Game.World(~S) & (Game.Instance(~S) & String)),O.output(output),output => result => (
        O.bind(~Game.Recovery(~S),~String,~(Game.World(~S) & (Game.Instance(~S) & String)),O.recovery(~S,recovery),recovery => r => (
          (world,(owner,release_result(~S,recovery,output,"outcome=" ++ O.outcome(outcome) ++ ";" ++ result ++ ";" ++ w ++ ";" ++ o ++ ";" ++ r)))
        ))
      ))
    ))
  ))
def rejected_released(~S:Data,target:W.Handle<S>,resource:Array<Array<U32>>,capture:Array<Array<U32>>,abort:Bool,r:String,c:String) -> String:
  discarded_resource = release(~Array<Array<U32>>,resource)
  discarded_capture = release(~Array<Array<U32>>,capture)
  "args(target=" ++ O.handle(~S,target) ++ ",resource=" ++ r ++ ",capture=" ++ c ++ ",abort=" ++ Bool.show(abort) ++ ")"
def rejected_args(~S:Data,args:Game.Args<S>) -> String:
  match args:
    case Game.Args{target,resource,capture,abort}:
      O.bind(~Array<Array<U32>>,~String,~String,O.matrix(resource),resource => r => (
        O.bind(~Array<Array<U32>>,~String,~String,O.matrix(capture),capture => c => (
          rejected_released(~S,target,resource,capture,abort,r,c)
        ))
      ))
type Observed<S:Data> is Type:
  Ready{world:Game.World(~S),owner:Game.Instance(~S),text:String}
  Stopped{text:String}
def ready(~S:Data,result:Game.World(~S) & (Game.Instance(~S) & String)) -> Observed<S>:
  match result:
    case (world,(owner,text)):Ready{world,owner,text}
def transport_released(~S:Data,world:Game.World(~S),text:String) -> Observed<S>:
  discarded_world = release(~Game.World(~S),world)
  Stopped{"TransportFailed;" ++ text}
def snapshot(~S:Data,result:Game.Run(~S)) -> Observed<S>:
  match result:
    case System.Completed{world,owner,outcome,output,recovery}:ready(~S,snapshot_result(~S,world,owner,outcome,output,recovery))
    case System.RegistrationRejected{world,owner,args}:
      O.bind(~Game.World(~S),~String,~Observed<S>,O.world(~S,world),world => w => (
        O.bind(~Game.Instance(~S),~String,~Observed<S>,O.owner(~S,owner),owner => o => (
          Ready{world,owner,"RegistrationRejected;" ++ w ++ ";" ++ o ++ ";" ++ rejected_args(~S,args)}
        ))
      ))
    case System.TransportFailed{world}:
      O.bind(~Game.World(~S),~String,~Observed<S>,O.world(~S,world),world => text => transport_released(~S,world,text))
def final(result:Observed<Scene>) -> String:
  match result:
    case Ready{world,owner,text}:
      discarded_world = release(~Game.World(~Scene),world)
      discarded_owner = release(~Game.Instance(~Scene),owner)
      text
    case Stopped{text}:text
def committed(prefix:String,result:Observed<Scene>) -> String:
  prefix ++ "\ncommit:" ++ final(result)
def retry(initial:String,result:Observed<Scene>) -> String:
  match result:
    case Ready{world,owner,text}:
      committed(initial ++ "\nrollback:" ++ text,snapshot(~Scene,Game.run(~Scene,owner,world,Game.Args{W.Handle{7,1},resource_commit(),capture_commit(),False{}})))
    case Stopped{text}:initial ++ "\nrollback:" ++ text
def started(world:Game.World(~Scene),owner:Game.Instance(~Scene)) -> String:
  O.bind(~Game.World(~Scene),~String,~String,O.world(~Scene,world),world => w => (
    O.bind(~Game.Instance(~Scene),~String,~String,O.owner(~Scene,owner),owner => o => (
      retry("initial:" ++ w ++ ";" ++ o,snapshot(~Scene,Game.run(~Scene,owner,world,Game.Args{W.Handle{7,1},resource_attempt(),capture_attempt(),True{}})))
    ))
  ))
def definition_released(world:Game.World(~Scene),capture:Array<Array<U32>>,w:String,c:String) -> String:
  discarded_world = release(~Game.World(~Scene),world)
  discarded_capture = release(~Array<Array<U32>>,capture)
  "DefinitionRejected;" ++ w ++ ";capture=" ++ c
def defined(result:System.Defined<Game.World(~Scene),Game.Instance(~Scene),Array<Array<U32>>>) -> String:
  match result:
    case System.Defined{world,owner}:started(world,owner)
    case System.DefinitionRejected{world,capture}:
      O.bind(~Game.World(~Scene),~String,~String,O.world(~Scene,world),world => w => (
        O.bind(~Array<Array<U32>>,~String,~String,O.matrix(capture),capture => c => definition_released(world,capture,w,c))
      ))
def seeded_ready(world:Game.World(~Scene),valid:Bool) -> String:
  match valid:
    case True{}:defined(Game.define(~Scene,world,capture_before()))
    case False{}:
      discarded_world = release(~Game.World(~Scene),world)
      "SeedFailed"
def scenario() -> String:O.bind(~Game.World(~Scene),~Bool,~String,bootstrap(),world => valid => seeded_ready(world,valid))
