import Base
import profile.bend as Profile
type Owner is Type:
  Owner{original:Array<U32>,reverseSamples:List<&2,Profile.Sample>}
def next(values:List<&2,Profile.Sample>) -> Nat:
  match values:
    case []:0n
    case value <> _:1n+Profile.ordinal(value)
def add(owner:Owner,sample:Profile.Sample) -> Owner:
  match owner:
    case Owner{original,+samples}:Owner{original,Profile.at_ordinal(sample,next(samples)) <> samples}
def bumped(samples:List<&2,Profile.Sample>,observed:Array<U32> & U32) -> Owner:
  match observed:
    case (original,count):Owner{Array.set(U32,original,0,U32.add(count,1)),samples}
def bump(owner:Owner) -> Owner:
  match owner:
    case Owner{original,samples}:bumped(samples,Array.get(U32,original,0))
def peek(owner:Owner) -> Owner & List<&2,Profile.Sample>:
  match owner:
    case Owner{original,+samples}:(Owner{original,samples},List.reverse(&2,Profile.Sample,samples))
def context_observed(samples:List<&2,Profile.Sample>,observed:Array<U32> & U32) -> Owner & U32:
  match observed:
    case (original,call):(Owner{original,samples},call)
def context(owner:Owner) -> Owner & U32:
  match owner:
    case Owner{original,samples}:context_observed(samples,Array.get(U32,original,0))
def record_rows(+kind:String,+iteration:U32,+phase:U32,+call:U32,+action:Profile.Action,rows:List<&2,Profile.Observation>,owner:Owner) -> Owner:
  match rows:
    case []:owner
    case row <> rest:record_rows(kind,iteration,phase,call,action,rest,add(owner,Profile.Sample{kind,Some{iteration},Some{phase},Some{call},0n,action,row}))
def record_context(kind:String,iteration:U32,phase:U32,action:Profile.Action,rows:List<&2,Profile.Observation>,observed:Owner & U32) -> Owner:
  match observed:
    case (owner,call):record_rows(kind,iteration,phase,call,action,rows,owner)
def record(kind:String,iteration:U32,phase:U32,action:Profile.Action,rows:List<&2,Profile.Observation>,owner:Owner) -> Owner:record_context(kind,iteration,phase,action,rows,context(owner))
