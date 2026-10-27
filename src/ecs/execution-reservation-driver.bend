import Base
import ./execution-reservation-frame.bend as Frame
import ./execution-reservation-task.bend as Task
import ./execution-reservation-administration.bend as Administration
import ./execution-reservation-permit.bend as Permit
import ./execution-state.bend as State

# Only the closed framework wrapper is supplied to the trusted host loop.
def trusted_drive(-S:Data,-R:Type,entry:Frame.Frame<S,Permit.Permit,R> -> Frame.Round(S,Permit.Permit,R),frame:Frame.Frame<S,Permit.Permit,R>) -> IO(Frame.Terminal<S,R>):
  import "./execution-reservation-driver.c"
  import "./execution-reservation-driver.js"
def drive(~S:Data,~R:Type,frame:Frame.Frame<S,Permit.Permit,R>) -> IO(Frame.Terminal<S,R>):
  trusted_drive(S,R,input => Frame.framework_step(~S,~Permit.Permit,~R,~Permit.authorized,input),frame)
def restored(~S:Data,~C:Type,~R:Type,~E:Data,~Out:Type,remainder:Administration.Remainder<S,C,R,E>,terminal:Frame.Terminal<S,Out>) -> State.Administration<S,C,R,E> & Out:
  match terminal:
    case Frame.Terminal{issuer,value}:(Administration.put(~S,~C,~R,~E,remainder,issuer),value)
def separated(~S:Data,~C:Type,~R:Type,~E:Data,~Out:Type,authorized:List<&2,U32>,task:Task.Task<S,Permit.Permit,Out>,result:Administration.Remainder<S,C,R,E> & Task.Issuer<S>) -> IO(State.Administration<S,C,R,E> & Out):
  match result:
    case (remainder,Task.Issuer{namespace,allocator,_}):IO.bind(Frame.Terminal<S,Out>,State.Administration<S,C,R,E> & Out,drive(~S,~Out,Frame.Frame{Task.Issuer{namespace,allocator,authorized},task}),terminal => IO.pure(State.Administration<S,C,R,E> & Out,restored(~S,~C,~R,~E,~Out,remainder,terminal)))
def run(~S:Data,~C:Type,~R:Type,~E:Data,~Out:Type,authorized:List<&2,U32>,admin:State.Administration<S,C,R,E>,task:Task.Task<S,Permit.Permit,Out>) -> IO(State.Administration<S,C,R,E> & Out):
  separated(~S,~C,~R,~E,~Out,authorized,task,Administration.take(~S,~C,~R,~E,admin))
