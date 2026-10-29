import Base
import ./schema.bend as S
import ./declarations.bend as D
import ./feature-motion.bend as Motion
import ./feature-labels.bend as Labels
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-resource-query-composite.bend as Composite
import ../../src/ecs/execution-resource-query-group.bend as Group
import ../../src/ecs/execution-resource-query-execution.bend as Execution
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/owner-product.bend as Product
def motion(node:D.MotionNode()) -> Leaf.Leaf<S.Nominal,S.components(),S.resources(),Unit,D.MotionNode(),String,String>:
  Leaf.from_retained(~S.Nominal,~S.components(),~S.resources(),~Unit,~String,~String,~Motion.Family(~S.Nominal),~Motion.Local<S.Nominal>,~D.motion_kernel,~Motion.body(~S.Nominal),~Decl.trusted_construction_caps(~S.Nominal,~S.Store(),~D.C(),~D.R(),~Motion.Family(~S.Nominal),D.motion_compiled()),node)
def motion_pair(nodes:D.MotionOwners()) -> Leaf.Leaf<S.Nominal,S.components(),S.resources(),Unit,D.MotionOwners(),String,String>:
  Composite.from_nodes(~S.Nominal,~S.components(),~S.resources(),~Unit,~String,~String,~D.MotionNode(),~D.MotionNode(),~motion,~motion,nodes)
def labels(node:D.LabelsNode()) -> Leaf.Leaf<S.Nominal,S.components(),S.resources(),Unit,D.LabelsNode(),String,String>:
  Leaf.from_retained(~S.Nominal,~S.components(),~S.resources(),~Unit,~String,~String,~Labels.Family(~S.Nominal),~Labels.Local<S.Nominal>,~D.labels_kernel,~Labels.body(~S.Nominal),~Decl.trusted_construction_caps(~S.Nominal,~S.Store(),~D.C(),~D.R(),~Labels.Family(~S.Nominal),D.labels_compiled()),node)
def labels_pair(nodes:D.LabelsOwners()) -> Leaf.Leaf<S.Nominal,S.components(),S.resources(),Unit,D.LabelsOwners(),String,String>:
  Composite.from_nodes(~S.Nominal,~S.components(),~S.resources(),~Unit,~String,~String,~D.LabelsNode(),~D.LabelsNode(),~labels,~labels,nodes)
def run(nodes:D.Owners(),world:S.World(),ids:List<&2,U32>) -> IO(Execution.RunResult<S.Nominal,S.components(),S.resources(),Unit,D.Owners(),String,String>):
  match nodes:
    case Product.Owner{left,right}:Group.run_retained(~S.Nominal,~S.components(),~S.resources(),~Unit,~String,~String,D.MotionOwners(),D.LabelsOwners(),ids,world,motion_pair(left),labels_pair(right))
