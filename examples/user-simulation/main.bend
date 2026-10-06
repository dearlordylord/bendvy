import Base
import driver.bend as D
import json.bend as J

def boolean(value: Bool) -> String:
  match value:
    case True{}: "true"
    case False{}: "false"

def checkpoint(value: D.Checkpoint) -> String:
  match value:
    case D.Observed{label,snapshot,filtered}: J.snapshot(label,snapshot,filtered)
    case D.FailedResult{label,error}: "{\"label\":\"" ++ label ++ "\",\"ok\":false,\"error\":{\"kind\":\"SystemFailure\",\"system\":\"retry\",\"error\":\"" ++ error ++ "\"}}"
    case D.ForeignResult{foreignId,localId,missing,queueUnchanged,postBarrierUnchanged}: "{\"label\":\"foreign-collision-reference\",\"foreignId\":" ++ U32.show(foreignId) ++ ",\"localId\":" ++ U32.show(localId) ++ ",\"ok\":" ++ boolean(Bool.not(missing)) ++ ",\"error\":\"MissingEntity\",\"queueUnchanged\":" ++ boolean(queueUnchanged) ++ ",\"postBarrierUnchanged\":" ++ boolean(postBarrierUnchanged) ++ "}"

def checkpoints(values: List<&2,D.Checkpoint>) -> String:
  match values:
    case []: ""
    case value <> []: checkpoint(value)
    case value <> rest: checkpoint(value) ++ "," ++ checkpoints(rest)

def main() -> IO(Unit):
  IO.print("{\"format\":1,\"checkpoints\":[" ++ checkpoints(D.main()) ++ "]}")
