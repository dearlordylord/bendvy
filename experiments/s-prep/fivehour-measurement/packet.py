#!/usr/bin/env python3
"""Executable packet boundary, blocked unless exact reviewed contract accepted."""
import argparse, datetime, json, os, pathlib, signal, subprocess, sys
import boundary, guard, decision
H=pathlib.Path(__file__).resolve().parent

def child(args,limit,log):
    guard.deadline(limit);p=subprocess.Popen(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
    try:o,e=p.communicate(timeout=limit)
    except subprocess.TimeoutExpired:
        os.killpg(p.pid,signal.SIGKILL);o,e=p.communicate();log.append({'args':list(map(str,args)),'limit':limit,'status':'TIMEOUT','stdout':o,'stderr':e});raise ValueError('child deadline failure')
    log.append({'args':list(map(str,args)),'limit':limit,'exit':p.returncode,'stderr':e})
    if p.returncode:raise ValueError('child exit failure '+str(args[0]))
    return o

def main():
    a=argparse.ArgumentParser();a.add_argument('--manifest',type=pathlib.Path,required=True);a.add_argument('--sha256',required=True);a.add_argument('--baseline-manifest',type=pathlib.Path,required=True);a.add_argument('--baseline-sha256',required=True);a.add_argument('--output',type=pathlib.Path,required=True);a.add_argument('--acceptance',type=pathlib.Path);a.add_argument('--acceptance-sha256');a.add_argument('--preflight-only',action='store_true');a.add_argument('--cpu',type=int,default=11);args=a.parse_args()
    m=boundary.verify(args.manifest,args.sha256);baseline=boundary.verify(args.baseline_manifest,args.baseline_sha256)
    if args.manifest.resolve()==args.baseline_manifest.resolve():raise ValueError('baseline must have distinct frozen manifest path')
    if args.preflight_only:print('PACKET_PREFLIGHT_ONLY_NO_EXECUTION');return
    if not args.acceptance or not args.acceptance_sha256:raise ValueError('accepted contract binding required; no child executed')
    if guard.sha(args.acceptance)!=args.acceptance_sha256:raise ValueError('acceptance file digest changed')
    contract=json.loads(args.acceptance.read_text())
    required={'accepted':True,'manifestSHA256':args.sha256,'baselineManifestSHA256':args.baseline_sha256,'protocolVersion':'fresh16-one-bracket-v1','packetCap':8,'noiseLimit':0.10,'bootstrapSeed':23,'bootstrapResamples':10000,'orchestrationPolicy':'backend-natural-owner-retention','deadlineUTC':guard.DEADLINE.isoformat()}
    if any(contract.get(k)!=v for k,v in required.items()):raise ValueError('incomplete/different accepted contract; no child executed')
    # All capability check commands and digest-bound receipts must already pass.
    receipts=contract.get('capabilityReceipts',{})
    if not receipts:raise ValueError('actual final capability receipts absent')
    for name,digest in receipts.items():
        p=pathlib.Path(name)
        if guard.sha(p)!=digest:raise ValueError('capability receipt differs from reviewed contract')
    args.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{args.cpu});logs=[];r={'sourceAndTools':m['files'],'artifactPins':{},'status':'INCOMPLETE','manifestSHA256':args.sha256,'acceptanceSHA256':args.acceptance_sha256,'raw':{},'commands':logs,'productAcceptance':False}
    try:
        artifacts={}
        for role,source,manifest,digest in [('reference',baseline,args.baseline_manifest,args.baseline_sha256),('candidate',m,args.manifest,args.sha256)]:
          artifacts[role]={}
          for schema in source['schemas']:
              artifacts[role][schema]={'TS':pathlib.Path(source['drivers'][schema]['TS'])}
              for backend in ('Native','JS'):
                  boundary.verify(manifest,digest);entry=pathlib.Path(source['drivers'][schema][backend]);checker=child(['bend',entry,'--check-only'],5,logs)
                  if 'ALL PROOFS CHECK' not in checker:raise ValueError('checker marker missing')
                  dest=args.output/(role+'-'+schema+('-native' if backend=='Native' else '.js'))
                  generated=args.output/(role+'-'+schema+'.c') if backend=='Native' else dest
                  child(['bend',entry,'-o',generated],30,logs)
                  if backend=='Native':child(['clang','-O3',generated,'-pthread','-lm','-o',dest],120,logs)
                  artifacts[role][schema][backend]=dest;r['artifactPins'][str(dest)]=guard.sha(dest);r['artifactPins'][str(generated)]=guard.sha(generated)
        refs={role:{k:[] for k in decision.KEYS} for role in ('reference','candidate')};cands={role:{k:[] for k in decision.KEYS} for role in ('reference','candidate')}
        for cohort in range(2):
            for role in ('reference','candidate'):
                for sample in range(7):
                    for schema in m['schemas']:
                        outputs={};base=['Native','TS','JS'];order=base[sample%3:]+base[:sample%3]
                        for backend in order:
                            boundary.verify(args.manifest,args.sha256)
                            boundary.verify(args.baseline_manifest,args.baseline_sha256)
                            executable=artifacts[role][schema][backend];command=[executable,'--threads','1','--gpu','off'] if backend=='Native' else ['node',executable]
                            if backend!='TS' and guard.sha(executable)!=r['artifactPins'][str(executable)]:raise ValueError('compiled artifact changed')
                            text=child(command,5,logs);raw=args.output/f'{cohort}-{role}-{sample}-{schema}-{backend}.txt';raw.write_text(text);outputs[backend]=raw
                        for backend in ('Native','JS'):
                            receipt=args.output/f'{cohort}-{role}-{sample}-{schema}-{backend}-check.json'
                            child([sys.executable,H/'semantic-check.py','--bend-output',outputs[backend],'--ts-output',outputs['TS'],'--schema',schema,'--batch','16','--evidence',receipt],5,logs)
                            value=float(next(x.split(':',1)[1] for x in outputs[backend].read_text().splitlines() if x.startswith('BATCH-MILLISECONDS:')))
                            ts=json.loads(outputs['TS'].read_text());tsvalue=ts['batchMilliseconds']
                            key=backend+'/'+schema
                            cands[role][key].append(value);refs[role][key].append(tsvalue)
                            r['raw'][f'{cohort}/{role}/{sample}/{schema}/{backend}']={'batchMilliseconds':value,'TSBatchMilliseconds':tsvalue,'rawPath':str(outputs[backend]),'rawSHA256':guard.sha(outputs[backend]),'TSRawPath':str(outputs['TS']),'TSRawSHA256':guard.sha(outputs['TS']),'receiptSHA256':guard.sha(receipt)}
        boundary.verify(args.manifest,args.sha256);r['decision']=decision.score(cands['candidate'],refs['candidate']);r['baselineDecision']=decision.score(cands['reference'],refs['reference']);r['keepProposed']=decision.keep(r['decision'],r['baselineDecision']);r['status']='PACKET_COMPLETE'
    except Exception as e:r.update(status='FAILED_NO_METRIC',error=repr(e))
    finally:(args.output/'packet.json').write_text(json.dumps(r,indent=2)+'\n')
    print(r['status'])
    if r['status']!='PACKET_COMPLETE':raise SystemExit(1)

if __name__=='__main__':main()
