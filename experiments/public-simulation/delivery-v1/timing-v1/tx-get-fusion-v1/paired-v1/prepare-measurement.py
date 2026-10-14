"""Prepare existing timer/profile routes; bind actual qualification before sampling."""
import copy,hashlib,json,runpy
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
DELIVERY=ROOT/'experiments/public-simulation/delivery-v1'
TIMING=DELIVERY/'timing-v1'
OPT=DELIVERY/'optimization-v1'
BASE_PLAN=DELIVERY/'ordinary-evidence-v7/plan.json'
CANDIDATE_PLAN=HERE.parent/'binding-repair-v2/plan.json'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()

def pin(plan,files):
    for file in files:plan['pins'][str(file.resolve())]=sha(file)
    plan['smallInputPaths']=sorted(set(plan['smallInputPaths'])|{str(p.resolve()) for p in files})

def expected_outputs_pinned(plan,required):
    outputs=plan['validationInputs']['expectedOutputs']
    if set(outputs)!=set(required):raise ValueError('complete expected-output roles required')
    for name in required:
        path=Path(outputs[name])
        if not path.is_absolute() or path.is_symlink() or not path.is_file() or plan['pins'].get(str(path))!=sha(path):
            raise ValueError('every expected output must be pinned')

def semantic(planpath):
    p=json.loads(planpath.read_bytes());e=Path(p['outputRoot']);r=json.loads((e/'receipt.json').read_bytes())
    if r['planSHA256']!=sha(planpath) or r['status']!='RELOCATED_SIMULATION_SEMANTIC_DELIVERY_PASS_NOT_TIMING_OR_FULL_PARITY':raise ValueError('qualified original required')
    if len(r['commands'])!=7 or any(c['exit']!=0 or c['failure'] is not None for c in r['commands']):raise ValueError('all ordinary stages required')
    for name in ['simulation.js','simulation.c']:
        if sha(e/name)!=r['generated'][name]:raise ValueError('qualified artifact drift')
    return p,e,r

def timed_inputs(role,planpath):
    p,e,r=semantic(planpath);i=HERE/'inputs'/role
    if i.exists():raise ValueError('fresh timer inputs required')
    i.mkdir(parents=True)
    instrument=runpy.run_path(str(TIMING/'instrument.py'))['instrument'];transforms={}
    for backend,suffix in [('JS','js'),('Native','c')]:
        original=e/('simulation.'+suffix);target=i/original.name
        target.write_text(instrument(backend,original.read_text()))
        transforms[backend]={'source':str(original),'sourceSHA256':sha(original),'target':str(target),'targetSHA256':sha(target),'inverseExact':True}
    spec=runpy.run_path(str(TIMING/'prepare-application.py'));ref=ROOT/'experiments/public-simulation/reference-v1';original=(ref/'reference.mjs').read_text()
    if original.count(spec['TS_OLD'])!=1:raise ValueError('one original TS seam required')
    changed=original.replace(spec['TS_OLD'],spec['TS_NEW'])
    if changed.replace(spec['TS_NEW'],spec['TS_OLD'])!=original:raise ValueError('TS inverse mismatch')
    (i/'reference.mjs').write_text(changed)
    for name in ['inputs.json','expected.json']:(i/name).write_bytes((ref/name).read_bytes())
    transforms['TS']={'source':str(ref/'reference.mjs'),'sourceSHA256':sha(ref/'reference.mjs'),'target':str(i/'reference.mjs'),'targetSHA256':sha(i/'reference.mjs'),'inverseExact':True}
    (i/'TRANSFORMATIONS.json').write_text(json.dumps(transforms,indent=2)+'\n')
    return p,e,i

