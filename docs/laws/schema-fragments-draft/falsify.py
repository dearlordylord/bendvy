"""Literal falsification of three unapproved Data-metadata subjects; no proofs."""
import hashlib,json,os,pathlib,subprocess
HERE=pathlib.Path(__file__).resolve().parent; ROOT=HERE.parents[2]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
kinds=['Component','Resource','Event','Relation','Service']
def entry(x):return 'F.Entry{F.'+kinds[x[0]]+'{},'+json.dumps(x[1])+','+json.dumps(x[2])+'}'
def entries(xs):return '['+','.join(map(entry,xs))+']'
def classify(seen,item):
 k,key,name=item
 if any(a==k and x==key for a,x,n in seen):return [1,k,key,'']
 if any(a==k and n==name for a,x,n in seen):return [2,k,'',name]
 return [0,0,'','']
def validate(xs):
 for k in range(5):
  seen=[]
  for item in xs:
   if item[0]==k:
    result=classify(seen,item)
    if result[0]:return result
    seen.append(item)
 return [0,0,'','']
collision=[]
for oldkind in range(5):
 for newkind in range(5):
  for key,name in [('a','A'),('a','B'),('b','A'),('b','B')]:
   collision.append(([(oldkind,'a','A')],(newkind,key,name)))
collision.append(([],(0,'a','A')))
priority=[[]]
for a in range(5):
 priority.extend([[(a,'a','A')],[(a,'a','A'),(a,'a','B')],[(a,'a','A'),(a,'b','A')],[(a,'a','A'),(a,'a','A')]])
 for b in range(5):
  if a!=b:priority.append([(a,'x','X'),(a,'y','X'),(b,'k','K'),(b,'k','L')])
priority.append([(0,'a','A'),(0,'b','B'),(0,'c','B'),(0,'a','C')])
membership=[]
for oldkind in range(5):
 for newkind in range(5):
  for key,name in [('a','A'),('a','B'),('b','A'),('b','B')]:membership.append(([(oldkind,'a','A')],(newkind,key,name)))
membership.extend([([],(0,'a','A')), ([(1,'b','B'),(0,'a','A')],(0,'a','A'))])
subjects={'collision_classification':(collision,[classify(*x) for x in collision]),'validation_priority':(priority,[validate(x) for x in priority]),'declaration_membership':(membership,[int(x in xs) for xs,x in membership])}
show='''def validation_show(value:F.Validation) -> String:
  match value:
    case F.Valid{}: "[0,0,\\\"\\\",\\\"\\\"]"
    case F.Invalid{F.DuplicateKey{k,key}}: "[1," ++ U32.show(M.kind_code(k)) ++ ",\\\"" ++ key ++ "\\\",\\\"\\\"]"
    case F.Invalid{F.DuplicateName{k,name}}: "[2," ++ U32.show(M.kind_code(k)) ++ ",\\\"\\\",\\\"" ++ name ++ "\\\"]"
    case F.Invalid{F.UndeclaredDescriptor{k,key,name}}: "[3," ++ U32.show(M.kind_code(k)) ++ ",\\\"" ++ key ++ "\\\",\\\"" ++ name ++ "\\\"]"
def bool_show(value:Bool) -> String:
  U32.show(Bool.to_u32(value))
'''
def fixture(subject):
 cases,_=subjects[subject];pairs=[]
 for case in cases:
  if subject=='collision_classification':
   xs,item=case;a='F.check_one(~M.Schema,'+entries(xs)+','+entry(item)+')';b='M.classify('+entries(xs)+','+entry(item)+')';render='validation_show'
  elif subject=='validation_priority':a='F.validate(~M.Schema,'+entries(case)+')';b='M.validate('+entries(case)+')';render='validation_show'
  else:
   xs,item=case;a='F.descriptor_present(~M.Schema,'+entries(xs)+','+entry(item)+')';b='M.member('+entries(xs)+','+entry(item)+')';render='bool_show'
  pairs.append('"[" ++ '+render+'('+a+') ++ "," ++ '+render+'('+b+') ++ "]"')
 return 'import Base\nimport ./core.bend as F\nimport ./model.bend as M\n'+show+'def main() -> IO(Unit):\n  IO.print(List.show(&2,String,(x => x),['+','.join(pairs)+']))\n'
