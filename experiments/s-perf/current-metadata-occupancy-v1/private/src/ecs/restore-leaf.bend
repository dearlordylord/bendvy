import Base
import ./persistence-declaration.bend as Persistence
import ./restore-data.bend as R
import ./decode-data.bend as D
import ./decode-construction.bend as Constructor
import ./bundle-construction.bend as Build
import ./ordinary-declaration.bend as Identity

type Record<I:Type,P:Type> is Type:
  Record{position:R.Position,owner:P,undo:P -> I}
type Applied<I:Type,P:Type> is Type:
  Applied{position:R.Position,undo:P -> I}
type State<Context:Type,I:Type,P:Type> is Type:
  State{context:Context,records:List<Record<I,P>>,returned:List<I>,removed:List<P>,applied:List<Applied<I,P>>}
type FamilyKind is Data:Component{} Resource{}
def same_kind(kind:FamilyKind,position:R.Position) -> Bool:
  match kind position:
    case Component{} R.Component{_}:True{}
    case Resource{} R.Resource{}:True{}
    case _ _:False{}
def constructed(~Context:Type,~I:Type,~P:Type,~Custom:Data,position:R.Position,records:List<Record<I,P>>,returned:List<I>,removed:List<P>,applied:List<Applied<I,P>>,context:Context,result:Build.Construction<I,P,Constructor.Error<Custom>>) -> State<Context,I,P> & R.Dispatch<Custom>:
  match result:
    case Build.Invalid{owner,error}:(State{context,records,List.append(&1,I,returned,[owner]),removed,applied},R.Rejected{error})
    case Build.Constructed{owner,undo}:(State{context,Record{position,owner,undo} <> records,returned,removed,applied},R.Staged{})
def stored(~I:Type,~P:Type,~Custom:Data,undo:P -> I,receipt:D.Receipt<P>) -> Build.Construction<I,P,Constructor.Error<Custom>>:
  match receipt:
    case D.Receipt{owner,D.Accepted{_}}:Build.Constructed{owner,undo}
    case D.Receipt{owner,D.Rejected{error}}:Build.Invalid{undo(owner),Constructor.Validation{error}}
def admitted(~S:Data,~I:Type,~P:Type,~Custom:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Persistence.Constructed<S,P,identity,project>,result:Build.Construction<I,P,Constructor.Error<Custom>>) -> Build.Construction<I,P,Constructor.Error<Custom>>:
  match result:
    case Build.Invalid{owner,error}:Build.Invalid{owner,error}
    case Build.Constructed{owner,undo}:stored(~I,~P,~Custom,undo,Persistence.validate(~S,~P,~identity,~project,declaration,owner))
def declaration(~S:Data,~I:Type,~P:Type,~Custom:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,Custom>,factory:Constructor.FallibleFactory<S,I,P,Custom,identity,project,incoming,build>) -> Persistence.Constructed<S,P,identity,project>:
  match factory:
    case Constructor.FallibleFactory{declaration,_}:declaration
def supplied(~S:Data,~Context:Type,~I:Type,~P:Type,~Custom:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,Custom>,~factory:Constructor.FallibleFactory<S,I,P,Custom,identity,project,incoming,build>,position:R.Position,records:List<Record<I,P>>,returned:List<I>,removed:List<P>,applied:List<Applied<I,P>>,observed:Context & I) -> State<Context,I,P> & R.Dispatch<Custom>:
  match observed:
    case (context,input):constructed(~Context,~I,~P,~Custom,position,records,returned,removed,applied,context,admitted(~S,~I,~P,~Custom,~identity,~project,declaration(~S,~I,~P,~Custom,~identity,~project,~incoming,~build,factory),Constructor.fallible_construct(~S,~I,~P,~Custom,~identity,~project,~incoming,~build,factory,input)))
def selected(~S:Data,~Context:Type,~I:Type,~P:Type,~Custom:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,Custom>,~factory:Constructor.FallibleFactory<S,I,P,Custom,identity,project,incoming,build>,~supply:Context -> D.Raw -> Context & I,matches:Bool,state:State<Context,I,P>,position:R.Position,field:D.Field) -> State<Context,I,P> & R.Dispatch<Custom>:
  match matches state field:
    case False{} state _:(state,R.Unhandled{})
    case True{} State{context,records,returned,removed,applied} D.Field{_,raw}:supplied(~S,~Context,~I,~P,~Custom,~identity,~project,~incoming,~build,~factory,position,records,returned,removed,applied,supply(context,raw))
def stage(~S:Data,~Context:Type,~I:Type,~P:Type,~Custom:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,Custom>,~factory:Constructor.FallibleFactory<S,I,P,Custom,identity,project,incoming,build>,~supply:Context -> D.Raw -> Context & I,~kind:FamilyKind,state:State<Context,I,P>,+position:R.Position,+field:D.Field) -> State<Context,I,P> & R.Dispatch<Custom>:
  match field:
    case D.Field{+name,+raw}:selected(~S,~Context,~I,~P,~Custom,~identity,~project,~incoming,~build,~factory,~supply,Bool.and(same_kind(kind,position),String.eq(name,Identity.key(~S,~P,identity))),state,position,D.Field{name,raw})
def released(~I:Type,~P:Type,head:I,rest:List<I>) -> List<I>:
  List.append(&1,I,rest,[head])
def release_records(~I:Type,~P:Type,records:List<Record<I,P>>,returned:List<I>) -> List<I>:
  match records:
    case []:returned
    case Record{_,owner,undo} <> rest:release_records(~I,~P,rest,undo(owner) <> returned)
def release(~Context:Type,~I:Type,~P:Type,state:State<Context,I,P>) -> State<Context,I,P>:
  match state:
    case State{context,records,returned,removed,applied}:State{context,[],release_records(~I,~P,records,returned),removed,applied}
def empty(~Context:Type,~I:Type,~P:Type,context:Context) -> State<Context,I,P>:
  State{context,[],[],[],[]}
def commit(~Context:Type,~I:Type,~P:Type,state:State<Context,I,P>) -> State<Context,I,P>:
  match state:
    case State{context,_,_,_,_}:State{context,[],[],[],[]}
def take_recovery(~Context:Type,~I:Type,~P:Type,state:State<Context,I,P>) -> State<Context,I,P> & List<I>:
  match state:
    case State{context,records,returned,removed,applied}:(State{context,records,[],removed,applied},returned)
