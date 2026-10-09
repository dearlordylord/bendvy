"""No-child current direct full30 mutation plans; existing Runner recipe only."""
from pathlib import Path
import sys,json,hashlib,gzip,importlib.util
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[7]
def sha(p):
 p=Path(p);assert p.is_file() and not p.is_symlink();return hashlib.sha256(p.read_bytes()).hexdigest()
def load(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def main(directory):
 directory=Path(directory).resolve();assert not directory.exists() and not directory.is_symlink()
 basepath=Path('/tmp/bendvy-relations42-direct-emission03/full-js-emit-plan.json');base=json.loads(basepath.read_text());P=load('source',HERE/'prepare.py');F=load('force',HERE.parents[3]/'trace-cheap.py');C=load('controls',HERE/'direct-mutant-source-controls.py');C.main()
 files=set(map(Path,base['pins']));files.update([basepath,Path(__file__).resolve(),HERE/'direct-mutant-execution.py',HERE/'direct-mutant-source-controls.py'])
 for n,h in base['pins'].items():assert sha(n)==h
 for path in [Path('/tmp/bendvy-relations42-direct-runtime01/full-js/receipt.json'),Path('/tmp/bendvy-relations42-direct-native-runtime01/native-full9/receipt.json')]:
  r=json.loads(path.read_text());assert r['status']=='NEXT_STATE_RUNTIME_PASS_NO_TIMING' and len(r['commands'])==9 and len(r['guards'])==20 and all(x['unchanged'] for x in r['guards']);assert all(x['completeOraclePass'] and x['markerStatGatePass'] for x in r['commands']);files.add(path)
 anchor=next(c for c in base['allNineOracles'] if c['input']==['depth','256','16','0']);positive=Path(anchor['oracle']);counter=positive.with_name('last-leaf-'+positive.name);files.add(counter);positiveWalk=F.force(json.loads(gzip.decompress(positive.read_bytes())));counterWalk=F.force(json.loads(gzip.decompress(counter.read_bytes())))
 entries={'last-leaf':HERE/'driver-direct-last-leaf.bend','moved-walk':HERE/'driver-direct-moved-walk.bend'};closures={}
 for label,entry in entries.items():
  seen=set();P.closure(entry,seen);files.update(seen);closures[label]={str(p):sha(p) for p in sorted(seen)}
 pins={str(p):sha(p) for p in sorted(files)};directory.mkdir();digests={};common={**base,'pins':pins,'scope':'Direct source-current reached mutation full30 depth256/span16 anchor; broad normal9JS/Native retained, no performance/taskclosure','status':'NOT_LAUNCH_ADMITTED'}
 for label,entry in entries.items():
  for backend,suffix in [('js','js'),('native','c')]:
   output=directory/(label+'-'+backend);artifact=output/('trace.'+suffix);plan={**common,'stage':'emit','output':str(output),'generated':[str(artifact)],'sourceInventory':closures[label],'commands':[{'label':'emit','argv':['/usr/bin/taskset','-c','5','/home/node/.bend/bin/bend-2.0.35',str(entry),'-o',str(artifact)],'seconds':30}]};target=directory/(label+'-'+backend+'-emit-plan.json');target.write_text(json.dumps(plan,indent=2)+'\n');digests[target.name]=sha(target)
  plan={k:common[k] for k in ['pins','resourceRoots','environment','cwd','lock']};plan.update(scope='Source-current direct full30 mutant source5 development, no backend',output=str(directory/(label+'-source5')),sourceInventory=closures[label],command={'label':'source5','argv':['/usr/bin/taskset','-c','5','/home/node/.bend/bin/bend-2.0.35',str(entry),'--check-only'],'seconds':5},recipe='Existing Inputs/Runner/CommandLogs expectedNone sharedlock pre/acquired/post/final/raw/unconditionalreceipt');target=directory/(label+'-source5-plan.json');target.write_text(json.dumps(plan,indent=2)+'\n');digests[target.name]=sha(target)
 sequence={'executionSource':str(HERE/'direct-mutant-execution.py'),'executionSourceSHA256':sha(HERE/'direct-mutant-execution.py'),'anchorInput':anchor['input'],'positiveOracle':str(positive),'lastLeafCounterOracle':str(counter),'positiveWalk':positiveWalk,'lastLeafCounterWalk':counterWalk,'movedWalkCounterOracle':str(positive),'movedWalkCounterWalk':{'nodes':0,'characters':0,'sum':0},'stages':['source5 each CPU5 cap5','emit each JS/C CPU5 cap30','inspect actual reached forced/effect continuations','bind JS artifact to existing negative Runner code runtime5','bind C to approvedClang19 build120 then freeze binary runtime5threads1GPUoff'],'futureArtifacts':'UNADMITTED until exactguards/hashbinding','normalBroadScope':'complete9JS and9Native immutable; one full30 governing mutation anchor authorized; no deletion of othercases','movedMutation':'actual sole Complete effect moved before force, not added fabricated extra marker; output oracle alone insufficient; primitive walk gate mustreject'};target=directory/'sequence.json';target.write_text(json.dumps(sequence,indent=2)+'\n');digests[target.name]=sha(target);print(json.dumps(digests,indent=2))
if __name__=='__main__':main(sys.argv[1])
