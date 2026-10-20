import Base
import component.bend as Cmp

# Closed declaration bundles contain operations, never runtime-owned storage.
# Gameplay specializes field projections while threading one abstract owner.
# Component read capability: threads opaque owner H and returns Access<V>.
# V is detached Data; no affine payload owner or setter is exposed.
type Read<-H: Type,-V: Data> is Type:
  Read{get: H -> H & Cmp.Access<V>}
# Component read/replacement capability. set consumes payload C and returns
# H; it does not itself return rejected C. The bound operation defines error
# recording and rollback. Raw constructors are trusted operation adapters.
type Write<-H: Type,-C: Type,-V: Data> is Type:
  Write{get: H -> H & Cmp.Access<V>,set: H -> C -> H}
# Heterogeneous pair of grants for the same application capability shape.
# Contains operations, not live World storage; nest for additional grants.
type Bundle<-A: Type,-B: Type> is Type:
  Bundle{first: A,second: B}
# Read capability returning a detached Data value without component Access
# wrapping. The supplied operation defines missing-value representation.
type ValueRead<-H: Type,-V: Data> is Type:
  ValueRead{get: H -> H & V}
# Read/replace capability for a Data view V and potentially affine input C.
# set consumes C and returns H; no automatic refusal receipt is added here.
type ValueWrite<-H: Type,-C: Type,-V: Data> is Type:
  ValueWrite{get: H -> H & V,set: H -> C -> H}
# Publication capability consuming C and returning opaque H. The supplied
# operation determines staging/refusal/ownership; this wrapper adds no rollback.
type Send<-H: Type,-C: Type> is Type:
  Send{send: H -> C -> H}
# No-argument operation capability threading one affine opaque owner H.
type Action<-H: Type> is Type:
  Action{run: H -> H}
# Operation capability consuming C and returning H plus detached Data V.
# Use OwnedRequest when the result must itself retain affine owners.
type Request<-H: Type,-C: Type,-V: Data> is Type:
  Request{run: H -> C -> H & V}

# Extract the first closed grant from a capability bundle, consuming it.
def first(~A: Type,~B: Type,cap: Bundle<A,B>) -> A:
  match cap:
    case Bundle{a,_}: a
# Extract the second closed grant from a capability bundle, consuming it.
def second(~A: Type,~B: Type,cap: Bundle<A,B>) -> B:
  match cap:
    case Bundle{_,b}: b
# Advanced setup projection extracting the closed operation from its grant.
# Does not invoke it, access World or grant capabilities beyond that value.
def read_field(~H: Type,~V: Data,cap: Read<H,V>) -> H -> H & Cmp.Access<V>:
  match cap:
    case Read{get}: get
# Advanced setup projection extracting the closed operation from its grant.
# Does not invoke it, access World or grant capabilities beyond that value.
def write_read_field(~H: Type,~C: Type,~V: Data,cap: Write<H,C,V>) -> H -> H & Cmp.Access<V>:
  match cap:
    case Write{get,_}: get
# Advanced setup projection extracting the closed operation from its grant.
# Does not invoke it, access World or grant capabilities beyond that value.
def write_field(~H: Type,~C: Type,~V: Data,cap: Write<H,C,V>) -> H -> C -> H:
  match cap:
    case Write{_,set}: set
# Invoke a declared component read, returning the owner and Access<V>.
# No extra validation is added beyond the bound get operation.
def read(~H: Type,~V: Data,~cap: Read<H,V>,ctx: H) -> H & Cmp.Access<V>:
  read_field(~H,~V,cap)(ctx)
# Read the detached view through a write-capable component grant, returning
# H and Access<V>. Does not consume or expose the stored affine C.
def get(~H: Type,~C: Type,~V: Data,~cap: Write<H,C,V>,ctx: H) -> H & Cmp.Access<V>:
  write_read_field(~H,~C,~V,cap)(ctx)
# Invoke replacement with consumed C, returning the opaque owner. Refusal
# results are determined by the bound operation; rejected C is not returned
# by this signature. Canonical grants record errors for enclosing execution.
def set(~H: Type,~C: Type,~V: Data,~cap: Write<H,C,V>,ctx: H,value: C) -> H:
  write_field(~H,~C,~V,cap)(ctx,value)

# Advanced setup projection extracting the closed operation from its grant.
# Does not invoke it, access World or grant capabilities beyond that value.
def value_read_field(~H: Type,~V: Data,cap: ValueRead<H,V>) -> H -> H & V:
  match cap:
    case ValueRead{get}: get
# Advanced setup projection extracting the closed operation from its grant.
# Does not invoke it, access World or grant capabilities beyond that value.
def value_write_read_field(~H: Type,~C: Type,~V: Data,cap: ValueWrite<H,C,V>) -> H -> H & V:
  match cap:
    case ValueWrite{get,_}: get
