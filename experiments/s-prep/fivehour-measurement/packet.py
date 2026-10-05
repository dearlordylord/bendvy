#!/usr/bin/env python3
"""Executable packet boundary, blocked unless exact reviewed contract accepted."""
import argparse, datetime, json, os, pathlib, signal, subprocess, sys, tempfile
import boundary, guard, decision, snapshot
H=pathlib.Path(__file__).resolve().parent
ENV={'HOME':'/home/node','PATH':'/home/node/.bend/bin:/usr/local/bin:/usr/bin:/bin','LANG':'C.UTF-8','LC_ALL':'C.UTF-8'}

def child(args,limit,log):
    guard.deadline(limit);guard.enable_subreaper();prior=guard.child_pids(os.getpid());p=subprocess.Popen(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True,env=ENV)
    try:o,e=p.communicate(timeout=limit)
    except subprocess.TimeoutExpired:
        cleanup_error=None
        try:guard.cleanup_owned(p.pid,prior)
        except Exception as failure:cleanup_error=repr(failure)
        try:o,e=p.communicate(timeout=1)
        except subprocess.TimeoutExpired:o,e='', 'finite cleanup did not close child pipes'
        log.append({'args':list(map(str,args)),'limit':limit,'status':'TIMEOUT','stdout':o,'stderr':e,'cleanupError':cleanup_error});raise ValueError('child deadline failure')
    survivors=guard.child_pids(os.getpid())-prior
    if survivors:
        guard.cleanup_owned(p.pid,prior);raise ValueError('child left owned descendants; no passing result')
    log.append({'args':list(map(str,args)),'limit':limit,'exit':p.returncode,'stderr':e})
    if p.returncode:raise ValueError('child exit failure '+str(args[0]))
    return o

def canonical_parent(m):
    """The evaluator must descend from the exact canonical next process."""
    pid=os.getppid()
    for _ in range(32):
        try:
            proc=pathlib.Path('/proc')/str(pid);argv=proc.joinpath('cmdline').read_bytes().split(b'\0');exe=proc.joinpath('exe').resolve()
            if exe==pathlib.Path(m['tools']['node']) and len(argv)>2 and pathlib.Path(argv[1].decode()).resolve()==pathlib.Path(m['canonicalCLI']).resolve() and argv[2]==b'next':return {'pid':pid,'startTime':proc.joinpath('stat').read_text().rsplit(')',1)[1].split()[19]}
            fields=proc.joinpath('stat').read_text().rsplit(')',1)[1].split();pid=int(fields[1])
            if pid<=1:break
        except (OSError,ValueError,UnicodeDecodeError):break
    raise ValueError('direct evaluator invocation forbidden; canonical next ancestor absent')

