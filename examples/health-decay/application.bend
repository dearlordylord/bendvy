import Base
import ./schema.bend as D
import ./root.bend as Root
import ./observe.bend as Observe
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/dependency-application.bend as App

def printed(next:Root.Application() -> I.Instance<D.Schema> -> IO(Unit),label:String,result:Root.Application() & (I.Instance<D.Schema> & Result<&2,&2,Unit,Observe.Snapshot>)) -> IO(Unit):
  match result:
    case (app,(instance,Done{Observe.Snapshot{selected,_,_}})):IO.bind(Unit,Unit,IO.print(label ++ selected),_ => next(app,instance))
    case _:IO.die(Unit,1,"health observation refused")
def executed(next:Root.Application() -> I.Instance<D.Schema> -> IO(Unit),label:String,instance:I.Instance<D.Schema>,result:Root.Application() & App.Report<String,Unit>) -> IO(Unit):
  match result:
    case (app,App.Finished{_}):printed(next,label,Observe.snapshot(app,instance))
    case _:IO.die(Unit,1,"health execution refused")
def tick(remaining:Nat,+index:U32,app:Root.Application(),instance:I.Instance<D.Schema>) -> IO(Unit):
  match remaining:
    case 0n:IO.pure(Unit,Unit{})
    case 1n++rest:IO.bind(Root.Application() & App.Report<String,Unit>,Unit,Root.run(app),result => executed(app => instance => tick(rest,U32.add(index,1),app,instance),"tick-" ++ U32.show(index) ++ "=",instance,result))
def start(result:Maybe<Root.Application()>) -> IO(Unit):
  match result:
    case Some{app}:IO.bind(Root.Application() & App.Report<String,Unit>,Unit,Root.run(app),result => executed(app => instance => tick(2n,1,Root.configure(True{},app),instance),"before-barrier=",I.Fresh{},result))
    case None{}:IO.die(Unit,1,"health registration refused")
