import Base
import ./app-a-payloads.bend as P
import ./app-a-schema.bend as D
import ./app-a-commands.bend as Author
import ./app-a-systems.bend as Systems
import ./app-a-captures.bend as Captures
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-resource-query-composite.bend as Composite
import ../../src/ecs/execution-resource-query-group.bend as Group
import ../../src/ecs/execution-resource-query-execution.bend as Execution
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/owner-product.bend as Product

def writer(node:Systems.WriterNode()) -> Leaf.Leaf<P.AuditWorkshop,D.components(),Author.resources(),Unit,Systems.WriterNode(),String,String>:
  Leaf.from_retained(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~String,~String,~Systems.WriterOps,~Systems.WriterLocal,~Systems.writer_kernel,~Systems.writer_body,~Decl.trusted_construction_caps(~P.AuditWorkshop,~Systems.Columns(),~Systems.C(),~Systems.R(),~Systems.WriterOps,Systems.writer_compiled()),node)

def query(node:Systems.QueryNode()) -> Leaf.Leaf<P.AuditWorkshop,D.components(),Author.resources(),Unit,Systems.QueryNode(),String,String>:
  Leaf.from_retained(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~String,~String,~Systems.QueryOps,~Systems.QueryLocal,~Systems.query_kernel,~Systems.query_body,~Decl.trusted_construction_caps(~P.AuditWorkshop,~Systems.Columns(),~Systems.C(),~Systems.R(),~Systems.QueryOps,Systems.query_compiled()),node)

def reader(node:Systems.ReaderNode()) -> Leaf.Leaf<P.AuditWorkshop,D.components(),Author.resources(),Unit,Systems.ReaderNode(),String,String>:
  Leaf.from_retained(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~String,~String,~Systems.ReaderOps,~Array<U32>,~Systems.reader_kernel,~Systems.reader_body,~Decl.trusted_construction_caps(~P.AuditWorkshop,~Systems.Columns(),~Systems.C(),~Systems.R(),~Systems.ReaderOps,Systems.reader_compiled()),node)

def Tail() -> Type:Product.Owner<Systems.QueryNode(),Systems.ReaderNode()>
def tail(nodes:Tail()) -> Leaf.Leaf<P.AuditWorkshop,D.components(),Author.resources(),Unit,Tail(),String,String>:
  Composite.from_nodes(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~String,~String,~Systems.QueryNode(),~Systems.ReaderNode(),~query,~reader,nodes)
def run(ids:List<&2,U32>,world:Systems.World(),nodes:Captures.Nodes()) -> IO(Execution.RunResult<P.AuditWorkshop,D.components(),Author.resources(),Unit,Captures.Nodes(),String,String>):
  match nodes:
    case Product.Owner{left,right}:Group.run_retained(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~String,~String,Systems.WriterNode(),Tail(),ids,world,writer(left),tail(right))
