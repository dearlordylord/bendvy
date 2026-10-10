import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema-dump.bend as Presentation
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dump.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-population.bend as Population
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-filter.bend as Filter
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-access.bend as Access
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event.bend as EventOwner
# Sole World is inside Runtime; schema/operational owners/phantom recipe remain retained.
type Application<S:Data,C:Type,R:Type,E:Data,H:Type,Rows:Data,-observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,-fold:H -> H & List<&2,Records.Fields<S>>,Events:Type,-eventFold:Events -> Events & List<&2,Access.Entry>> is Type:
  Application{schema:Schema.Schema<S,C,R>,runtime:Ev.Runtime<S,C,R,E>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,events:Events,debug:Bool}
def empty_events(unit:Unit) -> Unit & List<&2,Access.Entry>:(unit,[])
def start(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,capacity:Nat,value:SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>) -> Application<S,C,R,E,H,Rows,observe,fold,Unit,empty_events>:
  match value:
    case SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}}:Application{schema,Ev.start(~S,~C,~R,~E,world,capacity),owners,recipe,Unit{},debug}
def enabled(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,app:Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold>,flag:Bool) -> Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold>:
  match app:
    case Application{schema,runtime,owners,recipe,events,_}:Application{schema,runtime,owners,recipe,events,flag}
def indexed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,schema:Schema.Schema<S,C,R>,runtime:Ev.Runtime<S,C,R,E>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,prior:H & List<&2,Records.Fields<S>>,eventResult:Events & List<&2,Access.Entry>) -> Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> & Maybe<&2,List<&2,Access.Entry>>:
  match prior eventResult:
    case (owners,records),(events,entries):(Application{schema,runtime,owners,recipe,events,True{}},Some{Access.grouped(List.append(&2,Access.Entry,Access.fields(~S,records),entries),[])})
def index(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,app:Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold>) -> Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> & Maybe<&2,List<&2,Access.Entry>>:
  match app:
    case Application{schema,runtime,owners,recipe,events,False{}}:(Application{schema,runtime,owners,recipe,events,False{}},None{})
    case Application{schema,runtime,owners,recipe,events,True{}}:indexed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Events,~eventFold,schema,runtime,recipe,fold(owners),eventFold(events))
def pair_second(~L:Type,~R:Type,left:L,before:List<&2,Access.Entry>,right:R & List<&2,Access.Entry>) -> (L & R) & List<&2,Access.Entry>:
  match right:
    case (right,after):((left,right),List.append(&2,Access.Entry,before,after))
def pair_first(~L:Type,~R:Type,~rightFold:R -> R & List<&2,Access.Entry>,right:R,left:L & List<&2,Access.Entry>) -> (L & R) & List<&2,Access.Entry>:
  match left:
    case (left,before):pair_second(~L,~R,left,before,rightFold(right))
def pair(~L:Type,~R:Type,~leftFold:L -> L & List<&2,Access.Entry>,~rightFold:R -> R & List<&2,Access.Entry>,events:L & R) -> (L & R) & List<&2,Access.Entry>:
  match events:
    case (left,right):pair_first(~L,~R,~rightFold,right,leftFold(left))
type ReaderLeaf<S:Data,E:Data,Registry:Type> is Type:
  ReaderLeaf{reader:Ev.Reader<S>,owner:EventOwner.Owner<S,E,Registry>}
def writer_entry_returned(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,result:EventOwner.Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>> & Maybe<&2,Access.Entry>) -> EventOwner.Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>> & List<&2,Access.Entry>:
  match result:
    case (owner,None{}):(owner,[])
    case (owner,Some{entry}):(owner,[entry])
def writer_entry(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,leaf:EventOwner.Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>>) -> EventOwner.Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>> & List<&2,Access.Entry>:
  match leaf:
    case EventOwner.Owner{declaration,registry,debug}:writer_entry_returned(~S,~C,~R,~E,~A,~Error,~O,~runner,EventOwner.described(~S,~C,~R,~E,~A,~Error,~O,~runner,declaration,registry,debug))
