import Base
import ./declarations.bend as Ordinary
import ./constructors.bend as Factory
import ./staging.bend as Stage
import ./receiver.bend as Receiver
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-restore-publication.bend as Publish
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/restore-leaf.bend as Leaf
import ../../src/ecs/restore-data.bend as R
import ../../src/ecs/decode-data.bend as D
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/lifecycle.bend as Life

def present(values:List<&2,Saved.Field>) -> Bool:
  match values:
    case []:False{}
    case Saved.Field{_,value,_,_} <> _:value
def selected(~S:Data,equal:Bool,key:Key.Key,factory:Factory.ActorFactory(~S),owner:Ordinary.Actor<S>,undo:Ordinary.Actor<S> -> D.Raw,rest:List<Leaf.Record<D.Raw,Ordinary.Actor<S>>>,returned:List<D.Raw>,removed:List<Ordinary.Actor<S>>,applied:List<Leaf.Applied<D.Raw,Ordinary.Actor<S>>>) -> Stage.Actors(~S) & (Maybe<&1,Ordinary.Actor<S>> & Bool):
  match equal:
    case True{}:(Leaf.State{factory,rest,returned,removed,Leaf.Applied{R.Component{key},undo} <> applied},(Some{owner},True{}))
    case False{}:(Leaf.State{factory,Leaf.Record{R.Component{key},owner,undo} <> rest,returned,removed,applied},(None{},False{}))
def take(~S:Data,wanted:Bool,+key:Key.Key,state:Stage.Actors(~S)) -> Stage.Actors(~S) & (Maybe<&1,Ordinary.Actor<S>> & Bool):
  match wanted state:
    case False{} state:(state,(None{},True{}))
    case True{} Leaf.State{factory,Leaf.Record{R.Component{+saved},owner,undo} <> rest,returned,removed,applied}:selected(~S,Key.equal(key,saved),saved,factory,owner,undo,rest,returned,removed,applied)
    case True{} state:(state,(None{},False{}))
type Rows<-S:Data> is Type:Rows{actors:Stage.Actors(~S),values:List<Publish.Row<Receiver.Components(~S)>>,valid:Bool}
def row(~S:Data,key:Key.Key,values:List<Publish.Row<Receiver.Components(~S)>>,valid:Bool,next:Stage.Actors(~S) -> List<Publish.Row<Receiver.Components(~S)>> -> Bool -> Rows<S>,result:Stage.Actors(~S) & (Maybe<&1,Ordinary.Actor<S>> & Bool)) -> Rows<S>:
  match result:
    case (actors,(owner,other)):next(actors,Publish.Row{key,Product.Owner{owner,None{}}} <> values,Bool.and(valid,other))
def rows(~S:Data,entities:List<&2,Saved.Entity>,actors:Stage.Actors(~S),values:List<Publish.Row<Receiver.Components(~S)>>,valid:Bool) -> Rows<S>:
  match entities:
    case []:Rows{actors,values,valid}
    case Saved.Entity{+key,fields} <> rest:row(~S,key,values,valid,nextActors => nextValues => nextValid => rows(~S,rest,nextActors,nextValues,nextValid),take(~S,present(fields),key,actors))
def staged_rows(~S:Data,entities:List<&2,Saved.Entity>,actors:Stage.Actors(~S)) -> Rows<S>:
  rows(~S,List.reverse(&2,Saved.Entity,entities),actors,[],True{})
def publish(~S:Data,values:List<Publish.Row<Receiver.Components(~S)>>,world:Receiver.World(~S),tick:Tick.Tick) -> Publish.Published<S,Receiver.Components(~S),Receiver.Resources(~S),Unit>:
  Publish.publish(~S,~Receiver.Components(~S),~Receiver.Resources(~S),~Unit,values,world,tick)
