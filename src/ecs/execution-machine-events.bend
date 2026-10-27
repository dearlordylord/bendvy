import Base
import ./execution-machine-state.bend as State
import ./machine.bend as M
import ./execution-machine-stream.bend as Stream
import ./execution-machine-access.bend as Machine
import ./execution-access.bend as Access
import ./execution-builder.bend as Build
import ./execution-composer-layout.bend as Layout
import ./change-tick.bend as Tick

type Read<-S:Data,-K:Data,-V:Data,-origin:Layout.Layout,-route:Layout.Route,-H:Type> is Type:
  Read{read:Stream.Reader<S,K,V,origin,route> -> H -> H & Stream.Reading<S,K,V,origin,route>}
def Ops(~S:Data,~K:Data,~V:Data,~origin:Layout.Layout,~route:Layout.Route,H:Type) -> Type:Read<S,K,V,origin,route,H>
def returned(~S:Data,~K:Data,~V:Data,~origin:Layout.Layout,~route:Layout.Route,slot:M.Slot<S,K,V>,revision:Nat,stamp:Maybe<&2,Tick.Tick>,nextStamp:Maybe<&2,Tick.Tick>,sequence:Nat,initialPending:Bool,namespace:Maybe<&2,U32>,intent:State.Intent<V>,result:Stream.Store<V> & Stream.Reading<S,K,V,origin,route>) -> State.Cell<S,K,V> & Stream.Reading<S,K,V,origin,route>:
  match result:
    case (stream,reading):(State.Cell{slot,stream,revision,stamp,nextStamp,sequence,initialPending,namespace,intent},reading)
def read_cell(~S:Data,~K:Data,~V:Data,~origin:Layout.Layout,~route:Layout.Route,reader:Stream.Reader<S,K,V,origin,route>,tick:Tick.Tick,cell:State.Cell<S,K,V>) -> State.Cell<S,K,V> & Stream.Reading<S,K,V,origin,route>:
  match cell:
    case State.Cell{slot,stream,revision,stamp,nextStamp,+sequence,initialPending,+namespace,intent}:returned(~S,~K,~V,~origin,~route,slot,revision,stamp,nextStamp,sequence,initialPending,namespace,intent,Stream.read(~S,~K,~V,~origin,~route,namespace,sequence,tick,reader,stream))
def narrow(~S:Data,~K:Data,~V:Data,~origin:Layout.Layout,~route:Layout.Route,~H:Type,cap:Access.ResourceWrite<H,State.Cell<S,K,V>,State.View<S,K,V>>) -> Read<S,K,V,origin,route,H>:
  match cap:
    case Access.ResourceWrite{_,_,_,own_at}:Read{reader => own_at(Stream.Reading<S,K,V,origin,route>,read_cell(~S,~K,~V,~origin,~route,reader))}
def selected(~S:Data,~K:Data,~V:Data,~H:Type,~B:Type,~layout:Layout.Layout,~route:Layout.Route,~payload:{Layout.payload(layout,route) == State.Cell<S,K,V> : Type},~view:{Layout.view(layout,route) == State.View<S,K,V> : Data},result:B & Access.ResourceWrite<H,Layout.payload(layout,route),Layout.view(layout,route)>) -> B & Read<S,K,V,layout,route,H>:
  match result:
    case (book,cap):(book,narrow(~S,~K,~V,~layout,~route,~H,Machine.checked_write(~S,~K,~V,~H,~Layout.payload(layout,route),~Layout.view(layout,route),~payload,~view,cap)))
def select(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~H:Type,~B:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~payload:{Layout.payload(layout,route) == State.Cell<S,K,V> : Type},~view:{Layout.view(layout,route) == State.View<S,K,V> : Data},~write:Build.ResourceWrite(~S,~C,~R,~H,~B),book:B) -> B & Read<S,K,V,layout,route,H>:
  selected(~S,~K,~V,~H,~B,~layout,~route,~payload,~view,Build.basic_resource_write(~S,~C,~R,~H,~B,~layout,~route,~same,~valid,~write,book))
def read_field(~S:Data,~K:Data,~V:Data,~origin:Layout.Layout,~route:Layout.Route,~H:Type,cap:Read<S,K,V,origin,route,H>) -> Stream.Reader<S,K,V,origin,route> -> H -> H & Stream.Reading<S,K,V,origin,route>:
  match cap:
    case Read{read}:read
