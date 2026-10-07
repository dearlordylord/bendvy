import Base
import ../../string-equality/equality.bend as SE

# Standalone copied metadata value for isolated exact predicate controls only.
type RegistrationMeta is Data:
  RegistrationMeta{id: U32,name: String,access: List<&2,String>}

def access_equal(xs: List<&2,String>,ys: List<&2,String>) -> Bool:
  SE.access_equal(xs,ys)

def matching_access(sameName: Bool,metaAccess: List<&2,String>,wantedAccess: List<&2,String>) -> Bool:
  match sameName:
    case False{}: False{}
    case True{}: access_equal(metaAccess,wantedAccess)

def matching_id(sameId: Bool,metaName: String,wantedName: String,metaAccess: List<&2,String>,wantedAccess: List<&2,String>) -> Bool:
  match sameId:
    case False{}: False{}
    case True{}: matching_access(SE.equal(metaName,wantedName),metaAccess,wantedAccess)

def registration_meta_matches(meta: RegistrationMeta,+id: U32,+name: String,+access: List<&2,String>) -> Bool:
  match meta:
    case RegistrationMeta{mid,mname,maccess}: matching_id(U32.is_eq(mid,id),mname,name,maccess,access)

def registration_list_walk(registrations: List<&2,RegistrationMeta>,+id: U32,+name: String,+access: List<&2,String>,found: Bool) -> Bool:
  match registrations found:
    case _ True{}: True{}
    case [] False{}: False{}
    case meta <> rest False{}: registration_list_walk(rest,id,name,access,registration_meta_matches(meta,id,name,access))

def registration_list_matches(registrations: List<&2,RegistrationMeta>,+id: U32,+name: String,+access: List<&2,String>) -> Bool:
  registration_list_walk(registrations,id,name,access,False{})
