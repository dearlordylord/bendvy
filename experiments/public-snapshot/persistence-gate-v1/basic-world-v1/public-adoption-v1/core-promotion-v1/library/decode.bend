import Base
import ./decode-data.bend as D
import ./decode-size.bend as Size

# decode_owner uses the one Raw returned by the closed actual-owner projection.
# decode_budget is a trusted low-level helper taking separate Raw, fuel and owner.
# decode_owner derives structural fuel and does not invent a Raw-to-Owner inverse.
def decode_budget(~Owner:Type,+codec:D.Codec,raw:D.Raw,+fuel:Nat,owner:Owner) -> D.Receipt<Owner>:
  D.normalized(~Owner,fuel,codec,D.owned(~Owner,fuel,codec,D.Owned{owner,raw}))
def decode_projected(~Owner:Type,+codec:D.Codec,observed:Owner & D.Raw) -> D.Receipt<Owner>:
  match observed:
    case (owner,+raw): decode_budget(~Owner,codec,raw,Size.budget(codec,raw),owner)
def decode_owner(~Owner:Type,~project:Owner -> Owner & D.Raw,codec:D.Codec,owner:Owner) -> D.Receipt<Owner>:
  decode_projected(~Owner,codec,project(owner))
