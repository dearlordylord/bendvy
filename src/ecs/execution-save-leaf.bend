import Base
import ./execution-save-recipe.bend as Recipe
import ./execution-composer-layout.bend as Layout
import ./ordinary-declaration.bend as C
import ./persistence-declaration.bend as Decl
import ./decode-data.bend as D
import ./chunk-column.bend as Column
import ./chunk-partition.bend as Partition
import ./change-tick.bend as Tick
import ./execution-query-identity.bend as Index
import ./lifecycle.bend as Life

def viewed_returned(~S:Data,~P:Type,~V:Data,~identity:C.Declaration<S,P>,~project:P -> P & D.Raw,view:V,result:Recipe.Leaf<S,P,identity,project> & (P & Recipe.Field)) -> Layout.Viewed<P,V> & Recipe.Field:
  match result:
    case (_, (owner,field)):(Layout.Viewed{owner,view},field)
def viewed(~S:Data,~P:Type,~V:Data,~identity:C.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,stored:Layout.Viewed<P,V>) -> Layout.Viewed<P,V> & Recipe.Field:
  match stored:
    case Layout.Viewed{owner,view}:viewed_returned(~S,~P,~V,~identity,~project,view,Recipe.export(~S,~P,~identity,~project,Recipe.Constructed{declaration},owner))
def column_returned(~S:Data,~P:Type,~V:Data,~identity:C.Declaration<S,P>,~project:P -> P & D.Raw,~key:String,~origin:Layout.Layout,declaration:Decl.Constructed<S,P,identity,project>,result:Column.Column<S,Layout.Viewed<P,V>> & Maybe<&2,Recipe.Field>) -> Recipe.Leaf<S,P,identity,project> & (Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & Maybe<&2,Recipe.Field>):
  match result:
    case (column,field):(Recipe.Constructed{declaration},(Layout.ColumnSlot{column},field))
def column_offset(~S:Data,~P:Type,~V:Data,~identity:C.Declaration<S,P>,~project:P -> P & D.Raw,~key:String,~origin:Layout.Layout,+declaration:Decl.Constructed<S,P,identity,project>,column:Column.Column<S,Layout.Viewed<P,V>>,offset:Maybe<&2,U32>) -> Recipe.Leaf<S,P,identity,project> & (Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & Maybe<&2,Recipe.Field>):
  match offset:
    case None{}:(Recipe.Constructed{declaration},(Layout.ColumnSlot{column},None{}))
    case Some{index}:column_returned(~S,~P,~V,~identity,~project,~key,~origin,declaration,Column.edit_search(~S,~(Layout.Viewed<P,V>),~Recipe.Field,viewed(~S,~P,~V,~identity,~project,declaration),15n,Column.Visit{column,index,Column.Root{}},Tick.zero(),False{}))
def column_valid(~S:Data,~P:Type,~V:Data,~identity:C.Declaration<S,P>,~project:P -> P & D.Raw,~key:String,~origin:Layout.Layout,declaration:Decl.Constructed<S,P,identity,project>,logical:U32,column:Column.Column<S,Layout.Viewed<P,V>>,valid:Bool) -> Recipe.Leaf<S,P,identity,project> & (Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & Maybe<&2,Recipe.Field>):
  match valid:
    case False{}:(Recipe.Constructed{declaration},(Layout.ColumnSlot{column},Some{Recipe.Refused{Recipe.MalformedColumn{key}}}))
    case True{}:column_offset(~S,~P,~V,~identity,~project,~key,~origin,declaration,column,Index.physical_index(logical))
def column_inspected(~S:Data,~P:Type,~V:Data,~identity:C.Declaration<S,P>,~project:P -> P & D.Raw,~key:String,~origin:Layout.Layout,declaration:Decl.Constructed<S,P,identity,project>,logical:U32,result:Column.Column<S,Layout.Viewed<P,V>> & Partition.Inspection) -> Recipe.Leaf<S,P,identity,project> & (Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & Maybe<&2,Recipe.Field>):
  match result:
    case (column,Partition.Inspection{_,capacity,valid}):column_valid(~S,~P,~V,~identity,~project,~key,~origin,declaration,logical,column,Bool.and(valid,U32.is_le(capacity,Column.maximum_capacity())))
# The surrounding save traverses actual World.handles, then converts its logical
# key once. Reads preserve cached views and lifecycle stamps without refresh.
def component(~S:Data,~P:Type,~V:Data,~identity:C.Declaration<S,P>,~project:P -> P & D.Raw,~key:String,~origin:Layout.Layout,recipe:Recipe.Leaf<S,P,identity,project>,slot:Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin>,logical:U32) -> Recipe.Leaf<S,P,identity,project> & (Layout.ColumnSlot<S,Layout.Viewed<P,V>,key,origin> & Maybe<&2,Recipe.Field>):
  match recipe slot:
    case Recipe.Plain{} slot:(Recipe.Plain{},(slot,Some{Recipe.Refused{Recipe.PlainUnserializable{key}}}))
    case Recipe.Transient{} slot:(Recipe.Transient{},(slot,None{}))
    case Recipe.Constructed{declaration} Layout.ColumnSlot{column}:column_inspected(~S,~P,~V,~identity,~project,~key,~origin,declaration,logical,Partition.inspect(S,Layout.Viewed<P,V>,column))
def resource_returned(~S:Data,~P:Type,~V:Data,~identity:C.Declaration<S,P>,~project:P -> P & D.Raw,~key:String,~origin:Layout.Layout,view:V,stamp:Life.Stamp,result:Recipe.Leaf<S,P,identity,project> & (P & Recipe.Field)) -> Recipe.Leaf<S,P,identity,project> & (Layout.ResourceSlot<S,Layout.Viewed<P,V>,key,origin> & Recipe.Field):
  match result:
    case (recipe,(owner,field)):(recipe,(Layout.ResourceSlot{Layout.Viewed{owner,view},stamp},field))
def resource(~S:Data,~P:Type,~V:Data,~identity:C.Declaration<S,P>,~project:P -> P & D.Raw,~key:String,~origin:Layout.Layout,recipe:Recipe.Leaf<S,P,identity,project>,slot:Layout.ResourceSlot<S,Layout.Viewed<P,V>,key,origin>) -> Recipe.Leaf<S,P,identity,project> & (Layout.ResourceSlot<S,Layout.Viewed<P,V>,key,origin> & Recipe.Field):
  match slot:
    case Layout.ResourceSlot{Layout.Viewed{owner,view},stamp}:resource_returned(~S,~P,~V,~identity,~project,~key,~origin,view,stamp,Recipe.export(~S,~P,~identity,~project,recipe,owner))
