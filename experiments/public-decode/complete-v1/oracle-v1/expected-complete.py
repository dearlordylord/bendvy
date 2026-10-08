"""Full independent Bend fixture model; authored without Bend runtime outputs.
Constructor-neutral schema agreed for oracle comparison; TS Missing is a recorded
representation difference from JavaScript undefined, not a silently dropped field.
"""
import json

def raw(value):
    if value is None:return {'Null':{}}
    if isinstance(value,int):return {'Number':value}
    if isinstance(value,str):return {'Text':value}
    if isinstance(value,list):return {'Array':[raw(x) for x in value]}
    return {'Object':[{'Field':{'name':k,'value':raw(v)}} for k,v in value.items()]}
def observed(original,checked):
    return {'original':raw(original),'sentinel':[111,222],'checked':checked}
def accepted(value):return {'Accepted':raw(value)}
def invalid(path,value):return {'Rejected':{'Invalid':{'path':path,'expected':'integer','actual':value}}}
def expected():
    fields={f'f{i}':i for i in range(64)}
    return {
        'array3':observed([1]*3,accepted([1]*3)),
        'array128':observed([1]*128,accepted([1]*128)),
        'array256':observed([1]*256,accepted([1]*256)),
        'lateInvalid':observed([1]*127+['late-invalid'],invalid('$[127]',raw('late-invalid'))),
        'struct64':observed({**fields,'extra':'drop-me'},accepted(fields)),
        'nullableNull':observed({'items':None},accepted({'items':None})),
        'nestedValid':observed({'items':[{'value':1},{'value':2}]},accepted({'items':[{'value':1},{'value':2}]})),
        'nestedMissing':observed({'items':[{'value':1},{}]},invalid('$.items[1].value',{'Missing':{}}))}
if __name__=='__main__':print(json.dumps(expected(),indent=2))
