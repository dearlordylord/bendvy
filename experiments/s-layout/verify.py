#!/usr/bin/env python3
"""Fresh semantic comparisons, bounds, provider controls and actual mutants."""
import hashlib,json,os,re,sys,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import build,command,execute
from controls import test
ROOT=HERE.parent.parent

def paired(programs,args=(),timed=False):
 values=[execute(p,args) for p in programs]
 if timed:
  values=[value.splitlines()[-1].rsplit(':',1)[0] for value in values]
 assert values[0]==values[1],values
 return values[0]
def copied(folder,replacements):
 folder.mkdir()
 for p in HERE.glob('*.bend'):
  source=p.read_text()
  def rewrite(m):
   target=(p.parent/m.group(1)).resolve()
   target=folder/target.name if target.parent==HERE else target
   rel=os.path.relpath(target,folder)
   return 'import '+(rel if rel.startswith('.') else './'+rel)
  source=re.sub(r'import (\.[^\s]+)',rewrite,source)
  for filename,old,new in replacements:
   if p.name==filename:
    assert source.count(old)==1,(filename,old,source.count(old))
    source=source.replace(old,new)
  (folder/p.name).write_text(source)
def main():
 test()
 expected_pins=json.loads((ROOT/'.references/sources.json').read_text())['sources']
 for name,entry in expected_pins.items(): assert command(['git','-C','/workspace/formal-proofs/bendvy/.references/'+name,'rev-parse','HEAD']).strip()==entry['commit']
 ledger={}
 with tempfile.TemporaryDirectory(prefix='verify-',dir=HERE) as tmp:
  folder=Path(tmp)
  owned=paired(build(HERE/'owned-main.bend',folder));reference=command(['node',HERE/'owned-reference.mjs']).strip();assert owned==reference,(owned,reference)
  ledger['owned_trace']=owned.splitlines()
  relocated=paired(build(HERE/'relocation.bend',folder))
  assert relocated.splitlines()==['before:0=10;1=20;2=30;','relocate:moved','after:0=10;1=20;2=30;','vacated-component:0=10;2=30;','reinsert:0=10;1=20;2=30;','occupied:occupied','target-bound:bounds','id-bound:bounds','preserved:0=10;1=20;2=30;'],relocated
  relocation_reference=command(['node',HERE/'relocation-reference.mjs']).strip().splitlines()
  assert [line for line in relocated.splitlines() if line.startswith(('before:','after:','vacated-component:','reinsert:','preserved:'))]==relocation_reference
  ledger['relocation_trace']=relocated.splitlines()
  readers=paired(build(HERE/'readers.bend',folder));reader_reference=command(['node',HERE.parent/'t08'/'reference.mjs']).strip();assert readers==reader_reference,(readers,reader_reference)
  ledger['reader_trace']=readers.splitlines();assert len(ledger['reader_trace'])==21
  lifecycle=paired(build(HERE/'lifecycle.bend',folder)).splitlines()
  lr=command(['node',HERE/'lifecycle-reference.mjs']).strip().splitlines()
  assert [line for line in lifecycle if not line.startswith(('bound:','max-bound:','capacity:'))]==lr,(lifecycle,lr)
  assert lifecycle[-1]=='capacity:no-reuse' and 'bound:MissingEntity' in lifecycle and 'max-bound:MissingEntity' in lifecycle
  ledger['lifecycle_trace']=lifecycle
  foreign=paired(build(HERE/'foreign.bend',folder));assert json.loads(foreign)=='MissingEntity',foreign
  fr=command(['node',HERE.parent/'t05'/'reference.mjs']).strip().splitlines()[-1]
  assert fr=='foreign-collision:lookup:match:local:7',fr
  ledger['foreign_divergence']={'bend':json.loads(foreign),'ts':fr,'approved':True,'factory':'T05 single-lineage namespace creation, not fixture constants'}
  core=build(HERE/'main.bend',folder)
  for mode in [0,1,2,3,4,5]:
   value=paired(core,[str(mode),'64','2'],timed=True)
   expected=command(['node',HERE.parent/'t10'/'reference.mjs',str(mode),'64','2'],timeout=15).strip().rsplit(':',1)[0];assert value==expected,(mode,value,expected)
  boundary=paired(core,['0','2048','0'],timed=True)
  assert boundary=='2048:2048:0|'+''.join(f'{i}=1,' for i in range(2048)),boundary
  for size in ['2049','4294967295']:
   assert paired(core,['0',size,'0'],timed=True)=='0:0:0|'
  ledger['capacity_controls']=['2048 valid exact all-ID ordered projection','2049 rejected before filling arrays','4294967295 rejected before Nat initialization/no wrap']
  mutations=[
   ('selected-reader',[('seams.bend','C.read(b, success, with_rows(rs, meta))','C.read(False{}, success, with_rows(rs, meta))')],'readers.bend',[],readers),
   ('skip-reader',[('seams.bend','C.skip(b, meta)','C.skip(False{}, meta)')],'readers.bend',[],readers),
   ('stale-map',[('relocation.bend','Array.set(U32, map, id, target)','map')],'relocation.bend',[],relocated),
   ('mapping',[('core.bend','Array.get(C.Row, rows, slot(limit, id))','Array.get(C.Row, rows, id)')],'main.bend',['0','64','0'],None),
   ('order',[('core.bend','project(members, limit, rows, Projection{0, 0, ""})','project(List.reverse(&2, U32, members), limit, rows, Projection{0, 0, ""})')],'main.bend',['0','64','0'],None),
   ('write-observation',[('core.bend','C.set_row(x, tick, old)','old')],'main.bend',['5','64','2'],None),
   ('rollback',[('core.bend','restore(undo, limit, rows), members, meta','rows, members, meta')],'main.bend',['5','64','2'],None),
   ('churn',[('core.bend','flush(queue([C.Remove{0}, C.Insert{0, 1}], w))','w')],'main.bend',['3','64','2'],None),
   ('owned-forward-undo',[('owned.bend','restore_values(undo, items)','restore_values(List.reverse(&2, U32, undo), items)')],'owned-main.bend',[],owned),
   ('owned-restore',[('owned.bend','Payload{restore_values(undo, items)}','Payload{items}')],'owned-main.bend',[],owned),
  ]
  ledger['mutants']=[]
  for name,replacements,entry,args,expected in mutations:
   mf=folder/name;copied(mf,replacements)
   if expected is None:expected=paired(core,args,timed=True)
   value=paired(build(mf/entry,mf),args,timed=entry=='main.bend')
   assert value!=expected,('surviving mutant',name)
   ledger['mutants'].append({'name':name,'native_js_agree':True,'expected':expected,'observed':value,'replacements':replacements})
   print('compiling mutant detected:',name,flush=True)
 ledger['source_sha256']={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in HERE.iterdir() if p.suffix in ('.bend','.mjs','.py')}
 (HERE/'verification.json').write_text(json.dumps(ledger,indent=2)+'\n')
 print('S-LAYOUT finite validation PASS; no universal law/proof/performance acceptance')
if __name__=='__main__':main()
