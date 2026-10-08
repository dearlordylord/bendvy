import Base
import ./game.bend as Game
import ../../../../../../src/ecs/persistence-declaration.bend as Decl
import ../../../../../../src/ecs/snapshot-leaf.bend as Leaf
import ./legacy-fixture.bend as F
import ./legacy-owner.bend as Old
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/column.bend as Col
import ../../../../../../src/ecs/decode-data.bend as D
import ../../../../../../src/ecs/owner-product.bend as Product

# Evidence observer only: every physical owner/recipe is returned intact.
def transient_done(~S:Data,saved:Game.Saved(~S),savedData:Old.ColumnOwner,scratchRecipe:Decl.Transient<S,F.Payload,Game.scratch(~S)>,units:Product.Owner<Unit,Unit>,observed:Col.Column<S,F.Payload> & Old.ColumnOwner) -> Game.Store(~S) & Old.StoreOwner:
  match saved:
    case Leaf.Component{column,+declaration}:
      match observed:
        case (transient,transientData):(Product.Owner{Product.Owner{Leaf.Component{column,declaration},Leaf.TransientComponent{transient,scratchRecipe}},units},Old.StoreOwner{savedData,transientData,Decl.codec(~S,~F.Payload,~F.declaration(~S),~F.project,declaration)})
def saved_done(~S:Data,+handles:List<&2,W.Handle<S>>,savedRecipe:Decl.Constructed<S,F.Payload,F.declaration(~S),F.project>,scratch:Game.Scratch(~S),units:Product.Owner<Unit,Unit>,observed:Col.Column<S,F.Payload> & Old.ColumnOwner) -> Game.Store(~S) & Old.StoreOwner:
  match scratch:
    case Leaf.TransientComponent{column,declaration}:
      match observed:
        case (saved,savedData):transient_done(~S,Leaf.Component{saved,savedRecipe},savedData,declaration,units,Old.column(~S,"Scratch",handles,column))
def store(~S:Data,+handles:List<&2,W.Handle<S>>,owner:Game.Store(~S)) -> Game.Store(~S) & Old.StoreOwner:
  match owner:
    case Product.Owner{Product.Owner{Leaf.Component{column,declaration},scratch},units}:saved_done(~S,handles,declaration,scratch,units,Old.column(~S,F.saved_key(~S),handles,column))
def transient_resource_done(~S:Data,saved:Game.Settings(~S),savedData:D.Raw,scratchRecipe:Decl.Transient<S,F.Payload,Game.scratch_settings(~S)>,units:Product.Owner<Unit,Unit>,observed:F.Payload & D.Raw) -> Game.ResourceStore(~S) & Old.ResourceOwner:
  match saved:
    case Leaf.Resource{owner,+declaration}:
      match observed:
        case (transient,transientData):(Product.Owner{units,Product.Owner{Leaf.Resource{owner,declaration},Leaf.TransientResource{transient,scratchRecipe}}},Old.ResourceOwner{savedData,transientData,Decl.codec(~S,~F.Payload,~Game.settings(~S),~F.project,declaration)})
def saved_resource_done(~S:Data,savedRecipe:Decl.Constructed<S,F.Payload,Game.settings(~S),F.project>,scratch:Game.ScratchSettings(~S),units:Product.Owner<Unit,Unit>,observed:F.Payload & D.Raw) -> Game.ResourceStore(~S) & Old.ResourceOwner:
  match scratch:
    case Leaf.TransientResource{owner,declaration}:
      match observed:
        case (saved,savedData):transient_resource_done(~S,Leaf.Resource{saved,savedRecipe},savedData,declaration,units,F.project(owner))
def resource(~S:Data,owner:Game.ResourceStore(~S)) -> Game.ResourceStore(~S) & Old.ResourceOwner:
  match owner:
    case Product.Owner{units,Product.Owner{Leaf.Resource{owner,declaration},scratch}}:saved_resource_done(~S,declaration,scratch,units,F.project(owner))
