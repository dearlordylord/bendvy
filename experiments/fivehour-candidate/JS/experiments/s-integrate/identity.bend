import Base
import ./types.bend as T
import ./storage.bend as S

# Trusted bootstrap lineage. Independent public roots can collide; no global
# unforgeable-root theorem or constructor secrecy is claimed.
def factory() -> S.Factory:
  S.Factory{1}
def create_checked(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,
  ~initial_ledger: Unit -> L,available: Bool,+namespace: U32,mode: Mode) -> T.Creation<S.Factory,S.World<Schema,M,A,F,L,Mode>>:
  match available:
    case False{}: T.CreateRejected{S.Factory{namespace}}
    case True{}: T.Created{S.Factory{(namespace + 1 : U32)},S.World{namespace,1,S.rows_empty(M,A,F),[],Some{initial_ledger(Unit{})},mode}}
def create(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,
  ~initial_ledger: Unit -> L,factory: S.Factory,mode: Mode) -> T.Creation<S.Factory,S.World<Schema,M,A,F,L,Mode>>:
  match factory:
    case S.Factory{+namespace}: create_checked(~Schema,~M,~A,~F,~L,~Mode,~initial_ledger,U32.is_lt(namespace,4294967295),namespace,mode)

def reserve_checked(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  available: Bool,+namespace: U32,+next: U32,rows: S.Rows<M,A,F>,pending: List<S.Command<M,A,F>>,ledger: Maybe<L>,mode: Mode) -> S.World<Schema,M,A,F,L,Mode> & Maybe<&2,S.Handle<Schema>>:
  match available:
    case False{}: (S.World{namespace,next,rows,pending,ledger,mode},None{})
    case True{}: (S.World{namespace,(next + 1 : U32),rows,pending,ledger,mode},Some{S.Handle{namespace,next}})
# Reservation is deliberately independent of publication, enabling failed Tx
# publication to disappear without rewinding or reissuing its escaped handle.
def reserve_id(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  world: S.World<Schema,M,A,F,L,Mode>) -> S.World<Schema,M,A,F,L,Mode> & Maybe<&2,S.Handle<Schema>>:
  match world:
    case S.World{+namespace,+next,rows,pending,ledger,mode}:
      reserve_checked(Schema,M,A,F,L,Mode,U32.is_lt(next,4294967295),namespace,next,rows,pending,ledger,mode)
