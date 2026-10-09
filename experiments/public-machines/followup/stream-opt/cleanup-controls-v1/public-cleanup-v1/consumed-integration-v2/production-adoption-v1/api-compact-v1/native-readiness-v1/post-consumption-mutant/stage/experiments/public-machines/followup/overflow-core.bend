import Base
import ../provider.bend as P
import stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/machine.bend as M
import stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/machine-stream.bend as St
import ../observe.bend as O
import stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/world.bend as W
import stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/system.bend as Sys
import stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/transaction.bend as Tx
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/commands.bend as Cmd
import stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/event-runtime.bend as Ev

# Private numeric-machine application, with actual owned component/resource Arrays.
# Runtime loop inputs come from IO.args, not a huge checker-normalized literal.
type Resources<S: Data> is Type:
  Resources{owned: Array<U32>,slot: M.Slot<S,P.FlowToken,U32>,stream: St.Stream<U32>,frame: Nat,tick: Nat,error: Maybe<&2,String>}
type Input is Data:
  Seed{}
  Publish{}
type ReadInput is Data:
  ReadRequest{namespace: U32,id: U32,fails: Bool}
type View<S: Data> is Data:
  View{values: List<&2,M.Transition<U32>>,lagged: Bool}
type Frame<S: Data> is Type:
  Frame{tx: Tx.Tx<W.World<S,P.Store<S>,Resources<S>,Unit>,Unit>,reading: View<S>,error: Maybe<&2,String>}
type Work<S: Data,-H: Type> is Type:
  Work{current: Cap.ValueRead<H,M.CurrentView<S,P.FlowToken,U32>>,next: Cap.ValueWrite<H,M.QueueInput<U32>,M.NextView<S,P.FlowToken,U32>>,spawn: Cap.Send<H,Array<U32>>}
type ReaderWork<S: Data,-H: Type> is Type:
  ReaderWork{events: Cap.ValueRead<H,View<S>>}

def initial_resources(~S: Data) -> Resources<S>:
  Resources{ANode{ALeaf{30},ALeaf{130}},M.Present{0,M.NoPending{},None{},False{}},St.empty(~U32),0n,0n,None{}}
def take(~S: Data,world: W.World<S,P.Store<S>,Resources<S>,Unit>) -> W.World<S,P.Store<S>,Resources<S>,Unit> & M.Slot<S,P.FlowToken,U32>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Resources{owned,+slot,stream,frame,tick,error},events,commands,regs,nextSystem,clock}:
      (W.World{ns,next,high,live,capacity,depth,store,Resources{owned,slot,stream,frame,tick,error},events,commands,regs,nextSystem,clock},slot)
def put(~S: Data,world: W.World<S,P.Store<S>,Resources<S>,Unit>,slot: M.Slot<S,P.FlowToken,U32>) -> W.World<S,P.Store<S>,Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Resources{owned,_,stream,frame,tick,error},events,commands,regs,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,Resources{owned,slot,stream,frame,tick,error},events,commands,regs,nextSystem,clock}
def pulse(~S: Data,world: W.World<S,P.Store<S>,Resources<S>,Unit>) -> W.World<S,P.Store<S>,Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Resources{owned,slot,stream,frame,tick,error},events,commands,regs,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,Resources{owned,slot,stream,frame,1n+tick,error},events,commands,regs,nextSystem,clock}
def frame(~S: Data,world: W.World<S,P.Store<S>,Resources<S>,Unit>) -> W.World<S,P.Store<S>,Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Resources{owned,slot,stream,frame,+tick,error},events,commands,regs,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,Resources{owned,M.clear_changed(~S,~P.FlowToken,~U32,slot),St.frame(~U32,stream,tick),1n+frame,tick,error},events,commands,regs,nextSystem,clock}
def populate_error(~S: Data,world: W.World<S,P.Store<S>,Resources<S>,Unit>) -> W.World<S,P.Store<S>,Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Resources{owned,slot,stream,frame,tick,_},events,commands,regs,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,Resources{owned,slot,stream,frame,tick,Some{"POPULATE_REJECTED"}},events,commands,regs,nextSystem,clock}
def populated(~S: Data,result: Cmp.Replacement<W.World<S,P.Store<S>,Resources<S>,Unit>,Array<U32>>) -> W.World<S,P.Store<S>,Resources<S>,Unit>:
  match result:
    case Cmp.Replaced{world,_}: world
    case Cmp.ReplaceRejected{world,_,_}: populate_error(~S,world)

