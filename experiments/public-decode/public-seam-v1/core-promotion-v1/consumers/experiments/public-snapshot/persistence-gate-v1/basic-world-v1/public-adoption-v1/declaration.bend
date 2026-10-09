import Base
import ../../../../public-decode/typed.bend as D
import ../../../../public-decode/public.bend as Public
import ../../../../public-decode/complete-v1/decode.bend as Complete
import ../../../../public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Canonical

# Extensions of ONE ordinary nominal identity, shared with ordinary query paths.
# Schema authoring is trusted; no language-wide constructor secrecy is asserted.
type Plain<-S:Data,-P:Type,-identity:Canonical.Declaration<S,P>> is Data:
  Plain{}
type Transient<-S:Data,-P:Type,-identity:Canonical.Declaration<S,P>> is Data:
  Transient{}
type Constructed<-S:Data,-P:Type,-identity:Canonical.Declaration<S,P>,-project:P -> P & D.Raw> is Data:
  Constructed{codec:D.Codec}
def plain(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>) -> Plain<S,P,identity>:
  Plain{}
def transient(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>) -> Transient<S,P,identity>:
  Transient{}
def constructed(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,codec:D.Codec) -> Constructed<S,P,identity,project>:
  Constructed{codec}
def codec(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Constructed<S,P,identity,project>) -> D.Codec:
  match declaration:
    case Constructed{codec}:codec

# The SAME retained declaration supplies complete #46 validation and save codec.
# Projects once; no caller fuel/depth and no automatic Raw -> arbitrary P inverse.
def validate(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Constructed<S,P,identity,project>,owner:P) -> D.Receipt<P>:
  Complete.decode_owner(~P,~project,codec(~S,~P,~identity,~project,declaration),owner)
def prepare(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,+declaration:Constructed<S,P,identity,project>,owner:P) -> Constructed<S,P,identity,project> & D.Receipt<P>:
  (declaration,validate(~S,~P,~identity,~project,declaration,owner))

# Actual generic public admission callback retains every incoming affine owner.
# The retained list is a transport context, never the live ECS Store.
type Context<-S:Data,-P:Type,-identity:Canonical.Declaration<S,P>,-project:P -> P & D.Raw> is Type:
  Context{declaration:Constructed<S,P,identity,project>,retained:List<P>}
def decode(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,context:Context<S,P,identity,project>,owner:P) -> Context<S,P,identity,project> & D.Receipt<P>:
  match context:
    case Context{+declaration,retained}:(Context{declaration,retained},validate(~S,~P,~identity,~project,declaration,owner))
def admit(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,context:Context<S,P,identity,project>,receipt:D.Receipt<P>) -> Context<S,P,identity,project> & D.Checked:
  match context receipt:
    case Context{declaration,retained} D.Receipt{owner,checked}:(Context{declaration,owner <> retained},checked)
def request(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,context:Context<S,P,identity,project>,owner:P) -> Context<S,P,identity,project> & D.Checked:
  Public.request(~P,~Context<S,P,identity,project>,~D.Checked,~decode(~S,~P,~identity,~project),~admit(~S,~P,~identity,~project),context,owner)
