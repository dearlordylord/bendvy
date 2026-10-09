"""Independent complete leaf-reader omission model, authored before execution.

Only projected Component Access changes. The source still executes C.get and
returns its World; selectors, lifecycle predicates, Check and lookup validity
are unchanged. Retain every non-query output byte from the qualified model.
"""
import gzip,hashlib,json
from pathlib import Path
BASE_SHA='810259f78227f2b3d158c02644978b6c7ecf58b40a4b2fb398a816005b2867e2'
FIELDS={
 'optionalFour':{'stock':False,'title':False,'active':False,'count':False},
 'requiredPair':{'stock':True,'title':True,'active':False,'count':False},
 'fiveAlias':{'stock':True,'title':False,'active':False,'count':False,'stockAlias':False},
 'mixedFilters':{'active':False},'optionalUnselectedFilter':{'title':False}}
def projected(data,name):
    if name not in FIELDS:
        assert data=={},(name,data)
        return
    assert set(data)==set(FIELDS[name]),(name,data)
    for field,required in FIELDS[name].items():
        data[field]='UNEXPECTED_ABSENT_REQUIRED' if required else {'present':False}
def walk(value,name):
    if isinstance(value,dict):
        if set(value)=={'entityId','data'}:projected(value['data'],name)
        else:
            for child in value.values():walk(child,name)
    elif isinstance(value,list):
        for child in value:walk(child,name)
def expected(baseline):
    assert len(baseline)==5077477 and hashlib.sha256(baseline).hexdigest()==BASE_SHA
    lines=[];changed=0;query_count=0
    for line in baseline.decode().splitlines(keepends=True):
        prefix,sep,body=line.partition('|')
        if prefix in ('query','retryQuery'):
            value=json.loads(body);walk(value,value['query']);new=prefix+'|'+json.dumps(value,separators=(',',':'),ensure_ascii=False)+'\n';query_count+=1;changed+=new!=line;line=new
        lines.append(line)
    assert query_count==146 and changed>0
    return ''.join(lines).encode(),{'queryRecords':query_count,'changedRecords':changed}
if __name__=='__main__':
    import sys
    raw,counts=expected(gzip.decompress(Path(sys.argv[1]).read_bytes()))
    Path(sys.argv[2]).write_bytes(gzip.compress(raw,mtime=0));print(json.dumps({'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),**counts}))
