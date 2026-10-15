import Base
import main.bend as App
import schema.bend as Fixture
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/ordinary-machine-transition-reader.bend as Reader
import ../../../../src/ecs/system-instance.bend as SI

type State<S:Data> is Type:
  State{world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,foreign:W.World<S,Array<U32>,Fixture.Resources<S>,String>,fast:Maybe<&1,App.UserReader<S>>,slow:Maybe<&1,App.UserReader<S>>,trace:List<&2,String>}

def view_returned(~S:Data,pair:App.UserReader<S> & App.UserReaderView) -> Maybe<&1,App.UserReader<S>> & String:
  match pair:
    case (reader,view):(Some{reader},App.user_reader_view_text(view))

def reader_text(~S:Data,reader:Maybe<&1,App.UserReader<S>>) -> Maybe<&1,App.UserReader<S>> & String:
  match reader:
    case None{}:(None{},"disposed")
    case Some{reader}:view_returned(~S,App.user_reader_view(~S,reader))

def observed_slow(~S:Data,label:String,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,foreign:W.World<S,Array<U32>,Fixture.Resources<S>,String>,fast:Maybe<&1,App.UserReader<S>>,fastText:String,trace:List<&2,String>,pair:Maybe<&1,App.UserReader<S>> & String) -> State<S>:
  match pair:
    case (slow,slowText):State{world,foreign,fast,slow,List.append(&2,String,trace,[label ++ ";fast{" ++ fastText ++ "};slow{" ++ slowText ++ "}"])}

def observed_fast(~S:Data,label:String,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,foreign:W.World<S,Array<U32>,Fixture.Resources<S>,String>,slow:Maybe<&1,App.UserReader<S>>,trace:List<&2,String>,pair:Maybe<&1,App.UserReader<S>> & String) -> State<S>:
  match pair:
    case (fast,fastText):observed_slow(~S,label,world,foreign,fast,fastText,trace,reader_text(~S,slow))

def observed_foreign(~S:Data,label:String,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,fast:Maybe<&1,App.UserReader<S>>,slow:Maybe<&1,App.UserReader<S>>,trace:List<&2,String>,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & String) -> State<S>:
  match pair:
    case (foreign,text):observed_fast(~S,label ++ ";foreign{" ++ text ++ "}",world,foreign,slow,trace,reader_text(~S,fast))

def observed_world(~S:Data,label:String,foreign:W.World<S,Array<U32>,Fixture.Resources<S>,String>,fast:Maybe<&1,App.UserReader<S>>,slow:Maybe<&1,App.UserReader<S>>,trace:List<&2,String>,pair:W.World<S,Array<U32>,Fixture.Resources<S>,String> & String) -> State<S>:
  match pair:
    case (world,text):observed_foreign(~S,label ++ ";local{" ++ text ++ "}",world,fast,slow,trace,App.physical_world_observation(~S,foreign))

def observe(~S:Data,label:String,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,fast,slow,trace}:observed_world(~S,label,foreign,fast,slow,trace,App.physical_world_observation(~S,world))

def read_returned(~S:Data,label:String,foreign:W.World<S,Array<U32>,Fixture.Resources<S>,String>,slow:Maybe<&1,App.UserReader<S>>,trace:List<&2,String>,result:App.UserRun<S>) -> State<S>:
  match result:
    case App.UserRan{world,fast,line}:observe(~S,label ++ ";" ++ line,State{world,foreign,Some{fast},slow,trace})

def read_fast(~S:Data,label:String,fail:Bool,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,None{},slow,trace}:observe(~S,label ++ ";absent",State{world,foreign,None{},slow,trace})
    case State{world,foreign,Some{fast},slow,trace}:read_returned(~S,label,foreign,slow,trace,App.user_read(~S,fast,world,fail))

