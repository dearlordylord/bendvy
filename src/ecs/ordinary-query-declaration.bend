import Base
import ./column.bend as Col
import ./component.bend as Cmp
import ./persistence-declaration.bend as Recipe
import ./ordinary-declaration.bend as Identity
import ./declared-family.bend as Family
import ./snapshot-leaf.bend as Leaf
import ./decode-data.bend as D
import ./compose.bend as Q
import ./capabilities.bend as Cap
import ./world.bend as W

# One constructor owns both operational grant/matcher and detached syntax.
# Metadata is library-produced; the application supplies no metadata argument.
# Query clause kind used by declaration-derived inspection and access metadata.
type Mode is Data:
  Read{}
  Write{}
  Optional{}
  With{}
  Without{}
  Added{}
  Changed{}
# Detached schema-scoped description of one component query requirement.
type Clause<S:Data> is Data:
  Clause{name:String,mode:Mode}
# Typed query declaration: grants, row selection and debug clauses share one source.
# Build with read/write/filter constructors and pair; raw construction is a trusted
# adapter boundary. H is threaded affinely; G determines available operations.
type Declaration<-S:Data,H:Type,G:Type> is Type:
  Declaration{grant:G,select:H -> H & Bool,clauses:List<&2,Clause<S>>}
# Return the declaration owner together with its detached debug clauses.
# Does not inspect a world, execute a query or advance a system cursor.
def observe(~S:Data,~H:Type,~G:Type,declaration:Declaration<S,H,G>) -> Declaration<S,H,G> & List<&2,Clause<S>>:
  match declaration:
    case Declaration{grant,select,+clauses}:(Declaration{grant,select,clauses},clauses)
# Consume the declaration and extract its typed operations for a system body.
# This supplies only G; a read declaration cannot confer write operations.
def grant(~S:Data,~H:Type,~G:Type,declaration:Declaration<S,H,G>) -> G:
  match declaration:
    case Declaration{grant,_,_}:grant

# Constructed-component counterpart of read, using the declaration-bound save recipe.
# take/put must preserve the matching Leaf.Component and all remaining storage.
# Requires presence and returns a detached V while retaining the affine payload.
# Reads return Found, ComponentAbsent or MissingEntity (including stale/foreign).
def constructed_read(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Leaf.Component<S,P,identity,save>,~put:Rest -> Leaf.Component<S,P,identity,save> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>>:
  Declaration{Q.read_family(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put)),Q.family_match(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put),~Q.Required{}),[Clause{Identity.key(~S,~P,identity),Read{}}]}

# Constructed-component counterpart of write, using the declaration-bound save recipe.
# take/put must preserve the matching Leaf.Component and all remaining storage.
# Requires presence and grants transactional payload replacement, including rollback.
# Failed sets retain an error in Frame; Compose reports AccessError and rolls back.
# The set grant consumes P and does not return rejected input to the caller.
def constructed_write(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Leaf.Component<S,P,identity,save>,~put:Rest -> Leaf.Component<S,P,identity,save> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Write<Q.Frame<S,Store,R,E>,P,V>>:
  Declaration{Q.write_family(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put)),Q.family_match(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put),~Q.Required{}),[Clause{Identity.key(~S,~P,identity),Write{}}]}

# Constructed-component counterpart of optional, using the declaration-bound save recipe.
# take/put must preserve the matching Leaf.Component and all remaining storage.
# Allows absence; reads return Found, ComponentAbsent or MissingEntity.
# Stale/foreign handles yield MissingEntity, never an optional matching row.
def constructed_optional(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Leaf.Component<S,P,identity,save>,~put:Rest -> Leaf.Component<S,P,identity,save> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>>:
  Declaration{Q.read_family(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put)),Q.family_match(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put),~Q.Optional{}),[Clause{Identity.key(~S,~P,identity),Optional{}}]}

