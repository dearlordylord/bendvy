import Base
import ./dependency-composer-program.bend as Scoped
import ./dependency-plan.bend as Plan
import ./schema-fragments.bend as Fragment
import ./execution-declaration.bend as D

type Error is Data:
  Schema{error:Fragment.Error}
  Schedule{error:Plan.Invalid<String>}
  Nesting{error:Scoped.NestError}
def first_error(first:Maybe<&2,Error>,second:Maybe<&2,Error>) -> Maybe<&2,Error>:
  match first:
    case Some{error}:Some{error}
    case None{}:second
def schema_error(value:Fragment.Validation) -> Maybe<&2,Error>:
  match value:
    case Fragment.Valid{}:None{}
    case Fragment.Invalid{error}:Some{Schema{error}}
def schedule_error(value:Maybe<&2,Plan.Invalid<String>>) -> Maybe<&2,Error>:
  match value:
    case None{}:None{}
    case Some{error}:Some{Schedule{error}}
def kind_key(kind:Fragment.RegistryKind,key:String) -> String:
  match kind:
    case Fragment.Component{}:D.requirement_key(D.ComponentAccess{},key)
    case Fragment.Resource{}:D.requirement_key(D.ResourceAccess{},key)
    case Fragment.Service{}:D.requirement_key(D.ServiceAccess{},key)
    case Fragment.Event{}:"event/" ++ key
    case Fragment.Relation{}:"relation/" ++ key
def entry_key(~S:Data,entry:Fragment.Entry<S>) -> String:
  match entry:
    case Fragment.Entry{kind,key,_}:kind_key(kind,key)
    case Fragment.Classified{kind,key,_,_}:kind_key(kind,key)
def provides(~S:Data,entries:List<&2,Fragment.Entry<S>>,+key:String) -> Bool:
  match entries:
    case []:False{}
    case entry <> rest:Bool.or(String.eq(entry_key(~S,entry),key),provides(~S,rest,key))
def missing_step(available:Bool,id:U32,key:String,next:Maybe<&2,Plan.Invalid<String>>) -> Maybe<&2,Plan.Invalid<String>>:
  match available:
    case True{}:next
    case False{}:Some{Plan.Missing{id,key}}
def missing_needs(~S:Data,needs:List<&2,String>,+entries:List<&2,Fragment.Entry<S>>,+id:U32) -> Maybe<&2,Plan.Invalid<String>>:
  match needs:
    case []:None{}
    case +key <> rest:missing_step(provides(~S,entries,key),id,key,missing_needs(~S,rest,entries,id))
def missing(~S:Data,nodes:List<&2,Plan.Node<String>>,+entries:List<&2,Fragment.Entry<S>>) -> Maybe<&2,Plan.Invalid<String>>:
  match nodes:
    case []:None{}
    case Plan.Node{id,needs} <> rest:Plan.first_error(~String,missing_needs(~S,needs,entries,id),missing(~S,rest,entries))
def available(key:String) -> Bool:True{}