def foreign_returned(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,slow:Maybe<&1,App.UserReader<S>>,trace:List<&2,String>,result:App.UserRun<S>) -> State<S>:
  match result:
    case App.UserRan{foreign,fast,line}:observe(~S,"foreign-read;" ++ line,State{world,foreign,Some{fast},slow,trace})

def foreign_read(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,None{},slow,trace}:State{world,foreign,None{},slow,trace}
    case State{world,foreign,Some{fast},slow,trace}:foreign_returned(~S,world,slow,trace,App.user_read(~S,fast,foreign,True{}))


def disposal_world(~S:Data,label:String,other:W.World<S,Array<U32>,Fixture.Resources<S>,String>,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,fast:Maybe<&1,App.UserReader<S>>,slow:Maybe<&1,App.UserReader<S>>,trace:List<&2,String>,foreignCall:Bool) -> State<S>:
  match foreignCall:
    case True{}:observe(~S,label,State{other,world,fast,slow,trace})
    case False{}:observe(~S,label,State{world,other,fast,slow,trace})

def disposed(~S:Data,label:String,other:W.World<S,Array<U32>,Fixture.Resources<S>,String>,survivor:Maybe<&1,App.UserReader<S>>,trace:List<&2,String>,foreignCall:Bool,result:Reader.disposal_type(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Array<U32>,~Fixture.Resources<S>,~String,~Bool,~String,~Fixture.TransitionReadOutput,~Fixture.reader_take(~S),~Fixture.reader_put(~S),~Fixture.transition_reader_callback(~S))) -> State<S>:
  match result:
    case SI.Disposed{world}:disposal_world(~S,label ++ ";accepted",other,world,None{},survivor,trace,foreignCall)
    case SI.Rejected{world,instance}:disposal_world(~S,label ++ ";refused",other,world,Some{App.UserReader{instance}},survivor,trace,foreignCall)

def dispose_fast(~S:Data,foreignCall:Bool,state:State<S>) -> State<S>:
  match foreignCall state:
    case _, State{world,foreign,None{},slow,trace}:State{world,foreign,None{},slow,trace}
    case True{}, State{world,foreign,Some{App.UserReader{instance}},slow,trace}:disposed(~S,"foreign-dispose",world,slow,trace,True{},Reader.dispose(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Array<U32>,~Fixture.Resources<S>,~String,~Bool,~String,~Fixture.TransitionReadOutput,~Fixture.reader_take(~S),~Fixture.reader_put(~S),~Fixture.transition_reader_callback(~S),instance,foreign))
    case False{}, State{world,foreign,Some{App.UserReader{instance}},slow,trace}:disposed(~S,"local-dispose",foreign,slow,trace,False{},Reader.dispose(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Array<U32>,~Fixture.Resources<S>,~String,~Bool,~String,~Fixture.TransitionReadOutput,~Fixture.reader_take(~S),~Fixture.reader_put(~S),~Fixture.transition_reader_callback(~S),instance,world))

def swap(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,fast,slow,trace}:State{world,foreign,slow,fast,trace}

def done(~S:Data,state:State<S>) -> String:
  match state:
    case State{world,foreign,_,_,trace}:String.concat(List.append(&2,String,trace,["final-local{" ++ App.physical_world_text(~S,world) ++ "};final-foreign{" ++ App.physical_world_text(~S,foreign) ++ "}\n"]))

def cold_returned(~S:Data,foreign:W.World<S,Array<U32>,Fixture.Resources<S>,String>,slow:Maybe<&1,App.UserReader<S>>,trace:List<&2,String>,pair:Reader.instance_type(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Array<U32>,~Fixture.Resources<S>,~String,~Bool,~String,~Fixture.TransitionReadOutput,~Fixture.reader_take(~S),~Fixture.reader_put(~S),~Fixture.transition_reader_callback(~S)) & W.World<S,Array<U32>,Fixture.Resources<S>,String>) -> State<S>:
  match pair:
    case (reader,world):observe(~S,"cold-skip-before-first-open",State{world,foreign,Some{App.UserReader{reader}},slow,trace})