# Constructed-component counterpart of with_component, using the declaration-bound save recipe.
# take/put must preserve the matching Leaf.Component and all remaining storage.
# Requires presence without granting payload access.
def constructed_with_component(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Leaf.Component<S,P,identity,save>,~put:Rest -> Leaf.Component<S,P,identity,save> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit>:
  Declaration{Unit{},Q.family_match(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put),~Q.Required{}),[Clause{Identity.key(~S,~P,identity),With{}}]}

# Constructed-component counterpart of without_component, using the declaration-bound save recipe.
# take/put must preserve the matching Leaf.Component and all remaining storage.
# Requires absence without granting payload access.
def constructed_without_component(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Leaf.Component<S,P,identity,save>,~put:Rest -> Leaf.Component<S,P,identity,save> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit>:
  Declaration{Unit{},Q.family_match(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put),~Q.Absent{}),[Clause{Identity.key(~S,~P,identity),Without{}}]}

# Constructed-component counterpart of added, using the declaration-bound save recipe.
# take/put must preserve the matching Leaf.Component and all remaining storage.
# Matches added stamps relative to the executing system cursor; grants no access.
def constructed_added(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Leaf.Component<S,P,identity,save>,~put:Rest -> Leaf.Component<S,P,identity,save> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit>:
  Declaration{Unit{},Q.lifecycle_match(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put),~Q.Added{}),[Clause{Identity.key(~S,~P,identity),Added{}}]}

# Constructed-component counterpart of changed, using the declaration-bound save recipe.
# take/put must preserve the matching Leaf.Component and all remaining storage.
# Matches changed stamps relative to the executing system cursor; grants no access.
def constructed_changed(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Leaf.Component<S,P,identity,save>,~put:Rest -> Leaf.Component<S,P,identity,save> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit>:
  Declaration{Unit{},Q.lifecycle_match(~S,~Store,~R,~E,~(Rest & Recipe.Constructed<S,P,identity,save>),~P,~V,~Token,~Family.take_column(~S,~P,~Store,~Rest,~identity,~save,~take),~Family.put_column(~S,~P,~Store,~Rest,~identity,~save,~put),~view,~Family.family(~S,~P,~Store,~Rest,~V,~Token,~identity,~save,~view,~take,~put),~Q.Changed{}),[Clause{Identity.key(~S,~P,identity),Changed{}}]}

# Read the selected component through a read declaration, returning owner H
# with Access<V>. The detached Data view does not copy the affine payload.
# Results are Found, ComponentAbsent or MissingEntity; stale/foreign handles
# produce MissingEntity. No payload owner is transferred to the reader.
def execute_read(~S:Data,~H:Type,~V:Data,~declaration:Declaration<S,H,Cap.Read<H,V>>,owner:H) -> H & Cmp.Access<V>:
  Cap.read(~H,~V,~grant(~S,~H,~Cap.Read<H,V>,declaration),owner)

# Consume the declaration to obtain its owner-threading row predicate.
# Selection grants no additional component access and does not enumerate rows.
def selector(~S:Data,~H:Type,~G:Type,declaration:Declaration<S,H,G>) -> H -> H & Bool:
  match declaration:
    case Declaration{_,select,_}:select
# Consume the declaration and return detached schema-scoped query metadata.
# Prefer observe when the caller also needs to retain the declaration.
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
def pair_selected(~H:Type,right:H -> H & Bool,observed:H & Bool) -> H & Bool:
  match observed:
    case (owner,False{}):(owner,False{})
    case (owner,True{}):right(owner)
def pair_select(~H:Type,left:H -> H & Bool,right:H -> H & Bool,owner:H) -> H & Bool:
  pair_selected(~H,right,left(owner))
def pair_parts(~S:Data,~H:Type,~L:Type,~R:Type,left:Declaration<S,H,L>,right:Declaration<S,H,R>) -> Declaration<S,H,L & R>:
  match left right:
    case Declaration{leftGrant,leftSelect,leftClauses} Declaration{rightGrant,rightSelect,rightClauses}:Declaration{(leftGrant,rightGrant),owner=>pair_select(~H,leftSelect,rightSelect,owner),List.append(&2,Clause<S>,leftClauses,rightClauses)}
# Compose two declarations for the same schema and owner into one query.
# Selection is conjunction, evaluated left then right with short circuiting;
# grants retain the nested (L & R) shape and clauses retain left-to-right order.
# Nest pair to combine more than two selections; it does not impose a row order.
# Example: examples/scheduled-health/registration.bend defines query().
def pair(~S:Data,~H:Type,~L:Type,~R:Type,~left:Declaration<S,H,L>,~right:Declaration<S,H,R>) -> Declaration<S,H,L & R>:
  pair_parts(~S,~H,~L,~R,left,right)

# Require this component and grant read access to its detached Data view.
# identity and the storage binding must describe the same schema component.
# view consumes and returns P, including affine payloads; it must not discard
# the payload. This declaration neither visits rows nor changes the world.
# Reads return Found, ComponentAbsent or MissingEntity (including stale/foreign).
# Example bindings and query(): examples/scheduled-health/registration.bend.
def read(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>>:
  Declaration{Q.read_family(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)}),Q.family_match(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)},~Q.Required{}),[Clause{Identity.key(~S,~P,identity),Read{}}]}