def populate(~S: Data,world: W.World<S,P.Store<S>,Resources<S>,Unit>,handle: W.Handle<S>,owner: Array<U32>) -> W.World<S,P.Store<S>,Resources<S>,Unit>:
  populated(~S,Cmp.replace(~S,~P.Store<S>,~Resources<S>,~Unit,~Unit,~Array<U32>,~List<&2,U32>,~P.CellsToken,~(store => P.store_take(~S,store)),~(rest => column => P.store_put(~S,rest,column)),~P.array_view,Cmp.Family{"cells"},world,handle,Some{owner}))
def spawned(~S: Data,reading: View<S>,error: Maybe<&2,String>,result: Tx.Tx<W.World<S,P.Store<S>,Resources<S>,Unit>,Unit> & W.Reservation<S>) -> Frame<S>:
  match result:
    case (tx,W.Reserved{_}): Frame{tx,reading,error}
    case (tx,W.ReservationRejected{_}): Frame{tx,reading,Some{"SpawnRejected"}}
def spawn(~S: Data,ctx: Frame<S>,owner: Array<U32>) -> Frame<S>:
  match ctx:
    case Frame{tx,reading,error}: spawned(~S,reading,error,Cmd.tx_spawn(~S,~P.Store<S>,~Resources<S>,~Unit,~Array<U32>,~(world => handle => payload => populate(~S,world,handle,payload)),tx,owner))
def current_returned(~S: Data,reading: View<S>,error: Maybe<&2,String>,pair: Tx.Tx<W.World<S,P.Store<S>,Resources<S>,Unit>,Unit> & M.Slot<S,P.FlowToken,U32>) -> Frame<S> & M.CurrentView<S,P.FlowToken,U32>:
  (tx,slot)=pair
  (Frame{tx,reading,error},M.current_view(~S,~P.FlowToken,~U32,slot))
def current(~S: Data,ctx: Frame<S>) -> Frame<S> & M.CurrentView<S,P.FlowToken,U32>:
  match ctx:
    case Frame{tx,reading,error}: current_returned(~S,reading,error,M.read(~S,~P.FlowToken,~U32,~W.World<S,P.Store<S>,Resources<S>,Unit>,~Unit,~(world => take(~S,world)),tx))
def next_returned(~S: Data,reading: View<S>,error: Maybe<&2,String>,pair: Tx.Tx<W.World<S,P.Store<S>,Resources<S>,Unit>,Unit> & M.Slot<S,P.FlowToken,U32>) -> Frame<S> & M.NextView<S,P.FlowToken,U32>:
  (tx,slot)=pair
  (Frame{tx,reading,error},M.next_view(~S,~P.FlowToken,~U32,slot))
def next(~S: Data,ctx: Frame<S>) -> Frame<S> & M.NextView<S,P.FlowToken,U32>:
  match ctx:
    case Frame{tx,reading,error}: next_returned(~S,reading,error,M.read(~S,~P.FlowToken,~U32,~W.World<S,P.Store<S>,Resources<S>,Unit>,~Unit,~(world => take(~S,world)),tx))
def set(~S: Data,ctx: Frame<S>,value: M.QueueInput<U32>) -> Frame<S>:
  match ctx:
    case Frame{tx,reading,error}: Frame{M.next_declared(~S,~P.FlowToken,~U32,~W.World<S,P.Store<S>,Resources<S>,Unit>,~Unit,~(world => take(~S,world)),~(world => slot => put(~S,world,slot)),M.Family{"Flow"},tx,value),reading,error}
def work(~S: Data) -> Work<S,Frame<S>>:
  Work{Cap.ValueRead{ctx => current(~S,ctx)},Cap.ValueWrite{ctx => next(~S,ctx),ctx => value => set(~S,ctx,value)},Cap.Send{ctx => owner => spawn(~S,ctx,owner)}}
