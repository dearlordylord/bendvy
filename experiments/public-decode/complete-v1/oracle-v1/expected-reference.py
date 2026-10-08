"""Independent TS observations, authored before actual Node execution."""
import json
from pathlib import Path

def success(value):
    return {'ok':True,'value':value}
def failure(path,actual):
    return {'ok':False,'error':{'_tag':'DecodeError','path':path,'expected':'integer','actual':actual}}
def expected():
    fields={f'f{i}':i for i in range(64)}
    cases=[('normal',[1]*3,success([1]*3)),
           ('array128',[1]*128,success([1]*128)),
           ('array256',[1]*256,success([1]*256)),
           ('lateInvalid',[1]*127+['late-invalid'],failure('$[127]','late-invalid')),
           ('struct64',{**fields,'extra':'drop-me'},success(fields)),
           ('nestedNull',{'items':None},success({'items':None})),
           ('nestedValid',{'items':[{'value':1},{'value':2}]},success({'items':[{'value':1},{'value':2}]})),
           ('nestedMissing',{'items':[{'value':1},{}]},failure('$.items[1].value',{'undefined':True}))]
    return [{'name':name,'input':raw,'result':result} for name,raw,result in cases]
if __name__=='__main__':
    print(json.dumps(expected(),indent=2))
