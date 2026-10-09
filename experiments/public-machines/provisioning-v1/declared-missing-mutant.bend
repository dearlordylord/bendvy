import Base
import requirements.bend as Req
import scene/provider.bend as P
import scene/application.bend as App
import scene/conditions.bend as Cond
import scene/gameplay.bend as G
import ../../../../../bendvy/src/ecs/machine.bend as M
import ../../../../../bendvy/src/ecs/world.bend as W

type Token<S: Data> is Data:
  Flow{}
  Level{}
def same(~S: Data,left: Token<S>,right: Token<S>) -> Bool:
  match left right:
    case Flow{} Flow{}: True{}
    case Level{} Level{}: True{}
    case _ _: False{}
def leaf(~S: Data,atom: P.Atom<S>) -> Req.Requirements<S,Token<S>>:
  match atom:
    case P.InFlow{_}: Req.Requirements{[Flow{}]}
    case P.FlowChanged{}: Req.Requirements{[Flow{}]}
    case P.InLevel{_}: Req.Requirements{[Level{}]}
    case P.LevelChanged{}: Req.Requirements{[Level{}]}
    case P.FlowExists{}: Req.Requirements{[Flow{}]}
    case P.LevelExists{}: Req.Requirements{[Level{}]}
def condition(~S: Data,tree: Cond.Tree<P.Atom<S>>) -> Req.Requirements<S,Token<S>>:
  match tree:
    case Cond.Constant{_}: Req.Requirements{[]}
    case Cond.Leaf{atom}: leaf(~S,atom)
    case Cond.Negate{inner}: condition(~S,inner)
    case Cond.Both{left,right}: Req.union(~S,~Token<S>,~(a => b => same(~S,a,b)),condition(~S,left),condition(~S,right))
    case Cond.Either{left,right}: Req.union(~S,~Token<S>,~(a => b => same(~S,a,b)),condition(~S,left),condition(~S,right))
def action(~S: Data,action: App.Action<S>) -> Req.Requirements<S,Token<S>>:
  match action:
    case App.Body{_,_,G.Seed{}}: Req.Requirements{[]}
    case App.Body{_,_,_}: Req.Requirements{[Flow{},Level{}]}
    case App.Marker{False{}}: Req.Requirements{[]}
    case App.Marker{True{}}: Req.Requirements{[Flow{},Level{}]}
    case App.Deferred{}: Req.Requirements{[]}
    case App.Read{_,_,_}: Req.Requirements{[Flow{},Level{}]}
    case App.GatedRead{_,_,_}: Req.Requirements{[Flow{},Level{}]}
    case App.Gate{_,_,_}: Req.Requirements{[]}
def actions(~S: Data,items: List<&2,App.Action<S>>) -> Req.Requirements<S,Token<S>>:
  match items:
    case Nil{}: Req.Requirements{[]}
    case Con{head,rest}: Req.union(~S,~Token<S>,~(a => b => same(~S,a,b)),action(~S,head),actions(~S,rest))

# Referenced optional state resources are retained separately from required access.
def optional_action(~S: Data,item: App.Action<S>) -> Req.Requirements<S,Token<S>>:
  match item:
    case App.Gate{_,_,tree}: condition(~S,tree)
    case App.GatedRead{_,_,tree}: condition(~S,tree)
    case _: Req.Requirements{[]}
def optional_actions(~S: Data,items: List<&2,App.Action<S>>) -> Req.Requirements<S,Token<S>>:
  match items:
    case Nil{}: Req.Requirements{[]}
    case Con{head,rest}: Req.union(~S,~Token<S>,~(a => b => same(~S,a,b)),optional_action(~S,head),optional_actions(~S,rest))

type Plan<S: Data> is Data:
  Plan{name: String,actions: List<&2,App.Action<S>>,requirements: Req.Requirements<S,Token<S>>,optionalReferences: Req.Requirements<S,Token<S>>}
def declare(~S: Data,name: String,+items: List<&2,App.Action<S>>) -> Plan<S>:
  Plan{name,items,actions(~S,items),optional_actions(~S,items)}
def present(~S: Data,token: Token<S>,env: P.ConditionEnv<S>) -> Bool:
  match token env:
    case Flow{},P.ConditionEnv{flow,_}: P.slot_present(~S,~P.FlowToken,~P.Flow,flow)
    case Level{},P.ConditionEnv{_,level}: P.slot_present(~S,~P.LevelToken,~P.Level,level)
def inspect(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & P.ConditionEnv<S>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,+flow,+level,fs,ls,frame,tick,trace},events,pending,registrations,nextSystem,clock}:
      (W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,fs,ls,frame,tick,trace},events,pending,registrations,nextSystem,clock},P.ConditionEnv{flow,level})
def run_checked(~S: Data,name: String,+items: List<&2,App.Action<S>>,checked: Req.Checked<S,Token<S>,App.Owners<S>,W.World<S,P.Store<S>,P.Resources<S>,Unit>>) -> App.FrameResult<S>:
  match checked:
    case Req.Missing{owners,world,_}: App.named(~S,owners,name,items,W.namespace(~S,~P.Store<S>,~P.Resources<S>,~Unit,world))
    case Req.Ready{owners,world}: App.named(~S,owners,name,items,W.namespace(~S,~P.Store<S>,~P.Resources<S>,~Unit,world))
def frame(~S: Data,owners: App.Owners<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,plan: Plan<S>) -> App.FrameResult<S>:
  match plan:
    case Plan{name,+items,requirements,_}:
      run_checked(~S,name,items,Req.preflight(~S,~Token<S>,~P.ConditionEnv<S>,~App.Owners<S>,~W.World<S,P.Store<S>,P.Resources<S>,Unit>,~(w => inspect(~S,w)),~(key => env => present(~S,key,env)),requirements,owners,world))
