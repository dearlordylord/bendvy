#!/usr/bin/env python3
"""Independent canonical Checks: receipt verification and full raw oracle replay.

This does not claim a second fresh compilation of the connected gate suite.
"""
import argparse,json,pathlib
import boundary,decision,guard,packet,snapshot

def main():
    p=argparse.ArgumentParser()
    for name in ('manifest','baseline-manifest','output-root'):
        p.add_argument('--'+name,type=pathlib.Path,required=True)
    p.add_argument('--sha256',required=True);p.add_argument('--baseline-sha256',required=True)
    a=p.parse_args();original=json.loads(a.manifest.read_text()) if guard.sha(a.manifest)==a.sha256 else {}
    m=boundary.verify(a.manifest,a.sha256,allow=snapshot.editable(original))
    identity=packet.canonical_parent(m)
    root=a.output_root
    if root.absolute()!=root.resolve() or not root.resolve().is_relative_to(pathlib.Path('/tmp/bendvy-fivehour-packets')):
        raise ValueError('confined nonsymlink artifact root required')
    pointer=json.loads((root/'latest-packet.json').read_text())
    if pointer['canonicalNext']!=identity:raise ValueError('receipt belongs to another canonical next process')
    path=pathlib.Path(pointer['packet'])
    if path.absolute()!=path.resolve() or not path.resolve().is_relative_to(root.resolve()):raise ValueError('packet escaped artifact root')
    if guard.sha(path)!=pointer['sha256']:raise ValueError('packet receipt changed')
    r=json.loads(path.read_text());leaf=path.parent
    if r['status']!='PACKET_COMPLETE' or r['manifestSHA256']!=a.sha256 or r['baselineManifestSHA256']!=a.baseline_sha256 or r['canonicalNext']!=identity:
        raise ValueError('packet identity/status mismatch')
    captured=pathlib.Path(r['candidateSnapshotManifest']);digest=r['candidateSnapshotManifestSHA256']
    captured_m=boundary.verify(captured,digest)
    boundary.verify(a.baseline_manifest,a.baseline_sha256)
    for name,pin in captured_m['capturedCandidateBytes'].items():
        if guard.sha(pathlib.Path(name))!=pin:raise ValueError('current candidate differs from measured snapshot')
    checks=pathlib.Path(r['completeCheckReceipt'])
    if guard.sha(checks)!=r['freshCheckReceiptSHA256']:raise ValueError('connected gate receipt changed')
    c=json.loads(checks.read_text())
    if c['status']!=('EXACT_UNCHANGED_TWO_ROLE_GATES_REUSED' if r['initialReuseReceipt'] else 'FRESH_TWO_ROLE_CONNECTED_GATES_PASS'):raise ValueError('complete connected gate receipt required')
    if r['initialReuseReceipt']:
        reuse=r['initialReuseReceipt']
        if guard.sha(pathlib.Path(reuse['path']))!=reuse['sha256'] or c.get('sourceReceiptSHA256')!=reuse['sha256'] or c.get('reused') is not True:raise ValueError('initial reuse receipt changed')
    expected={'materialize-controls','host12','access','e11','owned-storage','staging','tx-baseline','tx-stale-head','tx-torn-tail','tx-lost-mark','tx-inverse-order'}
    if set(c['roles'])!={'JS','Native'} or c.get('schemaVersion')!=1:raise ValueError('gate schema/role mismatch')
    statuses={'materialize-controls':'PASS_DERIVED_CONTROL_SOURCE_MAP','host12':'PASS','access':'ACTUAL_ACCESS_9_PASS','e11':'BOUNDED_JOINED_PASS','owned-storage':'ACTUAL_FINAL_STORAGE_FIELDS_OWNERSHIP_MUTANTS_PASS','staging':'PASS_BOUNDED_STAGING_TYPE_BOUNDARY','tx-baseline':'FINITE_ACTUAL_TX_CACHE_FIELDS_PASS',**{'tx-'+v:'DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE' for v in ('stale-head','torn-tail','lost-mark','inverse-order')}}
    for backend,role in c['roles'].items():
        overlay=captured.parent/backend
        runtime=json.loads((overlay/'cache-specialization.json').read_text())
        if role['status']!=('REUSED' if r['initialReuseReceipt'] else 'PASS') or role['binding']['runtimeSources']!=runtime['runtimeClosure'] or role['binding']['runtimeClosureSHA256']!=runtime['runtimeClosureSHA256'] or len(role['gates'])!=11 or set(g['name'] for g in role['gates'])!=expected:
            raise ValueError('gate runtime applicability mismatch')
        for g in role['gates']:
            if g['exit']!=0 or g['status']!=statuses[g['name']]:raise ValueError('failed connected gate')
            if 'receipt' in g and guard.sha(pathlib.Path(g['receipt']))!=g['receiptSHA256']:raise ValueError('child gate receipt changed')
    for name,pin in r['artifactPins'].items():
        if guard.sha(pathlib.Path(name))!=pin:raise ValueError('compiled artifact changed')
    values={role:{key:[] for key in decision.KEYS} for role in ('candidate','reference')}
    tsvalues={role:{key:[] for key in decision.KEYS} for role in ('candidate','reference')}
    expected_keys={f'{cohort}/{role}/{sample}/{schema}/{backend}' for cohort in range(2) for role in values for sample in range(7) for schema in ('Motion','Health') for backend in ('Native','JS')}
    if set(r['raw'])!=expected_keys:raise ValueError('missing/extra measured raw records')
    log=[];verify_dir=leaf/'independent-checks';verify_dir.mkdir(exist_ok=False)
    for cohort in range(2):
      for role in values:
       for sample in range(7):
        for schema in ('Motion','Health'):
         for backend in ('Native','JS'):
            key=f'{cohort}/{role}/{sample}/{schema}/{backend}';raw=r['raw'][key]
            for field,pin in [('rawPath','rawSHA256'),('TSRawPath','TSRawSHA256'),('receiptPath','receiptSHA256')]:
                source=pathlib.Path(raw[field])
                if source.absolute()!=source.resolve() or not source.resolve().is_relative_to(leaf) or guard.sha(source)!=raw[pin]:raise ValueError('raw input/oracle receipt escaped or changed')
            packet.child([m['tools']['python'],packet.H/'semantic-check.py','--bend-output',raw['rawPath'],'--ts-output',raw['TSRawPath'],'--schema',schema,'--batch','16','--evidence',verify_dir/(key.replace('/','-')+'.json')],5,log)
            lines=pathlib.Path(raw['rawPath']).read_text().splitlines()
            clocks=[x.split(':',1)[1] for x in lines if x.startswith('BATCH-MILLISECONDS:')]
            if len(clocks)!=1:raise ValueError('clock marker count')
            value=float(clocks[0]);ts=json.loads(pathlib.Path(raw['TSRawPath']).read_text())['batchMilliseconds']
            if value!=raw['batchMilliseconds'] or ts!=raw['TSBatchMilliseconds']:raise ValueError('raw clock disagrees with score input')
            values[role][backend+'/'+schema].append(value);tsvalues[role][backend+'/'+schema].append(ts)
    candidate=decision.score(values['candidate'],tsvalues['candidate']);baseline=decision.score(values['reference'],tsvalues['reference'])
    if candidate!=r['decision'] or baseline!=r['baselineDecision'] or candidate['status']!='QUALIFIED_PROPOSAL' or baseline['status']!='QUALIFIED_PROPOSAL' or decision.keep(candidate,baseline)!=r['keepProposed']:
        raise ValueError('recomputed qualified decision mismatch')
    boundary.verify(captured,digest);boundary.verify(a.baseline_manifest,a.baseline_sha256)
    if guard.sha(path)!=pointer['sha256'] or guard.sha(checks)!=r['freshCheckReceiptSHA256']:raise ValueError('receipt drift during independent check')
    print('INDEPENDENT_PACKET_RAW_ORACLES_AND_RECEIPTS_PASS')

if __name__=='__main__':main()
