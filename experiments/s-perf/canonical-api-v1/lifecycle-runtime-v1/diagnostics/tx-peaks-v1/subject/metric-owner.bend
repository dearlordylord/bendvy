import Base
import tx-metrics.bend as Metrics
type Owner is Type:
  Owner{original:Array<U32>,samples:List<&2,Metrics.Sample>}
def add(owner:Owner,sample:Metrics.Sample) -> Owner:
  match owner:
    case Owner{original,samples}:Owner{original,List.append(&2,Metrics.Sample,samples,[sample])}
def bumped(samples:List<&2,Metrics.Sample>,observed:Array<U32> & U32) -> Owner:
  match observed:
    case (original,count):Owner{Array.set(U32,original,0,U32.add(count,1)),samples}
def bump(owner:Owner) -> Owner:
  match owner:
    case Owner{original,samples}:bumped(samples,Array.get(U32,original,0))
def peek(owner:Owner) -> Owner & List<&2,Metrics.Sample>:
  match owner:
    case Owner{original,+samples}:(Owner{original,samples},samples)
