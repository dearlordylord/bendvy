import Base
import ./execution-save-data.bend as Saved
import ./execution-save-recipe.bend as Recipe
import ./execution-composer-layout.bend as Layout
import ./chunk-column.bend as Column
import ./chunk-partition.bend as Part
import ./execution-query-identity.bend as Index
import ./lifecycle.bend as Life
import ./decode-data.bend as D
import ./decode-size.bend as Size

type Mode is Data:
  Plain{}
  Transient{}
  Constructed{codec:D.Codec}
def field(+key:String,stamp:Maybe<&2,Life.Stamp>,value:Maybe<&2,Recipe.Field>) -> Saved.Fields:
  match value:
    case None{}:Saved.Fields{[Saved.Field{key,False{},Saved.Absent{},stamp}],None{}}
    case Some{Recipe.Omitted{}}:Saved.Fields{[Saved.Field{key,True{},Saved.Omitted{},stamp}],None{}}
    case Some{Recipe.Saved{D.Field{_,raw}}}:Saved.Fields{[Saved.Field{key,True{},Saved.Persisted{raw},stamp}],None{}}
    case Some{Recipe.Refused{reason}}:Saved.error(reason)
def checked(-P:Type,owner:P,key:String,+codec:D.Codec,+fuel:Nat,checked:D.Checked) -> P & Recipe.Field:
  match checked:
    case D.Accepted{raw}:(owner,Recipe.Saved{D.Field{key,D.canonical(fuel,codec,raw)}})
    case D.Rejected{error}:(owner,Recipe.Refused{Recipe.InvalidProjection{key,error}})
def budgeted(-P:Type,owner:P,key:String,+codec:D.Codec,+raw:D.Raw,+fuel:Nat) -> P & Recipe.Field:
  checked(P,owner,key,codec,fuel,D.validate(fuel,D.Continue{[D.Work{codec,raw,"$"}]},raw))
def projected(-P:Type,key:String,+codec:D.Codec,result:P & D.Raw) -> P & Recipe.Field:
  match result:
    case (owner,+raw):budgeted(P,owner,key,codec,raw,Size.budget(codec,raw))
def describe(-P:Type,mode:Mode,key:String,project:P -> P & D.Raw,owner:P) -> P & Recipe.Field:
  match mode:
    case Plain{}:(owner,Recipe.Refused{Recipe.PlainUnserializable{key}})
    case Transient{}:(owner,Recipe.Omitted{})
    case Constructed{codec}:projected(P,key,codec,project(owner))
def viewed_returned(-P:Type,-V:Data,view:V,result:P & Recipe.Field) -> Layout.Viewed<P,V> & Recipe.Field:
  match result:
    case (owner,field):(Layout.Viewed{owner,view},field)
def viewed(-P:Type,-V:Data,mode:Mode,key:String,project:P -> P & D.Raw,stored:Layout.Viewed<P,V>) -> Layout.Viewed<P,V> & Recipe.Field:
  match stored:
    case Layout.Viewed{owner,view}:viewed_returned(P,V,view,describe(P,mode,key,project,owner))
def restored_value(-S:Data,-P:Type,values:Array<Maybe<&1,P>>,stamps:Array<Life.Stamp>,index:U32,stamp:Life.Stamp,result:P & Recipe.Field) -> Column.Column<S,P> & (Maybe<&2,Recipe.Field> & Maybe<&2,Life.Stamp>):
  match result:
    case (owner,field):(Column.Leaf{Array.set(Maybe<&1,P>,values,index,Some{owner}),stamps},(Some{field},Some{stamp}))
def taken(-S:Data,-P:Type,project:P -> P & Recipe.Field,stamps:Array<Life.Stamp>,index:U32,stamp:Life.Stamp,result:Array<Maybe<&1,P>> & Maybe<&1,P>) -> Column.Column<S,P> & (Maybe<&2,Recipe.Field> & Maybe<&2,Life.Stamp>):
  match result:
    case (values,None{}):(Column.Leaf{values,stamps},(None{},Some{stamp}))
    case (values,Some{owner}):restored_value(S,P,values,stamps,index,stamp,project(owner))
def stamp_read(-S:Data,-P:Type,project:P -> P & Recipe.Field,values:Array<Maybe<&1,P>>,+index:U32,result:Array<Life.Stamp> & Life.Stamp) -> Column.Column<S,P> & (Maybe<&2,Recipe.Field> & Maybe<&2,Life.Stamp>):
  match result:
    case (stamps,stamp):taken(S,P,project,stamps,index,stamp,Array.swap(Maybe<&1,P>,values,index,None{}))
def leaf(-S:Data,-P:Type,project:P -> P & Recipe.Field,values:Array<Maybe<&1,P>>,stamps:Array<Life.Stamp>,+index:U32,allowed:Bool) -> Column.Column<S,P> & (Maybe<&2,Recipe.Field> & Maybe<&2,Life.Stamp>):
  match allowed:
    case False{}:(Column.Leaf{values,stamps},(None{},None{}))
    case True{}:stamp_read(S,P,project,values,index,Array.get(Life.Stamp,stamps,index))
