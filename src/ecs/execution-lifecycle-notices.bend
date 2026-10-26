import Base
import ./entity-key.bend as Key
import ./change-tick.bend as Tick
import ./execution-composer-layout.bend as Layout

type Identity<-S:Data> is Data:
  Identity{namespace:U32,key:Key.Key}
type Selector is Data:
  Removed{key:String}
  Despawned{}
type Row<-S:Data> is Data:
  Row{sequence:Nat,entity:Identity<S>,tick:Tick.Tick}
type Channel<-S:Data> is Data:
  Channel{selector:Selector,next:Nat,previous:List<&2,Row<S>>,current:List<&2,Row<S>>,droppedThrough:Nat}
type Active is Data:
  Active{id:U32,selector:Selector}
type Journal<-S:Data> is Type:
  Journal{namespace:U32,channels:List<&2,Channel<S>>,nextReader:U32,active:List<&2,Active>}
type View<-S:Data> is Data:
  View{namespace:U32,channels:List<&2,Channel<S>>,active:List<&2,Active>}
type Reader<-S:Data,-origin:Layout.Layout,-selector:Selector> is Type:
  Reader{namespace:U32,id:U32,cursor:Nat}
type Start is Data:
  Retained{}
  Future{}
type Refusal is Data:
  ForeignWorld{}
  Inactive{}
  ReaderLimit{}
type Registration<-S:Data,-origin:Layout.Layout,-selector:Selector> is Type:
  Registered{reader:Reader<S,origin,selector>}
  RegistrationRefused{reason:Refusal}
type Retirement<-S:Data,-origin:Layout.Layout,-selector:Selector> is Type:
  Retired{}
  RetirementRefused{reader:Reader<S,origin,selector>,reason:Refusal}
type Reading<-S:Data,-origin:Layout.Layout,-selector:Selector> is Type:
  Item{reader:Reader<S,origin,selector>,row:Row<S>,missed:Nat}
  Empty{reader:Reader<S,origin,selector>,missed:Nat}
  ReadRefused{reader:Reader<S,origin,selector>,reason:Refusal}

def same(left:Selector,right:Selector) -> Bool:
  match left right:
    case Removed{left} Removed{right}:String.eq(left,right)
    case Despawned{} Despawned{}:True{}
    case _ _:False{}
def empty(~S:Data,namespace:U32) -> Journal<S>:
  Journal{namespace,[],1,[]}
def vacant(~S:Data,selector:Selector) -> Channel<S>:
  Channel{selector,1n,[],[],0n}
def choose_channel(~S:Data,found:Bool,channel:Channel<S>,other:Channel<S>) -> Channel<S>:
  match found:
    case True{}:channel
    case False{}:other
def channel_selector(~S:Data,channel:Channel<S>) -> Selector:
  match channel:
    case Channel{selector,_,_,_,_}:selector
def channel(~S:Data,+selector:Selector,channels:List<&2,Channel<S>>) -> Channel<S>:
  match channels:
    case []:vacant(~S,selector)
    case +current <> rest:choose_channel(~S,same(selector,channel_selector(~S,current)),current,channel(~S,selector,rest))
def replace_channel(~S:Data,found:Bool,value:Channel<S>,current:Channel<S>,rest:List<&2,Channel<S>>,replaced:List<&2,Channel<S>>) -> List<&2,Channel<S>>:
  match found:
    case True{}:value <> rest
    case False{}:current <> replaced
def put(~S:Data,+value:Channel<S>,channels:List<&2,Channel<S>>) -> List<&2,Channel<S>>:
  match channels:
    case []:[value]
    case +current <> +rest:replace_channel(~S,same(channel_selector(~S,value),channel_selector(~S,current)),value,current,rest,put(~S,value,rest))
def appended(~S:Data,entity:Identity<S>,tick:Tick.Tick,channel:Channel<S>) -> Channel<S>:
  match channel:
    case Channel{selector,+next,previous,current,floor}:Channel{selector,1n+next,previous,List.append(&2,Row<S>,current,[Row{next,entity,tick}]),floor}