def current_cap(~S: Data,~H: Type,caps: Work<S,H>) -> Cap.ValueRead<H,M.CurrentView<S,P.FlowToken,U32>>:
  match caps:
    case Work{cap,_,_}: cap
def next_cap(~S: Data,~H: Type,caps: Work<S,H>) -> Cap.ValueWrite<H,M.QueueInput<U32>,M.NextView<S,P.FlowToken,U32>>:
  match caps:
    case Work{_,cap,_}: cap
def spawn_cap(~S: Data,~H: Type,caps: Work<S,H>) -> Cap.Send<H,Array<U32>>:
  match caps:
    case Work{_,_,cap}: cap
def requested(~S: Data,~H: Type,~cap: Cap.ValueWrite<H,M.QueueInput<U32>,M.NextView<S,P.FlowToken,U32>>,pair: H & M.CurrentView<S,P.FlowToken,U32>) -> H & Tx.Outcome<String>:
  match pair:
    case (ctx,M.Unavailable{}): (ctx,Tx.Failure{"MachineProvisionRejected"})
    case (ctx,M.Current{value}): (Cap.value_set(~H,~M.QueueInput<U32>,~M.NextView<S,P.FlowToken,U32>,~cap,ctx,M.Set{(value+1 : U32),False{}}),Tx.Success{})
def body(~S: Data,~H: Type,~caps: Work<S,H>,input: Input,ctx: H) -> H & Tx.Outcome<String>:
  match input:
    case Seed{}: (Cap.send(~H,~Array<U32>,~spawn_cap(~S,~H,caps),ctx,ANode{ALeaf{10},ALeaf{99}}),Tx.Success{})
    case Publish{}: requested(~S,~H,~next_cap(~S,~H,caps),Cap.value_read(~H,~M.CurrentView<S,P.FlowToken,U32>,~current_cap(~S,~H,caps),ctx))
def effective(outcome: Tx.Outcome<String>,error: Maybe<&2,String>) -> Tx.Outcome<String>:
  match error:
    case None{}: outcome
    case Some{error}: Tx.Failure{error}
def finish_returned(~S: Data,result: Tx.Returned<W.World<S,P.Store<S>,Resources<S>,Unit>,String>) -> Sys.Outcome<W.World<S,P.Store<S>,Resources<S>,Unit>,String,Unit>:
  match result:
    case Tx.Returned{world,Tx.Success{}}: Sys.Succeeded{world,Unit{}}
    case Tx.Returned{world,Tx.Failure{error}}: Sys.Failed{world,error}
def finished(~S: Data,pair: Frame<S> & Tx.Outcome<String>) -> Sys.Outcome<W.World<S,P.Store<S>,Resources<S>,Unit>,String,Unit>:
  match pair:
    case (Frame{tx,_,error},outcome): finish_returned(~S,Cmd.tx_finish(~S,~P.Store<S>,~Resources<S>,~Unit,~String,tx,effective(outcome,error)))
def publisher_runner(~S: Data,world: W.World<S,P.Store<S>,Resources<S>,Unit>,input: Input) -> Sys.Outcome<W.World<S,P.Store<S>,Resources<S>,Unit>,String,Unit>:
  finished(~S,body(~S,~Frame<S>,~work(~S),input,Frame{Tx.begin(~W.World<S,P.Store<S>,Resources<S>,Unit>,~Unit,pulse(~S,world)),View{[],False{}},None{}}))

def events(~S: Data,ctx: Frame<S>) -> Frame<S> & View<S>:
  match ctx:
    case Frame{tx,+reading,error}: (Frame{tx,reading,error},reading)
def reader_work(~S: Data) -> ReaderWork<S,Frame<S>>:
  ReaderWork{Cap.ValueRead{ctx => events(~S,ctx)}}
def events_cap(~S: Data,~H: Type,caps: ReaderWork<S,H>) -> Cap.ValueRead<H,View<S>>:
  match caps:
    case ReaderWork{cap}: cap
type Completion<S: Data> is Data:
  Completion{view: View<S>,outcome: Tx.Outcome<String>}
def read_body_returned(~S: Data,~H: Type,fails: Bool,pair: H & View<S>) -> H & Completion<S>:
  match fails pair:
    case False{}, (ctx,view): (ctx,Completion{view,Tx.Success{}})
    case True{}, (ctx,view): (ctx,Completion{view,Tx.Failure{"reader-failed"}})
