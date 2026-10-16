import Base
import ../payload.bend as P
import ../system.bend as Sys
import ../scenario.bend as S
import ../format.bend as F
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/local.bend as L
import ../../../../src/ecs/captures.bend as Capture
import ../../../../src/ecs/ordinary-app-local-fields.bend as Ord

type Workshop is Data:
  Workshop{}
type Garden is Data:
  Garden{}
type Metadata is Data:
  Metadata{namespace:U32,id:U32,name:String,access:List<&2,String>}
# Only metadata is copied. The exact returned affine pack rebuilds a stale token.
def snapshot_join(~S:Data,label:String,a:W.World<S,Unit,U32,Unit> & S.WorldView,b:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)> & S.OwnerView) -> W.World<S,Unit,U32,Unit> & (L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)> & String):
  match a b:
    case (world,w), (instance,owner):(world,(instance,label ++ "|" ++ F.world(w) ++ "|" ++ F.owner(owner) ++ "\n"))
def snapshot(~S:Data,label:String,world:W.World<S,Unit,U32,Unit>,instance:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>) -> W.World<S,Unit,U32,Unit> & (L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)> & String):
  snapshot_join(~S,label,S.world_view(~S,world),S.owner_view(~S,instance))
def final(~S:Data,prefix:String,observed:W.World<S,Unit,U32,Unit> & (L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)> & String)) -> String:
  match observed:
    case (world,(instance,line)):prefix ++ line
def second_result(~S:Data,metadata:Metadata,prefix:String,result:L.Disposal<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),P.Pack>) -> String:
  match metadata result:
    case metadata L.DisposalRejected{world,instance}:final(~S,prefix,snapshot(~S,"second-refused",world,instance))
    case Metadata{ns,id,name,access} L.Disposed{world,pack}:final(~S,prefix,snapshot(~S,"second-disposed",world,L.Instance{ns,id,name,access,pack}))
def second(~S:Data,metadata:Metadata,prefix:String,observed:W.World<S,Unit,U32,Unit> & (L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)> & String)) -> String:
  match observed:
    case (world,(instance,line)):second_result(~S,metadata,prefix ++ line,Capture.unregister(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),instance,world))
def first_result(~S:Data,metadata:Metadata,prefix:String,result:L.Disposal<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),P.Pack>) -> String:
  match metadata result:
    case metadata L.DisposalRejected{world,instance}:final(~S,prefix,snapshot(~S,"first-refused",world,instance))
    case Metadata{+ns,+id,+name,+access} L.Disposed{world,pack}:second(~S,Metadata{ns,id,name,access},prefix,snapshot(~S,"first-disposed",world,L.Instance{ns,id,name,access,pack}))
def first(~S:Data,observed:W.World<S,Unit,U32,Unit> & (L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)> & String)) -> String:
  match observed:
    case (world,(L.Instance{+ns,+id,+name,+access,pack},line)):first_result(~S,Metadata{ns,id,name,access},line,Capture.unregister(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),L.Instance{ns,id,name,access,pack},world))
def registered(~S:Data,result:L.Registered<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>) -> String:
  match result:
    case L.Registered{world,instance}:first(~S,snapshot(~S,"registered",world,instance))
    case L.RegistrationRejected{world,pack}:"registration-refused\n"
def created(~S:Data,result:WI.Creation<S,Unit,U32,Unit>) -> IO(String):
  match result:
    case WI.Created{world}:IO.pure(String,registered(~S,S.define(~S,world,"repeated",P.initial(1))))
    case _:IO.die(String,1,"world creation failed")
def empty(unit:Unit) -> Unit:
  Unit{}
def run(~S:Data) -> IO(String):
  IO.bind(WI.Creation<S,Unit,U32,Unit>,String,WI.create(~S,~Unit,~U32,~Unit,~empty,10),created(~S))
def printed(a:String,b:String) -> IO(Unit):
  IO.print("Workshop\n" ++ a ++ "Garden\n" ++ b)
def workshop(a:String) -> IO(Unit):
  IO.bind(String,Unit,run(~Garden),b => printed(a,b))
def main() -> IO(Unit):
  IO.bind(String,Unit,run(~Workshop),workshop)
