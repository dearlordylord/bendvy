import Base
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/transaction.bend as T

# Additive row seam: a caller may give Rest any heterogeneous owned context.
# This is not yet the public World transaction/stamp integration.
type Context<-C:Type,-Rest:Type> is Type:
  Context{owner:C,rest:Rest,original:Maybe<&1,C>}
def projected(~C:Type,~Rest:Type,~V:Data,rest:Rest,original:Maybe<&1,C>,value:C & V) -> Context<C,Rest> & Cmp.Access<V>:
  match value:
    case (owner,view): (Context{owner,rest,original},Cmp.Found{view})
def get(~C:Type,~Rest:Type,~V:Data,~project:C -> C & V,context:Context<C,Rest>) -> Context<C,Rest> & Cmp.Access<V>:
  match context:
    case Context{owner,rest,original}: projected(~C,~Rest,~V,rest,original,project(owner))
def set(~C:Type,~Rest:Type,context:Context<C,Rest>,replacement:C) -> Context<C,Rest>:
  match context:
    case Context{owner,rest,None{}}: Context{replacement,rest,Some{owner}}
    case Context{owner,rest,Some{original}}: Context{replacement,rest,Some{original}}
def read(~C:Type,~Rest:Type,~V:Data,~project:C -> C & V) -> Cap.Read<Context<C,Rest>,V>:
  Cap.Read{get(~C,~Rest,~V,~project)}
def write(~C:Type,~Rest:Type,~V:Data,~project:C -> C & V) -> Cap.Write<Context<C,Rest>,C,V>:
  Cap.Write{get(~C,~Rest,~V,~project),set(~C,~Rest)}
def commit(~C:Type,~Rest:Type,context:Context<C,Rest>) -> C & Rest:
  match context:
    case Context{owner,rest,original}: (owner,rest)
def rollback(~C:Type,~Rest:Type,context:Context<C,Rest>) -> C & Rest:
  match context:
    case Context{owner,rest,None{}}: (owner,rest)
    case Context{owner,rest,Some{original}}: (original,rest)
def invoke(~C:Type,~Rest:Type,~Ops:Type -> Type,~A:Data,~Out:Data,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Out,~caps:Ops(Context<C,Rest>),args:A,owner:C,rest:Rest) -> Context<C,Rest> & Out:
  Cap.invoke(~Ops,~A,~Out,~body,~Context<C,Rest>,~caps,args,Context{owner,rest,None{}})