# Advanced setup projection extracting the closed operation from its grant.
# Does not invoke it, access World or grant capabilities beyond that value.
def value_write_field(~H: Type,~C: Type,~V: Data,cap: ValueWrite<H,C,V>) -> H -> C -> H:
  match cap:
    case ValueWrite{_,set}: set
# Read detached V through ValueRead while returning its opaque owner.
def value_read(~H: Type,~V: Data,~cap: ValueRead<H,V>,ctx: H) -> H & V:
  value_read_field(~H,~V,cap)(ctx)
# Read detached V through ValueWrite without replacing its stored value.
def value_get(~H: Type,~C: Type,~V: Data,~cap: ValueWrite<H,C,V>,ctx: H) -> H & V:
  value_write_read_field(~H,~C,~V,cap)(ctx)
# Consume replacement C through ValueWrite and return the opaque owner.
# The bound setter defines transaction/refusal behavior; this adds no receipt.
def value_set(~H: Type,~C: Type,~V: Data,~cap: ValueWrite<H,C,V>,ctx: H,value: C) -> H:
  value_write_field(~H,~C,~V,cap)(ctx,value)
# Advanced setup projection extracting the closed operation from its grant.
# Does not invoke it, access World or grant capabilities beyond that value.
def send_field(~H: Type,~C: Type,cap: Send<H,C>) -> H -> C -> H:
  match cap:
    case Send{send}: send
# Consume input C through a declared send operation and return H.
# Publication timing and failure behavior belong to the supplied operation.
def send(~H: Type,~C: Type,~cap: Send<H,C>,ctx: H,value: C) -> H:
  send_field(~H,~C,cap)(ctx,value)
# Advanced setup projection extracting the closed operation from its grant.
# Does not invoke it, access World or grant capabilities beyond that value.
def action_field(~H: Type,cap: Action<H>) -> H -> H:
  match cap:
    case Action{run}: run
# Execute a declared no-argument action, consuming and returning H once.
def action(~H: Type,~cap: Action<H>,ctx: H) -> H:
  action_field(~H,cap)(ctx)
# Advanced setup projection extracting the closed operation from its grant.
# Does not invoke it, access World or grant capabilities beyond that value.
def request_field(~H: Type,~C: Type,~V: Data,cap: Request<H,C,V>) -> H -> C -> H & V:
  match cap:
    case Request{run}: run
# Execute a request with consumed input C, returning H and Data result V.
# This is not the affine-output variant; use owned_request for Type results.
def request(~H: Type,~C: Type,~V: Data,~cap: Request<H,C,V>,ctx: H,value: C) -> H & V:
  request_field(~H,~C,~V,cap)(ctx,value)

# One executor for every caller-authored finite capability shape.
# Invoke a reusable universally quantified body with Data arguments and
# declared Ops(H). H remains opaque to the body; closed caps must implement
# the intended operations. This dispatcher adds no transaction or World checks.
def invoke(~Ops: Type -> Type,~A: Data,~U: Type,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & U,~H: Type,~caps: Ops(H),args: A,ctx: H) -> H & U:
  body(H,caps,args,ctx)

# Additive owned input/result capability; existing Data APIs are unchanged.
# Operation consuming an affine Input and returning H with affine Output.
# Operation-specific results can preserve refused payloads; the wrapper does
# not invent recovery or change their ownership semantics.
type OwnedRequest<-H:Type,-Input:Type,-Output:Type> is Type:
  OwnedRequest{run:H -> Input -> H & Output}
# Advanced setup projection extracting the closed operation from its grant.
# Does not invoke it, access World or grant capabilities beyond that value.
def owned_request_field(~H:Type,~Input:Type,~Output:Type,cap:OwnedRequest<H,Input,Output>) -> H -> Input -> H & Output:
  match cap:
    case OwnedRequest{run}: run
# Execute with affine input and return H plus the operation's affine
# result. Branch on that result to handle payload recovery or refusal.
def owned_request(~H:Type,~Input:Type,~Output:Type,~cap:OwnedRequest<H,Input,Output>,ctx:H,input:Input) -> H & Output:
  owned_request_field(~H,~Input,~Output,cap)(ctx,input)
# Args and output are fixed before opaque H; no Data restriction on owners.
# Invoke the universally quantified body with affine arguments/output.
# The callback consumes/returns H and consumes A exactly according to its
# signature; any error/recovery branches belong to its own output contract.
def invoke_owned(~Ops:Type -> Type,~A:Type,~U:Type,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & U,~H:Type,~caps:Ops(H),args:A,ctx:H) -> H & U:
  body(H,caps,args,ctx)
