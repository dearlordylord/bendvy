"""Existing benchmark balanced order applied to full simulation internal clocks."""
import importlib.util,json,random,statistics
from pathlib import Path
DECISION=Path('/workspace/formal-proofs/bendvy/benchmarks/decision.py')

def schedule(contract):
    if contract['pairs']!=20 or contract['warmups']!=2 or contract['seed']!=20261007:
        raise ValueError('unchanged sampling contract required')
    roles=['TS','baseline-JS','baseline-Native','candidate-JS','candidate-Native']
    rows=[]
    for warmup in range(contract['warmups']):
        for role in roles:
            rows.append({'label':f'warmup-{warmup}-{role}','role':role,'pair':None,'order':roles})
    # Exact order construction from the existing benchmarks/run.py pair loop.
    rng=random.Random(contract['seed']);orders={}
    for backend in ['JS','Native']:
        orders[backend]=[False,True]*(contract['pairs']//2);rng.shuffle(orders[backend])
    for pair in range(contract['pairs']):
        groups=[['TS']]
        for backend in ['JS','Native']:
            pair_roles=['baseline-'+backend,'candidate-'+backend]
            groups.append(list(reversed(pair_roles)) if orders[backend][pair] else pair_roles)
        rng.shuffle(groups);order=[role for group in groups for role in group]
        for role in order:
            rows.append({'label':f'pair-{pair}-{role}','role':role,'pair':pair,'order':order})
    return rows

def summarize(rows,commands):
    qualification=['qualification-'+role+'-'+label for role in ['baseline','candidate'] for label in ['TS','JS','Native-clang','Native']]
    if [c['label'] for c in commands[:8]]!=qualification or any(c.get('exit')!=0 or c.get('failure') is not None for c in commands[:8]):
        raise ValueError('both complete timed qualification prefixes required')
    commands=commands[8:]
    if len(rows)!=110 or [c['label'] for c in commands]!=[r['label'] for r in rows]:
        raise ValueError('complete ordered observations required')
    observed={};pairs=[]
    for row,command in zip(rows,commands):
        if row['pair'] is None:continue
        metric=json.loads(bytes.fromhex(command['stderr']['rawHex']))
        ns=metric['simulationNs']
        if type(ns)is not str or not ns.isdecimal() or int(ns)<=0:
            raise ValueError('positive typed simulation timer required')
        observed.setdefault(row['pair'],{})[row['role']]=metric
    ratios={backend:[] for backend in ['JS','Native']};reference=[]
    for pair in range(20):
        values=observed[pair]
        if set(values)!={'TS','baseline-JS','baseline-Native','candidate-JS','candidate-Native'}:
            raise ValueError('all five complete applications required')
        ns={role:int(m['simulationNs']) for role,m in values.items()}
        reference.append({'pair':pair,'simulationNs':ns,'transportNs':{role:int(m['transportNs']) for role,m in values.items()}})
        for backend in ['JS','Native']:
            before,after=ns['baseline-'+backend],ns['candidate-'+backend]
            pairs.append({'pair':pair,'backend':backend,'baselineMs':before/1e6,'candidateMs':after/1e6})
            ratios[backend].append(after/before)
    spec=importlib.util.spec_from_file_location('frozen_simulation_paired_decision',DECISION)
    decision=importlib.util.module_from_spec(spec);spec.loader.exec_module(decision)
    return {'scope':'Full14phase/twoschema fresh applications; baseline/candidate internal simulation clocks; not Workshop or same-process scaling',
            'pairs':pairs,'observedTS':reference,'medianPairedRatios':{k:statistics.median(v) for k,v in ratios.items()},
            'unchangedRegressionAssessment':decision.assess(pairs,20,0.05),
            'benefitInference':'Ratios are descriptive; this one-sided assessment detects slowdown, not a new statistical speedup criterion'}