def read_body(~S: Data,~H: Type,~caps: ReaderWork<S,H>,fails: Bool,ctx: H) -> H & Completion<S>:
  read_body_returned(~S,~H,fails,Cap.value_read(~H,~View<S>,~events_cap(~S,~H,caps),ctx))
def complete_stream(~S: Data,world: W.World<S,P.Store<S>,Resources<S>,Unit>,id: U32) -> W.World<S,P.Store<S>,Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Resources{owned,slot,stream,frame,+tick,error},events,commands,regs,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,Resources{owned,slot,St.complete(~U32,stream,id,tick,True{}),frame,tick,error},events,commands,regs,nextSystem,clock}
type ReadFailure<S: Data> is Data:
  ReadFailure{message: String,view: View<S>}
def read_finished_returned(~S: Data,id: U32,view: View<S>,result: Tx.Returned<W.World<S,P.Store<S>,Resources<S>,Unit>,String>) -> Sys.Outcome<W.World<S,P.Store<S>,Resources<S>,Unit>,ReadFailure<S>,View<S>>:
  match result:
    case Tx.Returned{world,Tx.Success{}}: Sys.Succeeded{complete_stream(~S,world,id),view}
    case Tx.Returned{world,Tx.Failure{error}}: Sys.Failed{world,ReadFailure{error,view}}
def read_finished(~S: Data,id: U32,pair: Frame<S> & Completion<S>) -> Sys.Outcome<W.World<S,P.Store<S>,Resources<S>,Unit>,ReadFailure<S>,View<S>>:
  match pair:
    case (Frame{tx,_,error},Completion{view,outcome}): read_finished_returned(~S,id,view,Cmd.tx_finish(~S,~P.Store<S>,~Resources<S>,~Unit,~String,tx,effective(outcome,error)))
def view(~S: Data,reading: Ev.Reading<M.Transition<U32>>) -> View<S>:
  match reading:
    case Ev.Reading{values,lagged}: View{values,lagged}
def read_prepared(~S: Data,id: U32,fails: Bool,reading: View<S>,world: W.World<S,P.Store<S>,Resources<S>,Unit>) -> Sys.Outcome<W.World<S,P.Store<S>,Resources<S>,Unit>,ReadFailure<S>,View<S>>:
  read_finished(~S,id,read_body(~S,~Frame<S>,~reader_work(~S),fails,Frame{Tx.begin(~W.World<S,P.Store<S>,Resources<S>,Unit>,~Unit,pulse(~S,world)),reading,None{}}))
def read_activated(~S: Data,+id: U32,fails: Bool,world: W.World<S,P.Store<S>,Resources<S>,Unit>) -> Sys.Outcome<W.World<S,P.Store<S>,Resources<S>,Unit>,ReadFailure<S>,View<S>>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Resources{owned,slot,+stream,frame,+tick,error},events,commands,regs,nextSystem,clock}:
      read_prepared(~S,id,fails,view(~S,St.observe(~U32,stream,id,tick)),W.World{ns,next,high,live,capacity,depth,store,Resources{owned,slot,St.activate(~U32,stream,id,tick),frame,tick,error},events,commands,regs,nextSystem,clock})
def read_checked(~S: Data,allowed: Bool,id: U32,fails: Bool,world: W.World<S,P.Store<S>,Resources<S>,Unit>) -> Sys.Outcome<W.World<S,P.Store<S>,Resources<S>,Unit>,ReadFailure<S>,View<S>>:
  match allowed:
    case False{}: Sys.Failed{world,ReadFailure{"ReaderNamespaceRejected",View{[],False{}}}}
    case True{}: read_activated(~S,id,fails,world)
def read_named_pair(~S: Data,namespace: U32,id: U32,fails: Bool,pair: W.World<S,P.Store<S>,Resources<S>,Unit> & U32) -> Sys.Outcome<W.World<S,P.Store<S>,Resources<S>,Unit>,ReadFailure<S>,View<S>>:
  match pair:
    case (world,actual): read_checked(~S,U32.is_eq(namespace,actual),id,fails,world)
