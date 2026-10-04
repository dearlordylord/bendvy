import Base
import ./types.bend as T

# Pure draft observation validator. Inputs are not runtime observations yet.
type Publication is Data:
  Publication{priorPing: U32, failedPingCount: U32, priorPending: U32, failedPending: U32, failedMarks: U32}
type Checkpoint is Data:
  Checkpoint{a: T.Four, b: T.Four, ledger: T.Four, mainMeta1: U32, mainMeta2: U32, epoch: U32, aux: T.Four, auxMeta: U32, publication: Publication, failedId: U32, nextId: U32}
def meta1(+health: Bool) -> U32:
  match health:
    case False{}: 7
    case True{}: 9
def meta2(+health: Bool) -> U32:
  match health:
    case False{}: 0
    case True{}: 2
def aux_meta(+health: Bool) -> U32:
  match health:
    case False{}: 1
    case True{}: 3
def both(+a: Bool,+b: Bool) -> Bool:
  Bool.and(a,b)
def four(+x: T.Four,+a: U32,+b: U32,+c: U32,+d: U32) -> Bool:
  match x:
    case T.Four{w,x,y,z}: both(U32.is_eq(w,a),both(U32.is_eq(x,b),both(U32.is_eq(y,c),U32.is_eq(z,d))))
def publication(+p: Publication) -> Bool:
  match p:
    case Publication{priorPing,failedPingCount,priorPending,failedPending,failedMarks}: both(U32.is_eq(priorPing,1),both(U32.is_eq(failedPingCount,0),both(U32.is_eq(priorPending,2),both(U32.is_eq(failedPending,0),U32.is_eq(failedMarks,0)))))
def failed_observation(+health: Bool,+o: Checkpoint) -> Bool:
  match o:
    case Checkpoint{a,b,ledger,m1,m2,epoch,aux,auxMeta,p,failedId,nextId}: both(four(a,11,11,12,13),both(four(b,20,21,22,23),both(four(ledger,101,101,102,103),both(U32.is_eq(m1,meta1(health)),both(U32.is_eq(m2,meta2(health)),both(U32.is_eq(epoch,4),both(four(aux,1,2,3,4),both(U32.is_eq(auxMeta,aux_meta(health)),both(publication(p),U32.is_lt(failedId,nextId))))))))))
def fixture(+health: Bool,+b0: U32,+tail: U32,+ledger0: U32,+failedPending: U32,+nextId: U32) -> Checkpoint:
  Checkpoint{T.Four{11,11,12,13},T.Four{b0,21,22,tail},T.Four{ledger0,101,102,103},meta1(health),meta2(health),4,T.Four{1,2,3,4},aux_meta(health),Publication{1,0,2,failedPending,0},5,nextId}
def erase_earlier_a(+o: Checkpoint) -> Checkpoint:
  match o:
    case Checkpoint{_,b,ledger,m1,m2,epoch,aux,auxMeta,p,failedId,nextId}: Checkpoint{T.Four{10,11,12,13},b,ledger,m1,m2,epoch,aux,auxMeta,p,failedId,nextId}
def controls(+health: Bool) -> Bool:
  both(failed_observation(health,fixture(health,20,23,101,0,6)),both(Bool.not(failed_observation(health,fixture(health,30,23,101,0,6))),both(Bool.not(failed_observation(health,fixture(health,20,99,101,0,6))),both(Bool.not(failed_observation(health,fixture(health,20,23,201,0,6))),both(Bool.not(failed_observation(health,fixture(health,20,23,101,1,6))),Bool.not(failed_observation(health,fixture(health,20,23,101,0,5))))))))
def main() -> Bool:
  both(both(controls(False{}),controls(True{})),both(Bool.not(failed_observation(False{},erase_earlier_a(fixture(False{},20,23,101,0,6)))),Bool.not(failed_observation(True{},erase_earlier_a(fixture(True{},20,23,101,0,6))))))
