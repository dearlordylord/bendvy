"""Independent runtime bridge expectation; no child/output-derived data."""
import copy, json, runpy
from pathlib import Path
P=runpy.run_path(str(Path(__file__).with_name('prior-input-model.py')))
c=P['c']; text=P['text']; number=P['number']; saved=P['saved']; owner=P['owner']; incoming=P['incoming']; some=P['some']
LABELS=['spawn','insert','resource','parseRefusal','wrongKind','downstreamRefusal','resourceParseRefusal','resourceWrongKind','resourceDownstreamRefusal','failure','failedInsert','failedResource','skip','hostRefusal']
def raw(label):
    if 'WrongKind' in label or label=='wrongKind':return number(7)
    if 'ParseRefusal' in label or label=='parseRefusal':return text('7;q')
    if 'DownstreamRefusal' in label or label=='downstreamRefusal':return text('9,8')
    return text('7,8')
def component(label):
    mode={'spawn':'success','insert':'success','failedInsert':'failure'}.get(label,label)
    report=P['report'](mode)
    if label in ('insert','failedInsert'):
        before=P['snapshot'](); committed=copy.deepcopy(before); barrier=copy.deepcopy(before)
        output=c('Accepted',target=c('Handle',namespace=1,id=1),spawned=False,canonical=saved(7,8),undoAvailable=True)
        if label=='insert':
            committed['pending']=1; barrier['meta']['clock']=2
            barrier['column']['slots']=[some(owner(7,8,text('7,8'),True))]
            barrier['column']['stamps']=[c('Entry',id=1,stamp=c('Stamp',added=1,changed=2))]
            barrier['mail']['retired']=[owner(7,99)]
            report['result']=c('Completed',output=output)
        else:
            report['instance']['recoveries'][0]['output']=copy.deepcopy(output)
        report.update(before=before,committed=committed,barrier=barrier)
    return report

def resource(label):
    r=raw(label)
    snap=c('Snapshot',meta=c('Meta',namespace=1,nextId=1,highWater=0,capacity=1,depth=0,events=[],registrations=[],nextSystemId=1,clock=0),live=[False],store=c('Unit'),resource=owner(7,100),pending=0)
    after=copy.deepcopy(snap)
    if label in ('resource','failedResource'):
        result=c('Replaced',canonical=saved(7,8),undoAvailable=True)
        if label=='resource':after['resource']=owner(7,8,r,True)
    else:
        if label=='resourceParseRefusal':error=c('Construction',error=c('Constructor',error=c('ParseError',raw=r)))
        elif label=='resourceWrongKind':error=c('Construction',error=c('Validation',error=P['invalid'](r,'$','string')))
        else:error=c('Admission',error=P['invalid'](number(9),'$.x','literal'))
        result=c('Refused',owner=incoming(r),error=error)
    return c('Report',before=snap,after=after,result=result,completion=c('Failure',error=c('Unit')) if label=='failedResource' else c('Success'))

def expected():
    cases=[]
    for schema in ('First','Second'):
        for label in LABELS:
            if label=='hostRefusal':
                message=('first' if schema=='First' else 'second')+' host refusal'
                issue=dict(message=message,path=[schema.lower()]); original=text('deny-'+schema.lower())
                cases.append(dict(schema=schema,label=label,input=copy.deepcopy(original),host=dict(ok=False,input=original,error=c('Array',items=[c('Object',fields=[c('Field',name='message',value=text(message))])]),issues=[issue]),argv=None));continue
            r=raw(label)
            original=r if r['$']=='Number' else text(('source:'+r['value']) if schema=='First' else ('pair('+r['value']+')'))
            cases.append(dict(schema=schema,label=label,input=original,host=dict(ok=True,value=copy.deepcopy(r)),runtimeInput=r,report=resource(label) if label.startswith('resource') or label=='failedResource' else component(label)))
    return cases
if __name__=='__main__':Path(__file__).with_name('expected.json').write_text(json.dumps(expected(),indent=2)+'\n')
