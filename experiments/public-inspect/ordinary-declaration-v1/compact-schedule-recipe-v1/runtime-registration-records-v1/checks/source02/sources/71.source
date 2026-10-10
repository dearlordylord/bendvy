import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-system.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
# Sole ordinary registration fields; no detached debug Binding or cached description.
# The private trusted token holds the actual registration's erased runner authority.
type RegistrationKind is Data:
  ComponentKind{}
  ResourceKind{mode:Query.Mode}
type Fields<S:Data> is Data:
  Fields{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32,slot:String,clauses:List<&2,Query.Clause<S>>,kind:RegistrationKind}
type Token<-Registry:Type> is Type:
  Token{}
def component_registry(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,slot:String,clauses:List<&2,Query.Clause<S>>,registry:Sys.Registry<S,C,R,E,Args,Error,Out,runner>) -> Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>> & Fields<S>:
  match registry:
    case Sys.Registry{namespace,id,name,access,cursor}:(Token{},Fields{namespace,id,name,access,cursor,slot,clauses,ComponentKind{}})
def component(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,owner:System.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>>) -> Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>> & Fields<S>:
  match owner:
    case System.Owner{registry,slot,clauses}:component_registry(~S,~C,~R,~E,~Args,~Error,~Out,~runner,slot,clauses,registry)
def restored_registry(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,fields:Fields<S>) -> System.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>>:
  match fields:
    case Fields{namespace,id,name,access,cursor,slot,clauses,_}:System.Owner{Sys.Registry{namespace,id,name,access,cursor},slot,clauses}
def restore_component(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,token:Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>>,fields:Fields<S>) -> System.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>>:
  match token:
    case Token{}:restored_registry(~S,~C,~R,~E,~Args,~Error,~Out,~runner,fields)
def resource_registry(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~mode:Query.Mode,slot:String,registry:Sys.Registry<S,C,R,E,Args,Error,Out,runner>) -> Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>> & Fields<S>:
  match registry:
    case Sys.Registry{namespace,id,name,access,cursor}:(Token{},Fields{namespace,id,name,access,cursor,slot,[],ResourceKind{mode}})
def resource(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~mode:Query.Mode,owner:Resource.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,mode>) -> Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>> & Fields<S>:
  match owner:
    case Resource.Owner{registry,slot}:resource_registry(~S,~C,~R,~E,~Args,~Error,~Out,~runner,~mode,slot,registry)
def restored_resource(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~mode:Query.Mode,fields:Fields<S>) -> Resource.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,mode>:
  match fields:
    case Fields{namespace,id,name,access,cursor,slot,_,_}:Resource.Owner{Sys.Registry{namespace,id,name,access,cursor},slot}
def restore_resource(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~mode:Query.Mode,token:Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>>,fields:Fields<S>) -> Resource.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,mode>:
  match token:
    case Token{}:restored_resource(~S,~C,~R,~E,~Args,~Error,~Out,~runner,~mode,fields)
