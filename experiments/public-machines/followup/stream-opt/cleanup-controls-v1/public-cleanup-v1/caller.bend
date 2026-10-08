import Base
import adapter.bend as G
import ports.bend as Ports
import current-core/ecs/world.bend as W
import current-core/ecs/system.bend as Sys
import current-core/ecs/machine-stream.bend as St

type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
type AlphaKey is Data:
  AlphaKey{}
type BetaKey is Data:
  BetaKey{}
type GammaKey is Data:
  GammaKey{}
type Alpha is Data:
  A0{}
  A1{}
type Beta is Data:
  B0{}
  B1{}
type Gamma is Data:
  C0{}
  C1{}
type Store<S: Data> is Type:
  Store{cells: Array<U32>}
type Resources<S: Data> is Type:
  Resources{payload: Array<U32>,alpha: St.Stream<Alpha>,beta: St.Stream<Beta>,gamma: St.Stream<Gamma>}

def empty_store(~S: Data,_: Unit) -> Store<S>:
  Store{Array.new(U32,1n,41)}
def resources(~S: Data) -> Resources<S>:
  Resources{Array.new(U32,1n,73),St.empty(~Alpha),St.empty(~Beta),St.empty(~Gamma)}
def runner(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>,args: Array<U32>) -> Sys.Outcome<W.World<S,Store<S>,Resources<S>,Unit>,String,Array<U32>>:
  Sys.Succeeded{world,args}

def remove_alpha_id(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>,id: U32) -> W.World<S,Store<S>,Resources<S>,Unit>:
  match world:
    case W.World{namespace,next,high,live,capacity,depth,store,Resources{payload,alpha,beta,gamma},events,commands,regs,nextSystem,clock}:
      W.World{namespace,next,high,live,capacity,depth,store,Resources{payload,St.dispose(~Alpha,alpha,id),beta,gamma},events,commands,regs,nextSystem,clock}
def remove_alpha(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>,reader: St.Reader<S,AlphaKey>) -> W.World<S,Store<S>,Resources<S>,Unit>:
  match reader:
    case St.Reader{_,id}: remove_alpha_id(~S,world,id)

def remove_beta_id(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>,id: U32) -> W.World<S,Store<S>,Resources<S>,Unit>:
  match world:
    case W.World{namespace,next,high,live,capacity,depth,store,Resources{payload,alpha,beta,gamma},events,commands,regs,nextSystem,clock}:
      W.World{namespace,next,high,live,capacity,depth,store,Resources{payload,alpha,St.dispose(~Beta,beta,id),gamma},events,commands,regs,nextSystem,clock}
def remove_beta(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>,reader: St.Reader<S,BetaKey>) -> W.World<S,Store<S>,Resources<S>,Unit>:
  match reader:
    case St.Reader{_,id}: remove_beta_id(~S,world,id)

def remove_gamma_id(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>,id: U32) -> W.World<S,Store<S>,Resources<S>,Unit>:
  match world:
    case W.World{namespace,next,high,live,capacity,depth,store,Resources{payload,alpha,beta,gamma},events,commands,regs,nextSystem,clock}:
      W.World{namespace,next,high,live,capacity,depth,store,Resources{payload,alpha,beta,St.dispose(~Gamma,gamma,id)},events,commands,regs,nextSystem,clock}
def remove_gamma(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>,reader: St.Reader<S,GammaKey>) -> W.World<S,Store<S>,Resources<S>,Unit>:
  match reader:
    case St.Reader{_,id}: remove_gamma_id(~S,world,id)

def remove_two(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>,ports: Ports.Two<S,AlphaKey,BetaKey>) -> W.World<S,Store<S>,Resources<S>,Unit>:
  Ports.remove_two(~W.World<S,Store<S>,Resources<S>,Unit>,~S,~AlphaKey,~BetaKey,~(world => reader => remove_alpha(~S,world,reader)),~(world => reader => remove_beta(~S,world,reader)),world,ports)
def finish_two(~S: Data,result: G.Cleanup<S,Store<S>,Resources<S>,Unit,Array<U32>,String,Array<U32>,(world => args => runner(~S,world,args)),Ports.Two<S,AlphaKey,BetaKey>>) -> Unit:
  match result:
    case G.Cleaned{_}: Unit{}
    case G.CleanupRejected{_,_}: Unit{}
def dispose_two_identified(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>,+namespace: U32,identified: Sys.Registry<S,Store<S>,Resources<S>,Unit,Array<U32>,String,Array<U32>,(world => args => runner(~S,world,args))> & U32) -> Unit:
  match identified:
    case (registry,+id): finish_two(~S,G.cleanup(~S,~Store<S>,~Resources<S>,~Unit,~Array<U32>,~String,~Array<U32>,~(world => args => runner(~S,world,args)),~Ports.Two<S,AlphaKey,BetaKey>,~(ports => ns => id => Ports.validate_two(~S,~AlphaKey,~BetaKey,ports,ns,id)),~(world => ports => remove_two(~S,world,ports)),G.Instance{registry,Ports.Two{St.Reader{namespace,id},St.Reader{namespace,id}}},world))
