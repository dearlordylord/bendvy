import Base
import ./world.bend as W
import ./system.bend as Sys
import ./schedule.bend as Sch

# Existing schedule semantics, with a command-aware barrier over the same owners.
def execute(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~barrier: H -> W.World<S,C,R,E> -> H & W.World<S,C,R,E>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,steps: List<&2,Sch.Step>,owners: H,world: W.World<S,C,R,E>,+namespace: U32,+name: String,+all: List<&2,Sch.Step>,+observations: List<&2,Sch.Observation>) -> Sch.RunResult<S,C,R,E,H,Error>:
  match steps:
    case []: Sch.Finished{Sch.Schedule{namespace,name,all,owners},world,observations}
    case Sch.Phase{phase} <> rest: execute(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~barrier,~condition,rest,owners,world,namespace,name,all,List.append(&2,Sch.Observation,observations,[Sch.Entered{phase}]))
    case Sch.Barrier{} <> rest: Sch.after_skip(~S,~C,~R,~E,~H,~Error,h => w => obs => execute(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~barrier,~condition,rest,h,w,namespace,name,all,obs),barrier(owners,world),List.append(&2,Sch.Observation,observations,[Sch.Applied{}]))
    case Sch.System{+id,slot} <> rest: Sch.after_condition_skip(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,h => w => obs => execute(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~barrier,~condition,rest,h,w,namespace,name,all,obs),condition(world,slot),owners,namespace,name,all,observations,id)

def run_checked(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~barrier: H -> W.World<S,C,R,E> -> H & W.World<S,C,R,E>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,allowed: Bool,schedule: Sch.Schedule<S,C,R,E,H>,world: W.World<S,C,R,E>) -> Sch.RunResult<S,C,R,E,H,Error>:
  match allowed schedule:
    case False{} schedule: Sch.Rejected{schedule,world}
    case True{} Sch.Schedule{+namespace,+name,+steps,owners}: execute(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~barrier,~condition,steps,owners,world,namespace,name,steps,[])


def run_actual(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~barrier: H -> W.World<S,C,R,E> -> H & W.World<S,C,R,E>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,schedule: Sch.Schedule<S,C,R,E,H>,world: W.World<S,C,R,E>,+actual: U32) -> Sch.RunResult<S,C,R,E,H,Error>:
  match schedule:
    case Sch.Schedule{+namespace,+name,+steps,owners}: run_checked(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~barrier,~condition,U32.is_eq(namespace,actual),Sch.Schedule{namespace,name,steps,owners},world)

def run_namespace(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~barrier: H -> W.World<S,C,R,E> -> H & W.World<S,C,R,E>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,schedule: Sch.Schedule<S,C,R,E,H>,named: W.World<S,C,R,E> & U32) -> Sch.RunResult<S,C,R,E,H,Error>:
  (world,+actual) = named
  run_actual(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~barrier,~condition,schedule,world,actual)

def run(~S: Data,~C: Type,~R: Type,~E: Data,~H: Type,~Error: Data,~skip: H -> W.World<S,C,R,E> -> U32 -> H & W.World<S,C,R,E>,~dispatch: H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~barrier: H -> W.World<S,C,R,E> -> H & W.World<S,C,R,E>,~condition: W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,schedule: Sch.Schedule<S,C,R,E,H>,world: W.World<S,C,R,E>) -> Sch.RunResult<S,C,R,E,H,Error>:
  run_namespace(~S,~C,~R,~E,~H,~Error,~skip,~dispatch,~barrier,~condition,schedule,W.namespace(~S,~C,~R,~E,world))
