import Base
import ./world.bend as W
import ./system.bend as Sys

# Detached facts copied from the single outer registration. The affine
# Registry stays with its provider and is never copied into a Param owner.
type RegistrationFacts is Data:
  RegistrationFacts{namespace:U32,id:U32,name:String,access:List<&2,String>}

def registration_facts(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,registry:Sys.Registry<S,C,R,E,Args,Error,Output,runner>) -> Sys.Registry<S,C,R,E,Args,Error,Output,runner> & RegistrationFacts:
  match registry:
    case Sys.Registry{+namespace,+id,+name,+access,+cursor}:(Sys.Registry{namespace,id,name,access,cursor},RegistrationFacts{namespace,id,name,access})

# A typed read parameter. The functions are template indices so the descriptor
# stores only its declaration metadata while retaining arbitrary affine owners.
type Param<W:Type,Owner:Type,View:Data,Delta:Type,-validateFn:W -> Owner -> W & (Owner & Bool),-prepareFn:W -> @+cursor:U32 -> Owner -> W & (Owner & (View & Delta)),-commitFn:W -> Owner -> Delta -> @+cursor:U32 -> W & Owner,-releaseFn:W -> Owner -> W> is Data:
  Param{access:List<&2,String>}

type ViewPair<L:Data,R:Data> is Data:
  ViewPair{left:L,right:R}

def make(~W:Type,~Owner:Type,~View:Data,~Delta:Type,~validateFn:W -> Owner -> W & (Owner & Bool),~prepareFn:W -> @+cursor:U32 -> Owner -> W & (Owner & (View & Delta)),~commitFn:W -> Owner -> Delta -> @+cursor:U32 -> W & Owner,~releaseFn:W -> Owner -> W,access:List<&2,String>) -> Param<W,Owner,View,Delta,validateFn,prepareFn,commitFn,releaseFn>:
  Param{access}

def access(~W:Type,~Owner:Type,~View:Data,~Delta:Type,~validateFn:W -> Owner -> W & (Owner & Bool),~prepareFn:W -> @+cursor:U32 -> Owner -> W & (Owner & (View & Delta)),~commitFn:W -> Owner -> Delta -> @+cursor:U32 -> W & Owner,~releaseFn:W -> Owner -> W,param:Param<W,Owner,View,Delta,validateFn,prepareFn,commitFn,releaseFn>) -> Param<W,Owner,View,Delta,validateFn,prepareFn,commitFn,releaseFn> & List<&2,String>:
  match param:
    case Param{+access}:(Param{access},access)

def validate(~W:Type,~Owner:Type,~View:Data,~Delta:Type,~validateFn:W -> Owner -> W & (Owner & Bool),~prepareFn:W -> @+cursor:U32 -> Owner -> W & (Owner & (View & Delta)),~commitFn:W -> Owner -> Delta -> @+cursor:U32 -> W & Owner,~releaseFn:W -> Owner -> W,param:Param<W,Owner,View,Delta,validateFn,prepareFn,commitFn,releaseFn>,world:W,owner:Owner) -> W & (Owner & Bool):
  match param:
    case Param{_}:validateFn(world,owner)

def prepare(~W:Type,~Owner:Type,~View:Data,~Delta:Type,~validateFn:W -> Owner -> W & (Owner & Bool),~prepareFn:W -> @+cursor:U32 -> Owner -> W & (Owner & (View & Delta)),~commitFn:W -> Owner -> Delta -> @+cursor:U32 -> W & Owner,~releaseFn:W -> Owner -> W,param:Param<W,Owner,View,Delta,validateFn,prepareFn,commitFn,releaseFn>,world:W,cursor:U32,owner:Owner) -> W & (Owner & (View & Delta)):
  match param:
    case Param{_}:prepareFn(world,cursor,owner)

def commit(~W:Type,~Owner:Type,~View:Data,~Delta:Type,~validateFn:W -> Owner -> W & (Owner & Bool),~prepareFn:W -> @+cursor:U32 -> Owner -> W & (Owner & (View & Delta)),~commitFn:W -> Owner -> Delta -> @+cursor:U32 -> W & Owner,~releaseFn:W -> Owner -> W,param:Param<W,Owner,View,Delta,validateFn,prepareFn,commitFn,releaseFn>,world:W,owner:Owner,delta:Delta,cursor:U32) -> W & Owner:
  match param:
    case Param{_}:commitFn(world,owner,delta,cursor)

