import Base
import ./declarations.bend as O
import ./receiver.bend as R
import ./execution.bend as E
import ./setup.bend as Setup
import ./observation.bend as Observe
import ./restore-receipt.bend as Receipt
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/persistence-declaration.bend as Decl
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/decode-data.bend as D

def Schema(~S:Data) -> Type:Plan.Schema<S,O.components(~S),O.resources(~S)>
# Only duplicable codec declarations are copied; no payload or factory owner is.
def declarations(~S:Data,schema:Schema(~S)) -> Schema(~S) & Schema(~S):
  match schema:
    case Plan.Schema{Product.Owner{Decl.Constructed{+actor},Decl.Transient{}},Product.Owner{Decl.Constructed{+config},Decl.Transient{}}}:(Plan.Schema{Product.Owner{Decl.Constructed{actor},Decl.Transient{}},Product.Owner{Decl.Constructed{config},Decl.Transient{}}},Plan.Schema{Product.Owner{Decl.Constructed{actor},Decl.Transient{}},Product.Owner{Decl.Constructed{config},Decl.Transient{}}})
type Outcome<-S:Data> is Type:
  Retried{first:Saved.Snapshot<S>,second:Saved.Snapshot<S>,failure:Receipt.Receipt<S>,result:E.Resumed<S>}
  SaveRefused{schema:Schema(~S),app:E.Application(~S),first:Maybe<&2,Saved.Snapshot<S>>,outcome:Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>}
  SetupRefused{result:Setup.Defined<S>}
def invalid_resources(values:List<&2,Saved.Field>) -> List<&2,Saved.Field>:
  match values:
    case []:[]
    case Saved.Field{key,present,_,stamp} <> rest:Saved.Field{key,present,Saved.Persisted{D.Object{[D.Field{"enabled",D.Boolean{True{}}},D.Field{"limit",D.BendvyText{"invalid integer"}}]}},stamp} <> rest
def invalid(~S:Data,input:Saved.Snapshot<S>) -> Saved.Snapshot<S>:
  match input:
    case Saved.Snapshot{version,metadata,entities,resources}:Saved.Snapshot{version,metadata,entities,invalid_resources(resources)}
def resumed(~S:Data,first:Saved.Snapshot<S>,second:Saved.Snapshot<S>,failure:Receipt.Receipt<S>,result:E.Resumed<S>) -> Outcome<S>:Retried{first,second,failure,result}
def refused(~S:Data,native:Bool,first:Saved.Snapshot<S>,+second:Saved.Snapshot<S>,retrySchema:Schema(~S),result:E.Application(~S) & Receipt.Receipt<S>) -> IO(Outcome<S>):
  match result:
    case (app,failure):IO.bind(E.Resumed<S>,Outcome<S>,E.resume(~S,native,E.restore(~S,retrySchema,second,app)),result => IO.pure(Outcome<S>,resumed(~S,first,second,failure,result)))
def schemas(~S:Data,native:Bool,first:Saved.Snapshot<S>,+second:Saved.Snapshot<S>,app:E.Application(~S),result:Schema(~S) & Schema(~S)) -> IO(Outcome<S>):
  match result:
    case (schema,retrySchema):refused(~S,native,first,second,retrySchema,E.restore(~S,schema,invalid(~S,second),app))
def second_saved(~S:Data,native:Bool,first:Saved.Snapshot<S>,result:Schema(~S) & (E.Application(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>)) -> IO(Outcome<S>):
  match result:
    case (schema,(app,Gate.Saved{second})):schemas(~S,native,first,second,app,declarations(~S,schema))
    case (schema,(app,outcome)):IO.pure(Outcome<S>,SaveRefused{schema,app,Some{first},outcome})
def first_saved(~S:Data,native:Bool,result:Schema(~S) & (E.Application(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>)) -> IO(Outcome<S>):
  match result:
    case (schema,(app,Gate.Saved{first})):second_saved(~S,native,first,E.save(~S,schema,app))
    case (schema,(app,outcome)):IO.pure(Outcome<S>,SaveRefused{schema,app,None{},outcome})
def defined(~S:Data,native:Bool,result:Setup.Defined<S>) -> IO(Outcome<S>):
  match result:
    case Setup.Defined{app}:first_saved(~S,native,E.save(~S,O.schema(~S),app))
    case other:IO.pure(Outcome<S>,SetupRefused{other})
def run(~S:Data,native:Bool,world:R.World(~S)) -> IO(Outcome<S>):defined(~S,native,Setup.setup(~S,world))
def failure_rendered(~S:Data,result:Schema(~S) & String) -> String:
  match result:
    case (schema,details):details ++ "/schema=" ++ Observe.schema(~S,schema)
def failure(~S:Data,receipt:Receipt.Receipt<S>) -> String:
  failure_rendered(~S,Observe.receipt_for_save(~S,receipt))
def observed(~S:Data,result:Outcome<S>) -> String:
  match result:
    case Retried{first,second,rejected,result}:"first=" ++ Observe.snapshot(~S,first) ++ "/second=" ++ Observe.snapshot(~S,second) ++ "/refusal=" ++ failure(~S,rejected) ++ "/retry=" ++ Observe.resumed(~S,result)
    case _:"save-or-setup-refused"