def append(~S:Data,+selector:Selector,entity:Identity<S>,tick:Tick.Tick,journal:Journal<S>) -> Journal<S>:
  match journal:
    case Journal{namespace,+channels,nextReader,active}:Journal{namespace,put(~S,appended(~S,entity,tick,channel(~S,selector,channels)),channels),nextReader,active}
def floor_after(~S:Data,rows:List<&2,Row<S>>,floor:Nat) -> Nat:
  match rows:
    case []:floor
    case Row{sequence,_,_} <> rest:floor_after(~S,rest,sequence)
def rotated(~S:Data,channel:Channel<S>) -> Channel<S>:
  match channel:
    case Channel{selector,next,previous,current,floor}:Channel{selector,next,current,[],floor_after(~S,previous,floor)}
def rotate_channels(~S:Data,channels:List<&2,Channel<S>>) -> List<&2,Channel<S>>:
  match channels:
    case []:[]
    case current <> rest:rotated(~S,current) <> rotate_channels(~S,rest)
# Bevy ad678262: sub_app.rs update clears trackers after the schedule;
# world/mod.rs clear_trackers updates removed-component messages. Only the
# completed public App boundary calls this rotation; reads never rotate it.
def maintain(~S:Data,journal:Journal<S>) -> Journal<S>:
  match journal:
    case Journal{namespace,channels,nextReader,active}:Journal{namespace,rotate_channels(~S,channels),nextReader,active}
def snapshot(~S:Data,journal:Journal<S>) -> Journal<S> & View<S>:
  match journal:
    case Journal{+namespace,+channels,nextReader,+active}:(Journal{namespace,channels,nextReader,active},View{namespace,channels,active})
def active_selected(found:Bool,next:Bool) -> Bool:
  match found:
    case True{}:True{}
    case False{}:next
def active(+id:U32,+selector:Selector,entries:List<&2,Active>) -> Bool:
  match entries:
    case []:False{}
    case Active{actual,current} <> rest:active_selected(Bool.and(U32.is_eq(id,actual),same(selector,current)),active(id,selector,rest))
def admitted(same:Bool,active:Bool) -> Maybe<&2,Refusal>:
  match same active:
    case False{} _:Some{ForeignWorld{}}
    case True{} False{}:Some{Inactive{}}
    case True{} True{}:None{}
def admission(namespace:U32,actual:U32,id:U32,selector:Selector,entries:List<&2,Active>) -> Maybe<&2,Refusal>:
  admitted(U32.is_eq(namespace,actual),active(id,selector,entries))
def starting(~S:Data,start:Start,channel:Channel<S>) -> Nat:
  match start channel:
    case Retained{} Channel{_,_,_,_,floor}:floor
    case Future{} Channel{_,next,_,_,_}:Nat.sub(next,1n)
def registered(~S:Data,~origin:Layout.Layout,~selector:Selector,+namespace:U32,+channels:List<&2,Channel<S>>,+id:U32,active:List<&2,Active>,start:Start,+channel:Channel<S>) -> Journal<S> & Registration<S,origin,selector>:
  (Journal{namespace,put(~S,channel,channels),U32.add(id,1),List.append(&2,Active,active,[Active{id,selector}])},Registered{Reader{namespace,id,starting(~S,start,channel)}})
def register_allowed(~S:Data,~origin:Layout.Layout,~selector:Selector,allowed:Bool,start:Start,journal:Journal<S>) -> Journal<S> & Registration<S,origin,selector>:
  match allowed journal:
    case False{} journal:(journal,RegistrationRefused{ReaderLimit{}})
    case True{} Journal{namespace,+channels,id,active}:registered(~S,~origin,~selector,namespace,channels,id,active,start,channel(~S,selector,channels))
def register(~S:Data,~origin:Layout.Layout,~selector:Selector,start:Start,journal:Journal<S>) -> Journal<S> & Registration<S,origin,selector>:
  match journal:
    case Journal{namespace,channels,+id,active}:register_allowed(~S,~origin,~selector,U32.is_lt(id,4294967295),start,Journal{namespace,channels,id,active})
