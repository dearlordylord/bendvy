import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-system.bend as Res
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query

def metadata_returned(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,same:Bool,registry:Sys.Registry<S,C,R,E,Args,Error,Out,runner>,observed:W.World<S,C,R,E> & Bool) -> Sys.Registry<S,C,R,E,Args,Error,Out,runner> & (W.World<S,C,R,E> & Bool):
  match observed:
    case (world,allowed):(registry,(world,Bool.and(same,allowed)))
def namespace_registry(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,world:W.World<S,C,R,E>,actual:U32,registry:Sys.Registry<S,C,R,E,Args,Error,Out,runner>) -> Sys.Registry<S,C,R,E,Args,Error,Out,runner> & (W.World<S,C,R,E> & Bool):
  match registry:
    case Sys.Registry{+namespace,+id,+name,+access,cursor}:metadata_returned(~S,~C,~R,~E,~Args,~Error,~Out,~runner,U32.is_eq(namespace,actual),Sys.Registry{namespace,id,name,access,cursor},W.registration_matches(~S,~C,~R,~E,world,id,name,access))
def namespace_returned(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,registry:Sys.Registry<S,C,R,E,Args,Error,Out,runner>,observed:W.World<S,C,R,E> & U32) -> Sys.Registry<S,C,R,E,Args,Error,Out,runner> & (W.World<S,C,R,E> & Bool):
  match observed:
    case (world,actual):namespace_registry(~S,~C,~R,~E,~Args,~Error,~Out,~runner,world,actual,registry)
def validate_registry(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,registry:Sys.Registry<S,C,R,E,Args,Error,Out,runner>,world:W.World<S,C,R,E>) -> Sys.Registry<S,C,R,E,Args,Error,Out,runner> & (W.World<S,C,R,E> & Bool):
  namespace_returned(~S,~C,~R,~E,~Args,~Error,~Out,~runner,registry,W.namespace(~S,~C,~R,~E,world))
def resource_returned(~S:Data,~C:Type,~R:Type,~E:Data,~CA:Data,~CE:Data,~CO:Data,~RA:Type,~RE:Data,~RO:Type,~kind:Query.Mode,~crun:W.World<S,C,R,E> -> (CA & U32) -> Sys.Outcome<W.World<S,C,R,E>,CE,List<&2,CO>>,~rrun:W.World<S,C,R,E> -> RA -> Sys.Outcome<W.World<S,C,R,E>,RE,RO>,component:Ord.Owner<S,Sys.Registry<S,C,R,E,CA & U32,CE,List<&2,CO>,crun>>,slot:String,prior:Bool,result:Sys.Registry<S,C,R,E,RA,RE,RO,rrun> & (W.World<S,C,R,E> & Bool)) -> (Ord.Owner<S,Sys.Registry<S,C,R,E,CA & U32,CE,List<&2,CO>,crun>> & Res.Owner<S,Sys.Registry<S,C,R,E,RA,RE,RO,rrun>,kind>) & (W.World<S,C,R,E> & Bool):
  match result:
    case (registry,(world,allowed)):((component,Res.Owner{registry,slot}),(world,Bool.and(prior,allowed)))
def resource(~S:Data,~C:Type,~R:Type,~E:Data,~CA:Data,~CE:Data,~CO:Data,~RA:Type,~RE:Data,~RO:Type,~kind:Query.Mode,~crun:W.World<S,C,R,E> -> (CA & U32) -> Sys.Outcome<W.World<S,C,R,E>,CE,List<&2,CO>>,~rrun:W.World<S,C,R,E> -> RA -> Sys.Outcome<W.World<S,C,R,E>,RE,RO>,component:Ord.Owner<S,Sys.Registry<S,C,R,E,CA & U32,CE,List<&2,CO>,crun>>,owner:Res.Owner<S,Sys.Registry<S,C,R,E,RA,RE,RO,rrun>,kind>,prior:Bool,world:W.World<S,C,R,E>) -> (Ord.Owner<S,Sys.Registry<S,C,R,E,CA & U32,CE,List<&2,CO>,crun>> & Res.Owner<S,Sys.Registry<S,C,R,E,RA,RE,RO,rrun>,kind>) & (W.World<S,C,R,E> & Bool):
  match owner:
    case Res.Owner{registry,slot}:resource_returned(~S,~C,~R,~E,~CA,~CE,~CO,~RA,~RE,~RO,~kind,~crun,~rrun,component,slot,prior,validate_registry(~S,~C,~R,~E,~RA,~RE,~RO,~rrun,registry,world))
def component_returned(~S:Data,~C:Type,~R:Type,~E:Data,~CA:Data,~CE:Data,~CO:Data,~RA:Type,~RE:Data,~RO:Type,~kind:Query.Mode,~crun:W.World<S,C,R,E> -> (CA & U32) -> Sys.Outcome<W.World<S,C,R,E>,CE,List<&2,CO>>,~rrun:W.World<S,C,R,E> -> RA -> Sys.Outcome<W.World<S,C,R,E>,RE,RO>,owner:Res.Owner<S,Sys.Registry<S,C,R,E,RA,RE,RO,rrun>,kind>,slot:String,clauses:List<&2,Query.Clause<S>>,result:Sys.Registry<S,C,R,E,CA & U32,CE,List<&2,CO>,crun> & (W.World<S,C,R,E> & Bool)) -> (Ord.Owner<S,Sys.Registry<S,C,R,E,CA & U32,CE,List<&2,CO>,crun>> & Res.Owner<S,Sys.Registry<S,C,R,E,RA,RE,RO,rrun>,kind>) & (W.World<S,C,R,E> & Bool):
  match result:
    case (registry,(world,allowed)):resource(~S,~C,~R,~E,~CA,~CE,~CO,~RA,~RE,~RO,~kind,~crun,~rrun,Ord.Owner{registry,slot,clauses},owner,allowed,world)
def validate(~S:Data,~C:Type,~R:Type,~E:Data,~CA:Data,~CE:Data,~CO:Data,~RA:Type,~RE:Data,~RO:Type,~kind:Query.Mode,~crun:W.World<S,C,R,E> -> (CA & U32) -> Sys.Outcome<W.World<S,C,R,E>,CE,List<&2,CO>>,~rrun:W.World<S,C,R,E> -> RA -> Sys.Outcome<W.World<S,C,R,E>,RE,RO>,owners:(Ord.Owner<S,Sys.Registry<S,C,R,E,CA & U32,CE,List<&2,CO>,crun>> & Res.Owner<S,Sys.Registry<S,C,R,E,RA,RE,RO,rrun>,kind>),world:W.World<S,C,R,E>) -> (Ord.Owner<S,Sys.Registry<S,C,R,E,CA & U32,CE,List<&2,CO>,crun>> & Res.Owner<S,Sys.Registry<S,C,R,E,RA,RE,RO,rrun>,kind>) & (W.World<S,C,R,E> & Bool):
  match owners:
    case (Ord.Owner{registry,slot,clauses},other):component_returned(~S,~C,~R,~E,~CA,~CE,~CO,~RA,~RE,~RO,~kind,~crun,~rrun,other,slot,clauses,validate_registry(~S,~C,~R,~E,~(CA & U32),~CE,~List<&2,CO>,~crun,registry,world))
