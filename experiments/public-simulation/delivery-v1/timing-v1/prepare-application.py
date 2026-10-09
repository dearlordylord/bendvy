"""Prepare one complete timed application qualification, launch no children."""
import hashlib,json,runpy
from pathlib import Path
HERE=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
TS_OLD='''const output=['Workshop','Garden'].map(run);
console.log(JSON.stringify(output));
assert.deepEqual(JSON.parse(JSON.stringify(output)),JSON.parse(readFileSync(new URL('./expected.json',import.meta.url))));'''
TS_NEW='''const expected=JSON.parse(readFileSync(new URL('./expected.json',import.meta.url)));
const simulationStart=process.hrtime.bigint();
const output=['Workshop','Garden'].map(run);
const simulationStop=process.hrtime.bigint();
const transportStart=process.hrtime.bigint();
const text=JSON.stringify(output);
const transportStop=process.hrtime.bigint();
console.log(text);
assert.deepEqual(JSON.parse(text),expected);
process.stderr.write(JSON.stringify({simulationNs:String(simulationStop-simulationStart),transportNs:String(transportStop-transportStart),bytes:Buffer.byteLength(text+'\\n','utf8')})+'\\n');'''
def prepare():
    planpath=Path('/tmp/bendvy63-timing-sequence-controls-plan-v4.json')
    if sha(planpath)!='93026e2b56be34d49ee145da19b2b64be26e5ab20e93122ed1f41e0b4b6c0889':raise ValueError('exact reached-control plan required')
    plan=json.loads(planpath.read_bytes());evidence=Path('/tmp/bendvy63-ordinary-delivery-v6')
    controls=Path('/tmp/bendvy63-timing-sequence-controls-v1/receipt.json')
    if json.loads(controls.read_bytes())['status']!='REACHED_TIMING_SEQUENCE_CONTROLS_PASS_NOT_MEASUREMENT':raise ValueError('reached controls required')
    inputs=Path('/tmp/bendvy63-timing-application-input-v1');out=Path('/tmp/bendvy63-timing-application-qualification-v1')
    if inputs.exists() or inputs.is_symlink() or out.exists() or out.is_symlink():raise ValueError('fresh application input/output roots required')
    receipt=json.loads((evidence/'receipt.json').read_bytes());instrument=runpy.run_path(str(HERE/'instrument.py'))['instrument'];inputs.mkdir(mode=0o700)
    transformations={}
    for role,suffix in [('JS','js'),('Native','c')]:
        original=evidence/('simulation.'+suffix)
        if sha(original)!=receipt['generated'][original.name]:raise ValueError('successful original artifact drift')
        raw=original.read_bytes();changed=instrument(role,raw.decode()).encode();target=inputs/original.name;target.write_bytes(changed)
        transformations[role]={'source':str(original),'sourceSHA256':sha(original),'target':str(target),'targetSHA256':sha(target),'inverseExact':True}
    reference=Path('/workspace/formal-proofs/bendvy/experiments/public-simulation/reference-v1');original=(reference/'reference.mjs').read_text()
    if original.count(TS_OLD)!=1:raise ValueError('exact TS two-run seam required')
    changed=original.replace(TS_OLD,TS_NEW);assert changed.replace(TS_NEW,TS_OLD)==original
    (inputs/'reference.mjs').write_text(changed)
    for name in ['inputs.json','expected.json']:(inputs/name).write_bytes((reference/name).read_bytes())
    transformations['TS']={'source':str(reference/'reference.mjs'),'sourceSHA256':sha(reference/'reference.mjs'),'target':str(inputs/'reference.mjs'),'targetSHA256':sha(inputs/'reference.mjs'),'inverseExact':True}
    (inputs/'TRANSFORMATIONS.json').write_text(json.dumps(transformations,indent=2)+'\n')
    tools=plan['toolConfiguration']['tools'];taskset=tools['taskset']
    def command(label,argv,cap,**more):return dict(label=label,argv=[taskset,'-c','5',*argv],capSeconds=cap,**more)
    commands=[command('timed-TS',[tools['node'],str(inputs/'reference.mjs')],5,control='TS'),command('timed-JS',[tools['node'],str(inputs/'simulation.js')],5,control='JS'),command('timed-Native-clang',[tools['clangWrapper'],'-O3',str(inputs/'simulation.c'),'-pthread','-lm','-o',str(out/'simulation.native')],120,emits='simulation.native',runtimeArtifact='simulation.native'),command('timed-Native',[str(out/'simulation.native'),'--threads','1','--gpu','off'],5,control='Native')]
    files=[*inputs.iterdir(),evidence/'TS.stdout',evidence/'JS-run.stdout',evidence/'Native-run.stdout',HERE/'prepare-application.py',HERE/'validate-application.py',HERE.parent/'TIMING-READINESS.md',planpath,controls,HERE/'evidence-controls-v4/MANIFEST.json',HERE/'evidence-controls-v4/verify.py']
    pins=dict(plan['pins'])
    for file in files:pins[str(file.resolve())]=sha(file)
    plan.update(pins=pins,smallInputPaths=sorted(set(plan['smallInputPaths'])|{str(p.resolve())for p in files}),outputRoot=str(out),commands=commands,qualificationValidator=str(HERE/'validate-application.py'),maximumProbeCommands=92,scope='One complete14phase/twoschema application timed-boundary semantic qualification per backend, no comparative performance verdict or repeated measurement',timing='Qualification only; require full original outputs, internal clocks typed, no ratio/threshold or startup/build measurements')
    return plan
if __name__=='__main__':print(json.dumps(prepare(),indent=2))
