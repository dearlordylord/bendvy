"""Reuse exact reached timer boundary on qualified named-loop artifacts; no children."""
import hashlib,json,runpy
from pathlib import Path
H=Path(__file__).resolve().parent;T=H.parent/'timing-v1';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def prepare():
 pp=Path('/tmp/bendvy63-named-loop-qualification-plan-v2.json');assert sha(pp)=='4a4367b17e3bffff1cea4e3f53181eaa7607fdc91d604234f316e8423e10873b';p=json.loads(pp.read_bytes());e=Path(p['outputRoot']);r=json.loads((e/'receipt.json').read_bytes());assert r['planSHA256']==sha(pp) and r['status']=='RELOCATED_SIMULATION_SEMANTIC_DELIVERY_PASS_NOT_TIMING_OR_FULL_PARITY'
 control=Path('/tmp/bendvy63-timing-sequence-controls-v1/receipt.json');assert json.loads(control.read_bytes())['status']=='REACHED_TIMING_SEQUENCE_CONTROLS_PASS_NOT_MEASUREMENT'
 i=Path('/tmp/bendvy63-named-loop-timing-input-v2');o=Path('/tmp/bendvy63-named-loop-timing-qualification-v2');assert not i.exists() and not i.is_symlink() and not o.exists() and not o.is_symlink();i.mkdir(mode=0o700)
 instrument=runpy.run_path(str(T/'instrument.py'))['instrument'];transforms={}
 for role,suffix in [('JS','js'),('Native','c')]:
  original=e/('simulation.'+suffix);assert not original.is_symlink() and sha(original)==r['generated'][original.name];raw=original.read_bytes();target=i/original.name;target.write_text(instrument(role,raw.decode()));transforms[role]=dict(source=str(original),sourceSHA256=sha(original),target=str(target),targetSHA256=sha(target),inverseExact=True)
 spec=runpy.run_path(str(T/'prepare-application.py'));ref=Path('/workspace/formal-proofs/bendvy/experiments/public-simulation/reference-v1');original=(ref/'reference.mjs').read_text();assert original.count(spec['TS_OLD'])==1;changed=original.replace(spec['TS_OLD'],spec['TS_NEW']);assert changed.replace(spec['TS_NEW'],spec['TS_OLD'])==original;(i/'reference.mjs').write_text(changed)
 for name in ['inputs.json','expected.json']:(i/name).write_bytes((ref/name).read_bytes())
 transforms['TS']=dict(source=str(ref/'reference.mjs'),sourceSHA256=sha(ref/'reference.mjs'),target=str(i/'reference.mjs'),targetSHA256=sha(i/'reference.mjs'),inverseExact=True);(i/'TRANSFORMATIONS.json').write_text(json.dumps(transforms,indent=2)+'\n')
 tools=p['toolConfiguration']['tools']
 def command(label,argv,cap,**extra):return dict(label=label,argv=[tools['taskset'],'-c','5',*argv],capSeconds=cap,**extra)
 commands=[command('timed-TS',[tools['node'],str(i/'reference.mjs')],5,control='TS'),command('timed-JS',[tools['node'],str(i/'simulation.js')],5,control='JS'),command('timed-Native-clang',[tools['clangWrapper'],'-O3',str(i/'simulation.c'),'-pthread','-lm','-o',str(o/'simulation.native')],120,emits='simulation.native',runtimeArtifact='simulation.native'),command('timed-Native',[str(o/'simulation.native'),'--threads','1','--gpu','off'],5,control='Native')]
 files={*i.iterdir(),pp,e/'receipt.json',e/'simulation.js',e/'simulation.c',e/'TS.stdout',e/'JS-run.stdout',e/'Native-run.stdout',control,T/'instrument.py',T/'prepare-application.py',T/'evidence-controls-v4/MANIFEST.json',T/'evidence-controls-v4/verify.py',H/'evidence-qualification-v2/MANIFEST.json',H/'evidence-qualification-v2/verify.py',H/'prepare-timing.py',H/'validate-timing.py'}
 for file in files:p['pins'][str(file.resolve())]=sha(file)
 p.update(outputRoot=str(o),commands=commands,qualificationValidator=str(H/'validate-timing.py'),maximumProbeCommands=92,smallInputPaths=sorted(set(p['smallInputPaths'])|{str(f.resolve())for f in files}),scope='Full named-loop generated-main timing-boundary semantic qualification; complete14×2 outputs preserved; no comparative verdict',timing='Qualification only; reviewed reached sequence controls unchanged;20balancedpairs/2warmups follow only after actual qualification review')
 return p
if __name__=='__main__':print(json.dumps(prepare(),indent=2))
