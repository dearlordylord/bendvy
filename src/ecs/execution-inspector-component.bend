import Base
import ./inspector.bend as I
import ./inspector-query.bend as Query
import ./inspector-query-projection.bend as Rows
import ./capabilities.bend as Cap
import ./component.bend as Component
import ./world.bend as W
import ./execution-composer-layout.bend as Layout
import ./execution-layout-access.bend as Access
import ./execution-query-identity.bend as Identity
import ./chunk-column.bend as Column
import ./lifecycle.bend as Life
import ./change-tick.bend as Tick
import ./check.bend as Check

# Cached Data views and actual column owners follow the same full-origin lens.
# Physical indexing is reached only after canonical full-handle validation.
def viewed(~S:Data,~layout:Layout.Layout,~route:Layout.Route,stamp:Life.Stamp,result:Column.Column<S,Layout.stored(layout,route)> & Maybe<&2,Layout.view(layout,route)>) -> Column.Column<S,Layout.stored(layout,route)> & (Maybe<&2,Layout.view(layout,route)> & Life.Stamp):
  match result:
    case (column,value):(column,(value,stamp))
def stamped(~S:Data,~layout:Layout.Layout,~route:Layout.Route,index:U32,result:Column.Column<S,Layout.stored(layout,route)> & Maybe<&2,Life.Stamp>) -> Column.Column<S,Layout.stored(layout,route)> & (Maybe<&2,Layout.view(layout,route)> & Life.Stamp):
  match result:
    case (column,None{}):viewed(~S,~layout,~route,Life.Stamp{None{},None{}},Column.view(~S,~Layout.stored(layout,route),~Layout.view(layout,route),~Layout.read(~Layout.payload(layout,route),~Layout.view(layout,route)),column,index))
    case (column,Some{stamp}):viewed(~S,~layout,~route,stamp,Column.view(~S,~Layout.stored(layout,route),~Layout.view(layout,route),~Layout.read(~Layout.payload(layout,route),~Layout.view(layout,route)),column,index))
def column_returned(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},rest:Layout.column_rest(~S,layout,route),result:Column.Column<S,Layout.stored(layout,route)> & (Maybe<&2,Layout.view(layout,route)> & Life.Stamp)) -> C & (Maybe<&2,Layout.view(layout,route)> & Life.Stamp):
  match result:
    case (column,value):(Access.column_put(~S,~C,~layout,~route,~same,rest,column),value)
def column_taken(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},+index:U32,result:Layout.column_rest(~S,layout,route) & Column.Column<S,Layout.stored(layout,route)>) -> C & (Maybe<&2,Layout.view(layout,route)> & Life.Stamp):
  match result:
    case (rest,column):column_returned(~S,~C,~layout,~route,~same,rest,stamped(~S,~layout,~route,index,Column.lifecycle(~S,~Layout.stored(layout,route),column,index)))
def column_read(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},index:U32,columns:C) -> C & (Maybe<&2,Layout.view(layout,route)> & Life.Stamp):
  column_taken(~S,~C,~layout,~route,~same,index,Access.column_take(~S,~C,~layout,~route,~same,columns))
def world_returned(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,cursor:Maybe<&2,Tick.Tick>,result:W.World<S,C,R,E> & (Maybe<&2,V> & Life.Stamp)) -> I.Frame<S,C,R,E> & I.Value<V>:
  match result:
    case (world,(None{},stamp)):I.family_join(~S,~C,~R,~E,~V,cursor,stamp,(world,Component.ComponentAbsent{}))
    case (world,(Some{value},stamp)):I.family_join(~S,~C,~R,~E,~V,cursor,stamp,(world,Component.Found{value}))
def offset(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},cursor:Maybe<&2,Tick.Tick>,result:W.World<S,C,R,E> & Identity.Offset<S>) -> I.Frame<S,C,R,E> & I.Value<Layout.view(layout,route)>:
  match result:
    case (world,Identity.Physical{_,index}):world_returned(~S,~C,~R,~E,~Layout.view(layout,route),cursor,W.with_store(~S,~C,~R,~E,~(Maybe<&2,Layout.view(layout,route)> & Life.Stamp),column_read(~S,~C,~layout,~route,~same,index),world))
    case (world,_):(I.Frame{world,cursor},I.Value{Component.MissingEntity{},False{},False{}})
