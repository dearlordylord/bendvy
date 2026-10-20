import ./ordinary-app-records.bend as Leaf
import Base
import ./ordinary-app-registration-fields.bend as Records
import ./ordinary-app-description.bend as Description
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-observation-data.bend as DTO
# Affine App carrier retaining actual World, heterogeneous registration owners,
# observation recipe and debug flag. observe/fold are trusted closed setup adapters;
# metadata and detached observations do not themselves grant gameplay operations.
type Registered<S:Data,World:Type,Owners:Type,Rows:Data,-observe:World -> World & DTO.Observation<Rows>,-fold:Owners -> Owners & List<&2,Records.Fields<S>>> is Type:
  Registered{world:World,owners:Owners,recipe:Tree.Recipe<World,Rows,observe>,debug:Bool}
# Advanced empty observer returning the actual World with Unit rows and no text.
# It does not enumerate entities, register readers or apply pending commands.
def empty_observe(~World:Type,world:World) -> World & DTO.Observation<Unit>:
  (world,DTO.Observation{Unit{},[]})
# Start an App with the actual World, Unit registration owner and empty observer.
# Debug is disabled; this performs no registration or gameplay execution.
def empty(~S:Data,~World:Type,world:World) -> Registered<S,World,Unit,Unit,empty_observe(~World),Leaf.empty(~S)>:
  Registered{world,Unit{},Tree.Recipe{},False{}}
# Replace only the observation-enable flag, returning actual World/owners/recipe.
# Enabling observation does not add gameplay access or execute a system.
def enabled(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,app:Registered<S,World,Owners,Rows,observe,fold>,flag:Bool) -> Registered<S,World,Owners,Rows,observe,fold>:
  match app:
    case Registered{world,owners,recipe,_}:Registered{world,owners,recipe,flag}
def observed(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,owners:Owners,fields:List<&2,Records.Fields<S>>,result:World & DTO.Observation<Rows>) -> Registered<S,World,Owners,Rows,observe,fold> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>:
  match result:
    case (world,view):(Registered{world,owners,Tree.Recipe{},True{}},Some{DTO.Product{Description.bindings(~S,fields),view}})
def folded(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,world:World,result:Owners & List<&2,Records.Fields<S>>) -> Registered<S,World,Owners,Rows,observe,fold> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>:
  match result:
    case (owners,fields):observed(~S,~World,~Owners,~Rows,~observe,~fold,owners,fields,observe(world))
# Return App and optional detached bindings/observation. Disabled returns None
# before calling fold or observe. Enabled folds registration owners first, then
# observes World, retaining both returned owners. The callbacks remain trusted;
# this wrapper is not a universal noninterference proof or a restorable save.
# See ordinary-app-component.bend and examples/scheduled-health/application.bend.
def snapshot(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,app:Registered<S,World,Owners,Rows,observe,fold>) -> Registered<S,World,Owners,Rows,observe,fold> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>:
  match app:
    case Registered{world,owners,recipe,False{}}:(Registered{world,owners,recipe,False{}},None{})
    case Registered{world,owners,_,True{}}:folded(~S,~World,~Owners,~Rows,~observe,~fold,world,fold(owners))
# Advanced registration-composition adapter pairing existing and leaf owners.
# Combine observations and field folds in left-before-right order, preserving the
# supplied World and debug flag. This does not itself register or run the leaf.
def appended(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~Leaf:Type,~Value:Data,~leafObserve:World -> World & DTO.Observation<Value>,~leafFold:Leaf -> Leaf & List<&2,Records.Fields<S>>,world:World,owners:Owners,leaf:Leaf,debug:Bool) -> Registered<S,World,Owners & Leaf,DTO.Product<Rows,Value>,Tree.observe_pair(~World,~Rows,~Value,~observe,~leafObserve),Leaf.fold_pair(~S,~Owners,~Leaf,~fold,~leafFold)>:
  Registered{world,(owners,leaf),Tree.Recipe{},debug}
