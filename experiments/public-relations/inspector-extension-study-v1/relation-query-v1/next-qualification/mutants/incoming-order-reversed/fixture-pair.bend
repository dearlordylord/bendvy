import Base
import fixture-schema.bend as D
import fixture-build.bend as Build
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/relation-commands.bend as A

type WorldPair<S:Data> is Type:
  WorldPair{factory:W.Factory,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,one:W.Handle<S>,two:W.Handle<S>,three:W.Handle<S>,four:W.Handle<S>,lookups:List<&2,W.Handle<S>>,errors:String}
  PrimaryRefused{factory:W.Factory,resource:D.Resources}
  ForeignRefused{world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,factory:W.Factory,resource:D.Resources}
  ShapeRefused{factory:W.Factory,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,targets:List<&2,W.Handle<S>>,foreignTargets:List<&2,W.Handle<S>>,errors:String}
def invalids(~S:Data,+one:W.Handle<S>,+two:W.Handle<S>,+three:W.Handle<S>,+four:W.Handle<S>,foreign:W.Handle<S>) -> List<&2,W.Handle<S>>:
  match one:
    case W.Handle{namespace,_}:[one,two,three,four,W.Handle{namespace,0},W.Handle{namespace,5},foreign]
def shaped(~S:Data,targets:List<&2,W.Handle<S>>,foreignTargets:List<&2,W.Handle<S>>,factory:W.Factory,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,errors:String) -> WorldPair<S>:
  match targets foreignTargets:
    case [+one,+two,+three,+four] alien <> rest:WorldPair{factory,world,foreign,one,two,three,four,invalids(~S,one,two,three,four,alien),errors}
    case targets foreignTargets:ShapeRefused{factory,world,foreign,targets,foreignTargets,errors}
def foreign_built(~S:Data,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,targets:List<&2,W.Handle<S>>,errors:String,result:Build.Built<S>) -> WorldPair<S>:
  match result:
    case Build.BuildRefused{factory,resource}:ForeignRefused{world,factory,resource}
    case Build.Built{factory,Build.Fixture{foreign,foreignTargets,foreignErrors}}:
      shaped(~S,targets,foreignTargets,factory,world,foreign,errors ++ foreignErrors)
def primary_built(~S:Data,base:U32,result:Build.Built<S>) -> WorldPair<S>:
  match result:
    case Build.BuildRefused{factory,resource}:PrimaryRefused{factory,resource}
    case Build.Built{factory,Build.Fixture{world,targets,errors}}:foreign_built(~S,world,targets,errors,Build.build(~S,(base + 1000 : U32),factory))
def build(~S:Data,+base:U32) -> WorldPair<S>:
  primary_built(~S,base,Build.build(~S,base,W.factory()))
