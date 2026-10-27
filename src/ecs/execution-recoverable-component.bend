import Base
import ./world.bend as W
import ./chunk-column.bend as Column
import ./execution-composer-layout.bend as Layout
import ./execution-layout-access.bend as Access
import ./execution-query-identity.bend as Identity
import ./execution-resource-policy.bend as Policy
import ./recoverable-component.bend as RC
import ./lifecycle.bend as Life
import ./change-tick.bend as Tick

# Explicit recovery boundary; ordinary scheduling does not invoke this facility.
type Exchange<-P:Type> is Type:
  Exchanged{stamp:Life.Stamp,previous:Maybe<P>}
  ExchangeRefused{incoming:Maybe<P>}
def packed(~layout:Layout.Layout,~route:Layout.Route,incoming:Maybe<Layout.payload(layout,route)>) -> Maybe<Layout.stored(layout,route)>:
  match incoming:
    case None{}:None{}
    case Some{owner}:Some{Layout.initialize(layout,route,owner)}
def unpacked(~P:Type,~V:Data,incoming:Maybe<Layout.Viewed<P,V>>) -> Maybe<P>:
  match incoming:
    case None{}:None{}
    case Some{Layout.Viewed{owner,_}}:Some{owner}
def restore_optional(~S:Data,~P:Type,column:Column.Column<S,P>,index:U32,saved:Maybe<&2,Life.Stamp>) -> Column.Column<S,P>:
  match saved:
    case None{}:column
    case Some{stamp}:Column.restore_stamp(~S,~P,column,index,stamp)
def swapped(~S:Data,~layout:Layout.Layout,~route:Layout.Route,index:U32,prior:Life.Stamp,saved:Maybe<&2,Life.Stamp>,result:Column.SwapOutcome<S,Layout.stored(layout,route)>) -> Column.Column<S,Layout.stored(layout,route)> & Exchange<Layout.payload(layout,route)>:
  match result:
    case Column.Accepted{column,previous}:(restore_optional(~S,~Layout.stored(layout,route),column,index,saved),Exchanged{prior,unpacked(~Layout.payload(layout,route),~Layout.view(layout,route),previous)})
    case Column.Rejected{column,incoming}:(column,ExchangeRefused{unpacked(~Layout.payload(layout,route),~Layout.view(layout,route),incoming)})
def observed(~S:Data,~layout:Layout.Layout,~route:Layout.Route,+index:U32,incoming:Maybe<Layout.payload(layout,route)>,tick:Tick.Tick,saved:Maybe<&2,Life.Stamp>,result:Column.Column<S,Layout.stored(layout,route)> & Maybe<&2,Life.Stamp>) -> Column.Column<S,Layout.stored(layout,route)> & Exchange<Layout.payload(layout,route)>:
  match result:
    case (column,None{}):(column,ExchangeRefused{incoming})
    case (column,Some{prior}):swapped(~S,~layout,~route,index,prior,saved,Column.swap_at(~S,~Layout.stored(layout,route),column,index,packed(~layout,~route,incoming),tick))
def column_returned(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},rest:Layout.column_rest(~S,layout,route),result:Column.Column<S,Layout.stored(layout,route)> & Exchange<Layout.payload(layout,route)>) -> C & Exchange<Layout.payload(layout,route)>:
  match result:
    case (column,result):(Access.column_put(~S,~C,~layout,~route,~same,rest,column),result)
def column_taken(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},+index:U32,incoming:Maybe<Layout.payload(layout,route)>,tick:Tick.Tick,saved:Maybe<&2,Life.Stamp>,result:Layout.column_rest(~S,layout,route) & Column.Column<S,Layout.stored(layout,route)>) -> C & Exchange<Layout.payload(layout,route)>:
  match result:
    case (rest,column):column_returned(~S,~C,~layout,~route,~same,rest,observed(~S,~layout,~route,index,incoming,tick,saved,Column.lifecycle(~S,~Layout.stored(layout,route),column,index)))
