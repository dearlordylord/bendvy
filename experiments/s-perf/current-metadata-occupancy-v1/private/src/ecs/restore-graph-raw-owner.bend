import Base
import ./decode-data.bend as D
import ./restore-graph-data.bend as Snapshot
import ./restore-graph-raw.bend as Raw
import ./restore-raw.bend as Basic

type Returned<Owner:Type,Runtime:Type,Output:Type> is Type:
  ParseRejected{owner:Owner,runtime:Runtime,original:D.Raw,error:Basic.Error}
  Delivered{original:D.Raw,output:Output}
def parsed(~Owner:Type,~Runtime:Type,~Output:Type,~run:Owner -> Runtime -> Snapshot.Snapshot -> Output,+original:D.Raw,owner:Owner,runtime:Runtime,result:Raw.Parsed) -> Returned<Owner,Runtime,Output>:
  match result:
    case Raw.Rejected{input,error}:ParseRejected{owner,runtime,input,error}
    case Raw.Accepted{snapshot}:Delivered{original,run(owner,runtime,snapshot)}
def run(~Owner:Type,~Runtime:Type,~Output:Type,~restore:Owner -> Runtime -> Snapshot.Snapshot -> Output,owner:Owner,runtime:Runtime,+input:D.Raw) -> Returned<Owner,Runtime,Output>:
  parsed(~Owner,~Runtime,~Output,~restore,input,owner,runtime,Raw.parse(input))
