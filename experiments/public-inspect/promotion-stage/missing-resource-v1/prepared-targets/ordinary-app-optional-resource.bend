import Base
import ./ordinary-optional-resource.bend as O
import ./ordinary-schema.bend as Schema
import ./owner-product.bend as Product
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-registration-fields.bend as Fields
import ./world.bend as W
import ./check.bend as K
import ./capabilities.bend as Cap

# Retain one ordinary resource declaration in the typed application boundary.
type Installed<-S:Data,-C:Type,-R:Type,-E:Data,-P:Type,-Rest:Type,-V:Data,-identity:Schema.Resource<S,P>,-lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,-view:P -> P & V,-declaration:O.Declaration<S,R,P,Rest,V,identity,lens,view>,-Owners:Type,-Rows:Data,-prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,-fold:Owners -> Owners & List<&2,Fields.Fields<S>>> is Type:
  Installed{app:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,prior,fold>}
def Application(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~view:P -> P & V,~declaration:O.Declaration<S,R,P,Rest,V,identity,lens,view>,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> Type:
  Installed<S,C,R,E,P,Rest,V,identity,lens,view,declaration,Owners,Rows,prior,fold>
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~view:P -> P & V,~declaration:O.Declaration<S,R,P,Rest,V,identity,lens,view>,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Out:Data,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,prior>,debug:Bool,result:W.World<S,C,R,E> & Out) -> Application(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration,~Owners,~Rows,~prior,~fold) & Out:
  match result:
    case (world,value):(Installed{Build.Registered{world,owners,recipe,debug}},value)
def optional_app(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~view:P -> P & V,~declaration:O.Declaration<S,R,P,Rest,V,identity,lens,view>,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration,~Owners,~Rows,~prior,~fold)) -> Application(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration,~Owners,~Rows,~prior,~fold) & Maybe<&2,V>:
  match app:
    case Installed{Build.Registered{world,owners,recipe,debug}}:returned(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration,~Owners,~Rows,~prior,~fold,~Maybe<&2,V>,owners,recipe,debug,O.observe(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration,world))

def install(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~view:P -> P & V,~declaration:O.Declaration<S,R,P,Rest,V,identity,lens,view>,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,prior,fold>) -> Application(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration,~Owners,~Rows,~prior,~fold):
  Installed{app}

# This is the existing read-only Check callback surface, not a new effect API.
def Ops(~V:Data,H:Type) -> Type:
  Cap.ValueRead<H,Maybe<&2,V>>
def plan(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~view:P -> P & V,~declaration:O.Declaration<S,R,P,Rest,V,identity,lens,view>) -> K.Plan<S,C,R,E,Ops(~V)>:
  K.Plan{O.required(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration),O.condition(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration)}
def checked(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~view:P -> P & V,~declaration:O.Declaration<S,R,P,Rest,V,identity,lens,view>,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,prior>,debug:Bool,result:K.Checked<S,C,R,E>) -> Application(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration,~Owners,~Rows,~prior,~fold) & Result<&2,&2,K.Error,Bool>:
  match result:
    case K.Checked{world,K.Fail{error}}:returned(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration,~Owners,~Rows,~prior,~fold,~Result<&2,&2,K.Error,Bool>,owners,recipe,debug,(world,Fail{error}))
    case K.Checked{world,K.Done{value}}:returned(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration,~Owners,~Rows,~prior,~fold,~Result<&2,&2,K.Error,Bool>,owners,recipe,debug,(world,Done{value}))
def required_app(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~view:P -> P & V,~declaration:O.Declaration<S,R,P,Rest,V,identity,lens,view>,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Args:Data,~body:@-H:Type -> @-caps:Ops(~V,H) -> Args -> H -> H & Bool,app:Application(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration,~Owners,~Rows,~prior,~fold),args:Args) -> Application(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration,~Owners,~Rows,~prior,~fold) & Result<&2,&2,K.Error,Bool>:
  match app:
    case Installed{Build.Registered{world,owners,recipe,debug}}:checked(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration,~Owners,~Rows,~prior,~fold,owners,recipe,debug,K.run(~S,~C,~R,~E,~Ops(~V),~Args,~body,~plan(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration),args,world))
