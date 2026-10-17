import Base
import ./decode-data.bend as D
import ./restore-graph-data.bend as R
import ./ordinary-machine-declaration.bend as Ordinary
import ./ordinary-machine-initialization.bend as Init
import ./machine.bend as M
import ./machine-stream.bend as Stream
import ./machine-stream-queue.bend as Queue
import ./owner-product.bend as Product

type Dispatch is Data:Unhandled{} Valid{} Invalid{}
type Schema<-Resources:Type,-read:Resources -> Resources & List<&2,D.Field>,-check:D.Field -> Dispatch,-clear:Resources -> Resources,-install:Resources -> List<&2,D.Field> -> Resources> is Data:
  Schema{}
def take_slot(~S:Data,~K:Data,~V:Data,state:Init.State<S,K,V>) -> Init.State<S,K,V> & M.Slot<S,K,V>:
  Init.slot(~S,~K,~V,state)
def cleared_stream(~V:Data,value:Stream.Stream<V>) -> Stream.Stream<V>:
  match value:
    case Stream.Stream{Queue.Queue{_,_,_,dropped,_},positions,frameStart}:Stream.Stream{Queue.Queue{[],[],0n,dropped,0n},positions,frameStart}
def clear(~S:Data,~K:Data,~V:Data,state:Init.State<S,K,V>) -> Init.State<S,K,V>:
  match state:
    case Init.State{slot,stream,revision}:Init.State{M.reset(~S,~K,~V,slot),cleared_stream(~V,stream),revision}
def encoded(~S:Data,~K:Data,~V:Data,~encode:V -> D.Raw,name:String,slot:M.Slot<S,K,V>) -> List<&2,D.Field>:
  match slot:
    case M.Missing{}:[]
    case M.Present{value,_,_,_}:[D.Field{name,encode(value)}]
def read(~S:Data,~K:Data,~V:Data,~encode:V -> D.Raw,~DeclaredOwner:Type,~take:DeclaredOwner -> DeclaredOwner & M.Slot<S,K,V>,~declaration:Ordinary.Declaration<S,K,V,DeclaredOwner,take>,state:Init.State<S,K,V>) -> Init.State<S,K,V> & List<&2,D.Field>:
  match state:
    case Init.State{+slot,+stream,+revision}:(Init.State{slot,stream,revision},encoded(~S,~K,~V,~encode,Ordinary.name(~S,~K,~V,~DeclaredOwner,~take,declaration),slot))
def member(~V:Data,~same:V -> V -> Bool,+value:V,values:List<&2,V>) -> Bool:
  match values:
    case []:False{}
    case other <> rest:Bool.or(same(value,other),member(~V,~same,value,rest))
def permitted(~V:Data,~same:V -> V -> Bool,value:V,values:Maybe<&2,List<&2,V>>) -> Bool:
  match values:
    case None{}:True{}
    case Some{values}:member(~V,~same,value,values)
def selected(value:Bool) -> Dispatch:
  match value:
    case True{}:Valid{}
    case False{}:Invalid{}
def decoded(~V:Data,~same:V -> V -> Bool,values:Maybe<&2,List<&2,V>>,value:Maybe<&2,V>) -> Dispatch:
  match value:
    case None{}:Invalid{}
    case Some{value}:selected(permitted(~V,~same,value,values))
def checked(~V:Data,~decode:D.Raw -> Maybe<&2,V>,~same:V -> V -> Bool,values:Maybe<&2,List<&2,V>>,result:D.Checked) -> Dispatch:
  match result:
    case D.Rejected{_}:Invalid{}
    case D.Accepted{raw}:decoded(~V,~same,values,decode(raw))
def named(~V:Data,~decode:D.Raw -> Maybe<&2,V>,~same:V -> V -> Bool,found:Bool,values:Maybe<&2,List<&2,V>>,+raw:D.Raw,codec:D.Codec) -> Dispatch:
  match found:
    case False{}:Unhandled{}
    case True{}:checked(~V,~decode,~same,values,D.validate(100000n,D.Continue{[D.Work{codec,raw,"$"}]},raw))
def check(~S:Data,~K:Data,~V:Data,~codec:D.Codec,~decode:D.Raw -> Maybe<&2,V>,~same:V -> V -> Bool,~DeclaredOwner:Type,~take:DeclaredOwner -> DeclaredOwner & M.Slot<S,K,V>,~declaration:Ordinary.Declaration<S,K,V,DeclaredOwner,take>,field:D.Field) -> Dispatch:
  match field:
    case D.Field{name,raw}:named(~V,~decode,~same,String.eq(name,Ordinary.name(~S,~K,~V,~DeclaredOwner,~take,declaration)),Ordinary.values(~S,~K,~V,~DeclaredOwner,~take,declaration),raw,codec)
def installed(~S:Data,~K:Data,~V:Data,state:Init.State<S,K,V>,value:V) -> Init.State<S,K,V>:
  match state:
    case Init.State{slot,stream,revision}:Init.State{Init.insertion_slot(~S,~K,~V,value,M.reset(~S,~K,~V,slot)),cleared_stream(~V,stream),1n+revision}
def decoded_install(~S:Data,~K:Data,~V:Data,state:Init.State<S,K,V>,value:Maybe<&2,V>) -> Init.State<S,K,V>:
  match value:
    case None{}:state
    case Some{value}:installed(~S,~K,~V,state,value)
def install_named(~S:Data,~K:Data,~V:Data,~decode:D.Raw -> Maybe<&2,V>,found:Bool,state:Init.State<S,K,V>,raw:D.Raw) -> Init.State<S,K,V>:
  match found:
    case False{}:state
    case True{}:decoded_install(~S,~K,~V,state,decode(raw))
