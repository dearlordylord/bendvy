import Base
import ../../../src/ecs/execution-machine-state.bend as State
import ../../../src/ecs/execution-machine-stream.bend as Stream
import ../../../src/ecs/machine.bend as M
import ../../../src/ecs/change-tick.bend as Tick
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/machine-stream-queue.bend as Queue

# Draft actual-function subjects. These quantify reusable V/event metadata and
# return the actual Type-valued Cell constructor. They do not quantify an
# arbitrary affine Cell, World, Local, capture, payload owner, or IO operation.
# No generic affine-owner preservation theorem is implied by these statements.

# Guarantees: comparator equality retains Current, revision and current stamp,
# consumes Next, and records the requested representation in Previous/event/intent.
# Why it matters: equal but differently represented state values must follow the
# same Bevy boundary as ordinary same-representation equality.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_state/src/state/transitions.rs#L138-L170
# Bevy behavior: equality retains State; exited is entered.clone(), and that
# requested exited value is written to both StateTransitionEvent and PreviousState.
law committed_equal_exact:
  for S:Data
  for K:Data
  for V:Data
  for +from:V
  for +to:V
  for +skipSame:Bool
  for +stream:Stream.Store<V>
  for +revision:Nat
  for +stamp:Maybe<&2,Tick.Tick>
  for +sequence:Nat
  for +tick:Tick.Tick
  for +namespace:Maybe<&2,U32>
  {State.committed(~S,~K,~V,from,to,skipSame,stream,revision,stamp,sequence,tick,True{},namespace) == State.Cell{M.Present{from,M.NoPending{},Some{to},False{}},Stream.publish(~V,stream,1n+sequence,M.Transition{to,to}),revision,stamp,Some{tick},1n+sequence,False{},namespace,State.Transition{to,to,Bool.not(skipSame)}} : State.Cell<S,K,V>}

# Guarantees: the actual pending-state apply path uses the same equal transition
# result, regardless of prior Previous/changed/intent/initial metadata.
# Why it matters: fixing a helper alone must not leave ordinary apply selecting
# the old representation or overwriting Current with an equivalent request.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_state/src/state/freely_mutable_state.rs#L54-L69
# Bevy behavior: the pending value and transition policy are taken at the actual
# apply boundary and passed into internal_apply_state_transition.
law apply_equal_exact:
  for S:Data
  for K:Data
  for V:Data
  for same:V -> V -> Bool
  for +from:V
  for +to:V
  for +skipSame:Bool
  for previous:Maybe<&2,V>
  for changed:Bool
  for +stream:Stream.Store<V>
  for +revision:Nat
  for +stamp:Maybe<&2,Tick.Tick>
  for nextStamp:Maybe<&2,Tick.Tick>
  for +sequence:Nat
  for initialPending:Bool
  for +namespace:Maybe<&2,U32>
  for priorIntent:State.Intent<V>
  for +tick:Tick.Tick
  for equal:{same(from,to) == True{} : Bool}
  {State.apply(~S,~K,~V,~same,State.Cell{M.Present{from,M.Queued{to,skipSame},previous,changed},stream,revision,stamp,nextStamp,sequence,initialPending,namespace,priorIntent},tick) == State.Cell{M.Present{from,M.NoPending{},Some{to},False{}},Stream.publish(~V,stream,1n+sequence,M.Transition{to,to}),revision,stamp,Some{tick},1n+sequence,False{},namespace,State.Transition{to,to,Bool.not(skipSame)}} : State.Cell<S,K,V>}

# Guarantees: an unequal commit installs the requested Current, remembers the
# actual prior Current, stamps the write, and enables Exit and Enter.
# Why it matters: comparator inequality must not silently retain the prior state.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_state/src/state/transitions.rs#L148-L170
# Bevy behavior: mem::replace installs entered and returns the actual exited value.
law committed_unequal_exact:
  for S:Data
  for K:Data
  for V:Data
  for +from:V
  for +to:V
  for skipSame:Bool
  for +stream:Stream.Store<V>
  for +revision:Nat
  for stamp:Maybe<&2,Tick.Tick>
  for +sequence:Nat
  for +tick:Tick.Tick
  for +namespace:Maybe<&2,U32>
  {State.committed(~S,~K,~V,from,to,skipSame,stream,revision,stamp,sequence,tick,False{},namespace) == State.Cell{M.Present{to,M.NoPending{},Some{from},True{}},Stream.publish(~V,stream,1n+sequence,M.Transition{from,to}),1n+revision,Some{tick},Some{tick},1n+sequence,False{},namespace,State.Transition{from,to,True{}}} : State.Cell<S,K,V>}

# Guarantees: Reset clears present Next and stamps that Next write at the supplied
# actual boundary tick while preserving every Current/event/phase field.
# Why it matters: cancelling a request must not commit it or erase earlier events.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_state/src/state/resources.rs#L213-L216
# Bevy behavior: reset writes NextState::Unchanged; the trusted Bend adapter
# supplies this tick from actual Scope.tick, not an ordinary caller clock.
law reset_present_exact:
  for S:Data
  for K:Data
  for V:Data
  for same:V -> V -> Bool
  for +current:V
  for pending:M.Pending<V>
  for +previous:Maybe<&2,V>
  for +changed:Bool
  for +stream:Stream.Store<V>
  for +revision:Nat
  for +stamp:Maybe<&2,Tick.Tick>
  for nextStamp:Maybe<&2,Tick.Tick>
  for +sequence:Nat
  for +initialPending:Bool
  for +namespace:Maybe<&2,U32>
  for +intent:State.Intent<V>
  for +tick:Tick.Tick
  {State.queued_at(~S,~K,~V,~same,M.Reset{},tick,State.Cell{M.Present{current,pending,previous,changed},stream,revision,stamp,nextStamp,sequence,initialPending,namespace,intent}) == (State.Cell{M.Present{current,M.NoPending{},previous,changed},stream,revision,stamp,Some{tick},sequence,initialPending,namespace,intent},Unit{}) : (State.Cell<S,K,V> & Unit)}

