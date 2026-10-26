import Base
import ./execution-lifecycle-notices.bend as Notice
import ./clock-state.bend as Clock
import ./deferred-command.bend as Deferred
import entity-key.bend as Key
import entity-allocator.bend as Alloc
import ./world.bend as W
import ./column.bend as Col
import ./component.bend as C
import ./lifecycle.bend as Life
# Canonical single-column provider. No caller-authored take/put/project.
type Tag is Data:Tag{}
def take(~S:Data,~P:Type,column:Col.Column<S,P>) -> Unit & Col.Column<S,P>:(Unit{},column)
def put(~S:Data,~P:Type,unit:Unit,column:Col.Column<S,P>) -> Col.Column<S,P>:column
def project(~P:Type,payload:P) -> P & Unit:(payload,Unit{})
type Record<S:Data,P:Type> is Type:
  Record{handle:W.Handle<S>,stamp:Life.Stamp,payload:Maybe<P>}
type Replacement<World:Type,S:Data,P:Type> is Type:
  Applied{world:World,previous:Record<S,P>}
  Refused{world:World,incoming:Maybe<P>,error:W.WorldError}
def family(~S:Data,~P:Type,~R:Type,~E:Data,name:String) -> C.Family<S,Col.Column<S,P>,Unit,P,Unit,Tag,take(~S,~P),put(~S,~P),project(~P)>:
  C.Family{name}
def replaced(~S:Data,~P:Type,~R:Type,~E:Data,handle:W.Handle<S>,stamp:Life.Stamp,result:C.Replacement<W.World<S,Col.Column<S,P>,R,E>,P>) -> Replacement<W.World<S,Col.Column<S,P>,R,E>,S,P>:
  match result:
    case C.Replaced{world,previous}:Applied{world,Record{handle,stamp,previous}}
    case C.ReplaceRejected{world,incoming,error}:Refused{world,incoming,error}
def stamped(~S:Data,~P:Type,~R:Type,~E:Data,name:String,+handle:W.Handle<S>,incoming:Maybe<P>,observed:W.World<S,Col.Column<S,P>,R,E> & Life.Stamp) -> Replacement<W.World<S,Col.Column<S,P>,R,E>,S,P>:
  match observed:
    case (world,stamp):replaced(~S,~P,~R,~E,handle,stamp,C.replace(~S,~Col.Column<S,P>,~R,~E,~Unit,~P,~Unit,~Tag,~take(~S,~P),~put(~S,~P),~project(~P),family(~S,~P,~R,~E,name),world,handle,incoming))
def replace(~S:Data,~P:Type,~R:Type,~E:Data,+name:String,world:W.World<S,Col.Column<S,P>,R,E>,+handle:W.Handle<S>,incoming:Maybe<P>) -> Replacement<W.World<S,Col.Column<S,P>,R,E>,S,P>:
  stamped(~S,~P,~R,~E,name,handle,incoming,C.lifecycle(~S,~Col.Column<S,P>,~R,~E,~Unit,~P,~Unit,~Tag,~take(~S,~P),~put(~S,~P),~project(~P),family(~S,~P,~R,~E,name),world,handle))
def restored(~S:Data,~P:Type,+handle:W.Handle<S>,stamp:Life.Stamp,released:Life.Stamp,result:Col.SwapOutcome<S,P>) -> Col.Column<S,P> & Record<S,P>:
  match handle result:
    case W.Handle{_,Key.EntityKey{id,_}},Col.Accepted{column,payload}:(Col.restore_stamp(~S,~P,column,id,stamp),Record{handle,released,payload})
    # For a saved ordinary record, ensure covers its positive live id, hence
    # swap accepts. Raw rejection returns the untouched incoming owner/record;
    # it does not claim that a different payload was displaced.
    case W.Handle{_,Key.EntityKey{id,_}},Col.Rejected{column,payload}:(column,Record{handle,stamp,payload})
def undo_stamped(~S:Data,~P:Type,+handle:W.Handle<S>,stamp:Life.Stamp,payload:Maybe<P>,observed:Col.Column<S,P> & Life.Stamp) -> Col.Column<S,P> & Record<S,P>:
  match handle observed:
    case W.Handle{_,Key.EntityKey{+id,_}}, (column,released):restored(~S,~P,handle,stamp,released,Col.swap(~S,~P,Col.ensure(~S,~P,column,id),id,payload))
def undo_column(~S:Data,~P:Type,+handle:W.Handle<S>,stamp:Life.Stamp,payload:Maybe<P>,column:Col.Column<S,P>) -> Col.Column<S,P> & Record<S,P>:
  match handle:
    case W.Handle{_,Key.EntityKey{id,_}}:undo_stamped(~S,~P,handle,stamp,payload,Col.lifecycle(~S,~P,column,id))
def undone(~S:Data,~P:Type,~R:Type,~E:Data,ns:U32,allocator:Alloc.Allocator,resource:R,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,Col.Column<S,P>,R,E>>>,regs:List<&2,W.RegistrationMeta>,sid:U32,clock:Clock.State,result:Col.Column<S,P> & Record<S,P>,lifecycle:Notice.Journal<S>) -> W.World<S,Col.Column<S,P>,R,E> & Record<S,P>:
  match result:
    case (column,record):(W.World{ns,allocator,column,resource,events,pending,regs,sid,clock,lifecycle},record)
# Trusted inverse: ordinary grants never alter allocation/live state or inject
# records. Canonical ensure preserves every cell and covers the saved live id;
# undo restores its exact stamp and returns the displaced owner with its own
# pre-undo stamp. World clock and every unrelated owner remain unchanged.
def undo_valid(~S:Data,~P:Type,~R:Type,~E:Data,record:Record<S,P>,world:W.World<S,Col.Column<S,P>,R,E>) -> W.World<S,Col.Column<S,P>,R,E> & Record<S,P>:
  match record world:
    case Record{handle,stamp,payload},W.World{ns,allocator,column,resource,events,pending,regs,sid,clock,lifecycle}:
      undone(~S,~P,~R,~E,ns,allocator,resource,events,pending,regs,sid,clock,undo_column(~S,~P,handle,stamp,payload,column),lifecycle)

# Invalid raw records remain intact; ordinary journal records use the accepted
# path because component operations cannot change namespace or entity liveness.
def undo_checked(~S:Data,~P:Type,~R:Type,~E:Data,record:Record<S,P>,checked:W.World<S,Col.Column<S,P>,R,E> & Bool) -> W.World<S,Col.Column<S,P>,R,E> & Record<S,P>:
  match checked:
    case (world,False{}):(world,record)
    case (world,True{}):undo_valid(~S,~P,~R,~E,record,world)
def undo(~S:Data,~P:Type,~R:Type,~E:Data,record:Record<S,P>,world:W.World<S,Col.Column<S,P>,R,E>) -> W.World<S,Col.Column<S,P>,R,E> & Record<S,P>:
  match record:
    case Record{+handle,stamp,payload}:undo_checked(~S,~P,~R,~E,Record{handle,stamp,payload},W.valid(~S,~Col.Column<S,P>,~R,~E,world,handle))
