import Base
import ./execution-builder.bend as Build
import ./execution-declaration.bend as D
import ./execution-resource-program.bend as Program
import ./execution-resource-recipe.bend as Resources
import ./execution-resource-description.bend as Description
import ./execution-query-schema.bend as Schema
import ./execution-query-admission.bend as Query
import ./execution-query-recipe.bend as Recipe
import ./execution-composer-layout.bend as L
import ./world.bend as W
import ./entity-allocator.bend as Allocator
import ./deferred-command.bend as Deferred
import ./clock-state.bend as Clock
import ./execution-lifecycle-notices.bend as Notice

# Both route inventories come from ONE actual closed compilation. The actual
# canonical affine owners remain in World; Data never substitutes for them.
type Evidence<-S:Data,-components:L.Layout,-resources:L.Layout,-C:Type,-R:Type,-Ops:Type -> Type,-program:Build.Program(~S,~L.columns(~S,components),~C,~R,~Ops)> is Data:
  Evidence{namespace:U32,handles:List<&2,W.Handle<S>>,queryRecipes:List<&2,Recipe.Recipe<S,L.columns(~S,components)>>,resourceRecipes:List<&2,Resources.Entry>,componentInfo:List<&2,Schema.Info>,resourceInfo:List<&2,Description.Info>,grants:List<&2,Query.Granted<S,L.columns(~S,components)>>,queryBook:Schema.Book<S,components>,resourceBook:Resources.Book<S,resources>}
type Inspection<-S:Data,-components:L.Layout,-resources:L.Layout,-C:Type,-R:Type,-E:Data,-Ops:Type -> Type,-program:Build.Program(~S,~L.columns(~S,components),~C,~R,~Ops)> is Type:
  Admitted{world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,compilation:D.Compilation<S,L.columns(~S,components),C,R,Ops>,evidence:Evidence<S,components,resources,C,R,Ops,program>}
  Refused{world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,compilation:D.Compilation<S,L.columns(~S,components),C,R,Ops>}
def lowered(~S:Data,~components:L.Layout,~resources:L.Layout,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~program:Build.Program(~S,~L.columns(~S,components),~C,~R,~Ops),world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,compilation:D.Compilation<S,L.columns(~S,components),C,R,Ops>,namespace:U32,handles:List<&2,W.Handle<S>>,queries:List<&2,Recipe.Recipe<S,L.columns(~S,components)>>,+resourceRecipes:List<&2,Resources.Entry>,componentInfo:List<&2,Schema.Info>,resourceInfo:List<&2,Description.Info>,result:Query.Lowering<S,L.columns(~S,components),components>) -> Inspection<S,components,resources,C,R,E,Ops,program>:
  match result:
    case Query.LoweringRefused{}:Refused{world,compilation}
    case Query.Lowered{grants,queryBook}:Admitted{world,compilation,Evidence{namespace,handles,queries,resourceRecipes,componentInfo,resourceInfo,grants,queryBook,Resources.Book{resourceRecipes}}}
def supported(~S:Data,~components:L.Layout,~resources:L.Layout,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~program:Build.Program(~S,~L.columns(~S,components),~C,~R,~Ops),world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,compilation:D.Compilation<S,L.columns(~S,components),C,R,Ops>,+namespace:U32,+handles:List<&2,W.Handle<S>>,+componentInfo:List<&2,Schema.Info>,resourceInfo:List<&2,Description.Info>,valid:Bool) -> Inspection<S,components,resources,C,R,E,Ops,program>:
  match compilation valid:
    case compilation False{}:Refused{world,compilation}
    case D.Unsupported{caps,access,recipes} True{}:Refused{world,D.Unsupported{caps,access,recipes}}
    case D.Supported{D.Declaration{caps,access},D.Recipes{+queries,+resourceRecipes}} True{}:lowered(~S,~components,~resources,~C,~R,~E,~Ops,~program,world,D.Supported{D.Declaration{caps,access},D.Recipes{queries,resourceRecipes}},namespace,handles,queries,resourceRecipes,componentInfo,resourceInfo,Query.lower(~S,~L.columns(~S,components),~components,~{==},queries,componentInfo,namespace,handles))
