import Base
import ../../main.bend as B
import ../main.bend as Q
import ../../application.bend as App
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
import ../selector.bend as Select
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/declaration.bend as Decl

def collect_cases(values:List<&2,B.Observation>) -> Maybe<&2,B.Cases>:
  match values:
    case h7 <> h6 <> h5 <> h4 <> h3 <> h2 <> h1 <> h0 <> []: Some{B.Cases{h0,h1,h2,h3,h4,h5,h6,h7}}
    case _: None{}
def case_done_7(~S:Data,+op:App.Operation,previous:List<&2,B.Observation>,value:B.Observation) -> Maybe<&2,B.Cases>: collect_cases(value <> previous)
def case_7(~S:Data,+op:App.Operation,previous:List<&2,B.Observation>) -> Maybe<&2,B.Cases>: case_done_7(~S,op,previous,B.run(~S,op,Input.nested_codec(),D.Object{[D.Field{"items",D.Array{[D.Object{[D.Field{"value",D.Number{1}}]},D.Object{[]}]}}]}))
def case_done_6(~S:Data,+op:App.Operation,previous:List<&2,B.Observation>,value:B.Observation) -> Maybe<&2,B.Cases>: case_7(~S,op,value <> previous)
def case_6(~S:Data,+op:App.Operation,previous:List<&2,B.Observation>) -> Maybe<&2,B.Cases>: case_done_6(~S,op,previous,B.run(~S,op,Input.nested_codec(),D.Object{[D.Field{"items",D.Array{[D.Object{[D.Field{"value",D.Number{1}}]},D.Object{[D.Field{"value",D.Number{2}}]}]}}]}))
def case_done_5(~S:Data,+op:App.Operation,previous:List<&2,B.Observation>,value:B.Observation) -> Maybe<&2,B.Cases>: case_6(~S,op,value <> previous)
def case_5(~S:Data,+op:App.Operation,previous:List<&2,B.Observation>) -> Maybe<&2,B.Cases>: case_done_5(~S,op,previous,B.run(~S,op,Input.nested_codec(),D.Object{[D.Field{"items",D.Null{}}]}))
def case_done_4(~S:Data,+op:App.Operation,previous:List<&2,B.Observation>,value:B.Observation) -> Maybe<&2,B.Cases>: case_5(~S,op,value <> previous)
def case_4(~S:Data,+op:App.Operation,previous:List<&2,B.Observation>) -> Maybe<&2,B.Cases>: case_done_4(~S,op,previous,B.run(~S,op,D.Struct{Input.codecs(64n,0)},D.Object{Input.fields(64n,0,[D.Field{"extra",D.Text{"drop-me"}}])}))
def case_done_3(~S:Data,+op:App.Operation,previous:List<&2,B.Observation>,value:B.Observation) -> Maybe<&2,B.Cases>: case_4(~S,op,value <> previous)
def case_3(~S:Data,+op:App.Operation,previous:List<&2,B.Observation>) -> Maybe<&2,B.Cases>: case_done_3(~S,op,previous,B.run(~S,op,D.ArrayValue{D.Integer{}},D.Array{Input.items(127n,[D.Text{"late-invalid"}])}))
def case_done_2(~S:Data,+op:App.Operation,previous:List<&2,B.Observation>,value:B.Observation) -> Maybe<&2,B.Cases>: case_3(~S,op,value <> previous)
def case_2(~S:Data,+op:App.Operation,previous:List<&2,B.Observation>) -> Maybe<&2,B.Cases>: case_done_2(~S,op,previous,B.run(~S,op,D.ArrayValue{D.Integer{}},D.Array{Input.items(256n,[])}))
def case_done_1(~S:Data,+op:App.Operation,previous:List<&2,B.Observation>,value:B.Observation) -> Maybe<&2,B.Cases>: case_2(~S,op,value <> previous)
def case_1(~S:Data,+op:App.Operation,previous:List<&2,B.Observation>) -> Maybe<&2,B.Cases>: case_done_1(~S,op,previous,B.run(~S,op,D.ArrayValue{D.Integer{}},D.Array{Input.items(128n,[])}))
def case_done_0(~S:Data,+op:App.Operation,previous:List<&2,B.Observation>,value:B.Observation) -> Maybe<&2,B.Cases>: case_1(~S,op,value <> previous)
def case_0(~S:Data,+op:App.Operation,previous:List<&2,B.Observation>) -> Maybe<&2,B.Cases>: case_done_0(~S,op,previous,B.run(~S,op,D.ArrayValue{D.Integer{}},D.Array{Input.items(3n,[])}))
type Item is Data: World{value:B.Observation} Decode{value:Input.Observation}
def collect_extension(values:List<&2,Item>) -> Maybe<&2,Q.Extension>:
  match values:
    case World{h11} <> World{h10} <> World{h9} <> World{h8} <> World{h7} <> World{h6} <> Decode{h5} <> Decode{h4} <> World{h3} <> World{h2} <> World{h1} <> World{h0} <> []: Some{Q.Extension{h0,h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11}}
    case _: None{}
