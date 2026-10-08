import Base
import ../../../../../../src/ecs/persistence-declaration.bend as Decl
import ../../../../../../src/ecs/decode-data.bend as D
import ../../../../../../src/ecs/column.bend as Col
import ../../../../../../src/ecs/ordinary-declaration.bend as Canonical

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
def insert(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,+declaration:Decl.Constructed<S,P,identity,project>,column:Col.Column<S,P>,id:U32,owner:P) -> Insertion<S,P,identity,project>:
  admitted(~S,~P,~identity,~project,declaration,column,id,Decl.validate(~S,~P,~identity,~project,declaration,owner))
