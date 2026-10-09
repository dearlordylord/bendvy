import Base
import inspector.bend as I
import inspector-metadata.bend as Meta
import world.bend as W

# Unchecked extraction draft. Descriptor is trusted closed schema setup;
# arbitrary runtime owner is threaded once, never captured by the callback.
type State<-S:Data,-Store:Type,-R:Type,-E:Data,-Ops:Type -> Type,-descriptor:Meta.Definition<S,I.Plan<S,Store,R,E,Ops>>,-Owner:Type> is Type:
  State{owner:Owner}
def metadata_field(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,definition:Meta.Definition<S,I.Plan<S,Store,R,E,Ops>>) -> Meta.Metadata<S>:
  match definition:
    case Meta.Definition{metadata,_}:metadata
def metadata(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~descriptor:Meta.Definition<S,I.Plan<S,Store,R,E,Ops>>) -> Meta.Metadata<S>:
  metadata_field(~S,~Store,~R,~E,~Ops,descriptor)
def plan(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~descriptor:Meta.Definition<S,I.Plan<S,Store,R,E,Ops>>) -> I.Plan<S,Store,R,E,Ops>:
  Meta.into_plan(~S,~I.Plan<S,Store,R,E,Ops>,descriptor)
def attach(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~descriptor:Meta.Definition<S,I.Plan<S,Store,R,E,Ops>>,~Owner:Type,owner:Owner) -> State<S,Store,R,E,Ops,descriptor,Owner>:
  State{owner}
def read(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~descriptor:Meta.Definition<S,I.Plan<S,Store,R,E,Ops>>,~Owner:Type,state:State<S,Store,R,E,Ops,descriptor,Owner>) -> State<S,Store,R,E,Ops,descriptor,Owner> & Meta.Metadata<S>:
  (state,metadata(~S,~Store,~R,~E,~Ops,~descriptor))
def invoke(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~descriptor:Meta.Definition<S,I.Plan<S,Store,R,E,Ops>>,~Owner:Type,~A:Data,~U:Data,~Out:Data,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Result<&2,&2,U,Out>,state:State<S,Store,R,E,Ops,descriptor,Owner>,instance:I.Instance<S>,args:A,world:W.World<S,Store,R,E>) -> State<S,Store,R,E,Ops,descriptor,Owner> & I.Observed<S,Store,R,E,U,Out>:
  (state,I.run(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan(~S,~Store,~R,~E,~Ops,~descriptor),~body,instance,args,world))
