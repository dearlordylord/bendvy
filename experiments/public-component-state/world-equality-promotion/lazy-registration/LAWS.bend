# DRAFT UNAPPROVED. No ECS proofs or runtime-refinement claim.
import Base
import candidate.bend as C
import ../../../../src/ecs/world.bend as W

def original_meta(meta: C.RegistrationMeta) -> W.RegistrationMeta:
  match meta:
    case C.RegistrationMeta{id,name,access}: W.RegistrationMeta{id,name,access}
def original_list(metas: List<&2,C.RegistrationMeta>) -> List<&2,W.RegistrationMeta>:
  match metas:
    case []: []
    case meta <> rest: original_meta(meta) <> original_list(rest)

law exact_meta_predicate:
  for +meta: C.RegistrationMeta
  for +id: U32
  for +name: String
  for +access: List<&2,String>
  {C.registration_meta_matches(meta,id,name,access) == W.registration_meta_matches(original_meta(meta),id,name,access) : Bool}

law exact_registration_list_predicate:
  for +metas: List<&2,C.RegistrationMeta>
  for +id: U32
  for +name: String
  for +access: List<&2,String>
  {C.registration_list_matches(metas,id,name,access) == W.registration_list_matches(original_list(metas),id,name,access) : Bool}
