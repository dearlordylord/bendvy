import Base
import ./ordinary-declaration.bend as C
import ./persistence-declaration.bend as Decl
import ./decode-data.bend as D
import ./decode.bend as Decode

type Leaf<-S:Data,-P:Type,-identity:C.Declaration<S,P>,-project:P -> P & D.Raw> is Type:
  Plain{}
  Transient{}
  Constructed{declaration:Decl.Constructed<S,P,identity,project>}
type Refusal is Data:
  PlainUnserializable{key:String}
  InvalidProjection{key:String,error:D.Error}
  MalformedColumn{key:String}
  DescriptorMismatch{expected:String,actual:String}
type Field is Data:
  Omitted{}
  Saved{field:D.Field}
  Refused{reason:Refusal}

def plain(~S:Data,~P:Type,~identity:C.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Plain<S,P,identity>) -> Leaf<S,P,identity,project>:Plain{}
def transient(~S:Data,~P:Type,~identity:C.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Transient<S,P,identity>) -> Leaf<S,P,identity,project>:Transient{}
def constructed(~S:Data,~P:Type,~identity:C.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>) -> Leaf<S,P,identity,project>:Constructed{declaration}
def eligibility(~S:Data,~P:Type,~identity:C.Declaration<S,P>,~project:P -> P & D.Raw,recipe:Leaf<S,P,identity,project>) -> Leaf<S,P,identity,project> & Maybe<&2,Refusal>:
  match recipe:
    case Plain{}:(Plain{},Some{PlainUnserializable{C.key(~S,~P,identity)}})
    case Transient{}:(Transient{},None{})
    case Constructed{declaration}:(Constructed{declaration},None{})
def projected(~S:Data,~P:Type,~identity:C.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,result:D.Receipt<P>) -> Leaf<S,P,identity,project> & (P & Field):
  match result:
    case D.Receipt{owner,D.Accepted{value}}:(Constructed{declaration},(owner,Saved{D.Field{C.key(~S,~P,identity),value}}))
    case D.Receipt{owner,D.Rejected{error}}:(Constructed{declaration},(owner,Refused{InvalidProjection{C.key(~S,~P,identity),error}}))
# The same retained ordinary declaration supplies codec and actual-owner
# projection. Transient and Plain never evaluate the projection.
def export(~S:Data,~P:Type,~identity:C.Declaration<S,P>,~project:P -> P & D.Raw,recipe:Leaf<S,P,identity,project>,owner:P) -> Leaf<S,P,identity,project> & (P & Field):
  match recipe:
    case Plain{}:(Plain{},(owner,Refused{PlainUnserializable{C.key(~S,~P,identity)}}))
    case Transient{}:(Transient{},(owner,Omitted{}))
    case Constructed{+declaration}:projected(~S,~P,~identity,~project,declaration,Decode.decode_owner(~P,~project,Decl.codec(~S,~P,~identity,~project,declaration),owner))
