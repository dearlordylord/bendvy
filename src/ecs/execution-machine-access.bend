import Base
import ./execution-resource-policy.bend as Policy
import ./execution-machine-state.bend as State
import ./machine.bend as M
import ./execution-access.bend as A
import ./execution-composer-layout.bend as Layout
import ./execution-builder.bend as Build
import ./change-tick.bend as Tick

type Read<-S:Data,-K:Data,-V:Data,-H:Type> is Type:
  Read{get:H -> H & State.View<S,K,V>}
type Write<-S:Data,-K:Data,-V:Data,-H:Type> is Type:
  Write{get:H -> H & State.View<S,K,V>,request:M.QueueInput<V> -> H -> H & Unit}
type Apply<-S:Data,-K:Data,-V:Data,-H:Type> is Type:
  Apply{step:H -> H & State.Intent<V>,get:H -> H & State.View<S,K,V>}
def Reads(~S:Data,~K:Data,~V:Data,Permit:Data,H:Type) -> Type:Read<S,K,V,H>
def Writes(~S:Data,~K:Data,~V:Data,Permit:Data,H:Type) -> Type:Write<S,K,V,H>
def Applies(~S:Data,~K:Data,~V:Data,Permit:Data,H:Type) -> Type:Apply<S,K,V,H>
def leaf(~S:Data,~K:Data,~V:Data,key:String) -> Layout.Layout:
  Layout.LayoutLeaf{State.Cell<S,K,V>,State.View<S,K,V>,State.projected(~S,~K,~V),key,Policy.Ordinary{}}
def read(-S:Data,-K:Data,-V:Data,-H:Type,cap:A.ResourceRead<H,State.View<S,K,V>>) -> Read<S,K,V,H>:
  match cap:
    case A.ResourceRead{get}:Read{get}
def write(~S:Data,~K:Data,~V:Data,~H:Type,~same:V -> V -> Bool,cap:A.ResourceWrite<H,State.Cell<S,K,V>,State.View<S,K,V>>) -> Write<S,K,V,H>:
  match cap:
    case A.ResourceWrite{get,_,_,own_at}:Write{get,request => own_at(Unit,State.queued_at(~S,~K,~V,~same,request))}
def applied(~S:Data,~K:Data,~V:Data,cell:State.Cell<S,K,V>) -> State.Cell<S,K,V> & State.Intent<V>:
  match cell:
    case State.Cell{slot,stream,revision,stamp,nextStamp,sequence,initialPending,namespace,+intent}:(State.Cell{slot,stream,revision,stamp,nextStamp,sequence,initialPending,namespace,intent},intent)
def applying(~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,tick:Tick.Tick,cell:State.Cell<S,K,V>) -> State.Cell<S,K,V> & State.Intent<V>:
  applied(~S,~K,~V,State.apply(~S,~K,~V,~same,cell,tick))
def apply(~S:Data,~K:Data,~V:Data,~H:Type,~same:V -> V -> Bool,cap:A.ResourceWrite<H,State.Cell<S,K,V>,State.View<S,K,V>>) -> Apply<S,K,V,H>:
  match cap:
    case A.ResourceWrite{get,_,_,own_at}:Apply{own_at(State.Intent<V>,applying(~S,~K,~V,~same)),get}
def checked_write(~S:Data,~K:Data,~V:Data,~H:Type,~P:Type,~View:Data,~payload:{P == State.Cell<S,K,V> : Type},~view:{View == State.View<S,K,V> : Data},cap:A.ResourceWrite<H,P,View>) -> A.ResourceWrite<H,State.Cell<S,K,V>,State.View<S,K,V>>:
  %payload : A.ResourceWrite<H,_,State.View<S,K,V>>
  %view : A.ResourceWrite<H,P,_>
  cap
def checked_read(-S:Data,-K:Data,-V:Data,-H:Type,-View:Data,view:{View == State.View<S,K,V> : Data},cap:A.ResourceRead<H,View>) -> A.ResourceRead<H,State.View<S,K,V>>:
  %view : A.ResourceRead<H,_>
  cap
# These selection helpers consume the existing Builder callbacks. They return no
# raw cell writer and keep capability+conflict metadata in the same closed Program.
def selected_write(~S:Data,~K:Data,~V:Data,~H:Type,~B:Type,~layout:Layout.Layout,~route:Layout.Route,~payload:{Layout.payload(layout,route) == State.Cell<S,K,V> : Type},~view:{Layout.view(layout,route) == State.View<S,K,V> : Data},~same:V -> V -> Bool,result:B & A.ResourceWrite<H,Layout.payload(layout,route),Layout.view(layout,route)>) -> B & Write<S,K,V,H>:
  match result:
    case (book,cap):(book,write(~S,~K,~V,~H,~same,checked_write(~S,~K,~V,~H,~(Layout.payload(layout,route)),~(Layout.view(layout,route)),~payload,~view,cap)))