def release(~W:Type,~Owner:Type,~View:Data,~Delta:Type,~validateFn:W -> Owner -> W & (Owner & Bool),~prepareFn:W -> @+cursor:U32 -> Owner -> W & (Owner & (View & Delta)),~commitFn:W -> Owner -> Delta -> @+cursor:U32 -> W & Owner,~releaseFn:W -> Owner -> W,param:Param<W,Owner,View,Delta,validateFn,prepareFn,commitFn,releaseFn>,world:W,owner:Owner) -> W:
  match param:
    case Param{_}:releaseFn(world,owner)

def unit_prepare(~W:Type,world:W,+cursor:U32,owner:Unit) -> W & (Unit & (Unit & Unit)):
  (world,(owner,(Unit{},Unit{})))

def unit_commit(~W:Type,world:W,owner:Unit,delta:Unit,+cursor:U32) -> W & Unit:
  (world,owner)

def unit_release(~W:Type,world:W,owner:Unit) -> W:
  match owner:
    case Unit{}:world

def unit_validate(~W:Type,world:W,owner:Unit) -> W & (Unit & Bool):
  (world,(owner,True{}))

def unit(~W:Type) -> Param<W,Unit,Unit,Unit,unit_validate(~W),unit_prepare(~W),unit_commit(~W),unit_release(~W)>:
  Param{[]}

def pair_access_second(~W:Type,~OwnerA:Type,~ViewA:Data,~DeltaA:Type,~validateA:W -> OwnerA -> W & (OwnerA & Bool),~prepareA:W -> @+cursor:U32 -> OwnerA -> W & (OwnerA & (ViewA & DeltaA)),~commitA:W -> OwnerA -> DeltaA -> @+cursor:U32 -> W & OwnerA,~releaseA:W -> OwnerA -> W,~OwnerB:Type,~ViewB:Data,~DeltaB:Type,~validateB:W -> OwnerB -> W & (OwnerB & Bool),~prepareB:W -> @+cursor:U32 -> OwnerB -> W & (OwnerB & (ViewB & DeltaB)),~commitB:W -> OwnerB -> DeltaB -> @+cursor:U32 -> W & OwnerB,~releaseB:W -> OwnerB -> W,first:List<&2,String>,second:Param<W,OwnerB,ViewB,DeltaB,validateB,prepareB,commitB,releaseB>) -> List<&2,String>:
  match second:
    case Param{access}:List.append(&2,String,first,access)

def pair_access(~W:Type,~OwnerA:Type,~ViewA:Data,~DeltaA:Type,~validateA:W -> OwnerA -> W & (OwnerA & Bool),~prepareA:W -> @+cursor:U32 -> OwnerA -> W & (OwnerA & (ViewA & DeltaA)),~commitA:W -> OwnerA -> DeltaA -> @+cursor:U32 -> W & OwnerA,~releaseA:W -> OwnerA -> W,~OwnerB:Type,~ViewB:Data,~DeltaB:Type,~validateB:W -> OwnerB -> W & (OwnerB & Bool),~prepareB:W -> @+cursor:U32 -> OwnerB -> W & (OwnerB & (ViewB & DeltaB)),~commitB:W -> OwnerB -> DeltaB -> @+cursor:U32 -> W & OwnerB,~releaseB:W -> OwnerB -> W,left:Param<W,OwnerA,ViewA,DeltaA,validateA,prepareA,commitA,releaseA>,right:Param<W,OwnerB,ViewB,DeltaB,validateB,prepareB,commitB,releaseB>) -> List<&2,String>:
  match left:
    case Param{access}:pair_access_second(~W,~OwnerA,~ViewA,~DeltaA,~validateA,~prepareA,~commitA,~releaseA,~OwnerB,~ViewB,~DeltaB,~validateB,~prepareB,~commitB,~releaseB,access,right)

def pair_validate_join(~W:Type,~OwnerA:Type,~OwnerB:Type,left_valid:Bool,validatedB:W & (OwnerB & Bool),ownerA:OwnerA) -> W & ((OwnerA & OwnerB) & Bool):
  match validatedB:
    case (world,(ownerB,right_valid)):(world,((ownerA,ownerB),Bool.and(left_valid,right_valid)))

def pair_validate_after_left(~W:Type,~OwnerA:Type,~OwnerB:Type,~validateB:W -> OwnerB -> W & (OwnerB & Bool),ownerB:OwnerB,validatedA:W & (OwnerA & Bool)) -> W & ((OwnerA & OwnerB) & Bool):
  match validatedA:
    case (world,(ownerA,left_valid)):pair_validate_join(~W,~OwnerA,~OwnerB,left_valid,validateB(world,ownerB),ownerA)