def reader_entry_returned(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,reader:Ev.Reader<S>,result:EventOwner.Owner<S,E,Sys.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>> & Maybe<&2,Access.Entry>) -> ReaderLeaf<S,E,Sys.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>> & List<&2,Access.Entry>:
  match result:
    case (owner,None{}):(ReaderLeaf{reader,owner},[])
    case (owner,Some{entry}):(ReaderLeaf{reader,owner},[entry])
def reader_entry(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,leaf:ReaderLeaf<S,E,Sys.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>>) -> ReaderLeaf<S,E,Sys.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>> & List<&2,Access.Entry>:
  match leaf:
    case ReaderLeaf{reader,EventOwner.Owner{declaration,registry,debug}}:reader_entry_returned(~S,~C,~R,~E,~A,~Error,~O,~runner,reader,EventOwner.described(~S,~C,~R,~E,~Ev.Input<E,A>,~Error,~O,~runner,declaration,registry,debug))
def writer_registered_world(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,result:EventOwner.WriterRegistered<S,C,R,E,A,Error,O,runner>) -> W.World<S,C,R,E> & Maybe<EventOwner.Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>>>:
  match result:
    case EventOwner.WriterFailed{world}:(world,None{})
    case EventOwner.WriterRegistered{world,owner}:(world,Some{owner})
def writer_appended(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,~Result:Type,done:Application<S,C,R,E,H,Rows,observe,fold,Events & EventOwner.Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>>,pair(~Events,~EventOwner.Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>>,~eventFold,~writer_entry(~S,~C,~R,~E,~A,~Error,~O,~runner))> -> Result,failed:Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> -> Result,schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,events:Events,debug:Bool,result:Ev.Runtime<S,C,R,E> & Maybe<EventOwner.Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>>>) -> Result:
  match result:
    case (runtime,None{}):failed(Application{schema,runtime,owners,recipe,events,debug})
    case (runtime,Some{owner}):done(Application{schema,runtime,owners,recipe,(events,owner),debug})
def register_writer(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,~Result:Type,done:Application<S,C,R,E,H,Rows,observe,fold,Events & EventOwner.Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>>,pair(~Events,~EventOwner.Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>>,~eventFold,~writer_entry(~S,~C,~R,~E,~A,~Error,~O,~runner))> -> Result,failed:Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> -> Result,app:Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold>,declaration:Event.Declaration<S,E>,name:String) -> Result:
  match app:
    case Application{schema,runtime,owners,recipe,events,debug}:writer_appended(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Events,~eventFold,~A,~Error,~O,~runner,~Result,done,failed,schema,owners,recipe,events,debug,Ev.with_world(~S,~C,~R,~E,~Maybe<EventOwner.Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>>>,world => writer_registered_world(~S,~C,~R,~E,~A,~Error,~O,~runner,EventOwner.register_writer(~S,~C,~R,~E,~A,~Error,~O,~runner,world,declaration,name)),runtime))
def reader_appended(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,~Result:Type,done:Application<S,C,R,E,H,Rows,observe,fold,Events & ReaderLeaf<S,E,Sys.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>>,pair(~Events,~ReaderLeaf<S,E,Sys.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>>,~eventFold,~reader_entry(~S,~C,~R,~E,~A,~Error,~O,~runner))> -> Result,failed:Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> -> Result,schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,events:Events,debug:Bool,result:EventOwner.ReaderRegistered<S,C,R,E,A,Error,O,runner>) -> Result:
  match result:
    case EventOwner.ReaderFailed{runtime}:failed(Application{schema,runtime,owners,recipe,events,debug})
    case EventOwner.ReaderRegistered{runtime,reader,owner}:done(Application{schema,runtime,owners,recipe,(events,ReaderLeaf{reader,owner}),debug})
