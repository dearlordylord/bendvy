import Base
import ./world.bend as W
import ./execution-system.bend as Sys
import ./execution-command-buffer.bend as Buffer

# The buffer is a separate affine owner from gameplay scope and user captures.
# This wrapper is the registered system's Local, so every executor outcome
# returns it through the existing system owner, including refusal/body error.
type Local<-S:Data,-P:Type,-User:Type> is Type:
  Local{user:User,commands:Buffer.Buffer<S,P>}
type Commands<-Q:Type,-S:Data,-P:Type> is Type:
  Commands{insert:Q -> W.Handle<S> -> P -> Q,remove:Q -> W.Handle<S> -> Q,split:Q -> Q & Q,merge:Q -> Q -> Q}
def fresh(~S:Data,~P:Type,~User:Type,user:User) -> Local<S,P,User>:
  Local{user,Buffer.empty(~S,~P)}
def insert_field(~Q:Type,~S:Data,~P:Type,commands:Commands<Q,S,P>) -> Q -> W.Handle<S> -> P -> Q:
  match commands:
    case Commands{insert,_,_,_}:insert
def remove_field(~Q:Type,~S:Data,~P:Type,commands:Commands<Q,S,P>) -> Q -> W.Handle<S> -> Q:
  match commands:
    case Commands{_,remove,_,_}:remove
def split_field(~Q:Type,~S:Data,~P:Type,commands:Commands<Q,S,P>) -> Q -> Q & Q:
  match commands:
    case Commands{_,_,split,_}:split
def merge_field(~Q:Type,~S:Data,~P:Type,commands:Commands<Q,S,P>) -> Q -> Q -> Q:
  match commands:
    case Commands{_,_,_,merge}:merge
def returned(~S:Data,~P:Type,~User:Type,~Error:Data,~Out:Data,~H:Type,result:H & (Buffer.Buffer<S,P> & (User & Sys.Completion<Error,Out>))) -> H & (Local<S,P,User> & Sys.Completion<Error,Out>):
  match result:
    case (scope,(commands,(user,completion))):(scope,(Local{user,commands},completion))

# Internal body adapter; the ordinary registration layer must select the
# component family from its closed schema and inventory this buffer for barriers.
# Both H and Q remain abstract to gameplay. The body never sees a World,
# the allocator, the concrete buffer constructor, or an application callback.
def invoke(~S:Data,~P:Type,~User:Type,~Error:Data,~Out:Data,~Ops:Type -> Type,~body:@-H:Type -> @-Q:Type -> @-caps:Ops(H) -> @-commands:Commands<Q,S,P> -> H -> Q -> User -> H & (Q & (User & Sys.Completion<Error,Out>)),~H:Type,~caps:Ops(H),scope:H,local:Local<S,P,User>) -> H & (Local<S,P,User> & Sys.Completion<Error,Out>):
  match local:
    case Local{user,commands}:returned(~S,~P,~User,~Error,~Out,~H,body(H,Buffer.Buffer<S,P>,caps,Commands{Buffer.insert(~S,~P),Buffer.remove(~S,~P),Buffer.split(~S,~P),Buffer.merge(~S,~P)},scope,commands,user))
