import Base
import definition.bend as Meta
import witness.bend as Witness
import ../../bend-candidate/inspect.bend as I
import ../../bend-candidate/consumer.bend as Workshop
import ../../bend-candidate/query-consumer.bend as Garden
import ../cardinality-workshop.bend as W
import ../cardinality-garden.bend as G

# Diagnostics consume Arrays only AFTER repeated metadata reads. The actual
# opaque typed Plan is returned intact; this consumer never invokes its lenses.
type Carrier<-P:Type> is Type:
  Carrier{left:Array<U32>,right:Array<U32>,plan:P}
def resource(~S:Data,value:Meta.Resource<S>) -> String:
  match value:
    case Meta.Resource{id,name}:"resource:" ++ U32.show(id) ++ ":" ++ name
def line(~S:Data,+schema:String,+label:String,pass:String,+left:String,+right:String,+metadata:Meta.Metadata<S>) -> String:
  schema ++ "|" ++ label ++ "|" ++ pass ++ "|kind=" ++ Meta.kind(~S,metadata) ++ "|name=" ++ Meta.name(~S,metadata) ++ "|requirements=" ++ List.show(&2,Meta.Resource<S>,resource(~S),Meta.requirements(~S,metadata)) ++ "|left=" ++ left ++ "|right=" ++ right ++ "\n"
def rendered(~S:Data,~P:Type,+schema:String,+label:String,first:Meta.Metadata<S>,second:Meta.Metadata<S>,owner:Carrier<P>) -> P & String:
  match owner:
    case Carrier{left,right,plan}:
      +leftText=List.show(&1,U32,U32.show,Array.to_list(~U32,left))
      +rightText=List.show(&1,U32,U32.show,Array.to_list(~U32,right))
      (plan,line(~S,schema,label,"first",leftText,rightText,first) ++ line(~S,schema,label,"repeat",leftText,rightText,second))
def read_result(~S:Data,~P:Type,schema:String,label:String,result:Meta.Definition<S,Carrier<P>> & (Meta.Metadata<S> & Meta.Metadata<S>)) -> P & String:
  (definition,(first,second))=result
  rendered(~S,~P,schema,label,first,second,Meta.into_plan(~S,~Carrier<P>,definition))
def left() -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,Array.new(U32,2n,101),1,102),2,103),3,104)
def right() -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,Array.new(U32,2n,201),1,202),2,203),3,204)
def run(~S:Data,~P:Type,+schema:String,+label:String,requirements:List<&2,Meta.Resource<S>>,plan:P) -> P & String:
  read_result(~S,~P,schema,label,Witness.twice(~S,~Carrier<P>,Meta.make(~S,~Carrier<P>,schema ++ "/Metadata/" ++ label,requirements,Carrier{left(),right(),plan})))
# The final closed driver explicitly disposes its returned opaque Plan only
# after the owner-preserving consumer returns. No Plan declaration derivation.
def text(~P:Type,result:P & String) -> String:
  (_,text)=result
  text
def workshop() -> String:
  text(~I.Plan<Workshop.Schema,Workshop.Store,Workshop.Resource,U32,W.Ops>,run(~Workshop.Schema,~I.Plan<Workshop.Schema,Workshop.Store,Workshop.Resource,U32,W.Ops>,"Workshop","empty",[],W.plan())) ++
  text(~I.Plan<Workshop.Schema,Workshop.Store,Workshop.Resource,U32,W.Ops>,run(~Workshop.Schema,~I.Plan<Workshop.Schema,Workshop.Store,Workshop.Resource,U32,W.Ops>,"Workshop","query-only",[],W.plan())) ++
  text(~I.Plan<Workshop.Schema,Workshop.Store,Workshop.Resource,U32,W.Ops>,run(~Workshop.Schema,~I.Plan<Workshop.Schema,Workshop.Store,Workshop.Resource,U32,W.Ops>,"Workshop","resource-absent",[Meta.Resource{1,"Workshop/Score"}],W.plan())) ++
  text(~I.Plan<Workshop.Schema,Workshop.Store,Workshop.Resource,U32,W.Ops>,run(~Workshop.Schema,~I.Plan<Workshop.Schema,Workshop.Store,Workshop.Resource,U32,W.Ops>,"Workshop","resource-present",[Meta.Resource{1,"Workshop/Score"}],W.plan())) ++
  text(~I.Plan<Workshop.Schema,Workshop.Store,Workshop.Resource,U32,W.Ops>,run(~Workshop.Schema,~I.Plan<Workshop.Schema,Workshop.Store,Workshop.Resource,U32,W.Ops>,"Workshop","aliases",[Meta.Resource{2,"Workshop/Bonus"},Meta.Resource{2,"Workshop/BonusAlias"},Meta.Resource{1,"Workshop/Score"}],W.plan())) ++
  text(~I.Plan<Workshop.Schema,Workshop.Store,Workshop.Resource,U32,W.Ops>,run(~Workshop.Schema,~I.Plan<Workshop.Schema,Workshop.Store,Workshop.Resource,U32,W.Ops>,"Workshop","same-name-interned-aliases",[Meta.Resource{3,"Workshop/Shared"},Meta.Resource{3,"Workshop/Shared"}],W.plan()))
def garden() -> String:
  text(~I.Plan<Garden.Schema,Garden.Store,Garden.Resource,U32,G.Ops>,run(~Garden.Schema,~I.Plan<Garden.Schema,Garden.Store,Garden.Resource,U32,G.Ops>,"Garden","empty",[],G.plan())) ++
  text(~I.Plan<Garden.Schema,Garden.Store,Garden.Resource,U32,G.Ops>,run(~Garden.Schema,~I.Plan<Garden.Schema,Garden.Store,Garden.Resource,U32,G.Ops>,"Garden","query-only",[],G.plan())) ++
  text(~I.Plan<Garden.Schema,Garden.Store,Garden.Resource,U32,G.Ops>,run(~Garden.Schema,~I.Plan<Garden.Schema,Garden.Store,Garden.Resource,U32,G.Ops>,"Garden","resource-absent",[Meta.Resource{1,"Garden/Score"}],G.plan())) ++
  text(~I.Plan<Garden.Schema,Garden.Store,Garden.Resource,U32,G.Ops>,run(~Garden.Schema,~I.Plan<Garden.Schema,Garden.Store,Garden.Resource,U32,G.Ops>,"Garden","resource-present",[Meta.Resource{1,"Garden/Score"}],G.plan())) ++
  text(~I.Plan<Garden.Schema,Garden.Store,Garden.Resource,U32,G.Ops>,run(~Garden.Schema,~I.Plan<Garden.Schema,Garden.Store,Garden.Resource,U32,G.Ops>,"Garden","aliases",[Meta.Resource{2,"Garden/Bonus"},Meta.Resource{2,"Garden/BonusAlias"},Meta.Resource{1,"Garden/Score"}],G.plan())) ++
  text(~I.Plan<Garden.Schema,Garden.Store,Garden.Resource,U32,G.Ops>,run(~Garden.Schema,~I.Plan<Garden.Schema,Garden.Store,Garden.Resource,U32,G.Ops>,"Garden","same-name-interned-aliases",[Meta.Resource{3,"Garden/Shared"},Meta.Resource{3,"Garden/Shared"}],G.plan()))
def main() -> String:
  workshop() ++ garden()