def register_reader(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,~Result:Type,done:Application<S,C,R,E,H,Rows,observe,fold,Events & ReaderLeaf<S,E,Sys.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>>,pair(~Events,~ReaderLeaf<S,E,Sys.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>>,~eventFold,~reader_entry(~S,~C,~R,~E,~A,~Error,~O,~runner))> -> Result,failed:Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> -> Result,app:Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold>,declaration:Event.Declaration<S,E>,name:String) -> Result:
  match app:
    case Application{schema,runtime,owners,recipe,events,debug}:reader_appended(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Events,~eventFold,~A,~Error,~O,~runner,~Result,done,failed,schema,owners,recipe,events,debug,EventOwner.register_reader(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,declaration,name))

type Previous<S:Data,C:Type,R:Type,E:Data,H:Type,Rows:Data,-observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,Out:Type> is Type:
  Previous{schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,output:Out}
def previous_finished(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Out:Type,result:SchemaApp.Application<S,C,R,E,H,Rows,observe,fold> & Out) -> W.World<S,C,R,E> & Previous<S,C,R,E,H,Rows,observe,Out>:
  match result:
    case (SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},output):(world,Previous{schema,owners,recipe,debug,output})
def previous_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,~Out:Type,events:Events,result:Ev.Runtime<S,C,R,E> & Previous<S,C,R,E,H,Rows,observe,Out>) -> Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> & Out:
  match result:
    case (runtime,Previous{schema,owners,recipe,debug,output}):(Application{schema,runtime,owners,recipe,events,debug},output)
def with_previous(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,~Out:Type,action:SchemaApp.Application<S,C,R,E,H,Rows,observe,fold> -> SchemaApp.Application<S,C,R,E,H,Rows,observe,fold> & Out,app:Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold>) -> Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> & Out:
  match app:
    case Application{schema,runtime,owners,recipe,events,debug}:previous_returned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Events,~eventFold,~Out,events,Ev.with_world(~S,~C,~R,~E,~Previous<S,C,R,E,H,Rows,observe,Out>,world => previous_finished(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Out,action(SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}})),runtime))
def AfterWriter(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,Error,O>) -> Type:Application<S,C,R,E,H,Rows,observe,fold,Events & EventOwner.Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>>,pair(~Events,~EventOwner.Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>>,~eventFold,~writer_entry(~S,~C,~R,~E,~A,~Error,~O,~runner))>
def AfterReader(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>) -> Type:Application<S,C,R,E,H,Rows,observe,fold,Events & ReaderLeaf<S,E,Sys.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>>,pair(~Events,~ReaderLeaf<S,E,Sys.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>>,~eventFold,~reader_entry(~S,~C,~R,~E,~A,~Error,~O,~runner))>

# Trusted internal action bridge: its arbitrary callback type does not imply read-only behavior.
# Ordinary population/dump use only the concrete qualified generated observations.
def internal_observation_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,~Out:Type,namespace:U32,batches:List<&2,Ev.Batch<E>>,positions:List<&2,Ev.Position>,nextReader:U32,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,dropped:Nat,events:Events,result:SchemaApp.Application<S,C,R,E,H,Rows,observe,fold> & Out) -> Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> & Out:
  match result:
    case (SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},output):(Application{schema,Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},owners,recipe,events,debug},output)
def internal_observation_runtime(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,~Out:Type,schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,events:Events,debug:Bool,action:SchemaApp.Application<S,C,R,E,H,Rows,observe,fold> -> SchemaApp.Application<S,C,R,E,H,Rows,observe,fold> & Out,runtime:Ev.Runtime<S,C,R,E>) -> Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> & Out:
  match runtime:
    case Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped}:internal_observation_returned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Events,~eventFold,~Out,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,events,action(SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}}))
def internal_observation(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,~Out:Type,action:SchemaApp.Application<S,C,R,E,H,Rows,observe,fold> -> SchemaApp.Application<S,C,R,E,H,Rows,observe,fold> & Out,app:Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold>) -> Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> & Out:
  match app:
    case Application{schema,runtime,owners,recipe,events,debug}:internal_observation_runtime(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Events,~eventFold,~Out,schema,owners,recipe,events,debug,action,runtime)