# Require this component and grant typed read/write operations to the body.
# The set operation consumes replacement P and returns the affine owner.
# Failed sets retain an error in Frame; Compose reports AccessError and rolls back.
# Rejected replacement payloads are not returned through this grant. Reads expose V.
# Writes participate in the enclosing system transaction and its rollback;
# declaring access performs no write. See scheduled-health/registration.bend.
def write(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Write<Q.Frame<S,Store,R,E>,P,V>>:
  Declaration{Q.write_family(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)}),Q.family_match(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)},~Q.Required{}),[Clause{Identity.key(~S,~P,identity),Write{}}]}

# Grant read access without excluding rows where the component is absent.
# The body handles Found/ComponentAbsent/MissingEntity; optional fabricates no V.
# Stale/foreign handles yield MissingEntity and never match as live rows.
# Payload projection consumes and returns P, preserving affine ownership.
def optional(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>>:
  Declaration{Q.read_family(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)}),Q.family_match(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)},~Q.Optional{}),[Clause{Identity.key(~S,~P,identity),Optional{}}]}

# Filter to entities with this component without granting its payload access.
# Produces Unit grants; combine with pair to add independently declared access.
def with_component(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit>:
  Declaration{Unit{},Q.family_match(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)},~Q.Present{}),[Clause{Identity.key(~S,~P,identity),With{}}]}

# Filter to entities without this component, granting no payload access.
# Membership follows the executing query and explicit structural barriers.
def without_component(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit>:
  Declaration{Unit{},Q.family_match(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)},~Q.Absent{}),[Clause{Identity.key(~S,~P,identity),Without{}}]}

# Filter by this component being added since the executing system cursor.
# Grants no payload access; combine with read/write to access matching values.
# Declaration creation and detached inspection do not consume lifecycle visibility.
def added(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit>:
  Declaration{Unit{},Q.lifecycle_match(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)},~Q.Added{}),[Clause{Identity.key(~S,~P,identity),Added{}}]}

# Filter by this component changing since the executing system cursor.
# Grants no payload access; cursor advancement follows system success/skip/failure
# rules, not creation or inspection of this declaration.
def changed(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit>:
  Declaration{Unit{},Q.lifecycle_match(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)},~Q.Changed{}),[Clause{Identity.key(~S,~P,identity),Changed{}}]}

# Declare required write access and a display function for its Data view.
# display formats detached V for enabled debug output; it never owns P.
# Failed sets retain an error in Frame; Compose reports AccessError and rolls back.
# The set grant consumes P without returning rejected input; see write.
def write_displayed(~S:Data,~P:Type,~Store:Type,~R:Type,~E:Data,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~display:V -> String,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Write<Q.Frame<S,Store,R,E>,P,V>>:
  Declaration{Q.write_family_displayed(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)},~display),Q.family_match(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~Cmp.Family{Identity.key(~S,~P,identity)},~Q.Required{}),[Clause{Identity.key(~S,~P,identity),Write{}}]}
