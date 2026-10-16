import Base
import ./application.bend as Game
import ./observe.bend as O
import ../heterogeneous-v1/schema.bend as Schema
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/lifecycle.bend as Life
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/ordinary-recovery-system.bend as System
import ../../../src/ecs/transaction.bend as T
type Scene is Data:Scene{}
# Trusted seed: two live entities, independent first/second columns, nontrivial stamps.
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
def bootstrap() -> Game.World(~Scene):
  first : Col.Column<Scene,Array<Array<U32>>> = Col.Column{ANode{ANode{ALeaf{None{}},ALeaf{Some{original()}}},ANode{ALeaf{Some{sibling()}},ALeaf{None{}}}},[Life.Entry{1,Life.Stamp{3,8}},Life.Entry{2,Life.Stamp{4,9}}]}
  second : Col.Column<Scene,Array<U32>> = Col.Column{ANode{ANode{ALeaf{None{}},ALeaf{Some{two(17,19)}}},ANode{ALeaf{Some{ALeaf{23}}},ALeaf{None{}}}},[Life.Entry{1,Life.Stamp{2,5}},Life.Entry{2,Life.Stamp{6,10}}]}
  W.World{7,3,2,ANode{ANode{ALeaf{False{}},ALeaf{True{}}},ANode{ALeaf{True{}},ALeaf{False{}}}},4,2n,Product.Owner{first,second},resource_before(),[],[],[],1,11}
def release(~P:Type,owner:P) -> Unit:Unit{}
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
def scenario() -> String:defined(Game.define(~Scene,bootstrap(),capture_before()))
