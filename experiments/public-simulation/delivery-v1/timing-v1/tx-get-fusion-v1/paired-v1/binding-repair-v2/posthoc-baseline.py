"""Revalidate retained outputs with corrected oracle pins; no child execution."""
import hashlib,importlib.util,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
P=HERE/'candidate-plan.json.proposal01'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
p=json.loads(P.read_bytes())
source=HERE.parent/'qualification-only-v1/actual01'
r=json.loads((source/'receipt.json').read_bytes())
if r['status']!='INCOMPLETE' or r['error']!='ValueError: expected output must match its admitted pin':raise ValueError('exact retained failure required')
expected=['qualification-baseline-TS','qualification-baseline-JS','qualification-baseline-Native-clang','qualification-baseline-Native']
if [c['label'] for c in r['commands']]!=expected or any(c['exit']!=0 or c['failure'] is not None for c in r['commands']):raise ValueError('all four completed original commands required')
collector=Path('/workspace/formal-proofs/bendvy/experiments/public-simulation/delivery-v1/run-delivery.py')
spec=importlib.util.spec_from_file_location('retained_collector_functions',collector);c=importlib.util.module_from_spec(spec);spec.loader.exec_module(c)
c.load('prepare',p['helpers']['prepare'],p['pins'])
compare=c.load('simulation_delivery_compare',p['comparator'],p['pins'])
parser=c.load('simulation_delivery_parser',p['parser'],p['pins']);compare.parser_functions=lambda:(parser.parse,parser.render)
validator=c.load('posthoc_existing_timer_validator',p['qualificationValidator'],p['pins'])
results={}
for role,label in [('TS',expected[0]),('JS',expected[1]),('Native',expected[3])]:
    stdout=(source/(label+'.stdout')).read_bytes();stderr=(source/(label+'.stderr')).read_bytes()
    row=next(c for c in r['commands'] if c['label']==label)
    if hashlib.sha256(stdout).hexdigest()!=row['stdout']['sha256'] or hashlib.sha256(stderr).hexdigest()!=row['stderr']['sha256']:raise ValueError('raw retention mismatch')
    validator.validate(role,stdout,stderr,plan=p)
    results[role]={'fullOutputAndClockMatch':True,'stdoutSHA256':hashlib.sha256(stdout).hexdigest(),'stderrSHA256':hashlib.sha256(stderr).hexdigest()}
if sha(source/'baseline.native')!=r['generated']['baseline.native']:raise ValueError('retained timed binary mismatch')
result={'status':'RETAINED_BASELINE_FULL_TIMER_REVALIDATION_PASS_NOT_FRESH_RUN','originalReceiptStatus':'INCOMPLETE','originalReceiptSHA256':sha(source/'receipt.json'),'originalPlanSHA256':r['planSHA256'],'repairedPlanSHA256':sha(P),'cases':results,'baselineNativeSHA256':sha(source/'baseline.native'),'scope':'Posthoc existing validator against same retained full oracles/strict clocks; original error/receipt unchanged, no children or comparison','comparativeAndProfiles':'HOLD'}
(HERE/'BASELINE-REVALIDATION.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