# Guarantees: a Reader from a different actual namespace is returned unchanged,
# with refusal and the exact supplied event store; its cursor does not advance.
# Why it matters: same-schema handles and matching reader ids cannot cross Worlds.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/message_cursor.rs#L54-L63
# Bend adaptation: exact origin/route are static Reader parameters; namespace
# refusal is the checked World adapter boundary, not a Bevy runtime Reader API.
law foreign_reader_exact:
  for S:Data
  for K:Data
  for V:Data
  for origin:Layout.Layout
  for route:Layout.Route
  for +namespace:U32
  for +foreign:U32
  for +id:U32
  for +cursor:Nat
  for sequence:Nat
  for tick:Tick.Tick
  for +store:Stream.Store<V>
  for unequal:{U32.is_eq(namespace,foreign) == False{} : Bool}
  {Stream.read(~S,~K,~V,~origin,~route,Some{namespace},sequence,tick,Stream.Reader{foreign,id,cursor},store) == (store,Stream.Refused{Stream.Reader{foreign,id,cursor}}) : (Stream.Store<V> & Stream.Reading<S,K,V,origin,route>)}

# Guarantees: a matching Reader advances to message sequence, independently of
# the genuine read tick, and returns the named queue read/missed result.
# Why it matters: tick zero and repeated same-tick events must not become cursors.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/message_cursor.rs#L54-L63
# Scope: this pins the actual typed Reader wrapper and cursor boundary; queue
# event ordering/filtering inside Queue.read needs its own laws.
law matching_reader_cursor_exact:
  for S:Data
  for K:Data
  for V:Data
  for origin:Layout.Layout
  for route:Layout.Route
  for +namespace:U32
  for +id:U32
  for +cursor:Nat
  for +sequence:Nat
  for +tick:Tick.Tick
  for +queue:Queue.Queue<M.Transition<V>>
  for +olderThrough:Nat
  for +maintenance:Maybe<&2,Tick.Tick>
  {Stream.read(~S,~K,~V,~origin,~route,Some{namespace},sequence,tick,Stream.Reader{namespace,id,cursor},Stream.Store{queue,olderThrough,maintenance}) == (Stream.Store{queue,olderThrough,maintenance},Stream.Read{Stream.Reader{namespace,id,sequence},Queue.read(~M.Transition<V>,queue,cursor),Stream.missed(~V,queue,cursor),tick}) : (Stream.Store<V> & Stream.Reading<S,K,V,origin,route>)}

# Guarantees: two increasing publications after a cursor are both returned in
# publication order at any genuine read tick, including tick zero or equal ticks.
# Why it matters: acknowledging one message sequence cannot hide another event
# merely because the captured execution tick is the same.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/message_cursor.rs#L54-L63
# Scope: arbitrary events, namespaces, ordered sequences and read ticks; exact
# typed result of the actual stream functions, not an opaque affine payload law.
law two_publications_sequence_exact:
  for S:Data
  for K:Data
  for V:Data
  for origin:Layout.Layout
  for route:Layout.Route
  for +namespace:U32
  for +id:U32
  for +cursor:Nat
  for +firstSequence:Nat
  for +secondSequence:Nat
  for +first:M.Transition<V>
  for +second:M.Transition<V>
  for +tick:Tick.Tick
  for afterCursor:{Nat.is_lt(cursor,firstSequence) == True{} : Bool}
  for increasing:{Nat.is_lt(firstSequence,secondSequence) == True{} : Bool}
  {Stream.read(~S,~K,~V,~origin,~route,Some{namespace},secondSequence,tick,Stream.Reader{namespace,id,cursor},Stream.publish(~V,Stream.publish(~V,Stream.empty(~V),firstSequence,first),secondSequence,second)) == (Stream.Store{Queue.Queue{[],[Queue.Batch{secondSequence,1n,[second]},Queue.Batch{firstSequence,1n,[first]}],2n,0n,2n},0n,None{}},Stream.Read{Stream.Reader{namespace,id,secondSequence},[first,second],0n,tick}) : (Stream.Store<V> & Stream.Reading<S,K,V,origin,route>)}

# Guarantees: two generation rotations retire both prior publications even when
# both boundaries carry the same genuine tick; sequence remains independent.
# Why it matters: an empty Finished update cannot be deduplicated by World time.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/messages.rs#L188-L201
# Scope: actual Store maintenance only. This does not prove that an affine
# ordinary Application calls maintenance exactly once on Finished/never on Stop.
law same_tick_two_generations_exact:
  for V:Data
  for +firstSequence:Nat
  for +secondSequence:Nat
  for first:M.Transition<V>
  for second:M.Transition<V>
  for +tick:Tick.Tick
  for positive:{Nat.is_lt(0n,firstSequence) == True{} : Bool}
  for increasing:{Nat.is_lt(firstSequence,secondSequence) == True{} : Bool}
  {Stream.maintain(~V,secondSequence,tick,Stream.maintain(~V,secondSequence,tick,Stream.publish(~V,Stream.publish(~V,Stream.empty(~V),firstSequence,first),secondSequence,second))) == Stream.Store{Queue.Queue{[],[],0n,2n,0n},secondSequence,Some{tick}} : Stream.Store<V>}