def read_named(~S: Data,input: ReadInput,pair: W.World<S,P.Store<S>,Resources<S>,Unit> & U32) -> Sys.Outcome<W.World<S,P.Store<S>,Resources<S>,Unit>,ReadFailure<S>,View<S>>:
  match input:
    case ReadRequest{namespace,id,fails}: read_named_pair(~S,namespace,id,fails,pair)
def reader_runner(~S: Data,world: W.World<S,P.Store<S>,Resources<S>,Unit>,input: ReadInput) -> Sys.Outcome<W.World<S,P.Store<S>,Resources<S>,Unit>,ReadFailure<S>,View<S>>:
  read_named(~S,input,W.namespace(~S,~P.Store<S>,~Resources<S>,~Unit,world))

def applied(~S: Data,resources: Resources<S>,change: M.Applied<S,P.FlowToken,U32>) -> Resources<S>:
  match resources change:
    case Resources{owned,_,stream,frame,tick,error} M.Applied{slot,None{}}: Resources{owned,slot,stream,frame,tick,error}
    case Resources{owned,_,stream,frame,+tick,error} M.Applied{slot,Some{event}}: Resources{owned,slot,St.publish(~U32,stream,1n+tick,event),frame,1n+tick,error}
def marked_resources(~S: Data,resources: Resources<S>) -> Resources<S>:
  match resources:
    case Resources{owned,+slot,stream,frame,tick,error}:
      applied(~S,Resources{owned,slot,stream,frame,tick,error},M.apply_snapshot(~S,~P.FlowToken,~U32,~U32.is_eq,slot,M.snapshot(~S,~P.FlowToken,~U32,slot)))
def marked(~S: Data,world: W.World<S,P.Store<S>,Resources<S>,Unit>) -> W.World<S,P.Store<S>,Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,regs,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,marked_resources(~S,resources),events,commands,regs,nextSystem,clock}
def marker(~S: Data,world: W.World<S,P.Store<S>,Resources<S>,Unit>) -> W.World<S,P.Store<S>,Resources<S>,Unit>:
  marked(~S,pulse(~S,W.barrier(~S,~P.Store<S>,~Resources<S>,~Unit,world)))

type Runtime<S: Data> is Type:
  Runtime{world: W.World<S,P.Store<S>,Resources<S>,Unit>,publisher: Sys.Registry<S,P.Store<S>,Resources<S>,Unit,Input,String,Unit,(world => input => publisher_runner(~S,world,input))>,reader: Sys.Registry<S,P.Store<S>,Resources<S>,Unit,ReadInput,ReadFailure<S>,View<S>,(world => input => reader_runner(~S,world,input))>,cap: St.Reader<S,P.FlowToken>,deliveries: List<&2,View<S>>,rows: List<&2,String>,status: String}
def publisher_returned(~S: Data,reader: Sys.Registry<S,P.Store<S>,Resources<S>,Unit,ReadInput,ReadFailure<S>,View<S>,(world => input => reader_runner(~S,world,input))>,cap: St.Reader<S,P.FlowToken>,deliveries: List<&2,View<S>>,rows: List<&2,String>,input: Input,result: Sys.RunResult<S,P.Store<S>,Resources<S>,Unit,Input,String,Unit,(world => input => publisher_runner(~S,world,input))>) -> Runtime<S>:
  match input result:
    case Seed{} Sys.Completed{publisher,Sys.Succeeded{world,_}}: Runtime{pulse(~S,W.barrier(~S,~P.Store<S>,~Resources<S>,~Unit,world)),publisher,reader,cap,deliveries,rows,"ok"}
    case Publish{} Sys.Completed{publisher,Sys.Succeeded{world,_}}: Runtime{marker(~S,world),publisher,reader,cap,deliveries,rows,"ok"}
    case _ Sys.Completed{publisher,Sys.Failed{world,error}}: Runtime{world,publisher,reader,cap,deliveries,rows,"failed:" ++ error}
    case _ Sys.RegistrationRejected{publisher,world,_}: Runtime{world,publisher,reader,cap,deliveries,rows,"publisher-registration-rejected"}
