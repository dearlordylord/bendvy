"""Freeze reached-control sequence on existing ordinary delivery collector."""
import hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def prepare():
    source=Path('/tmp/bendvy63-ordinary-delivery-plan-v6.json')
    if sha(source)!='89b02105f70aecdc82cdabff3be0b492f4e8d565018b7037957b6b8494af0635':raise ValueError('successful semantic plan required')
    plan=json.loads(source.read_bytes());out=Path('/tmp/bendvy63-timing-sequence-controls-v1')
    if out.exists() or out.is_symlink():raise ValueError('fresh controls output required')
    tools=plan['toolConfiguration']['tools'];taskset=tools['taskset']
    def command(label,argv,cap,**more):return dict(label=label,argv=[taskset,'-c','5',*argv],capSeconds=cap,**more)
    commands=[command('JS-controls',[tools['node'],str(HERE/'controls.mjs')],5,control='JS')]
    for name in ['positive','hoisted','included']:
        artifact='control-'+name+'.native'
        commands.append(command('Native-clang-'+name,[tools['clangWrapper'],'-O3',str(HERE/('control-'+name+'.c')),'-pthread','-lm','-o',str(out/artifact)],120,emits=artifact,runtimeArtifact=artifact))
        commands.append(command('Native-controls-'+name,[str(out/artifact)],5,expectedExit=0 if name=='positive' else 3,control=name))
    files=[p for p in HERE.iterdir() if p.is_file() and p.suffix in {'.py','.c','.mjs','.md'}]
    evidence=Path('/tmp/bendvy63-ordinary-delivery-v6'); receipt=json.loads((evidence/'receipt.json').read_bytes())
    if receipt['status']!='RELOCATED_SIMULATION_SEMANTIC_DELIVERY_PASS_NOT_TIMING_OR_FULL_PARITY':raise ValueError('complete semantic subject required')
    for name in ['simulation.js','simulation.c']:
        if sha(evidence/name)!=receipt['generated'][name]:raise ValueError('successful original artifact drift')
    files += [HERE.parent/'run-delivery.py',source,evidence/'receipt.json',evidence/'simulation.js',evidence/'simulation.c']
    pins=dict(plan['pins'])
    for file in files:pins[str(file.resolve())]=sha(file)
    # No previous generated artifact is silently rebound; source plan/receipt identify the semantic subject.
    plan.update(pins=pins,smallInputPaths=sorted(set(plan['smallInputPaths'])|{str(p.resolve())for p in files}),outputRoot=str(out),commands=commands,qualificationValidator=str(HERE/'validate-controls.py'),maximumProbeCommands=198,scope='Reached JS/C entry sequencing controls only on exact proposed artifact timing seams; ordinary guards, no simulation timing or numerical verdict',timing='No measurements admitted; controls qualify evaluation-before-printer order only')
    return plan
if __name__=='__main__':print(json.dumps(prepare(),indent=2))
