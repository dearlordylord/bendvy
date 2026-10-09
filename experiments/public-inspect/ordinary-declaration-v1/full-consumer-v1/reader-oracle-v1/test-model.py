from pathlib import Path
import importlib.util,json,gzip
p=Path(__file__).with_name('expected.py');s=importlib.util.spec_from_file_location('independent_reader_model',p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
for name,fields in m.FIELDS.items():
 data={k:(12 if required else {'present':True,'value':12}) for k,required in fields.items()};m.projected(data,name)
 assert all(data[k]==('UNEXPECTED_ABSENT_REQUIRED' if required else {'present':False}) for k,required in fields.items())
value={'each':[{'entityId':4,'data':{'stock':12,'title':12,'active':{'present':True,'value':False},'count':{'present':True,'value':[1]}}}], 'get':[{'target':99,'result':{'ok':False,'error':{'_tag':'MissingEntity','entityId':99}}}], 'single':{'ok':False,'error':{'_tag':'MultipleEntities','count':2}}}
old=json.dumps(value['get']);single=json.dumps(value['single']);m.walk(value,'requiredPair');assert old==json.dumps(value['get']) and single==json.dumps(value['single']);assert value['each'][0]['entityId']==4
try:m.projected({'stock':1},'requiredPair')
except AssertionError:pass
else:raise AssertionError('missing field accepted')
print('PASS five fieldroutes/errors/cardinality/entity preservation/field loss refusal')