def primary():
    base,be,br=semantic(BASE_PLAN);cand,ce,cr=semantic(CANDIDATE_PLAN)
    for role in ['baseline','candidate']:
        transforms=json.loads((HERE/'inputs'/role/'TRANSFORMATIONS.json').read_bytes())
        for record in transforms.values():
            if sha(Path(record['source']))!=record['sourceSHA256'] or sha(Path(record['target']))!=record['targetSHA256'] or record['inverseExact'] is not True:
                raise ValueError('reversible input binding drift')
    p=copy.deepcopy(cand);p['pins'].update(base['pins']);p['smallInputPaths']=sorted(set(p['smallInputPaths'])|set(base['smallInputPaths']))
    contract=json.loads((ROOT/'benchmarks/contract.json').read_bytes());api=runpy.run_path(str(HERE/'paired-sampling.py'));rows=api['schedule'](contract);t=p['toolConfiguration']['tools'];out=HERE/'measured01'
    commands=[]
    def command(label,argv,cap,**extra):return dict(label=label,argv=[t['taskset'],'-c','5',*argv],capSeconds=cap,**extra)
    for role in ['baseline','candidate']:
        i=HERE/'inputs'/role;binary=out/(role+'.native')
        commands.extend([command('qualification-'+role+'-TS',[t['node'],str(i/'reference.mjs')],5,control='TS'),command('qualification-'+role+'-JS',[t['node'],str(i/'simulation.js')],5,control='JS'),command('qualification-'+role+'-Native-clang',[t['clangWrapper'],'-O3',str(i/'simulation.c'),'-pthread','-lm','-o',str(binary)],120,emits=binary.name,runtimeArtifact=binary.name),command('qualification-'+role+'-Native',[str(binary),'--threads','1','--gpu','off'],5,control='Native')])
    programs={'TS':[t['node'],str(HERE/'inputs/baseline/reference.mjs')],'baseline-JS':[t['node'],str(HERE/'inputs/baseline/simulation.js')],'candidate-JS':[t['node'],str(HERE/'inputs/candidate/simulation.js')],'baseline-Native':[str(out/'baseline.native'),'--threads','1','--gpu','off'],'candidate-Native':[str(out/'candidate.native'),'--threads','1','--gpu','off']}
    commands.extend(command(r['label'],programs[r['role']],5,control='TS' if r['role']=='TS' else r['role'].split('-')[1]) for r in rows)
    p.update(outputRoot=str(out),commands=commands,samplingRows=rows,samplingHelper=str(HERE/'paired-sampling.py'),qualificationValidator=str(OPT/'validate-timing.py'),validationInputs={'expectedOutputs':{'TS':str(be/'TS.stdout'),'JS':str(ce/'JS-run.stdout'),'Native':str(ce/'Native-run.stdout')}},quietWindowContext='NOT_ESTABLISHED',maximumProbeCommands=11*(2*len(commands)+4),scope='Qualification8 then110 fresh full14phase/twoschema processes: balanced20 baseline/candidate pairs per backend,2warmups per role and observedTS; no Workshop change',timing='Internal simulation clocks, transport separate; build/startup excluded. Frozen preparation only until fresh CPU5 quiet/exclusive reservation is recorded.')
    pin(p,[BASE_PLAN,be/'receipt.json',be/'simulation.js',be/'simulation.c',be/'TS.stdout',be/'JS-run.stdout',CANDIDATE_PLAN,ce/'receipt.json',ce/'simulation.js',ce/'simulation.c',ce/'JS-run.stdout',ce/'Native-run.stdout',HERE/'prepare-measurement.py',HERE/'paired-sampling.py',HERE/'ADAPTER-CHECKS.json',ROOT/'benchmarks/contract.json',ROOT/'benchmarks/decision.py',ROOT/'benchmarks/run.py',OPT/'validate-timing.py',TIMING/'instrument.py',TIMING/'prepare-application.py',TIMING/'evidence-controls-v4/MANIFEST.json',TIMING/'evidence-controls-v4/verify.py',Path('/tmp/bendvy63-timing-sequence-controls-v1/receipt.json'),*sorted((HERE/'inputs').rglob('*.*'))])
    expected_outputs_pinned(p,['TS','JS','Native'])
    return p

def profiles(role,planpath):
    p,e,r=semantic(planpath);out=HERE/(role+'-profiles01');t=p['toolConfiguration']['tools'];commands=[]
    for control,flag,name in [('CPU','--cpu-prof','simulation.cpuprofile'),('allocation','--heap-prof','simulation.heapprofile')]:
        commands.append(dict(label=role+'-'+control,argv=[t['taskset'],'-c','5',t['node'],flag,flag+'-dir='+str(out),flag+'-name='+name,flag+'-interval='+('100' if control=='CPU' else '8192'),str(e/'simulation.js')],capSeconds=5,control=control,emits=name))
    p.update(outputRoot=str(out),commands=commands,qualificationValidator=str(OPT/'validate-after-profile.py'),validationInputs={'expectedOutputs':{'JS':str(e/'JS-run.stdout')}},maximumProbeCommands=48,scope='Actual '+role+' original JS whole-process CPU100us/sampled-allocation8192 diagnostic, includes startup/JIT/printer; no RSS or causal allocation claim',timing='Separate from unprofiled paired clocks; diagnostics only')
    pin(p,[planpath,e/'receipt.json',e/'simulation.js',e/'JS-run.stdout',OPT/'validate-after-profile.py',HERE/'prepare-measurement.py']);expected_outputs_pinned(p,['JS']);return p

if __name__=='__main__':
    outputs={'primary-plan.json':primary(),'baseline-profile-plan.json':profiles('baseline',BASE_PLAN),'candidate-profile-plan.json':profiles('candidate',CANDIDATE_PLAN)}
    for name,p in outputs.items():(HERE/name).write_text(json.dumps(p,indent=2,sort_keys=True)+'\n')
