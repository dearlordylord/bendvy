import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-61-audit/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as C
import ./reference-source/typed.bend as D

# Trusted schema-author witness, not an unforgeable public constructor.
# Decoder describes untrusted DATA validation; no implicit Raw -> P inverse.
type Gate<-S:Data,-P:Type,-declaration:C.Declaration<S,P>> is Type:
  Transient{}
  Persisted{codec:D.Codec,project:P -> P & D.Raw}
type Field is Data:
  Omitted{name:String}
  Saved{name:String,value:D.Raw}
def transient(~S:Data,~P:Type,~declaration:C.Declaration<S,P>) -> Gate<S,P,declaration>:
  Transient{}
def persisted(~S:Data,~P:Type,~declaration:C.Declaration<S,P>,codec:D.Codec,project:P -> P & D.Raw) -> Gate<S,P,declaration>:
  Persisted{codec,project}
def projected(~P:Type,name:String,observed:P & D.Raw) -> P & Field:
  match observed:
    case (owner,value):(owner,Saved{name,value})
# Static eligibility mirrors TS Gate: export itself does not run its decoder.
# Gate consumed here: retained multi-save capability is future integration.
def export_owner(~S:Data,~P:Type,~declaration:C.Declaration<S,P>,gate:Gate<S,P,declaration>,owner:P) -> P & Field:
  match gate:
    case Transient{}:(owner,Omitted{C.key(~S,~P,declaration)})
    case Persisted{_,project}:projected(~P,C.key(~S,~P,declaration),project(owner))

# INTERNAL validation study. Ordinary export above remains unchanged.
# Actual retained Codec validates projected Data; no payload construction/inverse.
type Validation is Data:
  Skipped{}
  Validated{result:D.Checked}
def validation_done(~P:Type,result:D.Receipt<P>) -> P & Validation:
  match result:
    case D.Receipt{owner,checked}:(owner,Validated{checked})
def projected_validation(~P:Type,fuel:Nat,codec:D.Codec,observed:P & D.Raw) -> P & Validation:
  match observed:
    case (owner,description):validation_done(~P,D.owned(~P,fuel,codec,D.Owned{owner,description}))
def validate_projection(~S:Data,~P:Type,~declaration:C.Declaration<S,P>,fuel:Nat,gate:Gate<S,P,declaration>,owner:P) -> P & Validation:
  match gate:
    case Transient{}:(owner,Skipped{})
    case Persisted{codec,project}:projected_validation(~P,fuel,codec,project(owner))
