import Base
import provider.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as St
import context.bend as Ctx
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev

type View<S: Data,Token: Data,V: Data> is Data:
  View{values: List<&2,M.Transition<V>>,lagged: Bool}
type Delivery is Data:
  Delivery{flow: List<&2,M.Transition<P.Flow>>,level: List<&2,M.Transition<P.Level>>,flowLagged: Bool,levelLagged: Bool}
type Failure is Data:
  Failure{message: String,delivery: Maybe<&2,Delivery>}
type Input is Data:
  Input{flowNamespace: U32,flowId: U32,levelNamespace: U32,levelId: U32,fails: Bool}
type Work<S: Data,-H: Type> is Type:
  Work{flow: Cap.ValueRead<H,View<S,P.FlowToken,P.Flow>>,level: Cap.ValueRead<H,View<S,P.LevelToken,P.Level>>}
type Completion is Data:
  Completion{delivery: Delivery,outcome: Tx.Outcome<String>}

def flow_cap(~S: Data,~H: Type,caps: Work<S,H>) -> Cap.ValueRead<H,View<S,P.FlowToken,P.Flow>>:
  match caps:
    case Work{cap,_}: cap
def level_cap(~S: Data,~H: Type,caps: Work<S,H>) -> Cap.ValueRead<H,View<S,P.LevelToken,P.Level>>:
  match caps:
    case Work{_,cap}: cap
def completed(~S: Data,~H: Type,fails: Bool,flow: View<S,P.FlowToken,P.Flow>,pair: H & View<S,P.LevelToken,P.Level>) -> H & Completion:
  match fails flow pair:
    case False{}, View{a,al}, (ctx,View{b,bl}): (ctx,Completion{Delivery{a,b,al,bl},Tx.Success{}})
    case True{}, View{a,al}, (ctx,View{b,bl}): (ctx,Completion{Delivery{a,b,al,bl},Tx.Failure{"reader-failed"}})
def level_read(~S: Data,~H: Type,~level: Cap.ValueRead<H,View<S,P.LevelToken,P.Level>>,fails: Bool,pair: H & View<S,P.FlowToken,P.Flow>) -> H & Completion:
  (ctx,flow)=pair
  completed(~S,~H,fails,flow,Cap.value_read(~H,~View<S,P.LevelToken,P.Level>,~level,ctx))

# No concrete world, registry, pending state or write capability is supplied.
def body(~S: Data,~H: Type,~caps: Work<S,H>,fails: Bool,ctx: H) -> H & Completion:
  level_read(~S,~H,~level_cap(~S,~H,caps),fails,Cap.value_read(~H,~View<S,P.FlowToken,P.Flow>,~flow_cap(~S,~H,caps),ctx))

type Frame<S: Data> is Type:
  Frame{base: Ctx.Frame<S>,flow: View<S,P.FlowToken,P.Flow>,level: View<S,P.LevelToken,P.Level>}
def read_flow(~S: Data,frame: Frame<S>) -> Frame<S> & View<S,P.FlowToken,P.Flow>:
  match frame:
    case Frame{base,+flow,level}: (Frame{base,flow,level},flow)
def read_level(~S: Data,frame: Frame<S>) -> Frame<S> & View<S,P.LevelToken,P.Level>:
  match frame:
    case Frame{base,flow,+level}: (Frame{base,flow,level},level)
def work(~S: Data) -> Work<S,Frame<S>>:
  Work{Cap.ValueRead{frame => read_flow(~S,frame)},Cap.ValueRead{frame => read_level(~S,frame)}}
def view(~S: Data,~Token: Data,~V: Data,reading: Ev.Reading<M.Transition<V>>) -> View<S,Token,V>:
  match reading:
    case Ev.Reading{values,lagged}: View{values,lagged}

def stream_completed(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,flowId: U32,levelId: U32) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,flowStream,levelStream,frame,+tick,trace},events,commands,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,St.complete(~P.Flow,flowStream,flowId,tick,True{}),St.complete(~P.Level,levelStream,levelId,tick,True{}),frame,tick,trace},events,commands,registrations,nextSystem,clock}
def finished(~S: Data,flowId: U32,levelId: U32,delivery: Delivery,result: Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Failure,Delivery>:
  match result:
    case Sys.Succeeded{world,_}: Sys.Succeeded{stream_completed(~S,world,flowId,levelId),delivery}
    case Sys.Failed{world,error}: Sys.Failed{world,Failure{error,Some{delivery}}}
def finish(~S: Data,flowId: U32,levelId: U32,pair: Frame<S> & Completion) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Failure,Delivery>:
  match pair:
    case (Frame{base,_,_},Completion{delivery,outcome}): finished(~S,flowId,levelId,delivery,Ctx.finish(~S,(base,outcome)))

def prepared(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,+flowStream: St.Stream<P.Flow>,+levelStream: St.Stream<P.Level>,+flowId: U32,+levelId: U32,+tick: Nat,fails: Bool) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Failure,Delivery>:
  finish(~S,flowId,levelId,body(~S,~Frame<S>,~work(~S),fails,Frame{Ctx.Frame{Tx.begin(~W.World<S,P.Store<S>,P.Resources<S>,Unit>,~Unit,P.pulse(~S,world)),None{}},view(~S,~P.FlowToken,~P.Flow,St.observe(~P.Flow,flowStream,flowId,tick)),view(~S,~P.LevelToken,~P.Level,St.observe(~P.Level,levelStream,levelId,tick))}))
def prepare(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,+flowId: U32,+levelId: U32,fails: Bool) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Failure,Delivery>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,+flowStream,+levelStream,frame,+tick,trace},events,commands,registrations,nextSystem,clock}:
      prepared(~S,W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,St.activate(~P.Flow,flowStream,flowId,tick),St.activate(~P.Level,levelStream,levelId,tick),frame,tick,trace},events,commands,registrations,nextSystem,clock},flowStream,levelStream,flowId,levelId,tick,fails)