def branches(-S:Data,-P:Type,half:U32,leftResult:Column.Column<S,P> & (Maybe<&2,Recipe.Field> & Maybe<&2,Life.Stamp>),rightResult:Column.Column<S,P> & (Maybe<&2,Recipe.Field> & Maybe<&2,Life.Stamp>),first:Bool) -> Column.Column<S,P> & (Maybe<&2,Recipe.Field> & Maybe<&2,Life.Stamp>):
  match leftResult rightResult first:
    case (left,value), (right,_), True{}:(Column.Branch{half,left,right},value)
    case (left,_), (right,value), False{}:(Column.Branch{half,left,right},value)
def branch(-S:Data,-P:Type,left:Maybe<&1,P -> P & Recipe.Field> -> Column.Column<S,P> & (Maybe<&2,Recipe.Field> & Maybe<&2,Life.Stamp>),right:Maybe<&1,P -> P & Recipe.Field> -> Column.Column<S,P> & (Maybe<&2,Recipe.Field> & Maybe<&2,Life.Stamp>),half:U32,project:P -> P & Recipe.Field,first:Bool) -> Column.Column<S,P> & (Maybe<&2,Recipe.Field> & Maybe<&2,Life.Stamp>):
  match first:
    case True{}:branches(S,P,half,left(Some{project}),right(None{}),True{})
    case False{}:branches(S,P,half,left(None{}),right(Some{project}),False{})
def project_column(-S:Data,-P:Type,column:Column.Column<S,P>,+index:U32,project:Maybe<&1,P -> P & Recipe.Field>) -> Column.Column<S,P> & (Maybe<&2,Recipe.Field> & Maybe<&2,Life.Stamp>):
  match column project:
    case column None{}:(column,(None{},None{}))
    case Column.Leaf{values,stamps} Some{project}:leaf(S,P,project,values,stamps,index,U32.is_lt(index,8))
    case Column.Branch{+half,left,right} Some{project}:branch(S,P,project_column(S,P,left,index),project_column(S,P,right,U32.sub(index,half)),half,project,U32.is_lt(index,half))
def component_returned(-S:Data,-P:Type,-V:Data,+key:String,-origin:Layout.Layout,result:Column.Column<S,Layout.Viewed<P,V>> & (Maybe<&2,Recipe.Field> & Maybe<&2,Life.Stamp>)) -> Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & Saved.Fields:
  match result:
    case (column,(value,stamp)):(Layout.ColumnSlot{column},field(key,stamp,value))
def component_offset(-S:Data,-P:Type,-V:Data,+key:String,-origin:Layout.Layout,mode:Mode,project:P -> P & D.Raw,column:Column.Column<S,Layout.Viewed<P,V>>,offset:Maybe<&2,U32>) -> Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & Saved.Fields:
  match offset:
    case None{}:(Layout.ColumnSlot{column},Saved.error(Recipe.MalformedColumn{key}))
    case Some{index}:component_returned(S,P,V,key,origin,project_column(S,Layout.Viewed<P,V>,column,index,Some{stored => viewed(P,V,mode,key,project,stored)}))
def component_valid(-S:Data,-P:Type,-V:Data,+key:String,-origin:Layout.Layout,mode:Mode,project:P -> P & D.Raw,column:Column.Column<S,Layout.Viewed<P,V>>,logical:U32,valid:Bool) -> Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & Saved.Fields:
  match valid:
    case False{}:(Layout.ColumnSlot{column},Saved.error(Recipe.MalformedColumn{key}))
    case True{}:component_offset(S,P,V,key,origin,mode,project,column,Index.physical_index(logical))
def component_inspected(-S:Data,-P:Type,-V:Data,+key:String,-origin:Layout.Layout,mode:Mode,project:P -> P & D.Raw,logical:U32,result:Column.Column<S,Layout.Viewed<P,V>> & Part.Inspection) -> Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & Saved.Fields:
  match result:
    case (column,Part.Inspection{_,capacity,valid}):component_valid(S,P,V,key,origin,mode,project,column,logical,Bool.and(valid,U32.is_le(capacity,Column.maximum_capacity())))
def component(-S:Data,-P:Type,-V:Data,+key:String,-origin:Layout.Layout,mode:Mode,project:P -> P & D.Raw,slot:Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin>,logical:U32) -> Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & Saved.Fields:
  match slot:
    case Layout.ColumnSlot{column}:component_inspected(S,P,V,key,origin,mode,project,logical,Part.inspect(S,Layout.Viewed<P,V>,column))
def resource_returned(-S:Data,-P:Type,-V:Data,+key:String,-origin:Layout.Layout,view:V,+stamp:Life.Stamp,result:P & Recipe.Field) -> Layout.ResourceSlot<S,Layout.Viewed<P,V>,key,origin> & Saved.Fields:
  match result:
    case (owner,value):(Layout.ResourceSlot{Layout.Viewed{owner,view},stamp},field(key,Some{stamp},Some{value}))
def resource(-S:Data,-P:Type,-V:Data,+key:String,-origin:Layout.Layout,mode:Mode,project:P -> P & D.Raw,slot:Layout.ResourceSlot<S,Layout.Viewed<P,V>,key,origin>) -> Layout.ResourceSlot<S,Layout.Viewed<P,V>,key,origin> & Saved.Fields:
  match slot:
    case Layout.ResourceSlot{Layout.Viewed{owner,view},stamp}:resource_returned(S,P,V,key,origin,view,stamp,describe(P,mode,key,project,owner))
