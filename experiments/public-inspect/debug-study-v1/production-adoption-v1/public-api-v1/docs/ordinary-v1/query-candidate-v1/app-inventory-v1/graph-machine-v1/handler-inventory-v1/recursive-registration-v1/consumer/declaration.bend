import Base
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/persistence-declaration.bend as Recipe
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/declared-family.bend as Family
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/snapshot-leaf.bend as Leaf
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

# One constructor owns both operational grant/matcher and detached syntax.
# Metadata is library-produced; the application supplies no metadata argument.
type Mode is Data:
  Read{}
  Write{}
  Optional{}
  With{}
  Without{}
  Added{}
  Changed{}
type Clause<S:Data> is Data:
  Clause{name:String,mode:Mode}
type Declaration<-S:Data,H:Type,G:Type> is Type:
  Declaration{grant:G,select:H -> H & Bool,clauses:List<&2,Clause<S>>}
def observe(~S:Data,~H:Type,~G:Type,declaration:Declaration<S,H,G>) -> Declaration<S,H,G> & List<&2,Clause<S>>:
  match declaration:
    case Declaration{grant,select,+clauses}:(Declaration{grant,select,clauses},clauses)
def grant(~S:Data,~H:Type,~G:Type,declaration:Declaration<S,H,G>) -> G:
  match declaration:
    case Declaration{grant,_,_}:grant

def constructed_read(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Leaf.Component<S,P,identity,save>,~put:Rest -> Leaf.Component<S,P,identity,save> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>>:
  Declaration{Q.read_family(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put)),Q.family_match(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put),~Q.Required{}),[Clause{Identity.key(~S,~P,identity),Read{}}]}

def constructed_write(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Leaf.Component<S,P,identity,save>,~put:Rest -> Leaf.Component<S,P,identity,save> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Write<Q.Frame<S,Store,R,E>,P,V>>:
  Declaration{Q.write_family(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put)),Q.family_match(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put),~Q.Required{}),[Clause{Identity.key(~S,~P,identity),Write{}}]}

def constructed_optional(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Leaf.Component<S,P,identity,save>,~put:Rest -> Leaf.Component<S,P,identity,save> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>>:
  Declaration{Q.read_family(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put)),Q.family_match(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put),~Q.Optional{}),[Clause{Identity.key(~S,~P,identity),Optional{}}]}

def constructed_with_component(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Leaf.Component<S,P,identity,save>,~put:Rest -> Leaf.Component<S,P,identity,save> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit>:
  Declaration{Unit{},Q.family_match(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put),~Q.Required{}),[Clause{Identity.key(~S,~P,identity),With{}}]}

def constructed_without_component(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Leaf.Component<S,P,identity,save>,~put:Rest -> Leaf.Component<S,P,identity,save> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit>:
  Declaration{Unit{},Q.family_match(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put),~Q.Absent{}),[Clause{Identity.key(~S,~P,identity),Without{}}]}

def constructed_added(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Leaf.Component<S,P,identity,save>,~put:Rest -> Leaf.Component<S,P,identity,save> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit>:
  Declaration{Unit{},Q.lifecycle_match(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put),~Q.Added{}),[Clause{Identity.key(~S,~P,identity),Added{}}]}

def constructed_changed(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Leaf.Component<S,P,identity,save>,~put:Rest -> Leaf.Component<S,P,identity,save> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit>:
  Declaration{Unit{},Q.lifecycle_match(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put),~Q.Changed{}),[Clause{Identity.key(~S,~P,identity),Changed{}}]}

def execute_read(~S:Data,~H:Type,~V:Data,~declaration:Declaration<S,H,Cap.Read<H,V>>,owner:H) -> H & Cmp.Access<V>:
  Cap.read(~H,~V,~grant(~S,~H,~Cap.Read<H,V>,declaration),owner)

def selector(~S:Data,~H:Type,~G:Type,declaration:Declaration<S,H,G>) -> H -> H & Bool:
  match declaration:
    case Declaration{_,select,_}:select
def clauses(~S:Data,~H:Type,~G:Type,declaration:Declaration<S,H,G>) -> List<&2,Clause<S>>:
  match declaration:
    case Declaration{_,_,clauses}:clauses
def selected_right(~H:Type,selected:Bool,observed:H & Bool) -> H & Bool:
  match observed:
    case (owner,right):(owner,Bool.and(selected,right))
def selected_left(~H:Type,~right:H -> H & Bool,observed:H & Bool) -> H & Bool:
  match observed:
    case (owner,False{}):(owner,False{})
    case (owner,True{}):right(owner)
def both(~H:Type,~left:H -> H & Bool,~right:H -> H & Bool,owner:H) -> H & Bool:
  selected_left(~H,~right,left(owner))
def pair(~S:Data,~H:Type,~L:Type,~R:Type,~left:Declaration<S,H,L>,~right:Declaration<S,H,R>) -> Declaration<S,H,L & R>:
  Declaration{(grant(~S,~H,~L,left),grant(~S,~H,~R,right)),both(~H,~selector(~S,~H,~L,left),~selector(~S,~H,~R,right)),List.append(&2,Clause<S>,clauses(~S,~H,~L,left),clauses(~S,~H,~R,right))}

def read(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>>:
  Declaration{Q.read_family(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)}),Q.family_match(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)},~Q.Required{}),[Clause{Identity.key(~S,~P,identity),Read{}}]}

def write(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Write<Q.Frame<S,Store,R,E>,P,V>>:
  Declaration{Q.write_family(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)}),Q.family_match(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)},~Q.Required{}),[Clause{Identity.key(~S,~P,identity),Write{}}]}

def optional(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>>:
  Declaration{Q.read_family(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)}),Q.family_match(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)},~Q.Optional{}),[Clause{Identity.key(~S,~P,identity),Optional{}}]}

def with_component(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit>:
  Declaration{Unit{},Q.family_match(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)},~Q.Present{}),[Clause{Identity.key(~S,~P,identity),With{}}]}

def without_component(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit>:
  Declaration{Unit{},Q.family_match(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)},~Q.Absent{}),[Clause{Identity.key(~S,~P,identity),Without{}}]}

def added(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit>:
  Declaration{Unit{},Q.lifecycle_match(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)},~Q.Added{}),[Clause{Identity.key(~S,~P,identity),Added{}}]}

def changed(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit>:
  Declaration{Unit{},Q.lifecycle_match(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)},~Q.Changed{}),[Clause{Identity.key(~S,~P,identity),Changed{}}]}
