import Base
import ../../../../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../../../../src/ecs/persistence-declaration.bend as Recipe
import ../../../../../../../src/ecs/snapshot-leaf.bend as Leaf
import ../../../../../../../src/ecs/decode-data.bend as D
import ../../../../../../../src/ecs/column.bend as Col
import ../dependencies/experiments/public-simulation/bend-v1/owner-view.bend as View

type Category is Data:
  Plain{}
  Transient{}
  Constructed{}
type Schema is Data:
  Schema{}
def identity(key:String) -> Identity.Declaration<Schema,Array<U32>>:
  Identity.component(~Schema,~Array<U32>,key)
def numbers(values:List<&2,U32>) -> List<&2,D.Raw>:
  match values:
    case []:[]
    case value <> rest:D.Number{value} <> numbers(rest)
def save_fetched(observed:Array<U32> & View.FullCell) -> Array<U32> & D.Raw:
  match observed:
    case (owner,View.FullCell{_,values}):(owner,D.Array{numbers(values)})
def save(owner:Array<U32>) -> Array<U32> & D.Raw:
  save_fetched(View.view(owner))
type PlainSlot<-key:String> is Type:
  PlainSlot{column:Col.Column<Schema,Array<U32>>,declaration:Recipe.Plain<Schema,Array<U32>,identity(key)>}

type Store<-P:Type,-V:Type,-H:Type> is Type:
  Store{position:P,velocity:V,health:H}
def plain_take(~key:String,owner:PlainSlot<key>) -> Recipe.Plain<Schema,Array<U32>,identity(key)> & Col.Column<Schema,Array<U32>>:
  match owner:
    case PlainSlot{column,declaration}:(declaration,column)
def plain_put(~key:String,declaration:Recipe.Plain<Schema,Array<U32>,identity(key)>,column:Col.Column<Schema,Array<U32>>) -> PlainSlot<key>:
  PlainSlot{column,declaration}
def plain_position() -> Type:
  PlainSlot<"Position">
def plain_velocity() -> Type:
  PlainSlot<"Velocity">
def plain_health() -> Type:
  PlainSlot<"Health">
def plain_store() -> Type:
  Store<plain_position(),plain_velocity(),plain_health()>
def transient_take(~key:String,owner:Leaf.TransientComponent<Schema,Array<U32>,identity(key)>) -> Recipe.Transient<Schema,Array<U32>,identity(key)> & Col.Column<Schema,Array<U32>>:
  match owner:
    case Leaf.TransientComponent{column,declaration}:(declaration,column)
def transient_put(~key:String,declaration:Recipe.Transient<Schema,Array<U32>,identity(key)>,column:Col.Column<Schema,Array<U32>>) -> Leaf.TransientComponent<Schema,Array<U32>,identity(key)>:
  Leaf.TransientComponent{column,declaration}
def transient_position() -> Type:
  Leaf.TransientComponent<Schema,Array<U32>,identity("Position")>
def transient_velocity() -> Type:
  Leaf.TransientComponent<Schema,Array<U32>,identity("Velocity")>
def transient_health() -> Type:
  Leaf.TransientComponent<Schema,Array<U32>,identity("Health")>
def transient_store() -> Type:
  Store<transient_position(),transient_velocity(),transient_health()>
def constructed_take(~key:String,owner:Leaf.Component<Schema,Array<U32>,identity(key),save>) -> Recipe.Constructed<Schema,Array<U32>,identity(key),save> & Col.Column<Schema,Array<U32>>:
  match owner:
    case Leaf.Component{column,declaration}:(declaration,column)
def constructed_put(~key:String,declaration:Recipe.Constructed<Schema,Array<U32>,identity(key),save>,column:Col.Column<Schema,Array<U32>>) -> Leaf.Component<Schema,Array<U32>,identity(key),save>:
  Leaf.Component{column,declaration}