def keep_active(equal:Bool,current:Active,rest:List<&2,Active>) -> List<&2,Active>:
  match equal:
    case True{}:rest
    case False{}:current <> rest
def without_entry(id:U32,current:Active,rest:List<&2,Active>) -> List<&2,Active>:
  match current:
    case Active{+actual,selector}:keep_active(U32.is_eq(id,actual),Active{actual,selector},rest)
def without(+id:U32,entries:List<&2,Active>) -> List<&2,Active>:
  match entries:
    case []:[]
    case +current <> rest:without_entry(id,current,without(id,rest))
def retired(~S:Data,~origin:Layout.Layout,~selector:Selector,reason:Maybe<&2,Refusal>,journal:Journal<S>,reader:Reader<S,origin,selector>) -> Journal<S> & Retirement<S,origin,selector>:
  match reason journal reader:
    case Some{reason} journal reader:(journal,RetirementRefused{reader,reason})
    case None{} Journal{namespace,channels,nextReader,active} Reader{_,id,_}:(Journal{namespace,channels,nextReader,without(id,active)},Retired{})
def retire(~S:Data,~origin:Layout.Layout,~selector:Selector,journal:Journal<S>,reader:Reader<S,origin,selector>) -> Journal<S> & Retirement<S,origin,selector>:
  match journal reader:
    case Journal{+namespace,channels,nextReader,+active} Reader{+actual,+id,cursor}:retired(~S,~origin,~selector,admission(namespace,actual,id,selector,active),Journal{namespace,channels,nextReader,active},Reader{actual,id,cursor})
def first_selected(~S:Data,found:Bool,row:Row<S>,other:Maybe<&2,Row<S>>) -> Maybe<&2,Row<S>>:
  match found:
    case True{}:Some{row}
    case False{}:other
def row_sequence(~S:Data,row:Row<S>) -> Nat:
  match row:
    case Row{sequence,_,_}:sequence
def first_after(~S:Data,+cursor:Nat,rows:List<&2,Row<S>>) -> Maybe<&2,Row<S>>:
  match rows:
    case []:None{}
    case +row <> rest:first_selected(~S,Nat.is_lt(cursor,row_sequence(~S,row)),row,first_after(~S,cursor,rest))
def yielded(~S:Data,~origin:Layout.Layout,~selector:Selector,namespace:U32,id:U32,cursor:Nat,missed:Nat,row:Maybe<&2,Row<S>>) -> Reading<S,origin,selector>:
  match row:
    case None{}:Empty{Reader{namespace,id,cursor},missed}
    case Some{+row}:Item{Reader{namespace,id,row_sequence(~S,row)},row,missed}
def read_channel(~S:Data,~origin:Layout.Layout,~selector:Selector,namespace:U32,id:U32,+cursor:Nat,channel:Channel<S>) -> Reading<S,origin,selector>:
  match channel:
    case Channel{_,_,previous,current,+floor}:yielded(~S,~origin,~selector,namespace,id,Nat.max(cursor,floor),Nat.sub(floor,cursor),first_after(~S,Nat.max(cursor,floor),List.append(&2,Row<S>,previous,current)))
def read_admitted(~S:Data,~origin:Layout.Layout,~selector:Selector,reason:Maybe<&2,Refusal>,view:View<S>,reader:Reader<S,origin,selector>) -> Reading<S,origin,selector>:
  match reason view reader:
    case Some{reason} _ reader:ReadRefused{reader,reason}
    case None{} View{_,channels,_} Reader{namespace,id,cursor}:read_channel(~S,~origin,~selector,namespace,id,cursor,channel(~S,selector,channels))
def read(~S:Data,~origin:Layout.Layout,~selector:Selector,view:View<S>,reader:Reader<S,origin,selector>) -> Reading<S,origin,selector>:
  match view reader:
    case View{+namespace,channels,+active} Reader{+actual,+id,cursor}:read_admitted(~S,~origin,~selector,admission(namespace,actual,id,selector,active),View{namespace,channels,active},Reader{actual,id,cursor})
