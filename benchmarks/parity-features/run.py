#!/usr/bin/env python3
"""Complete quiet-window paired feature observations, separate from #28."""
import argparse, json, os, pathlib, random, statistics
from execute import Harness
from validate import validate
import importlib.util
spec=importlib.util.spec_from_file_location('timer_preflight',pathlib.Path(__file__).with_name('timer-preflight.py'))
timer=importlib.util.module_from_spec(spec);spec.loader.exec_module(timer)

def telemetry(cpu):
    result={'loadavg':pathlib.Path('/proc/loadavg').read_text().strip(),'cpuStat':next(line for line in pathlib.Path('/proc/stat').read_text().splitlines() if line.startswith('cpu'+str(cpu)+' '))}
    for name,path in [('pressure','/proc/pressure/cpu'),('frequency',f'/sys/devices/system/cpu/cpu{cpu}/cpufreq/scaling_cur_freq')]:
        p=pathlib.Path(path)
        if p.exists():result[name]=p.read_text().strip()
    return result

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--features',nargs='+',choices=['nested','readers','fragments'],default=['nested','readers','fragments']);parser.add_argument('--stage',type=pathlib.Path,required=True);parser.add_argument('--output',type=pathlib.Path,required=True)
    parser.add_argument('--semantic-receipt',type=pathlib.Path,required=True)
    parser.add_argument('--quiet-window',required=True,help='Integrator-established quiet-window evidence/context; not an automatic noise threshold')
    parser.add_argument('--cpu',type=int,required=True)
    args=parser.parse_args();assert args.cpu in os.sched_getaffinity(0)
    semantic=json.loads(args.semantic_receipt.read_text());assert semantic['status']=='PASS'
    harness=Harness(args.stage,args.output)
    assert set(args.features)<=set(semantic.get('features',['nested','readers','fragments'])),'Feature missing from semantic receipt'
    assert semantic['stageReceiptSHA']==harness.receipt['stageReceiptSHA'],'Semantic receipt is from another staged source'
    contract=json.loads((pathlib.Path(__file__).parents[1]/'contract.json').read_text())
    harness.receipt.update(scope='Source-bound complete lifecycle feature timing/scaling; no #28 baseline change, statistical verdict or full-core qualification',quietWindowContext=args.quiet_window,cpu=args.cpu,semanticReceiptSHA=__import__('hashlib').sha256(args.semantic_receipt.read_bytes()).hexdigest(),pairs=contract['pairs'],warmups=contract['warmups'],observations=[])
    generator=random.Random(contract['seed']);summary=[]
    def sample(feature,batches,backend,command,label):
        result=harness.run(label,[harness.tools['taskset'],'-c',str(args.cpu),*command],5)
        validate(feature,backend,result.stdout.decode('utf8'),batches,harness.staged.get('nestedSpawn',False))
        region=json.loads(result.stderr)
        assert region['bytes']==len(result.stdout) and region['digest']==timer.fnv(result.stdout) and int(region['elapsedNs'])>=0
        return region
    try:
        for feature in args.features:
            for batches in [1,2,4]:
                name=feature+'-'+str(batches);commands=harness.build(name)
                for backend,command in commands.items():
                    for warmup in range(contract['warmups']):sample(feature,batches,backend,command,f'{name}-{backend}-warmup{warmup}')
                for backend in ['JS','Native']:
                    orders=[['TS',backend]]*(contract['pairs']//2)+[[backend,'TS']]*(contract['pairs']//2)
                    assert len(orders)==contract['pairs'];generator.shuffle(orders)
                    ratios=[]
                    for index,order in enumerate(orders):
                        before=telemetry(args.cpu);values={}
                        for role in order:values[role]=sample(feature,batches,role,commands[role],f'{name}-{backend}-pair{index}-{role}')
                        assert int(values['TS']['elapsedNs'])>0
                        ratio=int(values[backend]['elapsedNs'])/int(values['TS']['elapsedNs']);ratios.append(ratio)
                        harness.receipt['observations'].append({'feature':feature,'lifecycles':batches,'backend':backend,'pair':index,'order':order,'before':before,'after':telemetry(args.cpu),'regions':values,'ratio':ratio})
                        harness.save()
                    summary.append({'feature':feature,'lifecycles':batches,'backend':backend,'medianPairedRatio':statistics.median(ratios),'minimum':min(ratios),'maximum':max(ratios),'allPairedRatios':ratios})
        harness.guard();assert __import__('hashlib').sha256(args.semantic_receipt.read_bytes()).hexdigest()==harness.receipt['semanticReceiptSHA']
        harness.receipt.update(status='COMPLETE_FEATURE_OBSERVATIONS',summary=summary,qualification='Integrator must assess retained quiet-window evidence and existing targets per workload. No new sign test, tolerated slowdown, historical baseline or full-matrix claim.')
    finally:harness.save()
    print(json.dumps({'status':harness.receipt['status'],'output':str(args.output)}))

if __name__=='__main__':main()