def extension_done_11(previous:List<&2,Item>,value:Item) -> Maybe<&2,Q.Extension>: collect_extension(value <> previous)
def extension_11(previous:List<&2,Item>) -> Maybe<&2,Q.Extension>: extension_done_11(previous,World{Q.initialize(Q.constructed(Q.target_codec(),None{}),D.Object{[D.Field{"target",D.Text{"not-handle"}}]})})
def extension_done_10(previous:List<&2,Item>,value:Item) -> Maybe<&2,Q.Extension>: extension_11(value <> previous)
def extension_10(previous:List<&2,Item>) -> Maybe<&2,Q.Extension>: extension_done_10(previous,World{Q.initialize(Q.constructed(Q.target_codec(),None{}),D.Object{[D.Field{"target",D.Handle{1,0}}]})})
def extension_done_9(previous:List<&2,Item>,value:Item) -> Maybe<&2,Q.Extension>: extension_10(value <> previous)
def extension_9(previous:List<&2,Item>) -> Maybe<&2,Q.Extension>: extension_done_9(previous,World{Q.initialize(Q.constructed(Q.target_codec(),None{}),D.Object{[D.Field{"target",D.Handle{2,1}}]})})
def extension_done_8(previous:List<&2,Item>,value:Item) -> Maybe<&2,Q.Extension>: extension_9(value <> previous)
def extension_8(previous:List<&2,Item>) -> Maybe<&2,Q.Extension>: extension_done_8(previous,World{Q.initialize(Q.constructed(Q.target_codec(),None{}),D.Object{[D.Field{"target",D.Handle{1,1}}]})})
def extension_done_7(previous:List<&2,Item>,value:Item) -> Maybe<&2,Q.Extension>: extension_8(value <> previous)
def extension_7(previous:List<&2,Item>) -> Maybe<&2,Q.Extension>: extension_done_7(previous,World{Q.initialize(Q.constructed(D.Struct{[D.NamedCodec{"kind",D.Literal{D.Text{"ready"}}}]},None{}),D.Object{[D.Field{"kind",D.Text{"busy"}}]})})
def extension_done_6(previous:List<&2,Item>,value:Item) -> Maybe<&2,Q.Extension>: extension_7(value <> previous)
def extension_6(previous:List<&2,Item>) -> Maybe<&2,Q.Extension>: extension_done_6(previous,World{Q.initialize(Q.constructed(D.Struct{[D.NamedCodec{"kind",D.Literal{D.Text{"ready"}}}]},None{}),D.Object{[D.Field{"kind",D.Text{"ready"}},D.Field{"extra",D.Number{99}}]})})
def extension_done_5(previous:List<&2,Item>,value:Item) -> Maybe<&2,Q.Extension>: extension_6(value <> previous)
def extension_5(previous:List<&2,Item>) -> Maybe<&2,Q.Extension>: extension_done_5(previous,Decode{Q.load(D.Integer{},None{},D.Boolean{True{}})})
def extension_done_4(previous:List<&2,Item>,value:Item) -> Maybe<&2,Q.Extension>: extension_5(value <> previous)
def extension_4(previous:List<&2,Item>) -> Maybe<&2,Q.Extension>: extension_done_4(previous,Decode{Q.load(D.Integer{},Some{D.BoolValue{}},D.Boolean{True{}})})
def extension_done_3(previous:List<&2,Item>,value:Item) -> Maybe<&2,Q.Extension>: extension_4(value <> previous)
def extension_3(previous:List<&2,Item>) -> Maybe<&2,Q.Extension>: extension_done_3(previous,World{Q.initialize(Q.constructed(D.Integer{},Some{D.BoolValue{}}),D.Number{7})})
def extension_done_2(previous:List<&2,Item>,value:Item) -> Maybe<&2,Q.Extension>: extension_3(value <> previous)
def extension_2(previous:List<&2,Item>) -> Maybe<&2,Q.Extension>: extension_done_2(previous,World{Q.initialize(Q.constructed(D.Integer{},Some{D.BoolValue{}}),D.Boolean{True{}})})
def extension_done_1(previous:List<&2,Item>,value:Item) -> Maybe<&2,Q.Extension>: extension_2(value <> previous)
def extension_1(previous:List<&2,Item>) -> Maybe<&2,Q.Extension>: extension_done_1(previous,World{Q.initialize(Select.Transient{Decl.transient(~B.Schema,~Input.Owner,~App.resource_identity(~B.Schema))},D.Boolean{False{}})})
def extension_done_0(previous:List<&2,Item>,value:Item) -> Maybe<&2,Q.Extension>: extension_1(value <> previous)
def extension_0(previous:List<&2,Item>) -> Maybe<&2,Q.Extension>: extension_done_0(previous,World{Q.initialize(Select.Plain{Decl.plain(~B.Schema,~Input.Owner,~App.resource_identity(~B.Schema))},D.Text{"plain-value"})})
type Candidate is Data: Candidate{insert:Maybe<&2,B.Cases>,spawn:Maybe<&2,B.Cases>,resource:Maybe<&2,B.Cases>,otherSchema:Maybe<&2,B.Cases>,foreign:B.Foreign,extension:Maybe<&2,Q.Extension>}
def main() -> Candidate: Candidate{case_0(~B.Schema,App.Insert{},[]),case_0(~B.Schema,App.Spawn{},[]),case_0(~B.Schema,App.Resource{},[]),case_0(~B.OtherSchema,App.Insert{},[]),B.foreign_world(),extension_0([])}