def publish(~S: Data,runtime: Runtime<S>,+input: Input) -> Runtime<S>:
  match runtime:
    case Runtime{world,publisher,reader,cap,deliveries,rows,_}:
      publisher_returned(~S,reader,cap,deliveries,rows,input,Sys.run(~S,~P.Store<S>,~Resources<S>,~Unit,~Input,~String,~Unit,~(world => input => publisher_runner(~S,world,input)),publisher,frame(~S,world),input))
def read_returned(~S: Data,publisher: Sys.Registry<S,P.Store<S>,Resources<S>,Unit,Input,String,Unit,(world => input => publisher_runner(~S,world,input))>,cap: St.Reader<S,P.FlowToken>,deliveries: List<&2,View<S>>,rows: List<&2,String>,result: Sys.RunResult<S,P.Store<S>,Resources<S>,Unit,ReadInput,ReadFailure<S>,View<S>,(world => input => reader_runner(~S,world,input))>) -> Runtime<S>:
  match result:
    case Sys.Completed{reader,Sys.Succeeded{world,view}}: Runtime{world,publisher,reader,cap,List.append(&2,View<S>,deliveries,[view]),rows,"ok"}
    case Sys.Completed{reader,Sys.Failed{world,ReadFailure{error,view}}}: Runtime{world,publisher,reader,cap,List.append(&2,View<S>,deliveries,[view]),rows,"failed:" ++ error}
    case Sys.RegistrationRejected{reader,world,_}: Runtime{world,publisher,reader,cap,deliveries,rows,"reader-registration-rejected"}
def read(~S: Data,runtime: Runtime<S>,fails: Bool) -> Runtime<S>:
  match runtime:
    case Runtime{world,publisher,reader,St.Reader{+namespace,+id},deliveries,rows,_}:
      read_returned(~S,publisher,St.Reader{namespace,id},deliveries,rows,Sys.run(~S,~P.Store<S>,~Resources<S>,~Unit,~ReadInput,~ReadFailure<S>,~View<S>,~(world => input => reader_runner(~S,world,input)),reader,frame(~S,world),ReadRequest{namespace,id,fails}))
def empty_frame(~S: Data,runtime: Runtime<S>) -> Runtime<S>:
  match runtime:
    case Runtime{world,publisher,reader,cap,deliveries,rows,status}: Runtime{frame(~S,world),publisher,reader,cap,deliveries,rows,status}
def loop(~S: Data,count: Nat,runtime: Runtime<S>) -> Runtime<S>:
  match count:
    case 0n: runtime
    case 1n+rest: loop(~S,rest,publish(~S,runtime,Publish{}))

type Provision<S: Data> is Type:
  Provisioned{runtime: Runtime<S>}
  PublisherRejected{world: W.World<S,P.Store<S>,Resources<S>,Unit>}
  ReaderRejected{world: W.World<S,P.Store<S>,Resources<S>,Unit>,publisher: Sys.Registry<S,P.Store<S>,Resources<S>,Unit,Input,String,Unit,(world => input => publisher_runner(~S,world,input))>}
def provisioned_identity(~S: Data,publisher: Sys.Registry<S,P.Store<S>,Resources<S>,Unit,Input,String,Unit,(world => input => publisher_runner(~S,world,input))>,world: W.World<S,P.Store<S>,Resources<S>,Unit>,namespace: U32,pair: Sys.Registry<S,P.Store<S>,Resources<S>,Unit,ReadInput,ReadFailure<S>,View<S>,(world => input => reader_runner(~S,world,input))> & U32) -> Provision<S>:
  match pair:
    case (reader,id): Provisioned{Runtime{world,publisher,reader,St.Reader{namespace,id},[],[],"ok"}}
def provisioned_named(~S: Data,publisher: Sys.Registry<S,P.Store<S>,Resources<S>,Unit,Input,String,Unit,(world => input => publisher_runner(~S,world,input))>,named: W.World<S,P.Store<S>,Resources<S>,Unit> & U32,pair: Sys.Registry<S,P.Store<S>,Resources<S>,Unit,ReadInput,ReadFailure<S>,View<S>,(world => input => reader_runner(~S,world,input))> & U32) -> Provision<S>:
  match named:
    case (world,namespace): provisioned_identity(~S,publisher,world,namespace,pair)