mutants=[('collision_classification','omit-key','case True{} _: Invalid{DuplicateKey{kind,key}}','case True{} _: Valid{}'),('collision_classification','omit-name','case False{} True{}: Invalid{DuplicateName{kind,name}}','case False{} True{}: Valid{}'),('collision_classification','cross-kind-component-resource','case Component{} Resource{}','case Component{} Resource{}')]
# Third mutant is a deliberate insertion before same_kind's catch-all, not a law change.
mutants[-1]=('collision_classification','cross-kind-component-resource','    case _ _: False{}','    case Component{} Resource{}: True{}\n    case _ _: False{}')
mutants += [('validation_priority','resource-before-component','first_failure(validate_loop(~S,filter_kind(~S,entries,Component{}),[]),first_failure(validate_loop(~S,filter_kind(~S,entries,Resource{}),[])','first_failure(validate_loop(~S,filter_kind(~S,entries,Resource{}),[]),first_failure(validate_loop(~S,filter_kind(~S,entries,Component{}),[])'),('declaration_membership','ignore-name','Bool.and(String.eq(ax,bx),String.eq(an,bn))','String.eq(ax,bx)')]
def main():
 out=HERE/'evidence';out.mkdir(exist_ok=False);stage=out/'stage';stage.mkdir();core=ROOT/'src/ecs/schema-fragments.bend';original=core.read_text();corehash=sha(core)
 (stage/'core.bend').write_text(original);(stage/'model.bend').write_text((HERE/'model.bend').read_text().replace('../../../src/ecs/schema-fragments.bend','./core.bend'))
 receipt={'status':'INCOMPLETE','approval':'UNAPPROVED_DRAFT_NO_PROOFS','coreSHA256':corehash,'sources':{n:sha(HERE/n) for n in ['model.bend','LAWS.bend','falsify.py']},'cpu':11,'commands':[],'subjects':{},'mutants':[]}
 def save():(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
 def run(cmd,cap,label):
  command=['taskset','-c','11',*map(str,cmd)];r=subprocess.run(command,cwd=stage,capture_output=True,text=True,timeout=cap)
  (out/(label+'.stdout')).write_text(r.stdout);(out/(label+'.stderr')).write_text(r.stderr);receipt['commands'].append({'command':command,'capSeconds':cap,'exit':r.returncode});save();assert r.returncode==0,(label,r.stdout,r.stderr);return r.stdout
 def build(subject,label):
  src=stage/(subject+'.bend');src.write_text(fixture(subject));run(['bend',src,'--check-only'],5,label+'-check');run(['bend',src,'-o',out/(label+'.js')],30,label+'-emit');return json.loads(run(['node',out/(label+'.js')],5,label+'-run'))
 try:
  receipt['versions']={'bend':run(['bend','version'],5,'bend-version').strip(),'node':run(['node','--version'],5,'node-version').strip()}
  for subject,(cases,expected) in subjects.items():
   (out/(subject+'-inputs.json')).write_text(json.dumps(cases));(out/(subject+'-expected.json')).write_text(json.dumps(expected))
   actual=build(subject,subject);assert actual==[[x,x] for x in expected];receipt['subjects'][subject]={'literalInstances':len(cases),'status':'NO_COUNTEREXAMPLE_IN_LITERAL_DOMAIN'}
  for subject,label,old,new in mutants:
   assert original.count(old)==1,(label,original.count(old));changed=original.replace(old,new);(stage/'core.bend').write_text(changed);actual=build(subject,label);expected=subjects[subject][1]
   assert [x[1] for x in actual]==expected,'Independent reference changed';indices=[i for i,(pair,want) in enumerate(zip(actual,expected)) if pair[0]!=want];assert indices,(label,'survived')
   receipt['mutants'].append({'subject':subject,'label':label,'compiled':True,'detected':True,'mismatchingLiteralIndices':indices,'coreSHA256':sha(stage/'core.bend'),'reachedWitness':{'input':subjects[subject][0][indices[0]],'expected':expected[indices[0]],'actual':actual[indices[0]][0]}});save();(stage/'core.bend').write_text(original)
  assert sha(core)==corehash;assert (stage/'core.bend').read_text()==original
  assert {n:sha(HERE/n) for n in receipt['sources']}==receipt['sources'];receipt['artifacts']={str(p.relative_to(out)):sha(p) for p in out.rglob('*') if p.is_file() and p.name!='receipt.json'};receipt['status']='PASS_LITERAL_FALSIFICATION_AND_REACHED_MUTANTS'
 except Exception as e:receipt.update(status='ERROR',error=repr(e));raise
 finally:save()
 print(json.dumps({'status':receipt['status'],'subjects':receipt['subjects'],'mutants':len(receipt['mutants'])}))
if __name__=='__main__':main()
