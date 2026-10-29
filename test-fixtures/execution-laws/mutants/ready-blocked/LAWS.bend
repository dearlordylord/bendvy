import Base
import ./dependency-plan.bend as Plan
import ../../../../src/ecs/dependency-executor.bend as Exec
import ./spec.bend as Spec

law ready_exact:
  for Requirement:Data
  for +pending:List<&2,Plan.Node<Requirement>>
  for +edges:List<&2,Plan.Edge>
  {Plan.ready(~Requirement,pending,edges) == Spec.ready(~Requirement,pending,edges) : List<&2,Plan.Node<Requirement>>}
