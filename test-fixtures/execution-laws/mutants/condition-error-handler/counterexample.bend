import Base
import ../../../../src/ecs/dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec
import ./spec.bend as Spec

def finish(state:Nat,events:List<&2,Exec.Observation<U32,U32>>) -> Exec.ExecutionResult<Nat,U32,U32,U32>:Exec.Finished{state,events}
def continued(state:Nat,error:U32) -> Nat & Exec.Handling:(Nat.add(state,U32.to_nat(error)),Exec.Continue{})
def escalated(state:Nat,error:U32) -> Nat & Exec.Handling:(Nat.add(state,U32.to_nat(error)),Exec.Escalate{})
def dispatch(state:Nat,id:U32) -> Nat & Exec.Invocation<U32,U32>:(Nat.add(state,100n),Exec.Completed{id})
def condition(state:Nat,id:U32) -> Nat & Exec.Condition<U32>:(Nat.add(state,100n),Exec.ConditionError{id})


def condition_error_13() -> {Exec.conditioned(~Nat,~U32,~U32,~U32,~dispatch,~escalated,finish,(0n,Exec.ConditionError{0}),0,[]) == Spec.after_handler(~Nat,~U32,~U32,~U32,finish,escalated(0n,0),0,List.append(&2,Exec.Observation<U32,U32>,[],[Exec.ConditionFailed{0,0}])) : Exec.ExecutionResult<Nat,U32,U32,U32>}:{==}
