"""Source-bound finite seek controls. No profiling, timing or live promotion."""
import argparse,pathlib,hashlib,json,subprocess,os,tempfile,shutil,gzip,re

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
from task_runner import run as _run_command

HERE=pathlib.Path(__file__).resolve().parent; ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();OUT=a.output.resolve();OUT.mkdir(parents=True,exist_ok=False)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def source():return {str(p.relative_to(ROOT)):sha(p) for p in sorted([*ROOT.glob('src/ecs/*.bend'),*HERE.glob('*.bend'),HERE/'core-run.py',HERE.parent/'workshop/schema.bend'])}
SNAP=source();r={'status':'INCOMPLETE','sources':SNAP,'scope':'972 legacy/indexed/new triples and four wrapped raw controls; finite only; no performance qualification','commands':[],'mutants':{}}
def inventory(stage):return {str(p.relative_to(stage)):sha(p) for p in sorted(stage.rglob('*')) if p.is_file()}
def guard(stage,expected):assert inventory(stage)==expected,'staged source drift';assert source()==SNAP,'root source drift'
def run(stage,expected,label,cmd,cap,good=True):
 guard(stage,expected)
 q=_run_command(list(map(str,cmd)),capture_output=True,text=True,timeout=cap,env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root'))
 data=q.stdout.encode();gzip.open(OUT/(label+'.stdout.gz'),'wb').write(data);(OUT/(label+'.stderr')).write_text(q.stderr)
 r['commands'].append({'label':label,'command':list(map(str,cmd)),'cap_seconds':cap,'exit':q.returncode})
 assert (q.returncode==0)==good,(label,q.stderr)
 guard(stage,expected)
 return q.stdout if good else q.stdout+q.stderr

def validate(text):
 lines=text.splitlines();assert len(lines)==976,len(lines)
 for i,line in enumerate(lines[:972]):
  idx,legacy,old,new=line.split('|');assert int(idx)==i;assert legacy==old==new,(i,legacy,old,new)
  target=i%6;fuel=(i//6)%9;rows=(i//54)%3;changes=i>=486
  found=(rows>0 and target==2 and fuel>=2) or (rows==2 and target==4 and fuel>=4)
  if found:
   v=12 if target==2 else 14
   assert new.startswith('view=['+str(v)+', '+str(v+100)+'];'),(i,new)
   assert 'current='+str(target)+':['+str(v+int(changes))+','+str(v+100)+';calls=1]' in new,(i,new)
   assert new.count('calls=1')==2,(i,new)
  else:assert new.startswith('view=-;') and 'calls=1' not in new,(i,new)
  assert not re.search(r'calls=[2-9]',new),(i,new)
 for j,line in enumerate(lines[972:]):
  assert line.startswith('W'+str(j)+'|'),line
  value=line.split('|',1)[1]
  if j==0:assert value.startswith('view=[12, 112];') and 'current=2:[13,112;calls=1]' in value and value.count('calls=1')==2,value
  else:
   assert value.startswith('view=-;') and 'calls=1' not in value,value
   assert 'current='+('2' if j==1 else '0')+':-' in value,value
  def payload(v,calls=0):return '['+str(v)+','+str(v+100)+';calls='+str(calls)+']'
  stamps='stamps='+''.join(str(i)+':'+str(x)+','+str(y)+';' for i,x,y in [(0,0,0),(1,2,3),(2,4,5),(3,0,0),(4,8,9),(5,10,11),(6,0,0),(7,0,0),(8,0,0),(131073,0,0),(4294967295,0,0)])
  hist='history=3:-;1:'+payload(11)+';'
  if j==0:
   actualpayload='[13,112;calls=1]'
   expected='view=[12, 112];current=2:'+actualpayload+';capacity=8;remaining=;'+hist+';physical='+payload(11)+';'+actualpayload+';-;-;'+payload(15)+';'+payload(16)+';-;'+payload(18)+';'+stamps
  else:
   expected='view=-;current='+('2' if j==1 else '0')+':-;capacity=8;remaining=2:'+payload(12)+';4:'+payload(14)+';;'+hist+';physical='+payload(11)+';'+payload(12)+';-;'+payload(14)+';'+payload(15)+';'+payload(16)+';-;'+payload(18)+';'+stamps
  assert value==expected,(j,value,expected)
 return lines

try:
 with tempfile.TemporaryDirectory(prefix='indexed-seek-source-') as tmp:
  stage=pathlib.Path(tmp)
  for name,digest in SNAP.items():
   dst=stage/name;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/name,dst);assert sha(dst)==digest
  expected=inventory(stage);assert expected==SNAP
  fixture=stage/HERE.relative_to(ROOT)/'fixture.bend';fast=stage/'src/ecs/column.bend'
  initial=dict(expected)
  replacements={'F.Decision':'Col.IndexedViewDecision','F.Found':'Col.IndexedViewFound','F.Absent':'Col.IndexedViewAbsent','F.Exhausted':'Col.IndexedViewExhausted','F.Advance':'Col.IndexedViewAdvance','F.Wrapped':'Col.IndexedViewWrapped','F.inspect':'Col.indexed_view_inspect','F.loop':'Col.indexed_view_loop'}
  for client in [fixture,fixture.parent/'negative-owner.bend']:
   guard(stage,expected);text=client.read_text();text=text.replace('import fast.bend as F', '' if 'import ../../../src/ecs/column.bend as Col' in text else 'import ../../../src/ecs/column.bend as Col')
   for old,new in replacements.items():text=text.replace(old,new)
   client.write_text(text);expected[str(client.relative_to(stage))]=sha(client);guard(stage,expected)
  r['core_client_rebases']={k:{'original':initial[k],'rebased':v} for k,v in expected.items() if initial[k]!=v}
  run(stage,expected,'version',['bend','version'],5);run(stage,expected,'guide',['bend','guide'],5)
  run(stage,expected,'check',['bend',fixture,'--check-only'],5)
  error=run(stage,expected,'negative-owner',['bend',fixture.parent/'negative-owner.bend','--check-only'],5,False);assert 'decision (consumed more than once)' in error,error
  observed=[]
  def backends(label,expected,validator):
   texts=[]
   for backend in ['JS','Native']:
    target=OUT/(label+('.js' if backend=='JS' else '.c'));run(stage,expected,label+'-emit-'+backend,['bend',fixture,'-o',target],30)
    if backend=='Native':run(stage,expected,label+'-compile',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',OUT/label,'-pthread','-lm'],120)
    result=run(stage,expected,label+'-run-'+backend,['node',target] if backend=='JS' else [OUT/label],5);texts.append(result);validator(result,backend)
   assert texts[0]==texts[1],label+' backend output differs'
  backends('normal',expected,lambda text,backend:observed.append(validate(text)))
  original=fast.read_text()
  history='''def indexed_probe_append_history(~S:Data,~C:Type,past:History<S,C>,+id:U32,incoming:Maybe<&1,C>) -> History<S,C>:
  match past:
    case HistoryNil{}: HistoryCon{id,incoming,HistoryNil{}}
    case HistoryCon{oldid,oldowner,rest}: HistoryCon{oldid,oldowner,indexed_probe_append_history(~S,~C,rest,id,incoming)}
'''
  mutations={
   'head':original.replace('case True{} _: IndexedViewFound{owner,remaining,past}','case True{} _: IndexedViewAbsent{remaining,past}'),
   'history':original.replace('def indexed_view_choose(',history+'def indexed_view_choose(',1).replace('IndexedViewAdvance{remaining,HistoryCon{id,Some{owner},past}}','IndexedViewAdvance{remaining,indexed_probe_append_history(~S,~C,past,id,Some{owner})}'),
   'fuel':original.replace('case 1n H.HandoffCon{id,owner,rest}: IndexedViewExhausted{H.HandoffCon{id,owner,rest},past}','case 1n H.HandoffCon{+id,owner,rest}: indexed_view_choose(~S,~C,id,owner,rest,past,U32.is_eq(target,id),U32.is_lt(target,id))')}
  for name,text in mutations.items():
   assert text!=original;guard(stage,expected);fast.write_text(text);mutated=dict(expected);mutated[str(fast.relative_to(stage))]=sha(fast);r['mutants'][name]={'changed_source':str(fast.relative_to(stage)),'sha256':sha(fast),'backends':{}}
   run(stage,mutated,name+'-check',['bend',fixture,'--check-only'],5)
   def killed(text,backend):
    try:validate(text)
    except AssertionError:r['mutants'][name]['backends'][backend]='DETECTED'
    else:raise AssertionError(name+' survived '+backend)
   backends(name,mutated,killed);guard(stage,mutated);fast.write_text(original);guard(stage,expected)
  guard(stage,expected)
 assert source()==SNAP;r['status']='PASS';r['triples']=972;r['wrapped_controls']=4
finally:
 r['artifacts']={p.name:sha(p) for p in sorted(OUT.iterdir()) if p.is_file() and p.name!='receipt.json'};(OUT/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
