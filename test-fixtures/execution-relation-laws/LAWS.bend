import Base
import ../../src/ecs/entity-allocator.bend as A
import ../../src/ecs/entity-key.bend as K
import ../../src/ecs/world.bend as W
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/execution-relation-operation.bend as O
import ../../src/ecs/execution-relation-interpreter.bend as I
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-relation-publication.bend as Publication
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-stream-channel.bend as Channel
import ../../src/ecs/execution-relation-failure-message.bend as Failure
import ../../src/ecs/execution-relation-failure-channel.bend as Reader
import ../../src/ecs/execution-relation-failure-local.bend as Local
import ../../src/ecs/execution-system.bend as Sys

# DRAFT. These subjects are unapproved and unproved. The erased allocator
# variables denote actual affine owners, not an inventory model.

# A foreign source must leave both the actual allocator and graph unchanged.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/relationship/mod.rs#L28-L36
# Bevy behavior: relation changes maintain the target collection from the source.
# Namespace refusal is Bend's World contract, not a claimed Bevy namespace model.
# This subject covers the interpreter, not queue admission or World installation.
law foreign_unrelate_exact:
  for -S:Data
  for -descriptor:T.Descriptor<S>
  for -namespace:U32
  for -foreignNamespace:U32
  for -key:K.Key
  for -allocator:A.Allocator
  for -graph:T.Graph<S>
  for different:{U32.is_eq(namespace,foreignNamespace) == False{} : Bool}
  {I.apply(~S,~descriptor,namespace,allocator,graph,O.Unrelate{W.Handle{foreignNamespace,key}}) == (allocator,O.Refused{graph,O.Unrelate{W.Handle{foreignNamespace,key}},O.RelationError{T.MissingEntity{key}}}) : A.Allocator & O.Outcome<S>}

# An ordinary descriptor cannot obtain hierarchy-reorder mutation authority.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/relationship/mod.rs#L28-L41
# Bevy behavior: source and target relationship types form a corresponding pair.
# The nominal hierarchy distinction and refusal name are Bend API decisions.
# This subject does not establish the ordinary public declaration boundary.
law ordinary_reorder_refuses_exact:
  for -S:Data
  for -key:U32
  for -name:String
  for -inverse:String
  for -namespace:U32
  for -allocator:A.Allocator
  for -graph:T.Graph<S>
  for -parent:W.Handle<S>
  for -children:List<&2,W.Handle<S>>
  {I.apply(~S,~(T.Descriptor{key,name,inverse,T.Ordinary{}}),namespace,allocator,graph,O.Reorder{parent,children}) == (allocator,O.Refused{graph,O.Reorder{parent,children},O.HierarchyRequired{}}) : A.Allocator & O.Outcome<S>}

# Protected relation owners cannot use the generic resource-write policy.
# This only specifies the policy helper. It does not prove every provider calls it.
# Bevy source and behavior are the same relationship source-of-truth contract
# cited above; direct inverse mutation cannot be a gameplay operation.
law protected_relation_blocks_generic_write:
  for -S:Data
  for -descriptor:T.Descriptor<S>
  {Policy.generic_write(Policy.ProtectedRelation{S,descriptor}) == False{} : Bool}

# A foreign store refuses before using the actual allocator or graph interpreter.
# Namespace identity is Bend-specific. Bevy's relationship contract cited above
# motivates keeping this graph inside its owning World, not a cross-World grant.
law foreign_store_preserves_actual_owner:
  for -S:Data
  for -descriptor:T.Descriptor<S>
  for -namespace:U32
  for -foreignNamespace:U32
  for -allocator:A.Allocator
  for -graph:T.Graph<S>
  for -failures:Channel.Store<Failure.Message<S,descriptor>>
  for -sequence:Nat
  for -nextReader:U32
  for -operation:O.Operation<S>
  for different:{U32.is_eq(namespace,foreignNamespace) == False{} : Bool}
  {Store.apply(~S,~descriptor,namespace,allocator,Store.Store{foreignNamespace,graph,failures,sequence,nextReader},operation) == (allocator,(Store.Store{foreignNamespace,graph,failures,sequence,nextReader},Store.Refused{operation,Store.NamespaceMismatch{}})) : A.Allocator & (Store.Store<S,descriptor> & Store.Receipt<S>)}

