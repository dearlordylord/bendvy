import Base
import ./relation-types.bend as T
import ./execution-relation-failure-channel.bend as Reader
import ./execution-relation-failure-message.bend as Failure
import ./execution-relation-failure-access.bend as Access
import ./execution-composer-layout.bend as Layout
import ./execution-system.bend as Sys
import ./change-tick.bend as Tick

type Local<-S:Data,-descriptor:T.Descriptor<S>,-full:Layout.Layout,-route:Layout.Route,-User:Type> is Type:
  Local{reader:Reader.Reader<S,descriptor,full,route>,user:User}
type Invocation<-H:Type,-L:Type,-Error:Data,-Out:Data> is Type:
  Invoked{scope:H,local:L,completion:Sys.Completion<Error,Out>}
  Refused{scope:H,local:L}
def completed(~S:Data,~descriptor:T.Descriptor<S>,~full:Layout.Layout,~route:Layout.Route,~H:Type,~User:Type,~Error:Data,~Out:Data,reader:Reader.Reader<S,descriptor,full,route>,result:H & (User & Sys.Completion<Error,Out>)) -> Invocation<H,Local<S,descriptor,full,route,User>,Error,Out>:
  match result:
    case (scope,(user,completion)):Invoked{scope,Local{reader,user},completion}
def returned(~S:Data,~descriptor:T.Descriptor<S>,~full:Layout.Layout,~route:Layout.Route,~H:Type,~User:Type,~Error:Data,~Out:Data,~body:H -> User -> List<&2,Failure.Message<S,descriptor>> -> Nat -> Tick.Tick -> H & (User & Sys.Completion<Error,Out>),user:User,result:H & Reader.Reading<S,descriptor,full,route>) -> Invocation<H,Local<S,descriptor,full,route,User>,Error,Out>:
  match result:
    case (scope,Reader.Refused{reader}):Refused{scope,Local{reader,user}}
    case (scope,Reader.Read{reader,messages,missed,tick}):completed(~S,~descriptor,~full,~route,~H,~User,~Error,~Out,reader,body(scope,user,messages,missed,tick))
# Ordinary conditions run before this body adapter. A false condition never
# invokes it. Once read succeeds, the returned Local keeps its advanced reader
# on every body completion, including BodyError; it does not roll back a cursor.
def invoke(~S:Data,~descriptor:T.Descriptor<S>,~full:Layout.Layout,~route:Layout.Route,~H:Type,~User:Type,~Error:Data,~Out:Data,~body:H -> User -> List<&2,Failure.Message<S,descriptor>> -> Nat -> Tick.Tick -> H & (User & Sys.Completion<Error,Out>),cap:Access.Read<S,descriptor,full,route,H>,scope:H,local:Local<S,descriptor,full,route,User>) -> Invocation<H,Local<S,descriptor,full,route,User>,Error,Out>:
  match cap local:
    case Access.Read{read} Local{reader,user}:returned(~S,~descriptor,~full,~route,~H,~User,~Error,~Out,~body,user,read(reader,scope))
