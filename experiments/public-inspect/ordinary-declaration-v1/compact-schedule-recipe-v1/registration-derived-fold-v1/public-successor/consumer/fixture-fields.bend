import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/ordinary-mixed-app-opaque-registry-v1/full-consumer.bend as Full
import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
def kind_text(value:Records.RegistrationKind) -> String:
  match value:
    case Records.ComponentKind{}:"Component"
    case Records.ResourceKind{mode}:"Resource:" ++ Full.mode(mode)
def fields_text(~S:Data,fields:Records.Fields<S>) -> String:
  match fields:
    case Records.Fields{namespace,id,name,access,cursor,slot,clauses,kind}:"Registry{" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ "|name=" ++ name ++ "|access=" ++ List.show(&2,String,x=>x,access) ++ "|cursor=" ++ U32.show(cursor) ++ "|slot=" ++ slot ++ "|clauses=" ++ List.show(&2,Query.Clause<S>,Full.clause(~S),clauses) ++ "|kind=" ++ kind_text(kind) ++ "}"
