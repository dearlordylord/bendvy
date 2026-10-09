import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/graph-machine-v1/app.bend as Core
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/app.bend as OrdinaryApp
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/graph-machine-v1/handler-inventory-v1/handlers.bend as Inspect
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-handler-bundle.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/machine-world.bend as MW
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
type Application<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,Owners:Type,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,-take:R -> R & M.Slot<S,K,V>,-put:R -> M.Slot<S,K,V> -> R> is Type:
  Application{core:Core.Application<S,C,R,E,Owners>,family:M.Family<S,K,V,R,take,put>,bundle:B.Bundle<S,K,V,Q,C,R,E,runner>}
type Description<S:Data,K:Data,V:Data,Q:Data> is Data:
  Description{ordinary:Core.Description<S>,machine:String,handlers:Inspect.BundleView<S,K,V,Q>}
def declare(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Owners:Type,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,core:Core.Application<S,C,R,E,Owners>,family:M.Family<S,K,V,R,take,put>,bundle:B.Bundle<S,K,V,Q,C,R,E,runner>) -> Application<S,K,V,Q,C,R,E,Owners,runner,take,put>:
  Application{core,family,bundle}
def described(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Owners:Type,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,core:Core.Application<S,C,R,E,Owners>,+family:M.Family<S,K,V,R,take,put>,description:Core.Description<S>,got:B.Bundle<S,K,V,Q,C,R,E,runner> & Inspect.BundleView<S,K,V,Q>) -> Application<S,K,V,Q,C,R,E,Owners,runner,take,put> & Maybe<&2,Description<S,K,V,Q>>:
  match family:
    case M.Family{+name}:
      (bundle,handlers)=got
      (Application{core,M.Family{name},bundle},Some{Description{description,name,handlers}})
def projected(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Owners:Type,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,family:M.Family<S,K,V,R,take,put>,bundle:B.Bundle<S,K,V,Q,C,R,E,runner>,got:Core.Application<S,C,R,E,Owners> & Maybe<&2,Core.Description<S>>) -> Application<S,K,V,Q,C,R,E,Owners,runner,take,put> & Maybe<&2,Description<S,K,V,Q>>:
  match got:
    case (core,None{}):(Application{core,family,bundle},None{})
    case (core,Some{description}):described(~S,~K,~V,~Q,~C,~R,~E,~runner,~Owners,~take,~put,core,family,description,Inspect.inspect(~S,~K,~V,~Q,~C,~R,~E,~runner,bundle))
def describe(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Owners:Type,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,app:Application<S,K,V,Q,C,R,E,Owners,runner,take,put>) -> Application<S,K,V,Q,C,R,E,Owners,runner,take,put> & Maybe<&2,Description<S,K,V,Q>>:
  match app:
    case Application{core,family,bundle}:projected(~S,~K,~V,~Q,~C,~R,~E,~runner,~Owners,~take,~put,family,bundle,Core.describe(~S,~C,~R,~E,~Owners,core))
def debug(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Owners:Type,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,mode:OrdinaryApp.Debug,app:Application<S,K,V,Q,C,R,E,Owners,runner,take,put>) -> Application<S,K,V,Q,C,R,E,Owners,runner,take,put>:
  match app:
    case Application{Core.Application{OrdinaryApp.Application{schema,_,bindings,schedule},relations,machines},family,bundle}:Application{Core.Application{OrdinaryApp.Application{schema,mode,bindings,schedule},relations,machines},family,bundle}
def run(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Owners:Type,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,app:Application<S,K,V,Q,C,R,E,Owners,runner,take,put>,world:W.World<S,C,R,E>) -> B.BundleResult<S,K,V,Q,C,R,E,runner> & (Core.Application<S,C,R,E,Owners> & M.Family<S,K,V,R,take,put>):
  match app:
    case Application{core,family,bundle}:(B.run(~S,~K,~V,~Q,~C,~R,~E,~runner,~MW.take(~S,~K,~V,~C,~R,~E,~take),~MW.put(~S,~K,~V,~C,~R,~E,~put),~publish,~same,~requirement_same,~has,~frame,bundle,world),(core,family))
