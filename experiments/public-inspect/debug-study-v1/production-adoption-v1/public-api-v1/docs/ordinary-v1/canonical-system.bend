import Base
import ./canonical-schema.bend as Schema
import ./canonical-retained.bend as Retained
import ./canonical-grants.bend as Grants
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP

def completed(~S:Data,~Store:Type,~R:Type,~E:Data,observed:I.Observed<S,Store,R,E,Unit,Bool>) -> Sys.Outcome<W.World<S,Store,R,E>,Unit,I.Instance<S> & Result<&2,&2,Unit,Bool>>:
  match observed:
    case I.Observed{world,instance,result}:Sys.Succeeded{world,(instance,result)}

def invoke(~S:Data,~Store:Type,~P:Type,~Q:Type,~E:Data,~layout:Schema.Layout<S,P,Q>,~V:Data,~U:Data,~showP:P -> P & V,~showQ:Q -> Q & U,~first:Schema.Path,~second:Schema.Path,~body:@-H:Type -> @-caps:Grants.Ops(~V,~U,first,second,H) -> Unit -> H -> H & Result<&2,&2,Unit,Bool>,world:W.World<S,Store,Schema.Owner<S,P,Q,layout>,E>,args:I.Instance<S> & Unit) -> Sys.Outcome<W.World<S,Store,Schema.Owner<S,P,Q,layout>,E>,Unit,I.Instance<S> & Result<&2,&2,Unit,Bool>>:
  match args:
    case (instance,unit):completed(~S,~Store,~Schema.Owner<S,P,Q,layout>,~E,I.run(~S,~Store,~Schema.Owner<S,P,Q,layout>,~E,~(H => Grants.Ops(~V,~U,first,second,H)),~Unit,~Unit,~Bool,~I.Plan{Grants.pair(~S,~Store,~P,~Q,~E,~layout,~V,~U,~showP,~showQ,first,second)},~body,instance,unit,world))

def registered(~S:Data,~Store:Type,~P:Type,~Q:Type,~E:Data,~layout:Schema.Layout<S,P,Q>,~V:Data,~U:Data,~showP:P -> P & V,~showQ:Q -> Q & U,~first:Schema.Path,~second:Schema.Path,~body:@-H:Type -> @-caps:Grants.Ops(~V,~U,first,second,H) -> Unit -> H -> H & Result<&2,&2,Unit,Bool>,result:Sys.RegistrationResult<S,Store,Schema.Owner<S,P,Q,layout>,E,I.Instance<S> & Unit,Unit,I.Instance<S> & Result<&2,&2,Unit,Bool>,(world => args => invoke(~S,~Store,~P,~Q,~E,~layout,~V,~U,~showP,~showQ,~first,~second,~body,world,args))>) -> Retained.Defined<S,W.World<S,Store,Schema.Owner<S,P,Q,layout>,E>,Retained.Registered<S,P,Q,layout,Sys.Registry<S,Store,Schema.Owner<S,P,Q,layout>,E,I.Instance<S> & Unit,Unit,I.Instance<S> & Result<&2,&2,Unit,Bool>,(world => args => invoke(~S,~Store,~P,~Q,~E,~layout,~V,~U,~showP,~showQ,~first,~second,~body,world,args))>>>:
  match result:
    case Sys.RegistrationFailed{world}:Retained.Rejected{world}
    case Sys.Registered{world,registry}:Retained.Defined{world,Retained.Registered{registry,Schema.Params{first,second},[Schema.entry(~S,~P,~Q,layout,first),Schema.entry(~S,~P,~Q,layout,second)],SP.unique(~S,Schema.needs(~S,[Schema.entry(~S,~P,~Q,layout,first),Schema.entry(~S,~P,~Q,layout,second)]))}}

def define(~S:Data,~Store:Type,~P:Type,~Q:Type,~E:Data,~layout:Schema.Layout<S,P,Q>,~V:Data,~U:Data,~showP:P -> P & V,~showQ:Q -> Q & U,~first:Schema.Path,~second:Schema.Path,~body:@-H:Type -> @-caps:Grants.Ops(~V,~U,first,second,H) -> Unit -> H -> H & Result<&2,&2,Unit,Bool>,world:W.World<S,Store,Schema.Owner<S,P,Q,layout>,E>,name:String) -> Retained.Defined<S,W.World<S,Store,Schema.Owner<S,P,Q,layout>,E>,Retained.Registered<S,P,Q,layout,Sys.Registry<S,Store,Schema.Owner<S,P,Q,layout>,E,I.Instance<S> & Unit,Unit,I.Instance<S> & Result<&2,&2,Unit,Bool>,(world => args => invoke(~S,~Store,~P,~Q,~E,~layout,~V,~U,~showP,~showQ,~first,~second,~body,world,args))>>>:
  registered(~S,~Store,~P,~Q,~E,~layout,~V,~U,~showP,~showQ,~first,~second,~body,Sys.register(~S,~Store,~Schema.Owner<S,P,Q,layout>,~E,~(I.Instance<S> & Unit),~Unit,~(I.Instance<S> & Result<&2,&2,Unit,Bool>),~(world => args => invoke(~S,~Store,~P,~Q,~E,~layout,~V,~U,~showP,~showQ,~first,~second,~body,world,args)),world,name,Schema.names(~S,[Schema.entry(~S,~P,~Q,layout,first),Schema.entry(~S,~P,~Q,layout,second)])))