def reader_registered(~S: Data,publisher: Sys.Registry<S,P.Store<S>,Resources<S>,Unit,Input,String,Unit,(world => input => publisher_runner(~S,world,input))>,result: Sys.RegistrationResult<S,P.Store<S>,Resources<S>,Unit,ReadInput,ReadFailure<S>,View<S>,(world => input => reader_runner(~S,world,input))>) -> Provision<S>:
  match result:
    case Sys.Registered{world,reader}: provisioned_named(~S,publisher,W.namespace(~S,~P.Store<S>,~Resources<S>,~Unit,world),Sys.identity(~S,~P.Store<S>,~Resources<S>,~Unit,~ReadInput,~ReadFailure<S>,~View<S>,~(world => input => reader_runner(~S,world,input)),reader))
    case Sys.RegistrationFailed{world}: ReaderRejected{world,publisher}
def publisher_registered(~S: Data,result: Sys.RegistrationResult<S,P.Store<S>,Resources<S>,Unit,Input,String,Unit,(world => input => publisher_runner(~S,world,input))>) -> Provision<S>:
  match result:
    case Sys.Registered{world,publisher}: reader_registered(~S,publisher,Sys.register(~S,~P.Store<S>,~Resources<S>,~Unit,~ReadInput,~ReadFailure<S>,~View<S>,~(world => input => reader_runner(~S,world,input)),world,"reader",["transition.Flow.read"]))
    case Sys.RegistrationFailed{world}: PublisherRejected{world}
def provision(~S: Data,world: W.World<S,P.Store<S>,Resources<S>,Unit>) -> Provision<S>:
  publisher_registered(~S,Sys.register(~S,~P.Store<S>,~Resources<S>,~Unit,~Input,~String,~Unit,~(world => input => publisher_runner(~S,world,input)),world,"publisher",["machine.Flow.read","machine.Flow.next","component.cells.write","commands.spawn"]))

def resources_view_returned(~S: Data,pair: Array<U32> & String,+slot: M.Slot<S,P.FlowToken,U32>,+stream: St.Stream<U32>,+frame: Nat,+tick: Nat,+error: Maybe<&2,String>) -> Resources<S> & String:
  (owned,text)=pair
  (Resources{owned,slot,stream,frame,tick,error},"owned=" ++ text ++ ";flow=" ++ O.slot(~S,~P.FlowToken,~U32,~U32.show,slot) ++ ";flowStream=" ++ O.stream(~U32,~U32.show,stream) ++ ";frame=" ++ Nat.show(frame) ++ ";tick=" ++ Nat.show(tick) ++ ";error=" ++ O.previous(~String,~O.text,error))
def resources_view(~S: Data,resources: Resources<S>) -> Resources<S> & String:
  match resources:
    case Resources{owned,slot,stream,frame,tick,error}: resources_view_returned(~S,O.owner_view(owned),slot,stream,frame,tick,error)
def world_view_returned(~S: Data,+ns: U32,+next: U32,+high: U32,+capacity: U32,+depth: Nat,livePair: Array<Bool> & List<&2,Bool>,storePair: P.Store<S> & String,resourcePair: Resources<S> & String,+events: List<&2,Unit>,commandPair: List<&1,(W.World<S,P.Store<S>,Resources<S>,Unit> -> W.World<S,P.Store<S>,Resources<S>,Unit>)> & Nat,+registrations: List<&2,W.RegistrationMeta>,+nextSystem: U32,+clock: U32) -> W.World<S,P.Store<S>,Resources<S>,Unit> & String:
  (live,liveValues)=livePair
  (store,cells)=storePair
  (resources,text)=resourcePair
  (commands,commandCount)=commandPair
  (W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock},"ns=" ++ U32.show(ns) ++ ";next=" ++ U32.show(next) ++ ";high=" ++ U32.show(high) ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";live=" ++ List.show(&2,Bool,O.bool,liveValues) ++ ";cells=" ++ cells ++ ";" ++ text ++ ";queue=" ++ Nat.show(commandCount) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,O.registration,registrations) ++ ";nextSystem=" ++ U32.show(nextSystem) ++ ";componentClock=" ++ U32.show(clock) ++ ";busEvents=" ++ Nat.show(List.length(&2,Unit,events)))