def pair_validate_fn(~W:Type,~OwnerA:Type,~OwnerB:Type,~validateA:W -> OwnerA -> W & (OwnerA & Bool),~validateB:W -> OwnerB -> W & (OwnerB & Bool),world:W,owners:OwnerA & OwnerB) -> W & ((OwnerA & OwnerB) & Bool):
  match owners:
    case (ownerA,ownerB):pair_validate_after_left(~W,~OwnerA,~OwnerB,~validateB,ownerB,validateA(world,ownerA))

def pair_prepare_join(~W:Type,~OwnerA:Type,~OwnerB:Type,~ViewA:Data,~ViewB:Data,~DeltaA:Type,~DeltaB:Type,ownerA:OwnerA,viewA:ViewA,deltaA:DeltaA,preparedB:W & (OwnerB & (ViewB & DeltaB))) -> W & ((OwnerA & OwnerB) & (ViewPair<ViewA,ViewB> & (DeltaA & DeltaB))):
  match preparedB:
    case (world,(ownerB,(viewB,deltaB))):(world,((ownerA,ownerB),(ViewPair{viewA,viewB},(deltaA,deltaB))))

def pair_prepare_after_left(~W:Type,~OwnerA:Type,~OwnerB:Type,~ViewA:Data,~ViewB:Data,~DeltaA:Type,~DeltaB:Type,~prepareB:W -> @+cursor:U32 -> OwnerB -> W & (OwnerB & (ViewB & DeltaB)),cursor:U32,ownerB:OwnerB,preparedA:W & (OwnerA & (ViewA & DeltaA))) -> W & ((OwnerA & OwnerB) & (ViewPair<ViewA,ViewB> & (DeltaA & DeltaB))):
  match preparedA:
    case (world,(ownerA,(viewA,deltaA))):pair_prepare_join(~W,~OwnerA,~OwnerB,~ViewA,~ViewB,~DeltaA,~DeltaB,ownerA,viewA,deltaA,prepareB(world,cursor,ownerB))

def pair_prepare_fn(~W:Type,~OwnerA:Type,~OwnerB:Type,~ViewA:Data,~ViewB:Data,~DeltaA:Type,~DeltaB:Type,~prepareA:W -> @+cursor:U32 -> OwnerA -> W & (OwnerA & (ViewA & DeltaA)),~prepareB:W -> @+cursor:U32 -> OwnerB -> W & (OwnerB & (ViewB & DeltaB)),world:W,+cursor:U32,owners:OwnerA & OwnerB) -> W & ((OwnerA & OwnerB) & (ViewPair<ViewA,ViewB> & (DeltaA & DeltaB))):
  match owners:
    case (ownerA,ownerB):pair_prepare_after_left(~W,~OwnerA,~OwnerB,~ViewA,~ViewB,~DeltaA,~DeltaB,~prepareB,cursor,ownerB,prepareA(world,cursor,ownerA))

def pair_commit_join(~W:Type,~OwnerA:Type,~OwnerB:Type,ownerA:OwnerA,committedB:W & OwnerB) -> W & (OwnerA & OwnerB):
  match committedB:
    case (world,ownerB):(world,(ownerA,ownerB))

def pair_commit_after_left(~W:Type,~OwnerA:Type,~OwnerB:Type,~DeltaB:Type,~commitB:W -> OwnerB -> DeltaB -> @+cursor:U32 -> W & OwnerB,cursor:U32,ownerB:OwnerB,deltaB:DeltaB,committedA:W & OwnerA) -> W & (OwnerA & OwnerB):
  match committedA:
    case (world,ownerA):pair_commit_join(~W,~OwnerA,~OwnerB,ownerA,commitB(world,ownerB,deltaB,cursor))

def pair_commit_fn(~W:Type,~OwnerA:Type,~OwnerB:Type,~DeltaA:Type,~DeltaB:Type,~commitA:W -> OwnerA -> DeltaA -> @+cursor:U32 -> W & OwnerA,~commitB:W -> OwnerB -> DeltaB -> @+cursor:U32 -> W & OwnerB,world:W,owners:OwnerA & OwnerB,deltas:DeltaA & DeltaB,+cursor:U32) -> W & (OwnerA & OwnerB):
  match owners:
    case (ownerA,ownerB):
      match deltas:
        case (deltaA,deltaB):pair_commit_after_left(~W,~OwnerA,~OwnerB,~DeltaB,~commitB,cursor,ownerB,deltaB,commitA(world,ownerA,deltaA,cursor))

def pair_release_after_left(~W:Type,~OwnerB:Type,~releaseB:W -> OwnerB -> W,ownerB:OwnerB,context:W) -> W:
  releaseB(context,ownerB)