def ConfigSlot(~S:Data) -> Type:Layout.resources(~S,Layout.subtree(Plan.layout(Ordinary.resources(~S)),Layout.InLeft{Layout.AtLeaf{}}))
type ResourceUpdated<-S:Data> is Type:ResourceUpdated{state:Stage.Configs(~S),resources:Receiver.Resources(~S),previous:Maybe<&1,ConfigSlot(~S)>,valid:Bool}
def refreshed(~S:Data,previous:ConfigSlot(~S),stamp:Life.Stamp,result:Ordinary.Config<S> & Ordinary.ConfigView) -> ConfigSlot(~S) & ConfigSlot(~S):
  match result:
    case (owner,view):(Layout.ResourceSlot{Layout.Viewed{owner,view},stamp},previous)
def replace_slot(~S:Data,previous:ConfigSlot(~S),owner:Ordinary.Config<S>,tick:Tick.Tick) -> ConfigSlot(~S) & ConfigSlot(~S):
  match previous:
    case Layout.ResourceSlot{viewed,+stamp}:refreshed(~S,Layout.ResourceSlot{viewed,stamp},Life.after_write(True{},True{},stamp,tick),Ordinary.config_view(~S,owner))
def resource_returned(~S:Data,state:Stage.Configs(~S),transient:Layout.resources(~S,Layout.subtree(Plan.layout(Ordinary.resources(~S)),Layout.InRight{Layout.AtLeaf{}})),result:ConfigSlot(~S) & ConfigSlot(~S)) -> ResourceUpdated<S>:
  match result:
    case (current,previous):ResourceUpdated{state,Product.Owner{current,transient},Some{previous},True{}}
def resources(~S:Data,state:Stage.Configs(~S),resources:Receiver.Resources(~S),tick:Tick.Tick) -> ResourceUpdated<S>:
  match state resources:
    case Leaf.State{factory,[Leaf.Record{R.Resource{},owner,undo}],returned,removed,applied}, Product.Owner{previous,transient}:resource_returned(~S,Leaf.State{factory,[],returned,removed,Leaf.Applied{R.Resource{},undo} <> applied},transient,replace_slot(~S,previous,owner,tick))
    case state resources:ResourceUpdated{state,resources,None{},False{}}
def alpha_rows(entities:List<&2,Saved.Entity>,actors:Stage.Actors(~Ordinary.Alpha)) -> Rows<Ordinary.Alpha>:staged_rows(~Ordinary.Alpha,entities,actors)
def beta_rows(entities:List<&2,Saved.Entity>,actors:Stage.Actors(~Ordinary.Beta)) -> Rows<Ordinary.Beta>:staged_rows(~Ordinary.Beta,entities,actors)
def alpha_publish(values:List<Publish.Row<Receiver.Components(~Ordinary.Alpha)>>,world:Receiver.World(~Ordinary.Alpha),tick:Tick.Tick) -> Publish.Published<Ordinary.Alpha,Receiver.Components(~Ordinary.Alpha),Receiver.Resources(~Ordinary.Alpha),Unit>:publish(~Ordinary.Alpha,values,world,tick)
def beta_publish(values:List<Publish.Row<Receiver.Components(~Ordinary.Beta)>>,world:Receiver.World(~Ordinary.Beta),tick:Tick.Tick) -> Publish.Published<Ordinary.Beta,Receiver.Components(~Ordinary.Beta),Receiver.Resources(~Ordinary.Beta),Unit>:publish(~Ordinary.Beta,values,world,tick)
def alpha_resources(state:Stage.Configs(~Ordinary.Alpha),owners:Receiver.Resources(~Ordinary.Alpha),tick:Tick.Tick) -> ResourceUpdated<Ordinary.Alpha>:resources(~Ordinary.Alpha,state,owners,tick)
def beta_resources(state:Stage.Configs(~Ordinary.Beta),owners:Receiver.Resources(~Ordinary.Beta),tick:Tick.Tick) -> ResourceUpdated<Ordinary.Beta>:resources(~Ordinary.Beta,state,owners,tick)