def exchange(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},index:U32,incoming:Maybe<Layout.payload(layout,route)>,tick:Tick.Tick,saved:Maybe<&2,Life.Stamp>,columns:C) -> C & Exchange<Layout.payload(layout,route)>:
  column_taken(~S,~C,~layout,~route,~same,index,incoming,tick,saved,Access.column_take(~S,~C,~layout,~route,~same,columns))
def replaced(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,handle:W.Handle<S>,result:W.World<S,C,R,E> & Exchange<P>) -> RC.Replacement<W.World<S,C,R,E>,S,P>:
  match result:
    case (world,Exchanged{stamp,previous}):RC.Applied{world,RC.Record{handle,stamp,previous}}
    case (world,ExchangeRefused{incoming}):RC.Refused{world,incoming,W.CapacityExceeded{}}
def timed(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},handle:W.Handle<S>,index:U32,incoming:Maybe<Layout.payload(layout,route)>,result:W.World<S,C,R,E> & Tick.Tick) -> RC.Replacement<W.World<S,C,R,E>,S,Layout.payload(layout,route)>:
  match result:
    case (world,tick):replaced(~S,~C,~R,~E,~Layout.payload(layout,route),handle,W.with_store(~S,~C,~R,~E,~Exchange<Layout.payload(layout,route)>,exchange(~S,~C,~layout,~route,~same,index,incoming,tick,None{}),world))
def offset(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},incoming:Maybe<Layout.payload(layout,route)>,result:W.World<S,C,R,E> & Identity.Offset<S>) -> RC.Replacement<W.World<S,C,R,E>,S,Layout.payload(layout,route)>:
  match result:
    case (world,Identity.Physical{handle,index}):timed(~S,~C,~R,~E,~layout,~route,~same,handle,index,incoming,W.write_clock(~S,~C,~R,~E,world))
    case (world,Identity.MissingEntity{_}):RC.Refused{world,incoming,W.MissingEntity{}}
    case (world,Identity.OutsideStorage{_,_}):RC.Refused{world,incoming,W.CapacityExceeded{}}
def replace(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~ordinary:{Layout.policy(layout,route) == Policy.Ordinary{} : Policy.Policy},world:W.World<S,C,R,E>,handle:W.Handle<S>,incoming:Maybe<Layout.payload(layout,route)>) -> RC.Replacement<W.World<S,C,R,E>,S,Layout.payload(layout,route)>:
  offset(~S,~C,~R,~E,~layout,~route,~same,incoming,Identity.world_offset(~S,~C,~R,~E,world,Column.maximum_capacity(),handle))
def undone(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,handle:W.Handle<S>,saved:Life.Stamp,result:W.World<S,C,R,E> & Exchange<P>) -> W.World<S,C,R,E> & RC.Record<S,P>:
  match result:
    case (world,Exchanged{stamp,previous}):(world,RC.Record{handle,stamp,previous})
    case (world,ExchangeRefused{incoming}):(world,RC.Record{handle,saved,incoming})
def undo_offset(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},+stamp:Life.Stamp,payload:Maybe<Layout.payload(layout,route)>,result:W.World<S,C,R,E> & Identity.Offset<S>) -> W.World<S,C,R,E> & RC.Record<S,Layout.payload(layout,route)>:
  match result:
    case (world,Identity.Physical{+handle,index}):undone(~S,~C,~R,~E,~Layout.payload(layout,route),handle,stamp,W.with_store(~S,~C,~R,~E,~Exchange<Layout.payload(layout,route)>,exchange(~S,~C,~layout,~route,~same,index,payload,Tick.zero(),Some{stamp}),world))
    case (world,Identity.MissingEntity{handle}):(world,RC.Record{handle,stamp,payload})
    case (world,Identity.OutsideStorage{handle,_}):(world,RC.Record{handle,stamp,payload})
def undo(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~ordinary:{Layout.policy(layout,route) == Policy.Ordinary{} : Policy.Policy},record:RC.Record<S,Layout.payload(layout,route)>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & RC.Record<S,Layout.payload(layout,route)>:
  match record:
    case RC.Record{handle,stamp,payload}:undo_offset(~S,~C,~R,~E,~layout,~route,~same,stamp,payload,Identity.world_offset(~S,~C,~R,~E,world,Column.maximum_capacity(),handle))