def get(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},frame:I.Frame<S,C,R,E>,target:W.Handle<S>) -> I.Frame<S,C,R,E> & I.Value<Layout.view(layout,route)>:
  match frame:
    case I.Frame{world,cursor}:offset(~S,~C,~R,~E,~layout,~route,~same,cursor,Identity.world_offset(~S,~C,~R,~E,world,Column.maximum_capacity(),target))
def lookup(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool}) -> I.Lookup<I.Frame<S,C,R,E>,S,Layout.view(layout,route)>:
  I.Lookup{get(~S,~C,~R,~E,~layout,~route,~same)}

def read_rows(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~selection:Rows.Selection,handles:List<&2,W.Handle<S>>,frame:I.Frame<S,C,R,E>,rows:List<&2,Rows.Row<S,Layout.view(layout,route)>>) -> I.Frame<S,C,R,E> & List<&2,Rows.Row<S,Layout.view(layout,route)>>:
  match handles:
    case []:(frame,List.reverse(&2,Rows.Row<S,Layout.view(layout,route)>,rows))
    case +target <> rest:Rows.read_row(~S,~C,~R,~E,~Layout.view(layout,route),~selection,target,rows,(frame=>rows=>read_rows(~S,~C,~R,~E,~layout,~route,~same,~selection,rest,frame,rows)),get(~S,~C,~R,~E,~layout,~route,~same,frame,target))
def handles(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~selection:Rows.Selection,cursor:Maybe<&2,Tick.Tick>,result:W.World<S,C,R,E> & List<&2,W.Handle<S>>) -> I.Frame<S,C,R,E> & List<&2,Rows.Row<S,Layout.view(layout,route)>>:
  match result:
    case (world,handles):read_rows(~S,~C,~R,~E,~layout,~route,~same,~selection,handles,I.Frame{world,cursor},[])
def scan(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~selection:Rows.Selection,frame:I.Frame<S,C,R,E>) -> I.Frame<S,C,R,E> & List<&2,Rows.Row<S,Layout.view(layout,route)>>:
  match frame:
    case I.Frame{world,cursor}:handles(~S,~C,~R,~E,~layout,~route,~same,~selection,cursor,W.handles(~S,~C,~R,~E,world))
def query(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~selection:Rows.Selection) -> Query.ReadQuery<I.Frame<S,C,R,E>,S,Layout.view(layout,route)>:
  Query.ReadQuery{Cap.ValueRead{scan(~S,~C,~R,~E,~layout,~route,~same,~selection)},lookup(~S,~C,~R,~E,~layout,~route,~same,~valid),selection}
def check_rows(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,result:I.Frame<S,C,R,E> & List<&2,Rows.Row<S,V>>) -> Check.Frame<S,C,R,E> & List<&2,Check.Row<S,V>>:
  match result:
    case (I.Frame{world,_},rows):(Check.Frame{world},Check.plain_rows(~S,~V,rows))
def check_scan(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~selection:Check.PlainSelection,frame:Check.Frame<S,C,R,E>) -> Check.Frame<S,C,R,E> & List<&2,Check.Row<S,Layout.view(layout,route)>>:
  match frame:
    case Check.Frame{world}:check_rows(~S,~C,~R,~E,~Layout.view(layout,route),scan(~S,~C,~R,~E,~layout,~route,~same,~Check.selection(selection),I.Frame{world,None{}}))
def check_query(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~selection:Check.PlainSelection) -> Cap.ValueRead<Check.Frame<S,C,R,E>,List<&2,Check.Row<S,Layout.view(layout,route)>>>:
  Cap.ValueRead{check_scan(~S,~C,~R,~E,~layout,~route,~same,~selection)}
