from pathlib import Path
p=Path('experiments/public-relations/promotion-stage');out=p/'query-lifetime'
s=(p/'query-owned.bend').read_text().replace('../../../src/','../../../../src/')
a=s.index('def ran(');b=s.index('def created(',a)
S='W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>'
s=s[:a]+f'''def ran(~S:Data,result:Sys.RunResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,Unit,U32,String,runner(~S)>) -> {S} & String:
  match result:
    case Sys.Completed{{_,Sys.Succeeded{{world,text}}}}: (world,text)
    case Sys.Completed{{_,Sys.Failed{{world,_}}}}: (world,"SYSTEM_FAILED")
    case Sys.RegistrationRejected{{_,world,_}}: (world,"RUN_REJECTED")
def registered(~S:Data,result:Sys.RegistrationResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,Unit,U32,String,runner(~S)>) -> {S} & String:
  match result:
    case Sys.Registered{{world,registry}}: ran(~S,Sys.run(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Unit,~U32,~String,~runner(~S),registry,world,Unit{{}}))
    case Sys.RegistrationFailed{{world}}: (world,"REGISTER_REJECTED")
def registered_world(~S:Data,world:{S}) -> {S} & String:
  registered(~S,Sys.register(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Unit,~U32,~String,~runner(~S),world,"relation-query",["Payload.read","Link.read","LinkedBy.read","OtherLink.read","OtherIncoming.read"]))
def phase_applied(~S:Data,observed:{S} & String,text:String,retained:List<&2,RQ.Row<S,List<&2,U32>>>) -> String:
  (world,after) = observed
  rendered(~S,text ++ "applied\\n" ++ after ++ "retained=" ++ show_rows(~S,retained) ++ "\\n",O.observe_complete(~S,world))
def phase_queued(~S:Data,observed:{S} & String,text:String,retained:List<&2,RQ.Row<S,List<&2,U32>>>) -> String:
  (world,before) = observed
  phase_applied(~S,registered_world(~S,W.barrier(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world)),text ++ "queued\\n" ++ before,retained)
def captured(~S:Data,observed:{S} & List<&2,RQ.Row<S,List<&2,U32>>>,text:String) -> String:
  (world,retained) = observed
  phase_queued(~S,registered_world(~S,O.commit(~S,queue(~S,X.begin(~{S},~A.Notice<S,U32>,world),link(~S),3,2),X.Success{{}})),"initial\\n" ++ text,retained)
def lifetime(~S:Data,observed:{S} & String) -> String:
  (world,text) = observed
  captured(~S,RQ.each(~S,~List<&2,U32>,~O.Components<S>,~U32,~U32,~RQ.Row<S,List<&2,U32>>,~spec_optional(~S),~component_selected(~S),~read_body(~S),world),text)
''' +s[b:]
old='registered(~S,Sys.register(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Unit,~U32,~String,~runner(~S),seeded(~S,O.spawn(~S,5n,world)),"relation-query",["Payload.read","Link.read","LinkedBy.read","OtherLink.read","OtherIncoming.read"]))'
assert old in s;s=s.replace(old,'lifetime(~S,registered_world(~S,seeded(~S,O.spawn(~S,5n,world))))')
(out/'query-owned.bend').write_text(s)
(out/'owned-world.bend').write_text((p/'owned-world.bend').read_text().replace('../../../src/','../../../../src/'))