def checked_resources(~S:Data,~components:L.Layout,~resources:L.Layout,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~program:Build.Program(~S,~L.columns(~S,components),~C,~R,~Ops),world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,namespace:U32,handles:List<&2,W.Handle<S>>,componentInfo:List<&2,Schema.Info>,resourceInfo:List<&2,Description.Info>,valid:Bool,compilation:D.Compilation<S,L.columns(~S,components),C,R,Ops>) -> Inspection<S,components,resources,C,R,E,Ops,program>:
  match compilation:
    case D.Unsupported{caps,access,recipes}:Refused{world,D.Unsupported{caps,access,recipes}}
    case D.Supported{declaration,D.Recipes{queries,+resourceRecipes}}:supported(~S,~components,~resources,~C,~R,~E,~Ops,~program,world,D.Supported{declaration,D.Recipes{queries,resourceRecipes}},namespace,handles,componentInfo,resourceInfo,Bool.and(valid,Bool.and(L.unique(resources),Resources.valid(~resources,resourceRecipes))))
def described_resources(~S:Data,~components:L.Layout,~resources:L.Layout,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~program:Build.Program(~S,~L.columns(~S,components),~C,~R,~Ops),+namespace:U32,allocator:Allocator.Allocator,columns:L.columns(~S,components),events:List<&2,E>,pending:List<Deferred.Command<W.World<S,L.columns(~S,components),L.resources(~S,resources),E>>>,registrations:List<&2,W.RegistrationMeta>,next:U32,clock:Clock.State,lifecycle:Notice.Journal<S>,handles:List<&2,W.Handle<S>>,componentInfo:List<&2,Schema.Info>,valid:Bool,result:Description.Description<S,resources>) -> Inspection<S,components,resources,C,R,E,Ops,program>:
  match result:
    case Description.Description{owners,info}:checked_resources(~S,~components,~resources,~C,~R,~E,~Ops,~program,W.World{namespace,allocator,columns,owners,events,pending,registrations,next,clock,lifecycle},namespace,handles,componentInfo,info,valid,Program.compile(~S,~L.columns(~S,components),~C,~R,~Ops,~program))
def described_components(~S:Data,~components:L.Layout,~resources:L.Layout,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~program:Build.Program(~S,~L.columns(~S,components),~C,~R,~Ops),namespace:U32,allocator:Allocator.Allocator,owners:L.resources(~S,resources),events:List<&2,E>,pending:List<Deferred.Command<W.World<S,L.columns(~S,components),L.resources(~S,resources),E>>>,registrations:List<&2,W.RegistrationMeta>,next:U32,clock:Clock.State,lifecycle:Notice.Journal<S>,handles:List<&2,W.Handle<S>>,result:Schema.Description<S,components>) -> Inspection<S,components,resources,C,R,E,Ops,program>:
  match result:
    case Schema.Description{columns,info,valid}:described_resources(~S,~components,~resources,~C,~R,~E,~Ops,~program,namespace,allocator,columns,events,pending,registrations,next,clock,lifecycle,handles,info,valid,Description.describe(~S,resources,L.AtLeaf{},owners))
def captured(~S:Data,~components:L.Layout,~resources:L.Layout,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~program:Build.Program(~S,~L.columns(~S,components),~C,~R,~Ops),result:W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & List<&2,W.Handle<S>>) -> Inspection<S,components,resources,C,R,E,Ops,program>:
  match result:
    case (W.World{namespace,allocator,columns,owners,events,pending,registrations,next,clock,lifecycle},handles):described_components(~S,~components,~resources,~C,~R,~E,~Ops,~program,namespace,allocator,owners,events,pending,registrations,next,clock,lifecycle,handles,Schema.describe(~S,components,L.AtLeaf{},columns))
# No clock entry, registration, body, or resource-owner extraction occurs here.
def inspect(~S:Data,~components:L.Layout,~resources:L.Layout,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~program:Build.Program(~S,~L.columns(~S,components),~C,~R,~Ops),world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>) -> Inspection<S,components,resources,C,R,E,Ops,program>:
  captured(~S,~components,~resources,~C,~R,~E,~Ops,~program,W.handles(~S,~L.columns(~S,components),~L.resources(~S,resources),~E,world))
