import Base
import ./ordinary-resource-system.bend as P
import ./ordinary-schema.bend as Schema
import ./world.bend as W
import ./transaction.bend as T
import ./capabilities.bend as Cap
import ./ordinary-query-declaration.bend as Query
# One static declaration constructs operational and owner-preserving observation routes.
# It carries no runtime-owned World or resource payload.
# App declaration for the entire Resources owner R in one schema S.
# Keeps operational permissions, an owner-threading Data observation and its
# renderer together. It contains no live World or resource instance. Choose
# ordinary-app-resource-field-declaration when only one product field is needed.
# Concrete setup: test-fixtures/public-schedules/named-app-v1/
# matched-feature-v1/fixture.bend:declaration and reader_declaration.
type Declaration<-S:Data,-C:Type,-R:Type,-E:Data,-Ops:Type -> Type,-V:Data> is Type:
  Declaration{ordinary:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & V,render:V -> String}
# Operation-family alias for whole-resource read access to a Data view V.
# The callback receives an opaque owner H; the grant cannot replace Resources.
def read_ops(~V:Data,H:Type) -> Type:
  Cap.ValueRead<H,V>
# Operation-family alias for whole-resource read/replacement access.
# A write consumes a replacement R, which may contain affine Type payloads;
# this is not the narrower grant for replacing a single resource field.
def write_ops(~R:Type,~V:Data,H:Type) -> Type:
  Cap.ValueWrite<H,R,V>
# Declare read access using a schema-bound resource identity and projection.
# project threads R back with a Data view V; render formats that view for App
# observation. The returned declaration is setup data, not a live resource read.
# The observation path also threads the World; it does not imply that an
# arbitrary user projector is pure or can be undone automatically.
def read(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~project:R -> R & V,~render:V -> String,identity:Schema.Resource<S,R>) -> Declaration<S,C,R,E,read_ops(~V),V>:
  Declaration{P.read(~S,~C,~R,~E,~V,~project,identity),W.observe_resource(~S,~C,~R,~E,~V,~project),render}
# Declare read and whole-owner replacement access to schema resource R.
# Uses the same projection/rendering contract as read. Replacements made through
# the operational grant use the ordinary transaction journal: a failed system
# restores the old resource. This declaration does not execute a system or grant
# rollback for arbitrary host IO or effects outside those operations.
def write(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~project:R -> R & V,~render:V -> String,identity:Schema.Resource<S,R>) -> Declaration<S,C,R,E,write_ops(~R,~V),V>:
  Declaration{P.write(~S,~C,~R,~E,~V,~project,identity),W.observe_resource(~S,~C,~R,~E,~V,~project),render}
# Advanced App projection: consume the declaration and return its operational
# resource declaration. Recreate a closed declaration when multiple projections
# are needed; metadata strings alone cannot substitute for the typed grant.
def ordinary(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>:
  match declaration:
    case Declaration{ordinary,_,_}:ordinary
# Advanced App projection: consume the declaration and obtain the function
# World -> (World, V). The World owner is returned after the resource projection;
# this observer neither registers nor executes the resource system.
def observer(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> W.World<S,C,R,E> -> W.World<S,C,R,E> & V:
  match declaration:
    case Declaration{_,observe,_}:observe
# Obtain the declared Data-view renderer, consuming this declaration value.
# Rendering is observation work and grants no access to a World or resource.
def presenter(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> V -> String:
  match declaration:
    case Declaration{_,_,render}:render
def named(~S:Data,value:Query.Clause<S>) -> String:
  match value:
    case Query.Clause{key,_}:key
# Return the resource access key from this declaration's operational clause.
# Consumes the declaration and retains its declared name, not runtime authority.
# Use the schema identity for access, rather than reconstructing it from this text.
def name(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> String:
  named(~S,P.clause(~S,~R,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),ordinary(~S,~C,~R,~E,~Ops,~V,declaration)))
