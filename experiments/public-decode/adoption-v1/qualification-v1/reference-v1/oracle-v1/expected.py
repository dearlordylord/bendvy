"""Independent pinned TS public observation model, authored before Node output."""
import copy,json,importlib.util
from pathlib import Path
REF=Path('/workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/oracle-v1/expected-complete.py')
s=importlib.util.spec_from_file_location('inputs',REF);R=importlib.util.module_from_spec(s);s.loader.exec_module(R)
U={'undefined':True}
def owner(value,sentinel=None):return {'value':copy.deepcopy(value),'sentinel':[111,222] if sentinel is None else list(sentinel)}
def success(value):return {'ok':True,'value':value}
def error(path,expected,actual):return {'ok':False,'error':{'_tag':'DecodeError','path':path,'expected':expected,'actual':copy.deepcopy(actual)}}
def raw(v):
 if not isinstance(v,dict):return v
 if 'Number' in v:return v['Number']
 if 'Text' in v:return v['Text']
 if 'Null' in v:return None
 if 'Missing' in v:return copy.deepcopy(U)
 if 'Array' in v:return [raw(x) for x in v['Array']]
 if 'Object' in v:return {f['Field']['name']:raw(f['Field']['value']) for f in v['Object']}
 raise ValueError(v)
def dump(frame,tick,entities,resources,pending):return {'version':1,'frame':frame,'tick':tick,'entityCount':len(entities),'entities':copy.deepcopy(entities),'resources':copy.deepcopy(resources),'machines':{},'pendingCommands':copy.deepcopy(pending)}
def entity(id,value,marker=False):return {'id':id,'components':{'Value':copy.deepcopy(value),**({'Marker':1} if marker else {})},'relations':{}}
def trace(root,operation,name,case):
 incoming=owner(raw(case['original']));seed=[] if name.startswith('array') or name=='lateInvalid' else {f'f{i}':i for i in range(64)} if name=='struct64' else {'items':None};resource=owner(seed,[555,666]);initial=owner(9,[333,444]);before=dump(2,3,[entity(1,initial)],{'Resource':resource},[{'tag':'insert','system':'queue'}]);after=copy.deepcopy(before);after.update(frame=3,tick=4)
 if 'Rejected' in case['checked']:
  e=case['checked']['Rejected']['Invalid'];checked=error(e['path'],e['expected'],raw(e['actual']))
 else:
  canonical=owner(raw(case['checked']['Accepted']))
  checked=success([{'kind':'component','name':'Value'},canonical]) if operation=='spawn' else success(copy.deepcopy(U))
  if operation=='insert':after['entities'][0]['components']['Value']=canonical
  elif operation=='resource':after['resources']['Resource']=canonical
  else:after['pendingCommands'].append({'tag':'spawn','system':'spawn'})
 flushed=copy.deepcopy(after);flushed.update(frame=4,tick=5);flushed['pendingCommands']=[];flushed['entities'][0]['components']['Marker']=1
 if operation=='spawn' and checked['ok']:flushed['entities'].append(entity(2,checked['value'][1]));flushed['entityCount']=2
 return {'root':root,'operation':operation,'name':name,'original':copy.deepcopy(incoming),'checked':checked,'incomingAfter':copy.deepcopy(incoming),'before':before,'after':after,'flushed':flushed}
def handle(id):return {'root':copy.deepcopy(U),'intent':copy.deepcopy(U),'kind':'EntityHandle','value':id}
def selectors():
 b=error('$','integer',True);valid=dump(0,0,[],{'Selected':7},[])
 return {'initializeBoolean':{'ok':False,'error':{'Selected':b['error']}},'initializeInteger':{'ok':True,'dump':valid},'plain':True,'transient':True,'loadBoolean':success(True),'fallbackBoolean':b,'literalReady':success({'kind':'ready'}),'literalBusy':error('$.kind','"ready"','busy'),'handles':[success({'target':handle(1)}),success({'target':handle(1)}),error('$.target','entity handle',{'kind':'EntityHandle','value':0}),error('$.target','entity handle','not-handle')]}
def foreign():
 first=owner('first',[777,888]);second=owner(9,[333,444]);original=owner({**{f'f{i}':i for i in range(64)},'extra':'drop-me'});canonical=owner({f'f{i}':i for i in range(64)})
 before={'first':dump(1,2,[entity(1,first)],{},[]),'second':dump(2,3,[entity(1,second)],{},[{'tag':'insert','system':'queue'}])};after=copy.deepcopy(before);after['second']=dump(3,4,[entity(1,canonical)],{},[{'tag':'insert','system':'queue'}]);flushed=copy.deepcopy(after);flushed['second']=dump(4,5,[entity(1,canonical,True)],{},[])
 return {'firstId':1,'secondId':1,'foreign':handle(1),'original':original,'lookup':{'ok':True,'id':1},'checked':success(copy.deepcopy(U)),'before':before,'after':after,'flushed':flushed}
def expected():
 cases=R.expected();return {'traces':[trace('Workshop',op,name,c) for op in ['insert','spawn','resource'] for name,c in cases.items()]+[trace('Garden','insert',name,c) for name,c in cases.items()],'selectors':selectors(),'foreign':foreign()}
if __name__=='__main__':Path(__file__).with_name('expected.json').write_text(json.dumps(expected(),indent=2)+'\n')
