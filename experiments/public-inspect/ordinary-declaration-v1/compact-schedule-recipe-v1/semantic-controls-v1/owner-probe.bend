import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as Component
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-system.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
def text(value:String) -> String:
  value
def registry(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,value:Sys.Registry<S,C,R,E,Args,Error,Out,runner>) -> Sys.Registry<S,C,R,E,Args,Error,Out,runner> & String:
  match value:
    case Sys.Registry{+namespace,+id,+name,+access,+cursor}:(Sys.Registry{namespace,id,name,access,cursor},U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":access=" ++ List.show(&2,String,text,access) ++ ":cursor=" ++ U32.show(cursor))
def kind(value:Query.Mode) -> String:
  match value:
    case Query.Read{}:"Read"
    case Query.Write{}:"Write"
    case Query.Optional{}:"Optional"
    case Query.With{}:"With"
    case Query.Without{}:"Without"
    case Query.Added{}:"Added"
    case Query.Changed{}:"Changed"
def clause(~S:Data,value:Query.Clause<S>) -> String:
  match value:
    case Query.Clause{key,mode}:key ++ ":" ++ kind(mode)
def component_returned(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,+slot:String,+clauses:List<&2,Query.Clause<S>>,result:Sys.Registry<S,C,R,E,Args,Error,Out,runner> & String) -> Component.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>> & String:
  match result:
    case (registry,text):(Component.Owner{registry,slot,clauses},text ++ ":slot=" ++ slot ++ ":clauses=" ++ List.show(&2,Query.Clause<S>,clause(~S),clauses))
def component(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,owner:Component.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>>) -> Component.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>> & String:
  match owner:
    case Component.Owner{registered,slot,clauses}:component_returned(~S,~C,~R,~E,~Args,~Error,~Out,~runner,slot,clauses,registry(~S,~C,~R,~E,~Args,~Error,~Out,~runner,registered))
def resource_returned(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~mode:Query.Mode,+slot:String,result:Sys.Registry<S,C,R,E,Args,Error,Out,runner> & String) -> Resource.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,mode> & String:
  match result:
    case (registry,text):(Resource.Owner{registry,slot},text ++ ":slot=" ++ slot ++ ":mode=" ++ kind(mode))
def resource(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~mode:Query.Mode,owner:Resource.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,mode>) -> Resource.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,mode> & String:
  match owner:
    case Resource.Owner{registered,slot}:resource_returned(~S,~C,~R,~E,~Args,~Error,~Out,~runner,~mode,slot,registry(~S,~C,~R,~E,~Args,~Error,~Out,~runner,registered))
def resource_finished(~S:Data,~C:Type,~R:Type,~E:Data,~CE:Data,~RE:Data,~mode:Query.Mode,~crun:W.World<S,C,R,E> -> (Unit & U32) -> Sys.Outcome<W.World<S,C,R,E>,CE,List<&2,Unit>>,~rrun:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,RE,Unit>,componentOwner:Component.Owner<S,Sys.Registry<S,C,R,E,Unit & U32,CE,List<&2,Unit>,crun>>,first:String,result:Resource.Owner<S,Sys.Registry<S,C,R,E,Unit,RE,Unit,rrun>,mode> & String) -> (Component.Owner<S,Sys.Registry<S,C,R,E,Unit & U32,CE,List<&2,Unit>,crun>> & Resource.Owner<S,Sys.Registry<S,C,R,E,Unit,RE,Unit,rrun>,mode>) & String:
  match result:
    case (resourceOwner,second):((componentOwner,resourceOwner),"owners=[" ++ first ++ "," ++ second ++ "]")
def component_finished(~S:Data,~C:Type,~R:Type,~E:Data,~CE:Data,~RE:Data,~mode:Query.Mode,~crun:W.World<S,C,R,E> -> (Unit & U32) -> Sys.Outcome<W.World<S,C,R,E>,CE,List<&2,Unit>>,~rrun:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,RE,Unit>,resourceOwner:Resource.Owner<S,Sys.Registry<S,C,R,E,Unit,RE,Unit,rrun>,mode>,result:Component.Owner<S,Sys.Registry<S,C,R,E,Unit & U32,CE,List<&2,Unit>,crun>> & String) -> (Component.Owner<S,Sys.Registry<S,C,R,E,Unit & U32,CE,List<&2,Unit>,crun>> & Resource.Owner<S,Sys.Registry<S,C,R,E,Unit,RE,Unit,rrun>,mode>) & String:
  match result:
    case (componentOwner,first):resource_finished(~S,~C,~R,~E,~CE,~RE,~mode,~crun,~rrun,componentOwner,first,resource(~S,~C,~R,~E,~Unit,~RE,~Unit,~rrun,~mode,resourceOwner))
def owners(~S:Data,~C:Type,~R:Type,~E:Data,~CE:Data,~RE:Data,~mode:Query.Mode,~crun:W.World<S,C,R,E> -> (Unit & U32) -> Sys.Outcome<W.World<S,C,R,E>,CE,List<&2,Unit>>,~rrun:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,RE,Unit>,owner:(Component.Owner<S,Sys.Registry<S,C,R,E,Unit & U32,CE,List<&2,Unit>,crun>> & Resource.Owner<S,Sys.Registry<S,C,R,E,Unit,RE,Unit,rrun>,mode>)) -> (Component.Owner<S,Sys.Registry<S,C,R,E,Unit & U32,CE,List<&2,Unit>,crun>> & Resource.Owner<S,Sys.Registry<S,C,R,E,Unit,RE,Unit,rrun>,mode>) & String:
  match owner:
    case (componentOwner,resourceOwner):component_finished(~S,~C,~R,~E,~CE,~RE,~mode,~crun,~rrun,resourceOwner,component(~S,~C,~R,~E,~(Unit & U32),~CE,~List<&2,Unit>,~crun,componentOwner))
