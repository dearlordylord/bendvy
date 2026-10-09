"""Independent typed inversion of frozen expectation; synthetic, no runtime evidence."""
import importlib.util,json,os
from pathlib import Path
HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('base_synthetic',HERE.parent/'synthetic-raw.py');B=importlib.util.module_from_spec(s);s.loader.exec_module(B)
B.ENTRY=B.ENTRY.parent/'app-run-v1/main.bend'
for k,(f,c,fields) in list(B.records.items()):
 B.records[k]=('../'+f if not f.startswith('/') and f not in ['Base','main'] else f,c,fields)
for t,variants in B.sums.items():
 for k,(f,fields) in list(variants.items()):variants[k]=('../'+f if not f.startswith('/') and f not in ['Base','main'] else f,fields)
B.DECL='../declaration.bend'
B.records['Report']=('main','Complete',[(k,'AppOutcome') for k in ['plain','transient','constructed']])
B.records.update({
 'AppScenarioReport':('scenario.bend','Report',[('category','String'),('baseline','ScenarioReport'),('phases',['AppPhase']),('registrationBefore',['RegistrationMeta']),('removedRegistrations',['RegistrationMeta'])]),
 'AppPhase':('observation.bend','Phase',[('label','String'),('details','AppDetails'),('snapshot','Snapshot')]),
 'AppDetails':('application.bend','Details',[('status','AppStatus'),('observations',['Observation']),('trace','Trace'),('namespace','U32'),('name','String'),('steps',['Step']),('requirements',['Requirement'])]),
 'Trace':('dispatch.bend','Trace',[('failId','U32'),('records',['DispatchRecord'])]),
 'DispatchRecord':('dispatch.bend','DispatchRecord',[('id','U32'),('operation','Operation')]),
})
B.sums.update({
 'AppOutcome':{'Report':('output.bend','AppScenarioReport')},
 'AppStatus':{'Finished':('application.bend',[]),'Rejected':('application.bend',[]),'Failed':('application.bend',[('error','ApplicationError')]),'Missing':('application.bend',[('needs',['Requirement'])])},
 'ApplicationError':{'BodyFailure':('dispatch.bend',[('id','U32'),('error','Error')]),'RegistrationRefused':('dispatch.bend',[('id','U32'),('args','RejectedArgs'),('world','WorldSnapshot'),('registry','RegistrySnapshot')]),'UnknownSystem':('dispatch.bend',[('id','U32')])},
 'Observation':{'Entered':(B.SCH,[('name','String')]),'Ran':(B.SCH,[('id','U32')]),'Skipped':(B.SCH,[('id','U32')]),'Applied':(B.SCH,[])},
 'Requirement':{k:(str(B.ROOT/'src/ecs/schedule-provision.bend'),[('id','U32')]) for k in ['Component','Resource','Service']},
})
if __name__=='__main__':(HERE/'synthetic-complete.stdout').write_text(B.render('Report',json.loads((HERE/'expected.json').read_text()))+'\n')
