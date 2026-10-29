import Base
import ./decode-data.bend as D
import ./lifecycle.bend as Life
import ./entity-key.bend as Key
import ./execution-save-metadata.bend as Metadata
import ./execution-save-recipe.bend as Recipe

type Value is Data:
  Absent{}
  Omitted{}
  Persisted{raw:D.Raw}
type Field is Data:
  Field{key:String,present:Bool,value:Value,stamp:Maybe<&2,Life.Stamp>}
type Fields is Data:
  Fields{values:List<&2,Field>,error:Maybe<&2,Recipe.Refusal>}
type Entity is Data:
  Entity{key:Key.Key,fields:List<&2,Field>}
type Snapshot<-S:Data> is Data:
  Snapshot{version:U32,metadata:Metadata.Metadata<S>,entities:List<&2,Entity>,resources:List<&2,Field>}
def empty() -> Fields:Fields{[],None{}}
def error(error:Recipe.Refusal) -> Fields:Fields{[],Some{error}}
def first(left:Maybe<&2,Recipe.Refusal>,right:Maybe<&2,Recipe.Refusal>) -> Maybe<&2,Recipe.Refusal>:
  match left:
    case Some{error}:Some{error}
    case None{}:right
def join(left:Fields,right:Fields) -> Fields:
  match left right:
    case Fields{leftValues,leftError} Fields{rightValues,rightError}:Fields{List.append(&2,Field,leftValues,rightValues),first(leftError,rightError)}
