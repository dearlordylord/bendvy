import Base
import ./schedule.bend as Sch
import ./world.bend as W
import ./system.bend as Sys
# Declaration lowering owns fixed group order; closed callbacks retain failure outcomes.
type Declaration<-S:Data> is Data: Declaration{name:String}
def declare(~S:Data,name:String) -> Declaration<S>:Declaration{name}
def phase_name(id:U32) -> String:
  match id:
    case 1:"apply"
    case 2:"exit"
    case 3:"transition"
    case _:"enter"
def steps() -> List<&2,Sch.Step>:[Sch.Barrier{},Sch.Phase{phase_name(1)},Sch.System{1,0},Sch.Phase{phase_name(2)},Sch.System{2,0},Sch.Phase{phase_name(3)},Sch.System{3,0},Sch.Phase{phase_name(4)},Sch.System{4,0}]
def install(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,declaration:Declaration<S>,namespace:U32,owners:H) -> Sch.Build<S,C,R,E,H>:
  match declaration:
    case Declaration{name}:Sch.build(~S,~C,~R,~E,~H,namespace,name,steps(),[1,2,3,4],owners)
def dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~apply:H -> W.World<S,C,R,E> -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~exit:H -> W.World<S,C,R,E> -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~transition:H -> W.World<S,C,R,E> -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~enter:H -> W.World<S,C,R,E> -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,owners:H,world:W.World<S,C,R,E>,id:U32) -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  match id:
    case 1:apply(owners,world)
    case 2:exit(owners,world)
    case 3:transition(owners,world)
    case _:enter(owners,world)
def condition(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>,_:U32) -> W.World<S,C,R,E> & Bool:(world,True{})
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~apply:H -> W.World<S,C,R,E> -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~exit:H -> W.World<S,C,R,E> -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~transition:H -> W.World<S,C,R,E> -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~enter:H -> W.World<S,C,R,E> -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,schedule:Sch.Schedule<S,C,R,E,H>,world:W.World<S,C,R,E>) -> Sch.RunResult<S,C,R,E,H,Error>:Sch.run(~S,~C,~R,~E,~H,~Error,~dispatch(~S,~C,~R,~E,~H,~Error,~apply,~exit,~transition,~enter),~condition(~S,~C,~R,~E),schedule,world)
