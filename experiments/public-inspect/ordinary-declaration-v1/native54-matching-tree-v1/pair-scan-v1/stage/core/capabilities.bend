import Base
import component.bend as Cmp

# Closed declaration bundles contain operations, never runtime-owned storage.
# Gameplay specializes field projections while threading one abstract owner.
type Read<-H: Type,-V: Data> is Type:
  Read{get: H -> H & Cmp.Access<V>}
type Write<-H: Type,-C: Type,-V: Data> is Type:
  Write{get: H -> H & Cmp.Access<V>,set: H -> C -> H}
type Bundle<-A: Type,-B: Type> is Type:
  Bundle{first: A,second: B}
type ValueRead<-H: Type,-V: Data> is Type:
  ValueRead{get: H -> H & V}
type ValueWrite<-H: Type,-C: Type,-V: Data> is Type:
  ValueWrite{get: H -> H & V,set: H -> C -> H}
type Send<-H: Type,-C: Type> is Type:
  Send{send: H -> C -> H}
type Action<-H: Type> is Type:
  Action{run: H -> H}
type Request<-H: Type,-C: Type,-V: Data> is Type:
  Request{run: H -> C -> H & V}

def first(~A: Type,~B: Type,cap: Bundle<A,B>) -> A:
  match cap:
    case Bundle{a,_}: a
def second(~A: Type,~B: Type,cap: Bundle<A,B>) -> B:
  match cap:
    case Bundle{_,b}: b
def read_field(~H: Type,~V: Data,cap: Read<H,V>) -> H -> H & Cmp.Access<V>:
  match cap:
    case Read{get}: get
def write_read_field(~H: Type,~C: Type,~V: Data,cap: Write<H,C,V>) -> H -> H & Cmp.Access<V>:
  match cap:
    case Write{get,_}: get
def write_field(~H: Type,~C: Type,~V: Data,cap: Write<H,C,V>) -> H -> C -> H:
  match cap:
    case Write{_,set}: set
def read(~H: Type,~V: Data,~cap: Read<H,V>,ctx: H) -> H & Cmp.Access<V>:
  read_field(~H,~V,cap)(ctx)
def get(~H: Type,~C: Type,~V: Data,~cap: Write<H,C,V>,ctx: H) -> H & Cmp.Access<V>:
  write_read_field(~H,~C,~V,cap)(ctx)
def set(~H: Type,~C: Type,~V: Data,~cap: Write<H,C,V>,ctx: H,value: C) -> H:
  write_field(~H,~C,~V,cap)(ctx,value)

def value_read_field(~H: Type,~V: Data,cap: ValueRead<H,V>) -> H -> H & V:
  match cap:
    case ValueRead{get}: get
def value_write_read_field(~H: Type,~C: Type,~V: Data,cap: ValueWrite<H,C,V>) -> H -> H & V:
  match cap:
    case ValueWrite{get,_}: get
def value_write_field(~H: Type,~C: Type,~V: Data,cap: ValueWrite<H,C,V>) -> H -> C -> H:
  match cap:
    case ValueWrite{_,set}: set
def value_read(~H: Type,~V: Data,~cap: ValueRead<H,V>,ctx: H) -> H & V:
  value_read_field(~H,~V,cap)(ctx)
def value_get(~H: Type,~C: Type,~V: Data,~cap: ValueWrite<H,C,V>,ctx: H) -> H & V:
  value_write_read_field(~H,~C,~V,cap)(ctx)
def value_set(~H: Type,~C: Type,~V: Data,~cap: ValueWrite<H,C,V>,ctx: H,value: C) -> H:
  value_write_field(~H,~C,~V,cap)(ctx,value)
def send_field(~H: Type,~C: Type,cap: Send<H,C>) -> H -> C -> H:
  match cap:
    case Send{send}: send
def send(~H: Type,~C: Type,~cap: Send<H,C>,ctx: H,value: C) -> H:
  send_field(~H,~C,cap)(ctx,value)
def action_field(~H: Type,cap: Action<H>) -> H -> H:
  match cap:
    case Action{run}: run
def action(~H: Type,~cap: Action<H>,ctx: H) -> H:
  action_field(~H,cap)(ctx)
def request_field(~H: Type,~C: Type,~V: Data,cap: Request<H,C,V>) -> H -> C -> H & V:
  match cap:
    case Request{run}: run
def request(~H: Type,~C: Type,~V: Data,~cap: Request<H,C,V>,ctx: H,value: C) -> H & V:
  request_field(~H,~C,~V,cap)(ctx,value)

# One executor for every caller-authored finite capability shape.
def invoke(~Ops: Type -> Type,~A: Data,~U: Type,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & U,~H: Type,~caps: Ops(H),args: A,ctx: H) -> H & U:
  body(H,caps,args,ctx)

# Additive owned input/result capability; existing Data APIs are unchanged.
type OwnedRequest<-H:Type,-Input:Type,-Output:Type> is Type:
  OwnedRequest{run:H -> Input -> H & Output}
def owned_request_field(~H:Type,~Input:Type,~Output:Type,cap:OwnedRequest<H,Input,Output>) -> H -> Input -> H & Output:
  match cap:
    case OwnedRequest{run}: run
def owned_request(~H:Type,~Input:Type,~Output:Type,~cap:OwnedRequest<H,Input,Output>,ctx:H,input:Input) -> H & Output:
  owned_request_field(~H,~Input,~Output,cap)(ctx,input)
# Args and output are fixed before opaque H; no Data restriction on owners.
def invoke_owned(~Ops:Type -> Type,~A:Type,~U:Type,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & U,~H:Type,~caps:Ops(H),args:A,ctx:H) -> H & U:
  body(H,caps,args,ctx)
