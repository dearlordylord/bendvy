import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as ER
import ./readers.bend as R

type Status<E: Data> is Data:
  Succeeded{journal: List<&2,ER.Reading<E>>}
  Failed{error: R.Error<E>}
  Rejected{args: R.Args<E>}
  Skipped{}
type ReaderPair<S: Data,C: Type,R: Type,E: Data> is Type:
  ReaderPair{runtime: ER.Runtime<S,C,R,E>,a: R.Owner<S,C,R,E>,b: R.Owner<S,C,R,E>,journalA: List<&2,ER.Reading<E>>,journalB: List<&2,ER.Reading<E>>}
type Returned<S: Data,C: Type,R: Type,E: Data> is Type:
  Returned{pair: ReaderPair<S,C,R,E>,a: Status<E>,b: Status<E>}
type Registration<S: Data,C: Type,R: Type,E: Data> is Type:
  Ready{result: Returned<S,C,R,E>}
  ARegistrationFailed{runtime: ER.Runtime<S,C,R,E>}
  BRegistrationFailed{runtime: ER.Runtime<S,C,R,E>,a: R.Owner<S,C,R,E>}

def failed_journal(~E: Data,error: R.Error<E>) -> List<&2,ER.Reading<E>> & Status<E>:
  match error:
    case R.ReaderFailed{+journal}: (journal,Failed{R.ReaderFailed{journal}})

def completion(~E: Data,result: ER.Completion<R.Error<E>,List<&2,ER.Reading<E>>,R.Args<E>>) -> List<&2,ER.Reading<E>> & Status<E>:
  match result:
    case ER.Succeeded{+journal}: (journal,Succeeded{journal})
    case ER.Failed{error}: failed_journal(~E,error)
    case ER.Rejected{R.Args{+journal,+fail}}: (journal,Rejected{R.Args{journal,fail}})

def join_b(~S: Data,~C: Type,~R: Type,~E: Data,runtime: ER.Runtime<S,C,R,E>,a: R.Owner<S,C,R,E>,b: R.Owner<S,C,R,E>,+journalA: List<&2,ER.Reading<E>>,+statusA: Status<E>,completed: List<&2,ER.Reading<E>> & Status<E>) -> Returned<S,C,R,E>:
  (journalB,statusB) = completed
  Returned{ReaderPair{runtime,a,b,journalA,journalB},statusA,statusB}

def finish_b(~S: Data,~C: Type,~R: Type,~E: Data,result: R.Returned<S,C,R,E>,a: R.Owner<S,C,R,E>,+journalA: List<&2,ER.Reading<E>>,+statusA: Status<E>) -> Returned<S,C,R,E>:
  match result:
    case R.Returned{runtime,b,outcome}: join_b(~S,~C,~R,~E,runtime,a,b,journalA,statusA,completion(~E,outcome))

def join_a(~S: Data,~C: Type,~R: Type,~E: Data,runtime: ER.Runtime<S,C,R,E>,a: R.Owner<S,C,R,E>,b: R.Owner<S,C,R,E>,+journalB: List<&2,ER.Reading<E>>,+failB: Bool,completed: List<&2,ER.Reading<E>> & Status<E>) -> Returned<S,C,R,E>:
  (journalA,statusA) = completed
  finish_b(~S,~C,~R,~E,R.run(~S,~C,~R,~E,runtime,b,R.Args{journalB,failB}),a,journalA,statusA)

def finish_a(~S: Data,~C: Type,~R: Type,~E: Data,result: R.Returned<S,C,R,E>,b: R.Owner<S,C,R,E>,+journalB: List<&2,ER.Reading<E>>,+failB: Bool) -> Returned<S,C,R,E>:
  match result:
    case R.Returned{runtime,a,outcome}: join_a(~S,~C,~R,~E,runtime,a,b,journalB,failB,completion(~E,outcome))

def run(~S: Data,~C: Type,~R: Type,~E: Data,pair: ReaderPair<S,C,R,E>,+failB: Bool) -> Returned<S,C,R,E>:
  match pair:
    case ReaderPair{runtime,a,b,journalA,journalB}: finish_a(~S,~C,~R,~E,R.run(~S,~C,~R,~E,runtime,a,R.Args{journalA,False{}}),b,journalB,failB)

def retry_b(~S: Data,~C: Type,~R: Type,~E: Data,pair: ReaderPair<S,C,R,E>) -> Returned<S,C,R,E>:
  match pair:
    case ReaderPair{runtime,a,b,journalA,journalB}: finish_b(~S,~C,~R,~E,R.run(~S,~C,~R,~E,runtime,b,R.Args{journalB,False{}}),a,journalA,Skipped{})

def registered_b(~S: Data,~C: Type,~R: Type,~E: Data,result: R.Registration<S,C,R,E>,a: R.Owner<S,C,R,E>) -> Registration<S,C,R,E>:
  match result:
    case R.RegisterFailed{runtime}: BRegistrationFailed{runtime,a}
    case R.Registered{runtime,b}: Ready{run(~S,~C,~R,~E,ReaderPair{runtime,a,b,[],[]},False{})}

def registered_a(~S: Data,~C: Type,~R: Type,~E: Data,result: R.Registration<S,C,R,E>) -> Registration<S,C,R,E>:
  match result:
    case R.RegisterFailed{runtime}: ARegistrationFailed{runtime}
    case R.Registered{runtime,a}: registered_b(~S,~C,~R,~E,R.register(~S,~C,~R,~E,runtime,"Simulation/ReaderB"),a)

def register(~S: Data,~C: Type,~R: Type,~E: Data,runtime: ER.Runtime<S,C,R,E>) -> Registration<S,C,R,E>:
  registered_a(~S,~C,~R,~E,R.register(~S,~C,~R,~E,runtime,"Simulation/ReaderA"))
