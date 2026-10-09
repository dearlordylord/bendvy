import Base
import ./ordinary-declaration.bend as Identity
import ./persistence-declaration.bend as Decl
import ./snapshot-leaf.bend as Leaf
import ./decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as SF

# Closed trusted schema lenses, as in existing component.Family. The retained
# recipe becomes part of Family's Rest and survives ordinary column operations.
def split(~S:Data,~P:Type,~Rest:Type,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,observed:Rest & Leaf.Component<S,P,identity,save>) -> (Rest & Decl.Constructed<S,P,identity,save>) & Col.Column<S,P>:
  match observed:
    case (rest,Leaf.Component{column,declaration}):((rest,declaration),column)
def take_column(~S:Data,~P:Type,~Store:Type,~Rest:Type,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~take:Store -> Rest & Leaf.Component<S,P,identity,save>,owner:Store) -> (Rest & Decl.Constructed<S,P,identity,save>) & Col.Column<S,P>:
  split(~S,~P,~Rest,~identity,~save,take(owner))
def put_column(~S:Data,~P:Type,~Store:Type,~Rest:Type,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~put:Rest -> Leaf.Component<S,P,identity,save> -> Store,rest:Rest & Decl.Constructed<S,P,identity,save>,column:Col.Column<S,P>) -> Store:
  match rest:
    case (rest,declaration):put(rest,Leaf.Component{column,declaration})
def family(~S:Data,~P:Type,~Store:Type,~Rest:Type,~V:Data,~Token:Data,~identity:Identity.Declaration<S,P>,~save:P -> P & D.Raw,~view:P -> P & V,~take:Store -> Rest & Leaf.Component<S,P,identity,save>,~put:Rest -> Leaf.Component<S,P,identity,save> -> Store) -> Cmp.Family<S,Store,Rest & Decl.Constructed<S,P,identity,save>,P,V,Token,take_column(~S,~P,~Store,~Rest,~identity,~save,~take),put_column(~S,~P,~Store,~Rest,~identity,~save,~put),view>:
  Cmp.Family{Identity.key(~S,~P,identity)}
def descriptor(~S:Data,~P:Type,~Token:Data,~identity:Identity.Declaration<S,P>) -> SF.Descriptor<S,Token,P>:
  +key=Identity.key(~S,~P,identity)
  SF.Descriptor{SF.Component{},key,key}
