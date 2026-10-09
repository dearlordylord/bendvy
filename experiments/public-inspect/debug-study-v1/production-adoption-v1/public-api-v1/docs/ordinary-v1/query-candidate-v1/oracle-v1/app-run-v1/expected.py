"""Independent source model for frozen 598a3e33; no runtime observations."""
import copy,json,importlib.util
from pathlib import Path
spec=importlib.util.spec_from_file_location("baseline",Path(__file__).parents[1]/"expected.py")
B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
def scenario(category):
    baseline=B.scenario(category);last=baseline['phases'][-1]
    world=copy.deepcopy(last['world']);regs=copy.deepcopy(last['registries']);clock=world['clock'];trace=[];phases=[]
    steps=[{'Phase':{'name':'Update'}}]+[{'System':{'id':i,'condition':int(i==2)}} for i in range(1,6)]+[{'Barrier':{}}]
    desc=B.description();desc['steps']=copy.deepcopy(steps)
    def snap(label,w,factory,enabled):
        return copy.deepcopy({'label':label,'factoryNextNamespace':factory,'world':w,'registries':regs,'operation':{'Observed':{}},'descriptions':[{'Some':desc},{'Some':desc}] if enabled else [{'None':{}},{'None':{}}]})
    def phase(label,status,obs,w,factory,enabled,fail):
        phases.append(copy.deepcopy({'label':label,'details':{'status':status,'observations':obs,'trace':{'failId':fail,'records':trace},'namespace':1,'name':'Update','steps':steps,'requirements':[]},'snapshot':snap(label,w,factory,enabled)}))
    def run(i,ids):
        nonlocal clock
        rows=[]
        for entity in ids:
            cells={k:world['columns'][k]['cells'][entity-1] for k in ['position','velocity','health']}
            rows.append({'position':copy.deepcopy(cells['position']['payload']['Some']),'velocityBefore':copy.deepcopy(cells['velocity']['payload']['Some']),'health':{'Found':copy.deepcopy(cells['health']['payload']['Some'])} if 'Some' in cells['health']['payload'] else {'ComponentAbsent':{}}})
            clock+=1;cells['velocity']['payload']['Some']['values'][0]+=cells['position']['payload']['Some']['values'][0];cells['velocity']['stamp']['changed']=clock
        world['clock']=clock;regs[i-1]['cursor']=clock
        trace.append({'id':i,'operation':{'Run':{'result':{'Done':rows}}}})
    error={'UserError':{'Unit':{}}};clock+=1;world['clock']=clock
    trace.append({'id':1,'operation':{'Run':{'result':{'Fail':error}}}})
    phase('enabled-failure',{'Failed':{'error':{'BodyFailure':{'id':1,'error':error}}}},[{'Entered':{'name':'Update'}},{'Ran':{'id':1}}],world,3,True,1)
    observations=[{'Entered':{'name':'Update'}},{'Ran':{'id':1}},{'Skipped':{'id':2}},{'Ran':{'id':3}},{'Ran':{'id':4}},{'Ran':{'id':5}},{'Applied':{}}]
    run(1,[1,2]);run(3,[]);run(4,[2]);run(5,[1])
    phase('enabled-retry',{'Finished':{}},observations,world,3,True,0)
    trace=[];run(1,[1,2]);run(3,[]);run(4,[2]);run(5,[1])
    phase('disabled-success',{'Finished':{}},observations,world,3,False,0)
    foreign=copy.deepcopy(last['operation']['RefusedRegistration']['foreignWorld']);foreign['namespace']=3
    phase('namespace-rejected',{'Rejected':{}},[],foreign,4,False,0)
    before=copy.deepcopy(world['registrations']);removed=[r for r in before if r['id']==1];world['registrations']=[r for r in before if r['id']!=1]
    args={'fail':False,'cursor':regs[0]['cursor']};refusal={'args':args,'foreignWorld':copy.deepcopy(world),'registry':copy.deepcopy(regs[0])}
    trace.append({'id':1,'operation':{'RefusedRegistration':refusal}})
    err={'RegistrationRefused':{'id':1,'args':args,'world':copy.deepcopy(world),'registry':copy.deepcopy(regs[0])}}
    phase('registration-refusal',{'Failed':{'error':err}},[{'Entered':{'name':'Update'}},{'Ran':{'id':1}}],world,4,False,0)
    assert [p['snapshot']['world']['clock'] for p in phases]==[20,24,28,0,28]
    assert [r['cursor'] for r in regs]==[26,14,26,27,28]
    return {'Report':{'category':category.lower(),'baseline':baseline,'phases':phases,'registrationBefore':before,'removedRegistrations':removed}}
def expected():return {k:scenario(v) for k,v in [('plain','Plain'),('transient','Transient'),('constructed','Constructed')]}
if __name__=='__main__':print(json.dumps(expected(),indent=2))
