import Base
import ./change-tick.bend as Tick
import ./world.bend as W
import ./system.bend as Sys
import ./ordinary-system.bend as System
import ./ordinary-resource-system.bend as Resource
import ./ordinary-query-declaration.bend as Query
# Sole ordinary registration fields; no detached debug Binding or cached description.
# The private trusted token holds the actual registration's erased runner authority.
# Mixed readers retain each operational source rather than inferring modes from access strings.
# Detached classification of declared component, resource or event usage.
type UseCategory is Data:
  ComponentUse{}
  ResourceUse{}
  EventUse{}
# Detached origin of a read declaration, including distinct notice streams.
type ReaderSource is Data:
  QuerySource{}
  MessageSource{}
  RemovalSource{}
  RelationFailureSource{}
# Detached key/mode and source of one declared access; not runtime authority.
type DeclaredUse is Data:
  DeclaredUse{category:UseCategory,source:ReaderSource,key:String,mode:Query.Mode}
# Detached registration category; mixed registrations retain each declared use.
type RegistrationKind is Data:
  ComponentKind{}
  ResourceKind{mode:Query.Mode}
  FieldKind{}
  ServiceKind{}
  EventKind{}
  MixedKind{uses:List<&2,DeclaredUse>}
# Detached advanced registration description: namespace/ID/name/access,
# cursor, authored slot/query clauses and operation kind. This Data record
# is observation metadata; it does not independently prove a live registration
# or authorize execution without its matching typed token and World checks.
type Fields<S:Data> is Data:
  Fields{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>,slot:String,clauses:List<&2,Query.Clause<S>>,kind:RegistrationKind}
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

# Field declarations retain each canonical clause, including mixed read/write packs.
def field_registry(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,slot:String,clauses:List<&2,Query.Clause<S>>,registry:Sys.Registry<S,C,R,E,Args,Error,Out,runner>) -> Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>> & Fields<S>:
  match registry:
    case Sys.Registry{namespace,id,name,access,cursor}:(Token{},Fields{namespace,id,name,access,cursor,slot,clauses,FieldKind{}})
