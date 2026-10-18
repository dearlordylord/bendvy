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
def create(~S:Data,~C:Type,~R:Type,~empty:Unit -> C,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~E:Data,value:Provision.Provision<S,A.Store<S,Sc.Store<S,C>>,R,Ord.empty_store(~S,~C,~empty),Ord.count_store(~S,~C,~count)>,resource:R) -> IO(Provision.Provision<S,A.Store<S,Sc.Store<S,C>>,R,Ord.empty_store(~S,~C,~empty),Ord.count_store(~S,~C,~count)> & IOCreate.Creation<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>):
  IO.bind(IOCreate.Creation<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,Provision.Provision<S,A.Store<S,Sc.Store<S,C>>,R,Ord.empty_store(~S,~C,~empty),Ord.count_store(~S,~C,~count)> & IOCreate.Creation<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,IOCreate.create(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,~Ord.empty_store(~S,~C,~empty),resource),result => created(~S,~C,~R,~empty,~count,~E,value,result))
