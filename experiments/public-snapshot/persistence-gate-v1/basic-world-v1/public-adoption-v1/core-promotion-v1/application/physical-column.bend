import Base
import ./legacy-fixture.bend as F
import ./game.bend as Game
import ./format.bend as Format
import ../library/persistence-declaration.bend as Decl
import ../library/snapshot-leaf.bend as Leaf
import ../library/owner-product.bend as Product
import ../library/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as L
def payload_leaf(observed:F.Payload & D.Raw) -> Maybe<F.Payload> & D.Raw:
  match observed:
    case (owner,raw):(Some{owner},D.Object{[D.Field{"Some",raw}]})
def cell(value:Maybe<F.Payload>) -> Maybe<F.Payload> & D.Raw:
  match value:
    case None{}:(None{},D.Null{})
    case Some{owner}:payload_leaf(F.project(owner))
def array_leaf(observed:Maybe<F.Payload> & D.Raw) -> Array<Maybe<F.Payload>> & D.Raw:
  match observed:
    case (owner,raw):(ALeaf{owner},D.Object{[D.Field{"ALeaf",raw}]})
def array_joined(left:Array<Maybe<F.Payload>>,leftRaw:D.Raw,observed:Array<Maybe<F.Payload>> & D.Raw) -> Array<Maybe<F.Payload>> & D.Raw:
  match observed:
    case (right,rightRaw):(ANode{left,right},D.Object{[D.Field{"ANode",D.Array{[leftRaw,rightRaw]}}]})
def array_pair(observedLeft:Array<Maybe<F.Payload>> & D.Raw,observedRight:Array<Maybe<F.Payload>> & D.Raw) -> Array<Maybe<F.Payload>> & D.Raw:
  match observedLeft:
    case (left,leftRaw):array_joined(left,leftRaw,observedRight)
def array(owner:Array<Maybe<F.Payload>>) -> Array<Maybe<F.Payload>> & D.Raw:
  match owner:
    case ALeaf{value}:array_leaf(cell(value))
    case ANode{left,right}:array_pair(array(left),array(right))
def stamp(value:L.Entry) -> D.Raw:
  match value:
    case L.Entry{id,L.Stamp{added,changed}}:D.Object{[D.Field{"id",D.Number{id}},D.Field{"added",D.Number{added}},D.Field{"changed",D.Number{changed}}]}
def stamps(values:List<&2,L.Entry>) -> List<&2,D.Raw>:
  match values:
    case []:[]
    case value <> rest:stamp(value) <> stamps(rest)
def column_done(~S:Data,+metadata:List<&2,L.Entry>,observed:Array<Maybe<F.Payload>> & D.Raw) -> Col.Column<S,F.Payload> & D.Raw:
  match observed:
    case (values,raw):(Col.Column{values,metadata},D.Object{[D.Field{"values",raw},D.Field{"stamps",D.Array{stamps(metadata)}}]})
def column(~S:Data,owner:Col.Column<S,F.Payload>) -> Col.Column<S,F.Payload> & D.Raw:
  match owner:
    case Col.Column{values,metadata}:column_done(~S,metadata,array(values))
    case _: (owner,D.Text{"UnexpectedColumn"})
def transient_done(~S:Data,saved:Game.Saved(~S),savedRaw:D.Raw,recipe:Decl.Transient<S,F.Payload,Game.scratch(~S)>,units:Product.Owner<Unit,Unit>,observed:Col.Column<S,F.Payload> & D.Raw) -> Game.Store(~S) & String:
  match observed:
    case (transient,raw):(Product.Owner{Product.Owner{saved,Leaf.TransientComponent{transient,recipe}},units},"{\"saved\":" ++ Format.raw(savedRaw) ++ ",\"transient\":" ++ Format.raw(raw) ++ "}")
def scratch_done(~S:Data,saved:Game.Saved(~S),savedRaw:D.Raw,units:Product.Owner<Unit,Unit>,scratch:Game.Scratch(~S)) -> Game.Store(~S) & String:
  match scratch:
    case Leaf.TransientComponent{owner,recipe}:transient_done(~S,saved,savedRaw,recipe,units,column(~S,owner))
def saved_done(~S:Data,recipe:Decl.Constructed<S,F.Payload,F.declaration(~S),F.project>,scratch:Game.Scratch(~S),units:Product.Owner<Unit,Unit>,observed:Col.Column<S,F.Payload> & D.Raw) -> Game.Store(~S) & String:
  match observed:
    case (saved,savedRaw):scratch_done(~S,Leaf.Component{saved,recipe},savedRaw,units,scratch)
def store(~S:Data,owner:Game.Store(~S)) -> Game.Store(~S) & String:
  match owner:
    case Product.Owner{Product.Owner{Leaf.Component{physical,recipe},scratch},units}:saved_done(~S,recipe,scratch,units,column(~S,physical))
