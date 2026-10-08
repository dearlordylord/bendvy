import Base
import ./fixture.bend as F
import ./gate.bend as G
import ./format.bend as Format
import ./reference-source/typed.bend as D

def payload() -> F.Payload:
  F.Payload{Array.set(U32,Array.new(U32,1n,7),1,9)}
def owner_second(first:U32,observed:Array<U32> & U32) -> String:
  match observed:
    case (_,second): U32.show(first) ++ "," ++ U32.show(second)
def owner_first(observed:Array<U32> & U32) -> String:
  match observed:
    case (values,first): owner_second(first,Array.get(U32,values,1))
# Both physical fixture cells observed, then the returned array disposed once.
def owner(value:F.Payload) -> String:
  match value:
    case F.Payload{values}: owner_first(Array.get(U32,values,0))
def validation_row(label:String,result:F.Payload & G.Validation) -> String:
  match result:
    case (value,validation): label ++ "|" ++ Format.validation(validation) ++ "|owner:" ++ owner(value)
def field_row(label:String,result:F.Payload & G.Field) -> String:
  match result:
    case (value,field): label ++ "|" ++ Format.field(field) ++ "|owner:" ++ owner(value)
def mutate(value:F.Payload) -> F.Payload:
  match value:
    case F.Payload{values}: F.Payload{Array.set(U32,values,0,11)}
def lifetime_row(label:String,result:F.Payload & G.Field) -> String:
  match result:
    case (value,+field): label ++ "|" ++ Format.field(field) ++ "|owner:" ++ owner(mutate(value)) ++ "|saved-after:" ++ Format.field(field)
def success(~S:Data,label:String) -> String:
  validation_row(label,G.validate_projection(~S,~F.Payload,~F.declaration(~S),128n,G.persisted(~S,~F.Payload,~F.declaration(~S),D.Integer{},F.project),payload()))
def failure(~S:Data,label:String) -> String:
  validation_row(label,G.validate_projection(~S,~F.Payload,~F.declaration(~S),128n,G.persisted(~S,~F.Payload,~F.declaration(~S),D.StringValue{},F.project),payload()))
def skip(~S:Data,label:String) -> String:
  validation_row(label,G.validate_projection(~S,~F.Payload,~F.declaration(~S),128n,G.transient(~S,~F.Payload,~F.declaration(~S)),payload()))
def exported(~S:Data,label:String) -> String:
  field_row(label,F.ordinary(~S,payload()))
def omitted(~S:Data,label:String) -> String:
  field_row(label,F.omitted(~S,payload()))
def lifetime(~S:Data,label:String) -> String:
  lifetime_row(label,F.ordinary(~S,payload()))
def schema(~S:Data,+name:String) -> String:
  success(~S,name ++ ".validated-number") ++ "\n" ++ failure(~S,name ++ ".validation-error") ++ "\n" ++ skip(~S,name ++ ".transient-validation") ++ "\n" ++ exported(~S,name ++ ".export") ++ "\n" ++ omitted(~S,name ++ ".transient-export") ++ "\n" ++ lifetime(~S,name ++ ".save-view-lifetime")
def output() -> String:
  schema(~F.Workshop,"Workshop") ++ "\n" ++ schema(~F.Garden,"Garden")
