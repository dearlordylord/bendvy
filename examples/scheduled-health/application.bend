import Base
import ./schema.bend as D
import ./root.bend as Root
import ./observe.bend as Observe
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/dependency-application.bend as App

def final(result:Root.Application() & (I.Instance<D.Schema> & Result<&2,&2,Unit,Observe.Snapshot>)) -> IO(Unit):
  match result:
    case (_,(_,Done{Observe.Snapshot{_,untouched}})):IO.print("untouched=" ++ untouched)
    case _:IO.die(Unit,1,"final observation refused")
def printed(next:Root.Application() -> I.Instance<D.Schema> -> IO(Unit),label:String,result:Root.Application() & (I.Instance<D.Schema> & Result<&2,&2,Unit,Observe.Snapshot>)) -> IO(Unit):
  match result:
    case (app,(instance,Done{Observe.Snapshot{selected,_}})):IO.bind(Unit,Unit,IO.print(label ++ selected),_ => next(app,instance))
    case _:IO.die(Unit,1,"health observation refused")
def executed(next:Root.Application() -> I.Instance<D.Schema> -> IO(Unit),label:String,instance:I.Instance<D.Schema>,result:Root.Application() & App.Report<String,Unit>) -> IO(Unit):
  match result:
    case (app,App.Finished{_}):printed(next,label,Observe.snapshot(app,instance))
    case _:IO.die(Unit,1,"scheduled health execution refused")
def ticks(remaining:Nat,+index:U32,app:Root.Application(),instance:I.Instance<D.Schema>) -> IO(Unit):
  match remaining:
    case 0n:final(Observe.snapshot(app,instance))
    case 1n++rest:IO.bind(Root.Application() & App.Report<String,Unit>,Unit,Root.run(app),result => executed(app => instance => ticks(rest,U32.add(index,1),app,instance),"tick=" ++ U32.show(index) ++ " health=",instance,result))
def start(app:Root.Application()) -> IO(Unit):
  IO.bind(Root.Application() & App.Report<String,Unit>,Unit,Root.run(app),result => executed(app => instance => ticks(6n,1,Root.configure(True{},app),instance),"before-barrier=",I.Fresh{},result))