def select_write(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~H:Type,~B:Type,~layout:Layout.Layout,~route:Layout.Route,~same_resource:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.resource_write_valid(~layout,~route) == True{} : Bool},~payload:{Layout.payload(layout,route) == State.Cell<S,K,V> : Type},~view:{Layout.view(layout,route) == State.View<S,K,V> : Data},~same:V -> V -> Bool,~resource_write:Build.ResourceWrite(~S,~C,~R,~H,~B),book:B) -> B & Write<S,K,V,H>:
  selected_write(~S,~K,~V,~H,~B,~layout,~route,~payload,~view,~same,Build.basic_resource_write(~S,~C,~R,~H,~B,~layout,~route,~same_resource,~valid,~resource_write,book))
def selected_apply(~S:Data,~K:Data,~V:Data,~H:Type,~B:Type,~layout:Layout.Layout,~route:Layout.Route,~payload:{Layout.payload(layout,route) == State.Cell<S,K,V> : Type},~view:{Layout.view(layout,route) == State.View<S,K,V> : Data},~same:V -> V -> Bool,result:B & A.ResourceWrite<H,Layout.payload(layout,route),Layout.view(layout,route)>) -> B & Apply<S,K,V,H>:
  match result:
    case (book,cap):(book,apply(~S,~K,~V,~H,~same,checked_write(~S,~K,~V,~H,~(Layout.payload(layout,route)),~(Layout.view(layout,route)),~payload,~view,cap)))
def select_apply(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~H:Type,~B:Type,~layout:Layout.Layout,~route:Layout.Route,~same_resource:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.resource_write_valid(~layout,~route) == True{} : Bool},~payload:{Layout.payload(layout,route) == State.Cell<S,K,V> : Type},~view:{Layout.view(layout,route) == State.View<S,K,V> : Data},~same:V -> V -> Bool,~resource_write:Build.ResourceWrite(~S,~C,~R,~H,~B),book:B) -> B & Apply<S,K,V,H>:
  selected_apply(~S,~K,~V,~H,~B,~layout,~route,~payload,~view,~same,Build.basic_resource_write(~S,~C,~R,~H,~B,~layout,~route,~same_resource,~valid,~resource_write,book))
def selected_read(-S:Data,-K:Data,-V:Data,-H:Type,-B:Type,-layout:Layout.Layout,-route:Layout.Route,view:{Layout.view(layout,route) == State.View<S,K,V> : Data},result:B & A.ResourceRead<H,Layout.view(layout,route)>) -> B & Read<S,K,V,H>:
  match result:
    case (book,cap):(book,read(S,K,V,H,checked_read(S,K,V,H,(Layout.view(layout,route)),view,cap)))
def select_read(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~H:Type,~B:Type,~layout:Layout.Layout,~route:Layout.Route,~same_resource:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~view:{Layout.view(layout,route) == State.View<S,K,V> : Data},~resource_read:Build.ResourceRead(~S,~C,~R,~H,~B),book:B) -> B & Read<S,K,V,H>:
  selected_read(S,K,V,H,B,layout,route,view,Build.basic_resource_read(~S,~C,~R,~H,~B,~layout,~route,~same_resource,~valid,~resource_read,book))

def read_field(~S:Data,~K:Data,~V:Data,~H:Type,cap:Read<S,K,V,H>) -> H -> H & State.View<S,K,V>:
  match cap:
    case Read{get}:get
def write_read_field(~S:Data,~K:Data,~V:Data,~H:Type,cap:Write<S,K,V,H>) -> H -> H & State.View<S,K,V>:
  match cap:
    case Write{get,_}:get
def request_field(~S:Data,~K:Data,~V:Data,~H:Type,cap:Write<S,K,V,H>) -> M.QueueInput<V> -> H -> H & Unit:
  match cap:
    case Write{_,request}:request
def apply_field(~S:Data,~K:Data,~V:Data,~H:Type,cap:Apply<S,K,V,H>) -> H -> H & State.Intent<V>:
  match cap:
    case Apply{step,_}:step


def apply_read_field(~S:Data,~K:Data,~V:Data,~H:Type,cap:Apply<S,K,V,H>) -> H -> H & State.View<S,K,V>:
  match cap:
    case Apply{_,get}:get
