import Base
import ../metadata.bend as M
import ../description.bend as D
import ../state-metadata.bend as State
import ./owner-observation.bend as Owner
# Independent closed declarations mirror the pinned public TS constructors.
# Presence/current values come from actual owner projections, never these labels.
def components() -> List<&2,M.Component>:
  [M.Component{"Plain",M.Plain{}},M.Component{"Constructed",M.Constructed{}},M.Component{"Transient",M.Transient{}},M.Component{"Absent",M.Plain{}}]
def resources(observation:Owner.Observation) -> List<&2,M.Resource>:
  match observation:
    case Owner.Observation{plain,missing,constructed,transient,_,_}:[M.Resource{"RPlain",M.Plain{},plain},M.Resource{"RMissing",M.Plain{},missing},M.Resource{"RConstructed",M.Constructed{},constructed},M.Resource{"RTransient",M.Transient{},transient}]
def machines(observation:Owner.Observation) -> List<&2,State.Machine>:
  match observation:
    case Owner.Observation{_,_,_,_,text,numeric}:[State.Machine{"Text",[State.Text{"Boot"},State.Text{"Run"}],text},State.Machine{"Numeric",[State.NumberBits{0,0,"0"},State.NumberBits{0,2147483648,"0"},State.NumberBits{0,1073217536,"1.5"},State.NumberBits{0,1128267776,"9007199254740992"},State.NumberBits{0,2146435072,"Infinity"},State.NumberBits{0,4293918720,"-Infinity"}],numeric}]
def system(positions:List<&2,String>) -> M.System:
  M.System{"Inspect",positions,[M.Query{"q",["Plain"],["Constructed"],["Transient"],["Plain"],["Absent"],["Transient"],["Constructed"],[]}],M.Access{["RPlain"],["RMissing"]},M.Access{[],[]},M.MachineAccess{["Numeric"],["Text"],[],[]},["Absent"],True{},["Follows"],["Clock","Missing"],[]}
def all(+observation:Owner.Observation,+system:M.System,+schedule:M.Schedule) -> D.Description:
  D.describe(components(),resources(observation),[D.DebugEvent{"E"}],[M.Relation{"Parent","Children",M.Hierarchy{},True{},True{}},M.Relation{"Follows","Followers",M.GeneralRelation{},False{},False{}}],machines(observation),["HostOnly","Clock"],[schedule],[system],[M.ResolvedSchedule{"main",[M.ResolvedDeferred{},M.ResolvedSystem{system},M.ResolvedTransitions{[]}]}])
def empty() -> D.Description:
  D.describe([],[],[],[],[],[],[],[],[])
