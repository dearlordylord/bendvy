from pathlib import Path
import importlib.util,json,hashlib
p=Path(__file__).with_name('expected.py');s=importlib.util.spec_from_file_location('full_source_successor',p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
normal=m.complete(False);assert len(normal)==5077477 and hashlib.sha256(normal).hexdigest()=='810259f78227f2b3d158c02644978b6c7ecf58b40a4b2fb398a816005b2867e2'
absent={'query':'optionalFour','each':[{'entityId':1,'data':{k:{'present':False} for k in m.FIELDS['optionalFour']}}],'get':[],'single':{}}
assert m.gate_allowed(absent,m.projected_record(absent,True))
present={'query':'fiveAlias','each':[{'entityId':1,'data':{'stock':1,'title':{'present':False},'active':{'present':False},'count':{'present':False},'stockAlias':{'present':True,'value':1}}}],'get':[]}
x=m.projected_record(present,True);assert not m.gate_allowed(present,x) and x['each'][0]['data']['stock']=='UNEXPECTED_ABSENT_REQUIRED' and x['each'][0]['data']['stockAlias']=={'present':False}
for name in ['empty','addedBoth','withWithout']:
 q={'query':name,'each':[{'entityId':1,'data':{}}]};assert m.gate_allowed(q,m.projected_record(q,True));q['each']=[];assert not m.gate_allowed(q,m.projected_record(q,True))
mutant=m.complete(True);lines=mutant.decode().splitlines();normal_lines=normal.decode().splitlines();assert len(lines)==len(normal_lines)
# Inspector clocks/instances and retry fail/cursor histories remain source-derived unchanged.
for tag in ['instanceBefore','instanceAfter','finalInstance','retryWorldBefore','retryWorldAfter','retryInstanceBefore','retryInstanceAfter','retryQuery','retryFailed']:
 assert [x for x in lines if x.startswith(tag+'|')]==[x for x in normal_lines if x.startswith(tag+'|')]
assert any(a!=b for a,b in zip(lines,normal_lines) if a.startswith('diagnostic|'))
assert any('UNEXPECTED_ABSENT_REQUIRED' in x for x in lines if x.startswith('diagnostic|'))
assert any(a!=b for a,b in zip(lines,normal_lines) if a.startswith('argsAfter|'))
print('PASS fullnormal/optionalallAbsent/empty+nofield/repeatedalias/conditionequality/Args/diagnosticpropagation/retry-fail-cursor histories')