def world_view(~S: Data,world: W.World<S,P.Store<S>,Resources<S>,Unit>) -> W.World<S,P.Store<S>,Resources<S>,Unit> & String:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock}:
      world_view_returned(~S,ns,next,high,capacity,depth,O.live_view(live),O.store_view(~S,store),resources_view(~S,resources),events,O.queue_view(~W.World<S,P.Store<S>,Resources<S>,Unit>,commands),registrations,nextSystem,clock)
def show_view(~S: Data,view: View<S>) -> String:
  match view:
    case View{values,lagged}: "values=" ++ List.show(&2,M.Transition<U32>,value => O.transition(~U32,~U32.show,value),values) ++ ",lagged=" ++ O.bool(lagged)
def publisher_view(~S: Data,registry: Sys.Registry<S,P.Store<S>,Resources<S>,Unit,Input,String,Unit,(world => input => publisher_runner(~S,world,input))>) -> Sys.Registry<S,P.Store<S>,Resources<S>,Unit,Input,String,Unit,(world => input => publisher_runner(~S,world,input))> & String:
  match registry:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}: (Sys.Registry{ns,id,name,access,cursor},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,O.text,access) ++ ":" ++ U32.show(cursor))
def reader_view(~S: Data,registry: Sys.Registry<S,P.Store<S>,Resources<S>,Unit,ReadInput,ReadFailure<S>,View<S>,(world => input => reader_runner(~S,world,input))>) -> Sys.Registry<S,P.Store<S>,Resources<S>,Unit,ReadInput,ReadFailure<S>,View<S>,(world => input => reader_runner(~S,world,input))> & String:
  match registry:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}: (Sys.Registry{ns,id,name,access,cursor},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,O.text,access) ++ ":" ++ U32.show(cursor))
def checkpoint_returned(~S: Data,label: String,+status: String,cap: St.Reader<S,P.FlowToken>,+deliveries: List<&2,View<S>>,rows: List<&2,String>,worldPair: W.World<S,P.Store<S>,Resources<S>,Unit> & String,publisherPair: Sys.Registry<S,P.Store<S>,Resources<S>,Unit,Input,String,Unit,(world => input => publisher_runner(~S,world,input))> & String,readerPair: Sys.Registry<S,P.Store<S>,Resources<S>,Unit,ReadInput,ReadFailure<S>,View<S>,(world => input => reader_runner(~S,world,input))> & String) -> Runtime<S>:
  match cap:
    case St.Reader{+ns,+id}:
      (world,w)=worldPair
      (publisher,p)=publisherPair
      (reader,r)=readerPair
      Runtime{world,publisher,reader,St.Reader{ns,id},deliveries,List.append(&2,String,rows,[label ++ "|" ++ status ++ "|" ++ w ++ ";publisherOwner=" ++ p ++ ";readerOwner=" ++ r ++ ";readerCap=" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ";deliveries=" ++ List.show(&2,View<S>,value => show_view(~S,value),deliveries)]),status}
def checkpoint(~S: Data,label: String,runtime: Runtime<S>) -> Runtime<S>:
  match runtime:
    case Runtime{world,publisher,reader,cap,deliveries,rows,status}: checkpoint_returned(~S,label,status,cap,deliveries,rows,world_view(~S,world),publisher_view(~S,publisher),reader_view(~S,reader))
def execute(~S: Data,count: Nat,runtime: Runtime<S>) -> Runtime<S>:
  runtime=checkpoint(~S,"initial",publish(~S,runtime,Seed{}))
  runtime=checkpoint(~S,"activated-failed",read(~S,runtime,True{}))
  runtime=checkpoint(~S,"65537-published",loop(~S,count,runtime))
  runtime=checkpoint(~S,"capacity-frame",empty_frame(~S,runtime))
  runtime=checkpoint(~S,"overflow-failed-reader",read(~S,runtime,True{}))
  runtime=checkpoint(~S,"overflow-successful-retry",read(~S,runtime,False{}))
  checkpoint(~S,"empty-repeat",read(~S,runtime,False{}))
def finish(~S: Data,runtime: Runtime<S>) -> String:
  match runtime:
    case Runtime{_,_,_,_,_,rows,_}: String.join(rows,"\n")