# Refusing a foreign store preserves the actual canonical slot, its prior cache,
# its stamp, the allocator and the original operation. This is not a full-World law.
law foreign_publication_preserves_slot_and_stamp:
  for -S:Data
  for -descriptor:T.Descriptor<S>
  for -key:String
  for -origin:Layout.Layout
  for -namespace:U32
  for -foreignNamespace:U32
  for -allocator:A.Allocator
  for -graph:T.Graph<S>
  for -failures:Channel.Store<Failure.Message<S,descriptor>>
  for -sequence:Nat
  for -nextReader:U32
  for -view:Store.View<S,descriptor>
  for -stamp:Life.Stamp
  for -operation:O.Operation<S>
  for -tick:Tick.Tick
  for different:{U32.is_eq(namespace,foreignNamespace) == False{} : Bool}
  {Publication.apply(~S,~descriptor,~key,~origin,namespace,allocator,Layout.ResourceSlot{Layout.Viewed{Store.Store{foreignNamespace,graph,failures,sequence,nextReader},view},stamp},operation,tick) == (allocator,(Layout.ResourceSlot{Layout.Viewed{Store.Store{foreignNamespace,graph,failures,sequence,nextReader},view},stamp},Store.Refused{operation,Store.NamespaceMismatch{}})) : A.Allocator & (Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,key,origin> & Store.Receipt<S>)}

# Reader identity is independent of system registration. A foreign namespace
# preserves its actual affine reader and the exact shared channel.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/message_cursor.rs
# Bevy behavior: the cursor tracks a reader's consumed message count.
# Bend's namespace refusal and return of the same affine reader are additional
# ownership requirements; this law does not prove ordinary reader registration.
law foreign_failure_reader_exact:
  for -S:Data
  for -descriptor:T.Descriptor<S>
  for -full:Layout.Layout
  for -route:Layout.Route
  for -namespace:U32
  for -foreignNamespace:U32
  for -id:U32
  for -cursor:Nat
  for -sequence:Nat
  for -tick:Tick.Tick
  for -channel:Channel.Store<Failure.Message<S,descriptor>>
  for different:{U32.is_eq(namespace,foreignNamespace) == False{} : Bool}
  {Reader.read(~S,~descriptor,~full,~route,namespace,sequence,tick,Reader.Reader{foreignNamespace,id,cursor},channel) == (channel,Reader.Refused{Reader.Reader{foreignNamespace,id,cursor}}) : Channel.Store<Failure.Message<S,descriptor>> & Reader.Reading<S,descriptor,full,route>}

# Once the body reports an error, Local retains the already advanced actual
# reader alongside the returned actual scope and user owner. This pins the
# completion adapter, not every system body or the ordinary false-condition path.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs
# Bevy behavior: returned system errors reach the configured error handler.
# Exact reader/user/scope reassembly below is Bend-specific, not error rollback.
law body_error_retains_consumed_reader:
  for -S:Data
  for -descriptor:T.Descriptor<S>
  for -full:Layout.Layout
  for -route:Layout.Route
  for -H:Type
  for -User:Type
  for -Error:Data
  for -Out:Data
  for -scope:H
  for -user:User
  for -reader:Reader.Reader<S,descriptor,full,route>
  for -error:Error
  for -out:Out
  {Local.completed(~S,~descriptor,~full,~route,~H,~User,~Error,~Out,reader,(scope,(user,Sys.BodyError{error,out}))) == Local.Invoked{scope,Local.Local{reader,user},Sys.BodyError{error,out}} : Local.Invocation<H,Local.Local<S,descriptor,full,route,User>,Error,Out>}