def dispose_two_namespaced(~S: Data,registry: Sys.Registry<S,Store<S>,Resources<S>,Unit,Array<U32>,String,Array<U32>,(world => args => runner(~S,world,args))>,observed: W.World<S,Store<S>,Resources<S>,Unit> & U32) -> Unit:
  match observed:
    case (world,namespace): dispose_two_identified(~S,world,namespace,Sys.identity(~S,~Store<S>,~Resources<S>,~Unit,~Array<U32>,~String,~Array<U32>,~(world => args => runner(~S,world,args)),registry))
def registered_two(~S: Data,result: Sys.RegistrationResult<S,Store<S>,Resources<S>,Unit,Array<U32>,String,Array<U32>,(world => args => runner(~S,world,args))>) -> Unit:
  match result:
    case Sys.Registered{world,registry}: dispose_two_namespaced(~S,registry,W.namespace(~S,~Store<S>,~Resources<S>,~Unit,world))
    case Sys.RegistrationFailed{_}: Unit{}
def created_two(~S: Data,result: W.Creation<S,Store<S>,Resources<S>,Unit>) -> Unit:
  match result:
    case W.Created{_,world}: registered_two(~S,Sys.register(~S,~Store<S>,~Resources<S>,~Unit,~Array<U32>,~String,~Array<U32>,~(world => args => runner(~S,world,args)),world,"cleanup-two",["transition.alpha.read","transition.beta.read"]))
    case W.CreateRejected{_,_}: Unit{}
def case_two(~S: Data) -> Unit:
  created_two(~S,W.create(~S,~Store<S>,~Resources<S>,~Unit,~(_ => empty_store(~S,Unit{})),W.factory(),resources(~S)))

def remove_three(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>,ports: Ports.Three<S,AlphaKey,BetaKey,GammaKey>) -> W.World<S,Store<S>,Resources<S>,Unit>:
  Ports.remove_three(~W.World<S,Store<S>,Resources<S>,Unit>,~S,~AlphaKey,~BetaKey,~GammaKey,~(world => reader => remove_alpha(~S,world,reader)),~(world => reader => remove_beta(~S,world,reader)),~(world => reader => remove_gamma(~S,world,reader)),world,ports)
def finish_three(~S: Data,result: G.Cleanup<S,Store<S>,Resources<S>,Unit,Array<U32>,String,Array<U32>,(world => args => runner(~S,world,args)),Ports.Three<S,AlphaKey,BetaKey,GammaKey>>) -> Unit:
  match result:
    case G.Cleaned{_}: Unit{}
    case G.CleanupRejected{_,_}: Unit{}
def dispose_three_identified(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>,+namespace: U32,identified: Sys.Registry<S,Store<S>,Resources<S>,Unit,Array<U32>,String,Array<U32>,(world => args => runner(~S,world,args))> & U32) -> Unit:
  match identified:
    case (registry,+id): finish_three(~S,G.cleanup(~S,~Store<S>,~Resources<S>,~Unit,~Array<U32>,~String,~Array<U32>,~(world => args => runner(~S,world,args)),~Ports.Three<S,AlphaKey,BetaKey,GammaKey>,~(ports => ns => id => Ports.validate_three(~S,~AlphaKey,~BetaKey,~GammaKey,ports,ns,id)),~(world => ports => remove_three(~S,world,ports)),G.Instance{registry,Ports.Three{St.Reader{namespace,id},St.Reader{namespace,id},St.Reader{namespace,id}}},world))
def dispose_three_namespaced(~S: Data,registry: Sys.Registry<S,Store<S>,Resources<S>,Unit,Array<U32>,String,Array<U32>,(world => args => runner(~S,world,args))>,observed: W.World<S,Store<S>,Resources<S>,Unit> & U32) -> Unit:
  match observed:
    case (world,namespace): dispose_three_identified(~S,world,namespace,Sys.identity(~S,~Store<S>,~Resources<S>,~Unit,~Array<U32>,~String,~Array<U32>,~(world => args => runner(~S,world,args)),registry))
def registered_three(~S: Data,result: Sys.RegistrationResult<S,Store<S>,Resources<S>,Unit,Array<U32>,String,Array<U32>,(world => args => runner(~S,world,args))>) -> Unit:
  match result:
    case Sys.Registered{world,registry}: dispose_three_namespaced(~S,registry,W.namespace(~S,~Store<S>,~Resources<S>,~Unit,world))
    case Sys.RegistrationFailed{_}: Unit{}
def created_three(~S: Data,result: W.Creation<S,Store<S>,Resources<S>,Unit>) -> Unit:
  match result:
    case W.Created{_,world}: registered_three(~S,Sys.register(~S,~Store<S>,~Resources<S>,~Unit,~Array<U32>,~String,~Array<U32>,~(world => args => runner(~S,world,args)),world,"cleanup-three",["transition.alpha.read","transition.beta.read","transition.gamma.read"]))
    case W.CreateRejected{_,_}: Unit{}
def case_three(~S: Data) -> Unit:
  created_three(~S,W.create(~S,~Store<S>,~Resources<S>,~Unit,~(_ => empty_store(~S,Unit{})),W.factory(),resources(~S)))

def joined(a: Unit,b: Unit,c: Unit,d: Unit) -> Unit:
  Unit{}
def main() -> Unit:
  joined(case_two(~SchemaA),case_two(~SchemaB),case_three(~SchemaA),case_three(~SchemaB))
