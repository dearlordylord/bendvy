import Base
import ../../../../../profile.bend as Profile
import health-domain.bend as D
import health-systems.bend as S
import health-reader.bend as Reader
import health-program.bend as Program
import health.bend as F
import types.bend as T
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/meter.bend as Meter

def kind(value:U32) -> String:
  match value:
    case 0:"Spawn"
    case 1:"Update"
    case 2:"Dispose"
    case _:"Seed"
def facts(values:List<&2,D.MeasuredFacts>,+iteration:U32,+phase:Maybe<&2,U32>,+ordinal:Nat) -> List<&2,Profile.Sample>:
  match values:
    case []:[]
    case D.MeasuredFacts{D.TxFacts{operation,_,_,_,_,_},committed,report} <> rest:Profile.Sample{"domain",kind(operation),Some{iteration},phase,None{},None{},ordinal,committed,report} <> facts(rest,iteration,phase,1n+ordinal)
def seed(frame:D.Frame) -> List<&2,Profile.Sample>:
  match frame:
    case D.Frame{_,iteration,_,_,values}:facts(values,iteration,None{},0n)
def local_frame(phase:U32,ordinal:Nat,frame:Maybe<&2,D.Frame>) -> List<&2,Profile.Sample>:
  match frame:
    case None{}:[]
    case Some{D.Frame{_,iteration,_,_,values}}:facts(values,iteration,Some{phase},ordinal)
def locals(values:List<&2,S.LocalCall>,+ordinal:Nat) -> List<&2,Profile.Sample>:
  match values:
    case []:[]
    case S.LocalCall{_,_,_,frame,phase} <> rest:List.append(&2,Profile.Sample,local_frame(phase,ordinal,frame),locals(rest,1n+ordinal))
def read_value(ordinal:Nat,output:Maybe<&2,Reader.Read>,report:Maybe<&2,Meter.Report>,status:U32) -> List<&2,Profile.Sample>:
  match output report:
    case Some{Reader.Read{Reader.Args{who,phase,iteration},_}} Some{report}:[Profile.Sample{"reader","Reader",Some{iteration},Some{phase},Some{who},None{},ordinal,U32.is_eq(status,0),report}]
    case _ _:[]
def readers(values:List<&2,S.ReadCall>,+ordinal:Nat) -> List<&2,Profile.Sample>:
  match values:
    case []:[]
    case S.ReadCall{_,status,_,output,_,_,report} <> rest:List.append(&2,Profile.Sample,read_value(ordinal,output,report,status),readers(rest,1n+ordinal))
def view(value:Program.View) -> Program.View & List<&2,Profile.Sample>:
  match value:
    case Program.View{world,S.Owners{spawn,update,dispose,fast,slow,meta,tick,frame,phase,ids,+ls,+rs},namespace,logs,status}:(Program.View{world,S.Owners{spawn,update,dispose,fast,slow,meta,tick,frame,phase,ids,ls,rs},namespace,logs,status},List.append(&2,Profile.Sample,locals(ls,1n),readers(rs,0n)))