def pair_release_fn(~W:Type,~OwnerA:Type,~OwnerB:Type,~releaseA:W -> OwnerA -> W,~releaseB:W -> OwnerB -> W,context:W,owners:OwnerA & OwnerB) -> W:
  match owners:
    case (ownerA,ownerB):pair_release_after_left(~W,~OwnerB,~releaseB,ownerB,releaseA(context,ownerA))

def pair(~W:Type,~OwnerA:Type,~ViewA:Data,~DeltaA:Type,~validateA:W -> OwnerA -> W & (OwnerA & Bool),~prepareA:W -> @+cursor:U32 -> OwnerA -> W & (OwnerA & (ViewA & DeltaA)),~commitA:W -> OwnerA -> DeltaA -> @+cursor:U32 -> W & OwnerA,~releaseA:W -> OwnerA -> W,~OwnerB:Type,~ViewB:Data,~DeltaB:Type,~validateB:W -> OwnerB -> W & (OwnerB & Bool),~prepareB:W -> @+cursor:U32 -> OwnerB -> W & (OwnerB & (ViewB & DeltaB)),~commitB:W -> OwnerB -> DeltaB -> @+cursor:U32 -> W & OwnerB,~releaseB:W -> OwnerB -> W,left:Param<W,OwnerA,ViewA,DeltaA,validateA,prepareA,commitA,releaseA>,right:Param<W,OwnerB,ViewB,DeltaB,validateB,prepareB,commitB,releaseB>) -> Param<W,OwnerA & OwnerB,ViewPair<ViewA,ViewB>,DeltaA & DeltaB,pair_validate_fn(~W,~OwnerA,~OwnerB,~validateA,~validateB),pair_prepare_fn(~W,~OwnerA,~OwnerB,~ViewA,~ViewB,~DeltaA,~DeltaB,~prepareA,~prepareB),pair_commit_fn(~W,~OwnerA,~OwnerB,~DeltaA,~DeltaB,~commitA,~commitB),pair_release_fn(~W,~OwnerA,~OwnerB,~releaseA,~releaseB)>:
  Param{pair_access(~W,~OwnerA,~ViewA,~DeltaA,~validateA,~prepareA,~commitA,~releaseA,~OwnerB,~ViewB,~DeltaB,~validateB,~prepareB,~commitB,~releaseB,left,right)}

# Build two declarations against the same registration while threading one
# affine shared context through both initializers.
def initialize_pair_finish(~Context:Type,~Facts:Data,~OwnerA:Type,~ParameterA:Type,
  ~OwnerB:Type,~ParameterB:Type,~Parameter:Type,
  ~pair:ParameterA -> ParameterB -> Parameter,
  ownerA:OwnerA,paramA:ParameterA,
  initializedB:Context & (OwnerB & ParameterB)) -> Context & ((OwnerA & OwnerB) & Parameter):
  match initializedB:
    case (contextB,(ownerB,paramB)):
      (contextB,((ownerA,ownerB),pair(paramA,paramB)))

def initialize_pair_after_first(~Context:Type,~Facts:Data,~OwnerA:Type,~ParameterA:Type,
  ~OwnerB:Type,~ParameterB:Type,~Parameter:Type,
  ~initB:Context -> Facts -> Context & (OwnerB & ParameterB),
  ~pair:ParameterA -> ParameterB -> Parameter,
  +facts:Facts,
  initializedA:Context & (OwnerA & ParameterA)) -> Context & ((OwnerA & OwnerB) & Parameter):
  match initializedA:
    case (contextAfterA,(ownerA,paramA)):
      initialize_pair_finish(~Context,~Facts,~OwnerA,~ParameterA,~OwnerB,~ParameterB,~Parameter,
        ~pair,ownerA,paramA,initB(contextAfterA,facts))

def initialize_pair(~Context:Type,~Facts:Data,~OwnerA:Type,~ParameterA:Type,
  ~OwnerB:Type,~ParameterB:Type,~Parameter:Type,
  ~initA:Context -> Facts -> Context & (OwnerA & ParameterA),
  ~initB:Context -> Facts -> Context & (OwnerB & ParameterB),
  ~pair:ParameterA -> ParameterB -> Parameter,
  context:Context,+facts:Facts) -> Context & ((OwnerA & OwnerB) & Parameter):
  initialize_pair_after_first(~Context,~Facts,~OwnerA,~ParameterA,~OwnerB,~ParameterB,~Parameter,
    ~initB,~pair,facts,initA(context,facts))