def cold_skip(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,None{},slow,trace}:State{world,foreign,None{},slow,trace}
    case State{world,foreign,Some{App.UserReader{reader}},slow,trace}:cold_returned(~S,foreign,slow,trace,Reader.skip(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Array<U32>,~Fixture.Resources<S>,~String,~Bool,~String,~Fixture.TransitionReadOutput,~Fixture.reader_take(~S),~Fixture.reader_put(~S),~Fixture.transition_reader_callback(~S),reader,world))
def scenario(~S:Data,state:State<S>) -> String:
  done(~S,dispose_fast(~S,False{},read_fast(~S,"independent-survivor",False{},swap(~S,dispose_fast(~S,False{},read_fast(~S,"first-repeat",False{},read_fast(~S,"first-read-after-cold-skip",False{},cold_skip(~S,observe(~S,"registered-before-open",state)))))))))

def slow_registered(~S:Data,foreign:W.World<S,Array<U32>,Fixture.Resources<S>,String>,fast:App.UserReader<S>,result:Reader.registration_type(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Array<U32>,~Fixture.Resources<S>,~String,~Bool,~String,~Fixture.TransitionReadOutput,~Fixture.reader_take(~S),~Fixture.reader_put(~S),~Fixture.transition_reader_callback(~S))) -> String:
  match result:
    case SI.Registered{world,instance}:scenario(~S,State{world,foreign,Some{fast},Some{App.UserReader{instance}},[]})
    case SI.RegistrationFailed{world}:App.physical_world_text(~S,world) ++ App.physical_world_text(~S,foreign)

def fast_registered(~S:Data,foreign:W.World<S,Array<U32>,Fixture.Resources<S>,String>,result:Reader.registration_type(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~Array<U32>,~Fixture.Resources<S>,~String,~Bool,~String,~Fixture.TransitionReadOutput,~Fixture.reader_take(~S),~Fixture.reader_put(~S),~Fixture.transition_reader_callback(~S))) -> String:
  match result:
    case SI.Registered{world,instance}:slow_registered(~S,foreign,App.UserReader{instance},App.reader_create(~S,"survivor",world))
    case SI.RegistrationFailed{world}:App.physical_world_text(~S,world) ++ App.physical_world_text(~S,foreign)

def second(~S:Data,world:W.World<S,Array<U32>,Fixture.Resources<S>,String>,result:WI.Creation<S,Array<U32>,Fixture.Resources<S>,String>) -> IO(String):
  match result:
    case WI.Created{foreign}:IO.pure(String,fast_registered(~S,Fixture.initialize(~S,foreign),App.reader_create(~S,"first",Fixture.initialize(~S,world))))
    case WI.Refused{_}:IO.pure(String,App.physical_world_text(~S,world))

def first(~S:Data,result:WI.Creation<S,Array<U32>,Fixture.Resources<S>,String>) -> IO(String):
  match result:
    case WI.Created{world}:IO.bind(WI.Creation<S,Array<U32>,Fixture.Resources<S>,String>,String,WI.create(~S,~Array<U32>,~Fixture.Resources<S>,~String,~App.empty_store,Fixture.resources(~S)),result => second(~S,world,result))
    case WI.Refused{_}:IO.pure(String,"creation-refused")

def run(~S:Data) -> IO(String):
  IO.bind(WI.Creation<S,Array<U32>,Fixture.Resources<S>,String>,String,WI.create(~S,~Array<U32>,~Fixture.Resources<S>,~String,~App.empty_store,Fixture.resources(~S)),result => first(~S,result))

def printed(value:String) -> IO(Unit):IO.print(value)

def main() -> IO(Unit):
  IO.bind(String,Unit,run(~Fixture.SchemaA),a => IO.bind(String,Unit,run(~Fixture.SchemaB),b => printed(a ++ b)))
