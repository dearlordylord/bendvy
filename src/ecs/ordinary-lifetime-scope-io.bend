import Base
import ./ordinary-lifetime-scope.bend as Ord
import ./lifetime-scope.bend as Sc
import ./world-io.bend as IOCreate
import ./ordinary-schema-provision.bend as Provision
import ./world.bend as W
import ./relation-commands.bend as A

# Canonical IO creation remains foreign execution, never a mathematical proof.
def created(~S:Data,~C:Type,~R:Type,~empty:Unit -> C,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~E:Data,value:Provision.Provision<S,A.Store<S,Sc.Store<S,C>>,R,Ord.empty_store(~S,~C,~empty),Ord.count_store(~S,~C,~count)>,result:IOCreate.Creation<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>) -> IO(Provision.Provision<S,A.Store<S,Sc.Store<S,C>>,R,Ord.empty_store(~S,~C,~empty),Ord.count_store(~S,~C,~count)> & IOCreate.Creation<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>):
  IO.pure(Provision.Provision<S,A.Store<S,Sc.Store<S,C>>,R,Ord.empty_store(~S,~C,~empty),Ord.count_store(~S,~C,~count)> & IOCreate.Creation<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,(value,result))
# Create a World with the scope/relation-wrapped provision in host IO.
# Consumes resource R and returns the provision together with world-io.Creation:
# Created carries the new World; Refused returns the incoming resource owner.
# Uses the checked host namespace allocator, not a caller-chosen namespace.
# No entity is spawned, made live or assigned to a scope by World creation.
# Use lifetime-scope-legacy.scope on the returned World to obtain a same-world token;
# scoped spawn and cleanup remain deferred until an explicit command barrier.
# This is an IO setup boundary, not a mathematical proof or an automatic affine
# finalizer. Example: test-fixtures/public-scopes/feature-timing-v1/fixture.bend:
# create; main.bend observes linked, persistent, failed and retried scope work.
def create(~S:Data,~C:Type,~R:Type,~empty:Unit -> C,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~E:Data,value:Provision.Provision<S,A.Store<S,Sc.Store<S,C>>,R,Ord.empty_store(~S,~C,~empty),Ord.count_store(~S,~C,~count)>,resource:R) -> IO(Provision.Provision<S,A.Store<S,Sc.Store<S,C>>,R,Ord.empty_store(~S,~C,~empty),Ord.count_store(~S,~C,~count)> & IOCreate.Creation<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>):
  IO.bind(IOCreate.Creation<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,Provision.Provision<S,A.Store<S,Sc.Store<S,C>>,R,Ord.empty_store(~S,~C,~empty),Ord.count_store(~S,~C,~count)> & IOCreate.Creation<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,IOCreate.create(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,~Ord.empty_store(~S,~C,~empty),resource),result => created(~S,~C,~R,~empty,~count,~E,value,result))
