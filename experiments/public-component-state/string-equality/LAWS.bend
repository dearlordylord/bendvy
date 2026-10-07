# DRAFT — UNAPPROVED. No proof or universal runtime-refinement claim.
# Existing executable finite observations are mapped in law-evidence.md.
import Base
import equality.bend as E
import ../../../src/ecs/world.bend as W

law exact_string_equality:
  for +a: String
  for +b: String
  {E.equal(a,b) == String.eq(a,b) : Bool}

law exact_ordered_access_equality:
  for +xs: List<&2,String>
  for +ys: List<&2,String>
  {E.access_equal(xs,ys) == W.access_equal(xs,ys) : Bool}

law exact_registration_characterization:
  for +id: U32
  for +name: String
  for +access: List<&2,String>
  for +otherId: U32
  for +otherName: String
  for +otherAccess: List<&2,String>
  {E.registration_equal(id,name,access,otherId,otherName,otherAccess) == W.registration_meta_matches(W.RegistrationMeta{id,name,access},otherId,otherName,otherAccess) : Bool}
