import Base
import ./decode-data.bend as D
import ./snapshot-data.bend as Snapshot
import ./restore-raw.bend as Raw

# ParseRejected returns actual unchanged owner/runtime with original Raw/error.
# Delivered retains original Raw beside the restore callback's actual Output;
# its inner outcome/recovery determines semantic restore success or refusal.
type Returned<Owner:Type,Runtime:Type,Output:Type> is Type:
  ParseRejected{owner:Owner,runtime:Runtime,original:D.Raw,error:Raw.Error}
  Delivered{original:D.Raw,output:Output}
def parsed(~Owner:Type,~Runtime:Type,~Output:Type,~run:Owner -> Runtime -> Snapshot.Snapshot -> Output,+original:D.Raw,owner:Owner,runtime:Runtime,result:Raw.Parsed) -> Returned<Owner,Runtime,Output>:
  match result:
    case Raw.Rejected{input,error}:ParseRejected{owner,runtime,input,error}
    case Raw.Accepted{snapshot}:Delivered{original,run(owner,runtime,snapshot)}
# Parse before invoking the closed typed restore callback. Parse failure does not
# call restore or consume its actual owners; success transfers owner/runtime and
# Snapshot exactly once. Callback Output must retain whatever owners/results its
# contract requires; this generic wrapper adds no rollback or recovery guarantee.
# See docs/parity/restore-basic.md and its RawOwner.run consumer.
def run(~Owner:Type,~Runtime:Type,~Output:Type,~restore:Owner -> Runtime -> Snapshot.Snapshot -> Output,owner:Owner,runtime:Runtime,+input:D.Raw) -> Returned<Owner,Runtime,Output>:
  parsed(~Owner,~Runtime,~Output,~restore,input,owner,runtime,Raw.parse(input))
