import Base
import ../../../../src/ecs/decode-construction.bend as Constructor
import ../../../../src/ecs/bundle-construction.bend as Build
import ../../../../src/ecs/persistence-declaration.bend as Decl
import ../../../../src/ecs/decode-data.bend as D
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/ordinary-declaration.bend as Canonical

# Fixture caller policy over EXISTING validation receipt and column outcome.
# Rejection retains incoming owner before insertion; no save refusal/rollback.
type Insertion<-S:Data,-P:Type,-identity:Canonical.Declaration<S,P>,-project:P -> P & D.Raw> is Type:
  Insertion{declaration:Decl.Constructed<S,P,identity,project>,checked:D.Checked,outcome:Col.SwapOutcome<S,P>}
def admitted(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,column:Col.Column<S,P>,id:U32,receipt:D.Receipt<P>) -> Insertion<S,P,identity,project>:
  match receipt:
    case D.Receipt{owner,+checked}:
      match checked:
        case D.Accepted{value}:Insertion{declaration,checked,Col.swap(~S,~P,column,id,Some{owner})}
        case D.Rejected{error}:Insertion{declaration,checked,Col.Rejected{column,Some{owner}}}
# Explicit reversible identity constructor: arbitrary affine payload is moved once.
def undo(~P:Type,owner:P) -> P:owner
def build(~P:Type,owner:P,canonical:D.Raw) -> Build.Construction<P,P,D.Error>:
  Build.Constructed{owner,undo(~P)}
def projected(~P:Type,observed:P & D.Raw) -> D.Receipt<P>:
  match observed:
    case (owner,canonical):D.Receipt{owner,D.Accepted{canonical}}
def constructed(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,column:Col.Column<S,P>,id:U32,result:Build.Construction<P,P,D.Error>) -> Insertion<S,P,identity,project>:
  match result:
    case Build.Constructed{owner,_}:admitted(~S,~P,~identity,~project,declaration,column,id,projected(~P,project(owner)))
    case Build.Invalid{owner,+error}:Insertion{declaration,D.Rejected{error},Col.Rejected{column,Some{owner}}}
def insert(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,+declaration:Decl.Constructed<S,P,identity,project>,column:Col.Column<S,P>,id:U32,owner:P) -> Insertion<S,P,identity,project>:
  constructed(~S,~P,~identity,~project,declaration,column,id,Constructor.construct(~S,~P,~P,~identity,~project,~project,~build(~P),Constructor.factory(~S,~P,~P,~identity,~project,~project,~build(~P),declaration),owner))