def main():
    a=argparse.ArgumentParser();a.add_argument('--manifest',type=pathlib.Path,required=True);a.add_argument('--sha256',required=True);a.add_argument('--baseline-manifest',type=pathlib.Path,required=True);a.add_argument('--baseline-sha256',required=True);outputs=a.add_mutually_exclusive_group(required=True);outputs.add_argument('--output',type=pathlib.Path);outputs.add_argument('--output-root',type=pathlib.Path);a.add_argument('--acceptance',type=pathlib.Path);a.add_argument('--acceptance-sha256');a.add_argument('--preflight-only',action='store_true');a.add_argument('--cpu',type=int,default=11);args=a.parse_args()
    if args.cpu!=11:raise ValueError('fixed CPU11 required')
    original=json.loads(args.manifest.read_text()) if guard.sha(args.manifest)==args.sha256 else {}
    allow=snapshot.editable(original) if original else set()
    m=boundary.verify(args.manifest,args.sha256,allow=allow);baseline=boundary.verify(args.baseline_manifest,args.baseline_sha256)
    if args.manifest.resolve()==args.baseline_manifest.resolve():raise ValueError('baseline must have distinct frozen manifest path')
    if args.preflight_only:print('PACKET_PREFLIGHT_ONLY_NO_EXECUTION');return
    if not args.acceptance or not args.acceptance_sha256:raise ValueError('accepted contract binding required; no child executed')
    if guard.sha(args.acceptance)!=args.acceptance_sha256:raise ValueError('acceptance file digest changed')
    canonical_identity=canonical_parent(m)
    if not args.output_root:raise ValueError('execution requires fixed --output-root, not one-shot output leaf')
    contract=json.loads(args.acceptance.read_text())
    required={'artifactRoot':str(args.output_root.resolve()),'accepted':True,'manifestSHA256':args.sha256,'baselineManifestSHA256':args.baseline_sha256,'protocolVersion':'fresh16-one-bracket-v1','packetCap':8,'noiseLimit':0.10,'bootstrapSeed':23,'bootstrapResamples':10000,'orchestrationPolicy':'backend-natural-owner-retention','deadlineUTC':guard.DEADLINE.isoformat()}
    if any(contract.get(k)!=v for k,v in required.items()):raise ValueError('incomplete/different accepted contract; no child executed')
    # Historical receipts cannot authorize the current candidate snapshot.
    live=contract.get('liveChecks')
    if not isinstance(live,dict) or set(live)!={'script','sha256','receipt','requiredGateIDs','wholeCommandLimit','initialReuseReceipt','cleanupReserveSeconds'}:raise ValueError('live authoritative check contract absent')
    if live['wholeCommandLimit']!=3600 or live['cleanupReserveSeconds']!=5:raise ValueError('proposed full-check wrapper cap differs')
    checkscript=pathlib.Path(live['script'])
    if m['files'].get(str(checkscript))!=live['sha256'] or guard.sha(checkscript)!=live['sha256']:raise ValueError('live check implementation is not protected')
    allowed=pathlib.Path('/tmp/bendvy-fivehour-packets');allowed.mkdir(exist_ok=True)
    root=args.output_root
    if root.absolute()!=root.resolve() or not root.resolve().is_relative_to(allowed) or root.resolve()==allowed:raise ValueError('artifact root must be a nonsymlink directory below /tmp/bendvy-fivehour-packets')
    root.mkdir(parents=True,exist_ok=True);args.output=pathlib.Path(tempfile.mkdtemp(prefix='packet-',dir=root));os.sched_setaffinity(0,{args.cpu});logs=[];r={'environment':ENV,'cpu':11,'nativePolicy':{'threads':1,'gpu':'off','clang':'-O3'},'sourceAndTools':m['files'],'artifactPins':{},'status':'INCOMPLETE','manifestSHA256':args.sha256,'acceptanceSHA256':args.acceptance_sha256,'canonicalNext':canonical_identity,'baselineManifest':str(args.baseline_manifest.resolve()),'baselineManifestSHA256':args.baseline_sha256,'raw':{},'commands':logs,'productAcceptance':False}
    try:
        captured,captured_digest=snapshot.capture(args.manifest,args.sha256,args.output/'candidate-snapshot');m=boundary.verify(captured,captured_digest);r['candidateSnapshotManifest']=str(captured);r['candidateSnapshotManifestSHA256']=captured_digest;r['candidateSnapshotFiles']=m['files']
        checkoutput=args.output/'fresh-checks'
        checkcommand=[m['tools']['python'],checkscript,'--js-overlay',args.output/'candidate-snapshot/JS','--native-overlay',args.output/'candidate-snapshot/Native','--output',checkoutput,'--cpu','9']
        reuse=live['initialReuseReceipt'];reuse_selected=False
        if reuse is not None:
            if not isinstance(reuse,dict) or set(reuse)!={'path','sha256'}:raise ValueError('initial receipt must have exact accepted path/digest')
            priorpath=pathlib.Path(reuse['path'])
            if guard.sha(priorpath)!=reuse['sha256']:raise ValueError('accepted initial receipt drift')
            prior=json.loads(priorpath.read_text())
            if prior.get('status')!='FRESH_TWO_ROLE_CONNECTED_GATES_PASS':raise ValueError('initial receipt incomplete')
            reuse_selected=all(prior['roles'][backend]['binding']['runtimeSources']==json.loads((args.output/'candidate-snapshot'/backend/'cache-specialization.json').read_text())['runtimeClosure'] for backend in ('JS','Native'))
            if reuse_selected:checkcommand += ['--reuse-receipt',priorpath,'--reuse-receipt-sha256',reuse['sha256']]
        remaining=(guard.DEADLINE-datetime.datetime.now(datetime.timezone.utc)).total_seconds()
        check_limit=min(live['wholeCommandLimit'],remaining-live['cleanupReserveSeconds'])
        if check_limit<=0:raise ValueError('no remaining gate execution/cleanup allowance')
        r['effectiveCheckLimitSeconds']=check_limit;r['checkCleanupReserveSeconds']=5
        child(checkcommand,check_limit,logs)
        checkreceipt=checkoutput/live['receipt'];checks=json.loads(checkreceipt.read_text())
        required_ids={'materialize-controls','host12','access','e11','owned-storage','staging','tx-baseline','tx-stale-head','tx-torn-tail','tx-lost-mark','tx-inverse-order'}
        if set(live['requiredGateIDs'])!=required_ids or checks.get('status')!=('EXACT_UNCHANGED_TWO_ROLE_GATES_REUSED' if reuse_selected else 'FRESH_TWO_ROLE_CONNECTED_GATES_PASS') or checks.get('schemaVersion')!=1 or set(checks.get('roles',{}))!={'JS','Native'}:raise ValueError('current snapshot authoritative gates incomplete')
        for backend,role in checks['roles'].items():
            overlay=args.output/'candidate-snapshot'/backend
            expected=json.loads((overlay/'cache-specialization.json').read_text())['runtimeClosureSHA256']
            if role.get('status')!=('REUSED' if reuse_selected else 'PASS') or role['binding']['runtimeClosureSHA256']!=expected or role['binding']['runtimeSources']!=json.loads((overlay/'cache-specialization.json').read_text())['runtimeClosure'] or role['binding']['overlayManifestSHA256']!=guard.sha(overlay/'overlay.json') or set(g['name'] for g in role['gates'])!=required_ids:raise ValueError('check applicability does not match snapshot')
            for gate in role['gates']:
                if gate['exit']!=0:raise ValueError('failed authoritative gate')
                if 'receipt' in gate and guard.sha(pathlib.Path(gate['receipt']))!=gate['receiptSHA256']:raise ValueError('gate receipt changed')
        if reuse_selected and (checks.get('reused') is not True or checks.get('sourceReceiptSHA256')!=reuse['sha256']):raise ValueError('reuse authority mismatch')
        r['initialReuseReceipt']=reuse if reuse_selected else None;r['completeCheckReceipt']=str(checkreceipt);r['freshCheckReceiptSHA256']=guard.sha(checkreceipt)
        artifacts={}
        for role,source,manifest,digest in [('reference',baseline,args.baseline_manifest,args.baseline_sha256),('candidate',m,captured,captured_digest)]:
          artifacts[role]={}
          for schema in source['schemas']:
              artifacts[role][schema]={'TS':pathlib.Path(source['drivers'][schema]['TS'])}
              for backend in ('Native','JS'):
                  boundary.verify(manifest,digest);entry=pathlib.Path(source['drivers'][schema][backend]);checker=child([source['tools']['bend'],entry,'--check-only'],5,logs)
                  if 'ALL PROOFS CHECK' not in checker:raise ValueError('checker marker missing')
                  dest=args.output/(role+'-'+schema+('-native' if backend=='Native' else '.js'))
                  generated=args.output/(role+'-'+schema+'.c') if backend=='Native' else dest
                  child([source['tools']['bend'],entry,'-o',generated],30,logs)
                  if backend=='Native':child([source['tools']['clang'],'-O3',generated,'-pthread','-lm','-o',dest],120,logs)
                  artifacts[role][schema][backend]=dest;r['artifactPins'][str(dest)]=guard.sha(dest);r['artifactPins'][str(generated)]=guard.sha(generated)
        refs={role:{k:[] for k in decision.KEYS} for role in ('reference','candidate')};cands={role:{k:[] for k in decision.KEYS} for role in ('reference','candidate')}
        for cohort in range(2):
            for role in ('reference','candidate'):
                for sample in range(7):
                    for schema in m['schemas']:
                        outputs={};base=['Native','TS','JS'];order=base[sample%3:]+base[:sample%3]
                        for backend in order:
                            boundary.verify(captured,captured_digest)
                            boundary.verify(args.baseline_manifest,args.baseline_sha256)
                            source=baseline if role=='reference' else m
                            executable=artifacts[role][schema][backend];command=[executable,'--threads','1','--gpu','off'] if backend=='Native' else [source['tools']['node'],executable]
                            if backend!='TS' and guard.sha(executable)!=r['artifactPins'][str(executable)]:raise ValueError('compiled artifact changed')
                            text=child(command,5,logs);raw=args.output/f'{cohort}-{role}-{sample}-{schema}-{backend}.txt';raw.write_text(text);outputs[backend]=raw
                        for backend in ('Native','JS'):
                            receipt=args.output/f'{cohort}-{role}-{sample}-{schema}-{backend}-check.json'
                            child([m['tools']['python'],H/'semantic-check.py','--bend-output',outputs[backend],'--ts-output',outputs['TS'],'--schema',schema,'--batch','16','--evidence',receipt],5,logs)
                            value=float(next(x.split(':',1)[1] for x in outputs[backend].read_text().splitlines() if x.startswith('BATCH-MILLISECONDS:')))
                            ts=json.loads(outputs['TS'].read_text());tsvalue=ts['batchMilliseconds']
                            key=backend+'/'+schema
                            cands[role][key].append(value);refs[role][key].append(tsvalue)
                            r['raw'][f'{cohort}/{role}/{sample}/{schema}/{backend}']={'batchMilliseconds':value,'TSBatchMilliseconds':tsvalue,'rawPath':str(outputs[backend]),'rawSHA256':guard.sha(outputs[backend]),'TSRawPath':str(outputs['TS']),'TSRawSHA256':guard.sha(outputs['TS']),'receiptPath':str(receipt),'receiptSHA256':guard.sha(receipt)}
        boundary.verify(captured,captured_digest);boundary.verify(args.baseline_manifest,args.baseline_sha256)
        if guard.sha(checkreceipt)!=r['freshCheckReceiptSHA256']:raise ValueError('check receipt changed after execution')
        r['decision']=decision.score(cands['candidate'],refs['candidate']);r['baselineDecision']=decision.score(cands['reference'],refs['reference']);r['baselinePolicy']='fixed-initial-freshly-rerun';r['canonicalPriorBestScoreComparisonRequired']=True;r['canonicalKeepAuthorized']=False;r['keepProposed']=decision.keep(r['decision'],r['baselineDecision']);r['status']='PACKET_COMPLETE' if r['decision']['status']=='QUALIFIED_PROPOSAL' and r['baselineDecision']['status']=='QUALIFIED_PROPOSAL' else 'INCONCLUSIVE_NO_METRIC'
    except Exception as e:r.update(status='FAILED_NO_METRIC',error=repr(e))
    finally:(args.output/'packet.json').write_text(json.dumps(r,indent=2)+'\n')
    pointer=root/'latest-packet.json';temporary=root/'.latest-packet.tmp';temporary.write_text(json.dumps({'packet':str(args.output/'packet.json'),'sha256':guard.sha(args.output/'packet.json'),'canonicalNext':canonical_identity})+'\n');os.replace(temporary,pointer)
    if r['status']=='PACKET_COMPLETE':
        print('REPORT '+json.dumps({'candidate':r['decision'],'fixedInitialBaseline':r['baselineDecision'],'canonicalPriorBestScoreComparisonRequired':True,'canonicalKeepAuthorized':False,'keepProposed':r['keepProposed'],'focusedGoalMet':r['decision']['focusedGoalMet'],'productAcceptance':False},sort_keys=True))
        print('METRIC focused_score='+format(r['decision']['metric'],'.17g'))
    print(json.dumps({'status':r['status'],'metric':r.get('decision',{}).get('metric') if r['status']=='PACKET_COMPLETE' else None,'keepProposed':r.get('keepProposed',False) if r['status']=='PACKET_COMPLETE' else False,'receipt':str(args.output/'packet.json'),'packetReceiptSHA256':guard.sha(args.output/'packet.json'),'completeCheckReceipt':str(checkreceipt) if 'checkreceipt' in locals() else None,'completeCheckReceiptSHA256':r.get('freshCheckReceiptSHA256')},sort_keys=True))
    if r['status']!='PACKET_COMPLETE':raise SystemExit(1)

if __name__=='__main__':main()