def install_loop(~S:Data,~K:Data,~V:Data,~decode:D.Raw -> Maybe<&2,V>,~DeclaredOwner:Type,~take:DeclaredOwner -> DeclaredOwner & M.Slot<S,K,V>,~declaration:Ordinary.Declaration<S,K,V,DeclaredOwner,take>,values:List<&2,D.Field>,state:Init.State<S,K,V>) -> Init.State<S,K,V>:
  match values:
    case []:state
    case D.Field{name,raw} <> rest:install_loop(~S,~K,~V,~decode,~DeclaredOwner,~take,~declaration,rest,install_named(~S,~K,~V,~decode,String.eq(name,Ordinary.name(~S,~K,~V,~DeclaredOwner,~take,declaration)),state,raw))
def install(~S:Data,~K:Data,~V:Data,~decode:D.Raw -> Maybe<&2,V>,~DeclaredOwner:Type,~take:DeclaredOwner -> DeclaredOwner & M.Slot<S,K,V>,~declaration:Ordinary.Declaration<S,K,V,DeclaredOwner,take>,state:Init.State<S,K,V>,values:List<&2,D.Field>) -> Init.State<S,K,V>:
  install_loop(~S,~K,~V,~decode,~DeclaredOwner,~take,~declaration,values,state)
def machine(~S:Data,~K:Data,~V:Data,~codec:D.Codec,~encode:V -> D.Raw,~decode:D.Raw -> Maybe<&2,V>,~same:V -> V -> Bool,~DeclaredOwner:Type,~take:DeclaredOwner -> DeclaredOwner & M.Slot<S,K,V>,~declaration:Ordinary.Declaration<S,K,V,DeclaredOwner,take>) -> Schema<Init.State<S,K,V>,read(~S,~K,~V,~encode,~DeclaredOwner,~take,~declaration),check(~S,~K,~V,~codec,~decode,~same,~DeclaredOwner,~take,~declaration),clear(~S,~K,~V),install(~S,~K,~V,~decode,~DeclaredOwner,~take,~declaration)>:
  Schema{}
def joined_read(~L:Type,~Right:Type,left:L,leftFields:List<&2,D.Field>,result:Right & List<&2,D.Field>) -> Product.Owner<L,Right> & List<&2,D.Field>:
  match result:
    case (right,rightFields):(Product.Owner{left,right},List.append(&2,D.Field,leftFields,rightFields))
def left_read(~L:Type,~Right:Type,~readRight:Right -> Right & List<&2,D.Field>,right:Right,result:L & List<&2,D.Field>) -> Product.Owner<L,Right> & List<&2,D.Field>:
  match result:
    case (left,fields):joined_read(~L,~Right,left,fields,readRight(right))
def product_read(~L:Type,~Right:Type,~readLeft:L -> L & List<&2,D.Field>,~readRight:Right -> Right & List<&2,D.Field>,owner:Product.Owner<L,Right>) -> Product.Owner<L,Right> & List<&2,D.Field>:
  match owner:
    case Product.Owner{left,right}:left_read(~L,~Right,~readRight,right,readLeft(left))
def next_check(result:Dispatch,next:Unit -> Dispatch) -> Dispatch:
  match result:
    case Unhandled{}:next(Unit{})
    case result:result
def product_check(~left:D.Field -> Dispatch,~right:D.Field -> Dispatch,field:D.Field) -> Dispatch:
  +value=field
  next_check(left(value),_ => right(value))
def product_clear(~L:Type,~Right:Type,~left:L -> L,~right:Right -> Right,owner:Product.Owner<L,Right>) -> Product.Owner<L,Right>:
  match owner:
    case Product.Owner{l,r}:Product.Owner{left(l),right(r)}
def product_install(~L:Type,~Right:Type,~left:L -> List<&2,D.Field> -> L,~right:Right -> List<&2,D.Field> -> Right,owner:Product.Owner<L,Right>,fields:List<&2,D.Field>) -> Product.Owner<L,Right>:
  match owner:
    case Product.Owner{l,r}:
      +values=fields
      Product.Owner{left(l,values),right(r,values)}
def product(~L:Type,~Right:Type,~readLeft:L -> L & List<&2,D.Field>,~checkLeft:D.Field -> Dispatch,~clearLeft:L -> L,~installLeft:L -> List<&2,D.Field> -> L,~readRight:Right -> Right & List<&2,D.Field>,~checkRight:D.Field -> Dispatch,~clearRight:Right -> Right,~installRight:Right -> List<&2,D.Field> -> Right,-left:Schema<L,readLeft,checkLeft,clearLeft,installLeft>,-right:Schema<Right,readRight,checkRight,clearRight,installRight>) -> Schema<Product.Owner<L,Right>,product_read(~L,~Right,~readLeft,~readRight),product_check(~checkLeft,~checkRight),product_clear(~L,~Right,~clearLeft,~clearRight),product_install(~L,~Right,~installLeft,~installRight)>:
  Schema{}
def field_checked(+field:D.Field,result:Dispatch) -> Maybe<&2,R.Error>:
  match field result:
    case D.Field{name,_} Unhandled{}:Some{R.UnknownMachine{name}}
    case D.Field{name,raw} Invalid{}:Some{R.InvalidMachineState{name,raw}}
    case _ Valid{}:None{}
def continued(error:Maybe<&2,R.Error>,next:Unit -> Maybe<&2,R.Error>) -> Maybe<&2,R.Error>:
  match error:
    case Some{error}:Some{error}
    case None{}:next(Unit{})
def validate(~check:D.Field -> Dispatch,values:List<&2,D.Field>) -> Maybe<&2,R.Error>:
  match values:
    case []:None{}
    case +field <> rest:continued(field_checked(field,check(field)),_ => validate(~check,rest))
