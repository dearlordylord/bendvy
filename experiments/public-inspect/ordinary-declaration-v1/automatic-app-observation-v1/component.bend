import Base
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
type A is Data:
  A{}
type Other is Data:
  Other{}
type Token is Data:
  Token{}
# Affine payload, deliberately not a persistence/Data requirement.
type Payload is Type:
  Payload{values:Array<U32>}
def viewed(result:Array<U32> & U32) -> Payload & U32:
  match result:
    case (values,value):(Payload{values},value)
def view(payload:Payload) -> Payload & U32:
  match payload:
    case Payload{values}:
      viewed(Array.get(U32,values,0))
def take(~S:Data,column:Col.Column<S,Payload>) -> Unit & Col.Column<S,Payload>:
  (Unit{},column)
def put(~S:Data,rest:Unit,column:Col.Column<S,Payload>) -> Col.Column<S,Payload>:
  column
def binding(~S:Data) -> B.Binding<S,Col.Column<S,Payload>,Unit,Payload,U32,Token,take(~S),put(~S),view>:
  B.bind(~S,~Col.Column<S,Payload>,~Unit,~Payload,~U32,~Token,~take(~S),~put(~S),~view,Identity.component(~S,~Payload,"Position"))

def family(~S:Data) -> C.Family<S,Col.Column<S,Payload>,Unit,Payload,U32,Token,take(~S),put(~S),view>:
  B.family(~S,~Col.Column<S,Payload>,~Unit,~Payload,~U32,~Token,~take(~S),~put(~S),~view,binding(~S))