def constructed_position() -> Type:
  Leaf.Component<Schema,Array<U32>,identity("Position"),save>
def constructed_velocity() -> Type:
  Leaf.Component<Schema,Array<U32>,identity("Velocity"),save>
def constructed_health() -> Type:
  Leaf.Component<Schema,Array<U32>,identity("Health"),save>
def constructed_store() -> Type:
  Store<constructed_position(),constructed_velocity(),constructed_health()>
def position_split(~P:Type,~V:Type,~H:Type,~RecipeOwner:Data,v: V,h: H,observed:RecipeOwner & Col.Column<Schema,Array<U32>>) -> ((V & H) & RecipeOwner) & Col.Column<Schema,Array<U32>>:
  match observed:
    case (recipe,column):(((v,h),recipe),column)
def position_take(~P:Type,~V:Type,~H:Type,~RecipeOwner:Data,~take:P -> RecipeOwner & Col.Column<Schema,Array<U32>>,owner:Store<P,V,H>) -> ((V & H) & RecipeOwner) & Col.Column<Schema,Array<U32>>:
  match owner:
    case Store{position,velocity,health}:position_split(~P,~V,~H,~RecipeOwner,velocity,health,take(position))
def position_put(~P:Type,~V:Type,~H:Type,~RecipeOwner:Data,~put:RecipeOwner -> Col.Column<Schema,Array<U32>> -> P,rest:(V & H) & RecipeOwner,column:Col.Column<Schema,Array<U32>>) -> Store<P,V,H>:
  match rest:
    case ((v,h),recipe):Store{put(recipe,column), v, h}
def velocity_split(~P:Type,~V:Type,~H:Type,~RecipeOwner:Data,p: P,h: H,observed:RecipeOwner & Col.Column<Schema,Array<U32>>) -> ((P & H) & RecipeOwner) & Col.Column<Schema,Array<U32>>:
  match observed:
    case (recipe,column):(((p,h),recipe),column)
def velocity_take(~P:Type,~V:Type,~H:Type,~RecipeOwner:Data,~take:V -> RecipeOwner & Col.Column<Schema,Array<U32>>,owner:Store<P,V,H>) -> ((P & H) & RecipeOwner) & Col.Column<Schema,Array<U32>>:
  match owner:
    case Store{position,velocity,health}:velocity_split(~P,~V,~H,~RecipeOwner,position,health,take(velocity))
def velocity_put(~P:Type,~V:Type,~H:Type,~RecipeOwner:Data,~put:RecipeOwner -> Col.Column<Schema,Array<U32>> -> V,rest:(P & H) & RecipeOwner,column:Col.Column<Schema,Array<U32>>) -> Store<P,V,H>:
  match rest:
    case ((p,h),recipe):Store{p, put(recipe,column), h}
def health_split(~P:Type,~V:Type,~H:Type,~RecipeOwner:Data,p: P,v: V,observed:RecipeOwner & Col.Column<Schema,Array<U32>>) -> ((P & V) & RecipeOwner) & Col.Column<Schema,Array<U32>>:
  match observed:
    case (recipe,column):(((p,v),recipe),column)
def health_take(~P:Type,~V:Type,~H:Type,~RecipeOwner:Data,~take:H -> RecipeOwner & Col.Column<Schema,Array<U32>>,owner:Store<P,V,H>) -> ((P & V) & RecipeOwner) & Col.Column<Schema,Array<U32>>:
  match owner:
    case Store{position,velocity,health}:health_split(~P,~V,~H,~RecipeOwner,position,velocity,take(health))
def health_put(~P:Type,~V:Type,~H:Type,~RecipeOwner:Data,~put:RecipeOwner -> Col.Column<Schema,Array<U32>> -> H,rest:(P & V) & RecipeOwner,column:Col.Column<Schema,Array<U32>>) -> Store<P,V,H>:
  match rest:
    case ((p,v),recipe):Store{p, v, put(recipe,column)}
