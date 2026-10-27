import Base
import ./declarations.bend as Ordinary
import ./constructors.bend as Factory
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-restore-stage.bend as Stage
import ../../src/ecs/restore-leaf.bend as Leaf
import ../../src/ecs/restore-data.bend as R
import ../../src/ecs/decode-construction.bend as Constructor
import ../../src/ecs/decode-data.bend as D
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/persistence-declaration.bend as Decl

def Actors(~S:Data) -> Type:Leaf.State<Factory.ActorFactory(~S),D.Raw,Ordinary.Actor<S>>
def Configs(~S:Data) -> Type:Leaf.State<Factory.ConfigFactory(~S),D.Raw,Ordinary.Config<S>>
type State<-S:Data> is Type:
  State{schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,actors:Actors(~S),configs:Configs(~S)}
def empty(~S:Data,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>) -> State<S>:
  match schema:
    case Plan.Schema{Product.Owner{Decl.Constructed{+actorCodec},componentTransient},Product.Owner{Decl.Constructed{+configCodec},resourceTransient}}:State{Plan.Schema{Product.Owner{Decl.Constructed{actorCodec},componentTransient},Product.Owner{Decl.Constructed{configCodec},resourceTransient}},Leaf.empty(~Factory.ActorFactory(~S),~D.Raw,~Ordinary.Actor<S>,Factory.actor_factory(~S,Decl.Constructed{actorCodec})),Leaf.empty(~Factory.ConfigFactory(~S),~D.Raw,~Ordinary.Config<S>,Factory.config_factory(~S,Decl.Constructed{configCodec}))}
def actor(~S:Data,state:Actors(~S),position:R.Position,raw:D.Raw) -> Actors(~S) & R.Dispatch<Unit>:
  match state:
    case Leaf.State{+factory,records,returned,removed,applied}:Leaf.constructed(~Factory.ActorFactory(~S),~D.Raw,~Ordinary.Actor<S>,~Unit,position,records,returned,removed,applied,factory,Constructor.fallible_construct(~S,~D.Raw,~Ordinary.Actor<S>,~Unit,~Plan.identity(~S,~Ordinary.Actor<S>,"actor"),~Ordinary.actor_project(~S),~Factory.incoming,~Factory.actor_build(~S),factory,raw))
def config(~S:Data,state:Configs(~S),position:R.Position,raw:D.Raw) -> Configs(~S) & R.Dispatch<Unit>:
  match state:
    case Leaf.State{+factory,records,returned,removed,applied}:Leaf.constructed(~Factory.ConfigFactory(~S),~D.Raw,~Ordinary.Config<S>,~Unit,position,records,returned,removed,applied,factory,Constructor.fallible_construct(~S,~D.Raw,~Ordinary.Config<S>,~Unit,~Plan.identity(~S,~Ordinary.Config<S>,"config"),~Ordinary.config_project(~S),~Factory.incoming,~Factory.config_build(~S),factory,raw))
def actor_returned(~S:Data,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,configs:Configs(~S),result:Actors(~S) & R.Dispatch<Unit>) -> State<S> & R.Dispatch<Unit>:
  match result:
    case (actors,dispatch):(State{schema,actors,configs},dispatch)
def config_returned(~S:Data,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,actors:Actors(~S),result:Configs(~S) & R.Dispatch<Unit>) -> State<S> & R.Dispatch<Unit>:
  match result:
    case (configs,dispatch):(State{schema,actors,configs},dispatch)
def actor_named(~S:Data,matches:Bool,state:State<S>,position:R.Position,raw:D.Raw) -> State<S> & R.Dispatch<Unit>:
  match matches state:
    case False{} state:(state,R.Unhandled{})
    case True{} State{schema,actors,configs}:actor_returned(~S,schema,configs,actor(~S,actors,position,raw))
def config_named(~S:Data,matches:Bool,state:State<S>,position:R.Position,raw:D.Raw) -> State<S> & R.Dispatch<Unit>:
  match matches state:
    case False{} state:(state,R.Unhandled{})
    case True{} State{schema,actors,configs}:config_returned(~S,schema,actors,config(~S,configs,position,raw))
def field(~S:Data,state:State<S>,position:R.Position,field:D.Field) -> State<S> & R.Dispatch<Unit>:
  match position field:
    case R.Component{key} D.Field{name,raw}:actor_named(~S,String.eq(name,"actor"),state,R.Component{key},raw)
    case R.Resource{} D.Field{name,raw}:config_named(~S,String.eq(name,"config"),state,R.Resource{},raw)
def release(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{schema,actors,configs}:State{schema,Leaf.release(~Factory.ActorFactory(~S),~D.Raw,~Ordinary.Actor<S>,actors),Leaf.release(~Factory.ConfigFactory(~S),~D.Raw,~Ordinary.Config<S>,configs)}
# Internal continuation after admission; records are not yet receiver payloads.
def admitted(~S:Data,state:State<S>,input:Saved.Snapshot<S>) -> State<S> & (Saved.Snapshot<S> & Maybe<&2,R.Error<Unit>>):
  Stage.admitted(~S,~State<S>,~Unit,~field(~S),~release(~S),state,input)
def alpha(state:State<Ordinary.Alpha>,input:Saved.Snapshot<Ordinary.Alpha>) -> State<Ordinary.Alpha> & (Saved.Snapshot<Ordinary.Alpha> & Maybe<&2,R.Error<Unit>>):admitted(~Ordinary.Alpha,state,input)
def beta(state:State<Ordinary.Beta>,input:Saved.Snapshot<Ordinary.Beta>) -> State<Ordinary.Beta> & (Saved.Snapshot<Ordinary.Beta> & Maybe<&2,R.Error<Unit>>):admitted(~Ordinary.Beta,state,input)
