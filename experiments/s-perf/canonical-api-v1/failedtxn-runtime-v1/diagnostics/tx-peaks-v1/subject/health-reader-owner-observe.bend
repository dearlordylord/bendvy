import Base
import health.bend as F
import ../../../../dense-runtime-v1/types.bend as T
import health-events.bend as E
import health-family.bend as Family
import health-parameters.bend as P
import health-reader.bend as Reader
import health-publications.bend as Publications
import ../../../../../../../src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../../../../src/ecs/ordinary-reader-stream-parameter.bend as SP
import ../../../../../../../src/ecs/reader-parameter.bend as RP
import ../../../../../../../src/ecs/event-family-routing.bend as Route
import ../../../../../../../src/ecs/system.bend as Sys
def facts(value:RP.RegistrationFacts) -> String:
  match value:
    case RP.RegistrationFacts{ns,id,name,access}:"ns=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,access)
def ping_owner(value:P.ping_owner()) -> P.ping_owner() & String:
  match value:
    case SP.EventOwner{+registration,Route.Reader{+namespace,+id,+registryId}}:(SP.EventOwner{registration,Route.Reader{namespace,id,registryId}},"facts={" ++ facts(registration) ++ "};reader={namespace=" ++ U32.show(namespace) ++ ";id=" ++ U32.show(id) ++ ";registryId=" ++ U32.show(registryId) ++ "}")
def provider_registry(owner:P.ping_owner(),text:String,+access:List<&2,String>,unit:Unit,registry:Reader.Registry()) -> Reader.Provider() & String:
  match registry:
    case Sys.Registry{+ns,+id,+name,+uses,+cursor}:(Ordinary.Provider{Sys.Registry{ns,id,name,uses,cursor},owner,RP.Param{access},unit},"registry={ns=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,uses) ++ ";cursor=" ++ U32.show(cursor) ++ "};parameter=" ++ List.show(&2,String,x=>x,access) ++ ";declaration=Unit;owners={" ++ text ++ "}")
def provider_join(registry:Reader.Registry(),+access:List<&2,String>,unit:Unit,observed:P.ping_owner() & String) -> Reader.Provider() & String:
  (owner,text)=observed
  provider_registry(owner,text,access,unit,registry)
def provider(value:Reader.Provider()) -> Reader.Provider() & String:
  match value:
    case Ordinary.Provider{registry,owner,RP.Param{access},unit}:provider_join(registry,access,unit,ping_owner(owner))
def publications_registry(owner:P.ping_owner(),text:String,+access:List<&2,String>,unit:Unit,registry:Publications.Registry()) -> Publications.Provider() & String:
  match registry:
    case Sys.Registry{+ns,+id,+name,+uses,+cursor}:(Ordinary.Provider{Sys.Registry{ns,id,name,uses,cursor},owner,RP.Param{access},unit},"registry={ns=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,uses) ++ ";cursor=" ++ U32.show(cursor) ++ "};parameter=" ++ List.show(&2,String,x=>x,access) ++ ";declaration=Unit;owners={" ++ text ++ "}")
def publications_join(registry:Publications.Registry(),+access:List<&2,String>,unit:Unit,observed:P.ping_owner() & String) -> Publications.Provider() & String:
  (owner,text)=observed
  publications_registry(owner,text,access,unit,registry)
def publications(value:Publications.Provider()) -> Publications.Provider() & String:
  match value:
    case Ordinary.Provider{registry,owner,RP.Param{access},unit}:publications_join(registry,access,unit,ping_owner(owner))
