import Base
import ./game.bend as Game
import ../library/persistence-declaration.bend as Decl
import ./admission.bend as Admission
import ../library/snapshot-schema.bend as Schema
import ./format.bend as Format
import ./legacy-fixture.bend as F
import ../library/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as L
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import ../library/ordinary-declaration.bend as Canonical
import ../library/ordinary-schema.bend as Ordinary

def kind(value:Fragment.RegistryKind) -> String:
  match value:
    case Fragment.Component{}:"Component"
    case Fragment.Resource{}:"Resource"
    case _:"UnexpectedKind"
def entry(value:Fragment.Entry<F.Workshop>) -> D.Raw:
  match value:
    case Fragment.Entry{category,key,name}:D.Object{[D.Field{"kind",D.Text{kind(category)}},D.Field{"key",D.Text{key}},D.Field{"name",D.Text{name}}]}
def entries(values:List<&2,Fragment.Entry<F.Workshop>>) -> List<&2,D.Raw>:
  match values:
    case []:[]
    case value <> rest:entry(value) <> entries(rest)
def inventory() -> D.Raw:
  D.Array{entries(Ordinary.entries(~F.Workshop,~Game.Store(~F.Workshop),~Game.ResourceStore(~F.Workshop),Schema.inventory(~F.Workshop,~Game.Store(~F.Workshop),~Game.ResourceStore(~F.Workshop),~True{},~Game.all_components(~F.Workshop),~Game.all_resources(~F.Workshop),Game.ordinary(~F.Workshop))))}
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
def column_done(+metadata:List<&2,L.Entry>,observed:Array<Maybe<F.Payload>> & D.Raw) -> Col.Column<F.Workshop,F.Payload> & D.Raw:
  match observed:
    case (values,raw):(Col.Column{values,metadata},D.Object{[D.Field{"values",raw},D.Field{"stamps",D.Array{stamps(metadata)}}]})
def column(owner:Col.Column<F.Workshop,F.Payload>) -> Col.Column<F.Workshop,F.Payload> & D.Raw:
  match owner:
    case Col.Column{values,metadata}:column_done(metadata,array(values))
    case _: (owner,D.Text{"UnexpectedColumn"})
# Every accepted/rejected receipt's payload and retained recipe are observed.
def recipe(value:Decl.Constructed<F.Workshop,F.Payload,F.declaration(~F.Workshop),F.project>) -> String:
  "{\"key\":" ++ Format.quoted(Canonical.key(~F.Workshop,~F.Payload,F.declaration(~F.Workshop))) ++ ",\"codec\":" ++ Format.codec(Decl.codec(~F.Workshop,~F.Payload,~F.declaration(~F.Workshop),~F.project,value)) ++ "}"
def rejected_owner(declaration:Decl.Constructed<F.Workshop,F.Payload,F.declaration(~F.Workshop),F.project>,checked:D.Checked,before:D.Raw,after:D.Raw,observed:F.Payload & D.Raw) -> String:
  match observed:
    case (_,incoming):"{\"recipe\":" ++ recipe(declaration) ++ ",\"checked\":" ++ Format.checked(checked) ++ ",\"before\":" ++ Format.raw(before) ++ ",\"after\":" ++ Format.raw(after) ++ ",\"incoming\":" ++ Format.raw(incoming) ++ "}"
def rejected_column(declaration:Decl.Constructed<F.Workshop,F.Payload,F.declaration(~F.Workshop),F.project>,checked:D.Checked,before:D.Raw,incoming:F.Payload,observed:Col.Column<F.Workshop,F.Payload> & D.Raw) -> String:
  match observed:
    case (_,after):rejected_owner(declaration,checked,before,after,F.project(incoming))
def rejected(before:D.Raw,result:Admission.Insertion<F.Workshop,F.Payload,F.declaration(~F.Workshop),F.project>) -> String:
  match result:
    case Admission.Insertion{declaration,checked,Col.Rejected{owner,Some{incoming}}}:rejected_column(declaration,checked,before,incoming,column(owner))
    case _:"UnexpectedAdmissionOutcome"
def accepted_column(+declaration:Decl.Constructed<F.Workshop,F.Payload,F.declaration(~F.Workshop),F.project>,checked:D.Checked,observed:Col.Column<F.Workshop,F.Payload> & D.Raw) -> String:
  match observed:
    case (owner,+before):"{\"accepted\":{\"recipe\":" ++ recipe(declaration) ++ ",\"checked\":" ++ Format.checked(checked) ++ ",\"column\":" ++ Format.raw(before) ++ "},\"rejected\":" ++ rejected(before,Admission.insert(~F.Workshop,~F.Payload,~F.declaration(~F.Workshop),~F.project,declaration,owner,1,F.payload(11,13))) ++ "}"
def accepted(result:Admission.Insertion<F.Workshop,F.Payload,F.declaration(~F.Workshop),F.project>) -> String:
  match result:
    case Admission.Insertion{declaration,checked,Col.Accepted{owner,None{}}}:accepted_column(declaration,checked,column(owner))
    case _:"UnexpectedAdmissionOutcome"
def admission() -> String:
  accepted(Admission.insert(~F.Workshop,~F.Payload,~F.declaration(~F.Workshop),~F.project,Decl.constructed(~F.Workshop,~F.Payload,~F.declaration(~F.Workshop),~F.project,D.ArrayValue{D.LiteralValues{[D.Number{7},D.Number{9}]}}),Col.ensure(~F.Workshop,~F.Payload,Col.empty(~F.Workshop,~F.Payload),2),1,F.payload(7,9)))
def output() -> String:
  "{\"inventory\":" ++ Format.raw(inventory()) ++ ",\"admission\":" ++ admission() ++ "}"
