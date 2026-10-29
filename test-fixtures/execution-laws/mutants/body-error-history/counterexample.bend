import Base
import ../../../../src/ecs/dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec
import ./spec.bend as Spec

def finish(state:Nat,events:List<&2,Exec.Observation<U32,U32>>) -> Exec.ExecutionResult<Nat,U32,U32,U32>:Exec.Finished{state,events}
def continued(state:Nat,error:U32) -> Nat & Exec.Handling:(Nat.add(state,U32.to_nat(error)),Exec.Continue{})
def escalated(state:Nat,error:U32) -> Nat & Exec.Handling:(Nat.add(state,U32.to_nat(error)),Exec.Escalate{})
def dispatch(state:Nat,id:U32) -> Nat & Exec.Invocation<U32,U32>:(Nat.add(state,100n),Exec.Completed{id})
def condition(state:Nat,id:U32) -> Nat & Exec.Condition<U32>:(Nat.add(state,100n),Exec.ConditionError{id})


def body_24() -> {Exec.invoked(~Nat,~U32,~U32,~U32,~continued,finish,(0n,Exec.BodyError{0,0}),0,[Exec.Ran{4,8},Exec.Skipped{5}]) == Spec.after_handler(~Nat,~U32,~U32,~U32,finish,continued(0n,0),0,List.append(&2,Exec.Observation<U32,U32>,[Exec.Ran{4,8},Exec.Skipped{5}],[Exec.BodyFailed{0,0,0}])) : Exec.ExecutionResult<Nat,U32,U32,U32>}:{==}
