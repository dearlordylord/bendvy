import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sy
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as ER

# Host/local journal is explicit input and output; failure returns its observation.
type Args<E: Data> is Data:
  Args{journal: List<&2,ER.Reading<E>>,fail: Bool}
type Error<E: Data> is Data:
  ReaderFailed{journal: List<&2,ER.Reading<E>>}

def decide(~S: Data,~C: Type,~R: Type,~E: Data,fail: Bool,world: W.World<S,C,R,E>,+journal: List<&2,ER.Reading<E>>) -> Sy.Outcome<W.World<S,C,R,E>,Error<E>,List<&2,ER.Reading<E>>>:
  match fail:
    case False{}: Sy.Succeeded{world,journal}
    case True{}: Sy.Failed{world,ReaderFailed{journal}}

def runner(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>,input: ER.Input<E,Args<E>>) -> Sy.Outcome<W.World<S,C,R,E>,Error<E>,List<&2,ER.Reading<E>>>:
  match input:
    case ER.Input{items,lagged,Args{journal,fail}}: decide(~S,~C,~R,~E,fail,world,ER.append(~ER.Reading<E>,journal,[ER.Reading{items,lagged}]))

def Registry(~S: Data,~C: Type,~R: Type,~E: Data) -> Type:
  Sy.Registry<S,C,R,E,ER.Input<E,Args<E>>,Error<E>,List<&2,ER.Reading<E>>,runner(~S,~C,~R,~E)>
type Owner<S: Data,C: Type,R: Type,E: Data> is Type:
  Owner{reader: ER.Reader<S>,registry: Registry(~S,~C,~R,~E)}
type Registration<S: Data,C: Type,R: Type,E: Data> is Type:
  Registered{runtime: ER.Runtime<S,C,R,E>,owner: Owner<S,C,R,E>}
  RegisterFailed{runtime: ER.Runtime<S,C,R,E>}

def registered(~S: Data,~C: Type,~R: Type,~E: Data,result: ER.Registered<S,C,R,E,Args<E>,Error<E>,List<&2,ER.Reading<E>>,runner(~S,~C,~R,~E)>) -> Registration<S,C,R,E>:
  match result:
    case ER.Registered{runtime,reader,registry}: Registered{runtime,Owner{reader,registry}}
    case ER.RegisterFailed{runtime}: RegisterFailed{runtime}

def register(~S: Data,~C: Type,~R: Type,~E: Data,runtime: ER.Runtime<S,C,R,E>,+name: String) -> Registration<S,C,R,E>:
  registered(~S,~C,~R,~E,ER.register(~S,~C,~R,~E,~Args<E>,~Error<E>,~List<&2,ER.Reading<E>>,~runner(~S,~C,~R,~E),runtime,name,["event:read"]))

type Returned<S: Data,C: Type,R: Type,E: Data> is Type:
  Returned{runtime: ER.Runtime<S,C,R,E>,owner: Owner<S,C,R,E>,completion: ER.Completion<Error<E>,List<&2,ER.Reading<E>>,Args<E>>}

def returned(~S: Data,~C: Type,~R: Type,~E: Data,result: ER.RunResult<S,C,R,E,Args<E>,Error<E>,List<&2,ER.Reading<E>>,runner(~S,~C,~R,~E)>) -> Returned<S,C,R,E>:
  match result:
    case ER.Ran{runtime,reader,registry,completion}: Returned{runtime,Owner{reader,registry},completion}

def run(~S: Data,~C: Type,~R: Type,~E: Data,runtime: ER.Runtime<S,C,R,E>,owner: Owner<S,C,R,E>,args: Args<E>) -> Returned<S,C,R,E>:
  match owner:
    case Owner{reader,registry}: returned(~S,~C,~R,~E,ER.run(~S,~C,~R,~E,~Args<E>,~Error<E>,~List<&2,ER.Reading<E>>,~runner(~S,~C,~R,~E),runtime,reader,registry,args))

type Disposal<S: Data,C: Type,R: Type,E: Data> is Type:
  Disposed{runtime: ER.Runtime<S,C,R,E>}
  DisposalRejected{runtime: ER.Runtime<S,C,R,E>,owner: Owner<S,C,R,E>}

def disposed(~S: Data,~C: Type,~R: Type,~E: Data,result: ER.Disposal<S,C,R,E,Args<E>,Error<E>,List<&2,ER.Reading<E>>,runner(~S,~C,~R,~E)>) -> Disposal<S,C,R,E>:
  match result:
    case ER.Disposed{runtime}: Disposed{runtime}
    case ER.DisposalRejected{runtime,reader,registry}: DisposalRejected{runtime,Owner{reader,registry}}

def dispose(~S: Data,~C: Type,~R: Type,~E: Data,runtime: ER.Runtime<S,C,R,E>,owner: Owner<S,C,R,E>) -> Disposal<S,C,R,E>:
  match owner:
    case Owner{reader,registry}: disposed(~S,~C,~R,~E,ER.dispose(~S,~C,~R,~E,~Args<E>,~Error<E>,~List<&2,ER.Reading<E>>,~runner(~S,~C,~R,~E),runtime,reader,registry))