def prepare_checked(~S: Data,allowed: Bool,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,flowId: U32,levelId: U32,fails: Bool) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Failure,Delivery>:
  match allowed:
    case False{}: Sys.Failed{world,Failure{"ReaderNamespaceRejected",None{}}}
    case True{}: prepare(~S,world,flowId,levelId,fails)
def namespace_checked(~S: Data,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & U32,input: Input) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Failure,Delivery>:
  match pair input:
    case (world,+actual), Input{a,id,b,jd,fails}: prepare_checked(~S,Bool.and(U32.is_eq(actual,a),U32.is_eq(actual,b)),world,id,jd,fails)
def runner(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,input: Input) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Failure,Delivery>:
  namespace_checked(~S,W.namespace(~S,~P.Store<S>,~P.Resources<S>,~Unit,world),input)

type Instance<S: Data,-run: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> Input -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Failure,Delivery>> is Type:
  Instance{registry: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,Input,Failure,Delivery,run>,flow: St.Reader<S,P.FlowToken>,level: St.Reader<S,P.LevelToken>}
type Provision<S: Data,-run: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> Input -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Failure,Delivery>> is Type:
  Provisioned{world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,instance: Instance<S,run>}
  ProvisionFailed{world: W.World<S,P.Store<S>,P.Resources<S>,Unit>}
def registered_identity(~S: Data,~run: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> Input -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Failure,Delivery>,named: W.World<S,P.Store<S>,P.Resources<S>,Unit> & U32,pair: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,Input,Failure,Delivery,run> & U32) -> Provision<S,run>:
  match named pair:
    case (actual,+namespace), (registry,+id): Provisioned{actual,Instance{registry,St.Reader{namespace,id},St.Reader{namespace,id}}}
def registered(~S: Data,~run: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> Input -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Failure,Delivery>,result: Sys.RegistrationResult<S,P.Store<S>,P.Resources<S>,Unit,Input,Failure,Delivery,run>) -> Provision<S,run>:
  match result:
    case Sys.Registered{world,registry}: registered_identity(~S,~run,W.namespace(~S,~P.Store<S>,~P.Resources<S>,~Unit,world),Sys.identity(~S,~P.Store<S>,~P.Resources<S>,~Unit,~Input,~Failure,~Delivery,~run,registry))
    case Sys.RegistrationFailed{world}: ProvisionFailed{world}
def provision(~S: Data,~run: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> Input -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Failure,Delivery>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,name: String) -> Provision<S,run>:
  registered(~S,~run,Sys.register(~S,~P.Store<S>,~P.Resources<S>,~Unit,~Input,~Failure,~Delivery,~run,world,name,["transition.Flow.read","transition.Level.read"]))

type Returned<S: Data,-run: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> Input -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Failure,Delivery>> is Type:
  Returned{instance: Instance<S,run>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,delivery: Maybe<&2,Delivery>,status: String}
def returned(~S: Data,~run: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> Input -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Failure,Delivery>,flow: St.Reader<S,P.FlowToken>,level: St.Reader<S,P.LevelToken>,result: Sys.RunResult<S,P.Store<S>,P.Resources<S>,Unit,Input,Failure,Delivery,run>) -> Returned<S,run>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,delivery}}: Returned{Instance{registry,flow,level},world,Some{delivery},"ok"}
    case Sys.Completed{registry,Sys.Failed{world,Failure{error,delivery}}}: Returned{Instance{registry,flow,level},world,delivery,error}
    case Sys.RegistrationRejected{registry,world,_}: Returned{Instance{registry,flow,level},world,None{},"reader-registration-rejected"}
def invoke(~S: Data,~run: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> Input -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Failure,Delivery>,instance: Instance<S,run>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,fails: Bool) -> Returned<S,run>:
  match instance:
    case Instance{registry,St.Reader{+a,+id},St.Reader{+b,+jd}}:
      returned(~S,~run,St.Reader{a,id},St.Reader{b,jd},Sys.run(~S,~P.Store<S>,~P.Resources<S>,~Unit,~Input,~Failure,~Delivery,~run,registry,world,Input{a,id,b,jd,fails}))

def skipped_world(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,flowId: U32,levelId: U32) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,flowStream,levelStream,frame,+tick,trace},events,commands,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,St.skip(~P.Flow,flowStream,flowId,tick),St.skip(~P.Level,levelStream,levelId,tick),frame,tick,trace},events,commands,registrations,nextSystem,clock}
def skip(~S: Data,~run: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> Input -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Failure,Delivery>,instance: Instance<S,run>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> Instance<S,run> & W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match instance:
    case Instance{registry,St.Reader{a,+id},St.Reader{b,+jd}}:
      (Instance{registry,St.Reader{a,id},St.Reader{b,jd}},skipped_world(~S,world,id,jd))
