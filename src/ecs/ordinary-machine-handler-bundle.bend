import Base
import ./machine-handler-phases.bend as Phase
import ./ordinary-machine-handler-bundle-context.bend as Context
import ./trace-facts.bend as Facts
import ./world.bend as W
import ./system.bend as Sys
import ./machine.bend as M
import ./machine-handlers.bend as H
import ./machine-handler-bundle.bend as B
import ./schedule.bend as Sch
import ./ordinary-machine-schedule.bend as Ordinary

# Bundle preflight precedes ordinary barrier; selected registry owners recover authored order.
# Advanced marker-phase owner state retaining all registered handlers.
# Pending/Unavailable retain authored entries; Selected also retains positions
# needed to restore authored order. Thread these owners; never copy registries.
type Owners<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Pending{entries:List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>>}
  Unavailable{entries:List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>>}
  Selected{positions:List<&2,B.Position<S,K,V,Q>>,kept:List<&1,H.Entry<S,C,R,E,V,runner>>,active:Phase.Owners<S,K,V,C,R,E,runner>,phase:H.Phase}
# Marker outcome retains the handler bundle and world inside BundleResult,
# with actual schedule steps and observations. Refusal is distinct from handler
# failure; use the result status rather than inferring success from step count.
type MarkerResult<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  MarkerResult{result:B.BundleResult<S,K,V,Q,C,R,E,runner>,steps:List<&2,Sch.Step>,observations:List<&2,Sch.Observation>}
def unobserved(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,trace:Facts.State,world:W.World<S,C,R,E>,args:H.Invocation<V>) -> Sys.Outcome<W.World<S,C,R,E>,String,Unit> & Facts.State:
  (runner(world,args),trace)
def returned(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,value:Context.MarkerResult<S,K,V,Q,C,R,E,runner>) -> MarkerResult<S,K,V,Q,C,R,E,runner>:
  match value:
    case Context.MarkerResult{result,steps,observations,_}:MarkerResult{result,steps,observations}
# Execute a complete ordinary transition marker with a registered handler
# bundle. Checks bundle world and requirements before the structural barrier,
# then applies the existing exit/transition/enter sequence. Owners return in
# authored order. Exit/transition failures retain retryable pending transition;
# enter failure retains committed current state/publication. Earlier successful
# handler transactions are not rolled back with the entire marker.
# Detailed contract: docs/parity/handlers.md.
def run(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,+declaration:Ordinary.Declaration<S>,bundle:B.Bundle<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>) -> MarkerResult<S,K,V,Q,C,R,E,runner>:
  returned(~S,~K,~V,~Q,~C,~R,~E,~runner,Context.run(~S,~K,~V,~Q,~C,~R,~E,~runner,~unobserved(~S,~C,~R,~E,~V,~runner),~"",~take,~put,~publish,~same,~requirement_same,~has,~frame,declaration,bundle,world,Facts.Off{}))
def context_owners(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,owners:Owners<S,K,V,Q,C,R,E,runner>) -> Context.Owners<S,K,V,Q,C,R,E,runner>:
  match owners:
    case Pending{entries}:Context.Pending{entries,Facts.Off{}}
    case Unavailable{entries}:Context.Unavailable{entries,Facts.Off{}}
    case Selected{positions,kept,active,phase}:Context.Selected{positions,kept,active,phase,Facts.Off{}}
def classic_owners(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,owners:Context.Owners<S,K,V,Q,C,R,E,runner>) -> Owners<S,K,V,Q,C,R,E,runner>:
  match owners:
    case Context.Pending{entries,_}:Pending{entries}
    case Context.Unavailable{entries,_}:Unavailable{entries}
    case Context.Selected{positions,kept,active,phase,_}:Selected{positions,kept,active,phase}
def phase_returned(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,result:Context.Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>) -> Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match result:
    case (owners,outcome):(classic_owners(~S,~K,~V,~Q,~C,~R,~E,~runner,owners),outcome)
# Advanced schedule-phase adapter: begin processing a pending transition and
# select matching handlers, returning phase owners plus system outcome.
# Use run for the complete preflight/barrier/phase/recovery sequence; this
# individual adapter does not perform bundle admission on its own.
def apply(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,owners:Owners<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>) -> Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  phase_returned(~S,~K,~V,~Q,~C,~R,~E,~runner,Context.apply(~S,~K,~V,~Q,~C,~R,~E,~runner,~unobserved(~S,~C,~R,~E,~V,~runner),~"",~take,~put,~publish,~same,~requirement_same,~has,~frame,context_owners(~S,~K,~V,~Q,~C,~R,~E,~runner,owners),world))
# Advanced adapter for the exit-handler phase, returning handler owners
# and world outcome. It does not imply whole-marker rollback on failure;
# prefer run to preserve the full validated phase sequence.
def exit(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,owners:Owners<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>) -> Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  phase_returned(~S,~K,~V,~Q,~C,~R,~E,~runner,Context.exit(~S,~K,~V,~Q,~C,~R,~E,~runner,~unobserved(~S,~C,~R,~E,~V,~runner),~"",~take,~put,~publish,~same,~requirement_same,~has,~frame,context_owners(~S,~K,~V,~Q,~C,~R,~E,~runner,owners),world))
# Advanced adapter for transition handlers within the ordinary marker
# sequence. Returns owners and world outcome; earlier successful transactions
# remain committed. Use run for preflight and final bundle-owner recovery.
def transition(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,owners:Owners<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>) -> Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  phase_returned(~S,~K,~V,~Q,~C,~R,~E,~runner,Context.transition(~S,~K,~V,~Q,~C,~R,~E,~runner,~unobserved(~S,~C,~R,~E,~V,~runner),~"",~take,~put,~publish,~same,~requirement_same,~has,~frame,context_owners(~S,~K,~V,~Q,~C,~R,~E,~runner,owners),world))
# Advanced adapter for enter handlers after transition commitment. Failure
# retains committed state and publication; it does not restore the previous
# machine state. Returns owners and world outcome for final recovery.
def enter(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,owners:Owners<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>) -> Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  phase_returned(~S,~K,~V,~Q,~C,~R,~E,~runner,Context.enter(~S,~K,~V,~Q,~C,~R,~E,~runner,~unobserved(~S,~C,~R,~E,~V,~runner),~"",~take,~put,~publish,~same,~requirement_same,~has,~frame,context_owners(~S,~K,~V,~Q,~C,~R,~E,~runner,owners),world))
def finished_returned(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,result:B.BundleResult<S,K,V,Q,C,R,E,runner> & Facts.State) -> B.BundleResult<S,K,V,Q,C,R,E,runner>:
  match result:
    case (result,_):result
# Advanced finalization adapter recovering the registered bundle in authored
# order and reporting the supplied phase error/status. Returns world and all
# retained owners; does not undo already committed handler transactions.
def finished(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,namespace:U32,owners:Owners<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>,error:Maybe<&2,String>) -> B.BundleResult<S,K,V,Q,C,R,E,runner>:
  finished_returned(~S,~K,~V,~Q,~C,~R,~E,~runner,Context.finished(~S,~K,~V,~Q,~C,~R,~E,~runner,~unobserved(~S,~C,~R,~E,~V,~runner),~"",~take,~put,~publish,~same,~requirement_same,~has,~frame,namespace,context_owners(~S,~K,~V,~Q,~C,~R,~E,~runner,owners),world,error))
