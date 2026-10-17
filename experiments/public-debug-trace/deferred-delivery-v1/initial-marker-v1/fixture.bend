import Base
import ../selector-handlers-v1/fixture.bend as BaseF
import ../../../../src/ecs/ordinary-app-machine-initialization-field.bend as Initial
import ../../../../src/ecs/ordinary-app-machine-handler.bend as App
import ../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../src/ecs/ordinary-machine-schedule.bend as Ordinary
import ../../../../src/ecs/machine-handler-bundle.bend as B
import ../../../../src/ecs/machine-stream.bend as St
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/execution-trace.bend as Trace

type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
def Application(~S:Data) -> Type:Initial.Application<S,BaseF.Mode,U32,BaseF.Need,Unit,BaseF.Resources(~S),Unit,BaseF.runner(~S),Array<U32>>
def RunResult(~S:Data) -> Type:Initial.RunResult<S,BaseF.Mode,U32,BaseF.Need,Unit,BaseF.Resources(~S),Unit,BaseF.runner(~S),Array<U32>>
type Setup<S:Data> is Type:
  Ready{app:Application(~S)}
  BaseRejected{result:BaseF.Setup<S>}
  MarkerRejected{app:BaseF.Application(~S)}
def initial_bound(~S:Data,value:Initial.Definition<S,BaseF.Mode,U32,BaseF.Need,Unit,BaseF.Resources(~S),Unit,BaseF.runner(~S),Array<U32>>) -> Setup<S>:
  match value:
    case Initial.Bound{app}:Ready{app}
    case Initial.Rejected{app}:MarkerRejected{app}
def setup_returned(~S:Data,value:BaseF.Setup<S>) -> Setup<S>:
  match value:
    case BaseF.Ready{app}:initial_bound(~S,Initial.bind(~S,~BaseF.Mode,~U32,~BaseF.Need,~Unit,~BaseF.Resources(~S),~Unit,~BaseF.runner(~S),~Array<U32>,~BaseF.take_state(~S),~BaseF.put_state(~S),~U32.is_eq,~BaseF.requirement_same,~BaseF.has(~S),~BaseF.frame(~S),~BaseF.machine(~S),app))
    case result:BaseRejected{result}
def setup(~S:Data,world:BaseF.World(~S)) -> Setup<S>:setup_returned(~S,BaseF.setup(~S,world))
def enabled(~S:Data,app:Application(~S),flag:Bool) -> Application(~S):Initial.enabled(~S,~BaseF.Mode,~U32,~BaseF.Need,~Unit,~BaseF.Resources(~S),~Unit,~BaseF.runner(~S),~Array<U32>,app,flag)
def snapshot(~S:Data,app:Application(~S)) -> Application(~S) & Maybe<&2,App.Description<S,BaseF.Mode,U32,BaseF.Need>>:Initial.snapshot(~S,~BaseF.Mode,~U32,~BaseF.Need,~Unit,~BaseF.Resources(~S),~Unit,~BaseF.runner(~S),~Array<U32>,app)
def run(~S:Data,app:Application(~S)) -> RunResult(~S) & Trace.Batch<String>:Initial.run(~S,~BaseF.Mode,~U32,~BaseF.Need,~Unit,~BaseF.Resources(~S),~Unit,~BaseF.Ops(~S),~U32,~BaseF.declaration(~S),~BaseF.body(~S),~BaseF.take_state(~S),~BaseF.put_state(~S),~U32.is_eq,~BaseF.requirement_same,~BaseF.has(~S),~BaseF.frame(~S),~BaseF.machine(~S),~Array<U32>,app)
def resume(~S:Data,value:RunResult(~S)) -> Application(~S) & B.Status<BaseF.Need>:Initial.resume(~S,~BaseF.Mode,~U32,~BaseF.Need,~Unit,~BaseF.Resources(~S),~Unit,~BaseF.runner(~S),~Array<U32>,value)
def inserted(~S:Data,app:Application(~S)) -> Application(~S):
  match app:
    case Initial.Application{App.Application{world,bundle,declaration,extra,debug},reader}:Initial.Application{App.Application{Init.insert_state(~S,~BaseF.Mode,~U32,~BaseF.Resources(~S),~BaseF.take_state(~S),~BaseF.put_state(~S),~Unit,~Unit,~BaseF.machine(~S),world,1),bundle,declaration,extra,debug},reader}
    case app:app
def queued(~S:Data,reader:St.Reader<S,BaseF.Mode>,pair:BaseF.Application(~S) & T.Outcome<String>) -> Application(~S) & T.Outcome<String>:
  match pair:
    case (app,outcome):(Initial.Application{app,reader},outcome)
def queue(~S:Data,app:Application(~S),value:U32,skip:Bool) -> Application(~S) & T.Outcome<String>:
  match app:
    case Initial.Application{app,reader}:queued(~S,reader,BaseF.queue(~S,app,value,skip))
def make_initial(~S:Data,world:BaseF.World(~S)) -> BaseF.World(~S) & U32:(world,1)
def initialized(~S:Data,app:Application(~S)) -> Application(~S):
  match app:
    case Initial.Application{App.Application{world,bundle,declaration,extra,debug},reader}:Initial.Application{App.Application{Init.init_state(~S,~BaseF.Mode,~U32,~BaseF.Resources(~S),~BaseF.take_state(~S),~BaseF.put_state(~S),~Unit,~Unit,~BaseF.machine(~S),~make_initial(~S),world),bundle,declaration,extra,debug},reader}
    case app:app
