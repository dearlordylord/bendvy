import Base
import ./ordinary-declaration.bend as C
import ./decode-data.bend as D

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
# This low-level operation consumes Gate; snapshot-leaf reconstructs it from
# the retained ordinary declaration for repeated owner-preserving saves.
def export_owner(~S:Data,~P:Type,~declaration:C.Declaration<S,P>,gate:Gate<S,P,declaration>,owner:P) -> P & Field:
  match gate:
    case Transient{}:(owner,Omitted{C.key(~S,~P,declaration)})
    case Persisted{_,project}:projected(~P,C.key(~S,~P,declaration),project(owner))