def population(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~components:C -> U32 -> C & List<&2,Maybe<&2,String>>,~resources:R -> R & List<&2,Maybe<&2,String>>,presentation:Presentation.Recipe<S,C,R,count,components,resources>,app:Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold>) -> Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> & Maybe<&2,Population.Population>:
  match presentation:
    case Presentation.Recipe{}:internal_observation(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Events,~eventFold,~Maybe<&2,Population.Population>,value => Population.schema_population(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~count,value),app)
def dump(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~components:C -> U32 -> C & List<&2,Maybe<&2,String>>,~resources:R -> R & List<&2,Maybe<&2,String>>,presentation:Presentation.Recipe<S,C,R,count,components,resources>,criteria:Filter.Filter<S>,app:Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold>) -> Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> & Maybe<&2,Dump.Dump<S>>:
  match presentation:
    case Presentation.Recipe{}:internal_observation(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Events,~eventFold,~Maybe<&2,Dump.Dump<S>>,value => Dump.schema_snapshot(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~count,~components,~resources,criteria,value),app)

# Descriptive values only. Position.id is the actual Reader ID, not a Registry ID.
type RuntimeView<E:Data> is Data:
  RuntimeView{namespace:U32,batches:List<&2,Ev.Batch<E>>,positions:List<&2,Ev.Position>,nextReader:U32,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,droppedThrough:Nat,log:List<&2,E>}
def runtime_view_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,events:Events,+namespace:U32,+batches:List<&2,Ev.Batch<E>>,+positions:List<&2,Ev.Position>,+nextReader:U32,+tick:Nat,+frameStart:Nat,+boundary:Nat,+capacity:Nat,+dropped:Nat,result:W.World<S,C,R,E> & List<&2,E>) -> Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> & Maybe<&2,RuntimeView<E>>:
  match result:
    case (world,log):(Application{schema,Ev.Runtime{world,namespace,batches,positions,nextReader,1n+tick,frameStart,boundary,capacity,dropped},owners,recipe,events,True{}},Some{RuntimeView{namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,log}})
def runtime_view_enabled(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,events:Events,runtime:Ev.Runtime<S,C,R,E>) -> Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> & Maybe<&2,RuntimeView<E>>:
  match runtime:
    case Ev.Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}:runtime_view_returned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Events,~eventFold,schema,owners,recipe,events,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,W.events_view(~S,~C,~R,~E,world))
def runtime_view(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,app:Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold>) -> Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> & Maybe<&2,RuntimeView<E>>:
  match app:
    case Application{schema,runtime,owners,recipe,events,False{}}:(Application{schema,runtime,owners,recipe,events,False{}},None{})
    case Application{schema,runtime,owners,recipe,events,True{}}:runtime_view_enabled(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Events,~eventFold,schema,owners,recipe,events,runtime)
def runtime_batch_u32(batch:Ev.Batch<U32>) -> String:
  match batch:
    case Ev.Batch{tick,values}:Nat.show(tick) ++ ":" ++ List.show(~&2,~U32,~U32.show,values)
def runtime_position(position:Ev.Position) -> String:
  match position:
    case Ev.Position{id,cursor,registeredAt}:"Reader" ++ U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(registeredAt)
def runtime_text_u32(view:Maybe<&2,RuntimeView<U32>>) -> String:
  match view:
    case None{}:"runtime=None"
    case Some{RuntimeView{namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,log}}:"runtime=namespace:" ++ U32.show(namespace) ++ ";batches:" ++ List.show(~&2,~Ev.Batch<U32>,~runtime_batch_u32,batches) ++ ";readers:" ++ List.show(~&2,~Ev.Position,~runtime_position,positions) ++ ";nextReader:" ++ U32.show(nextReader) ++ ";tick:" ++ Nat.show(tick) ++ ";frameStart:" ++ Nat.show(frameStart) ++ ";boundary:" ++ Nat.show(boundary) ++ ";capacity:" ++ Nat.show(capacity) ++ ";droppedThrough:" ++ Nat.show(dropped) ++ ";log:" ++ List.show(~&2,~U32,~U32.show,log)
