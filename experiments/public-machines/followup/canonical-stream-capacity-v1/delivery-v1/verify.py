#!/usr/bin/env python3
"""Offline verifier for the bounded canonical FIFO stream capacity delivery."""
from __future__ import annotations
import gzip, hashlib, importlib.util, json, shutil, sys, tempfile, zipfile
from pathlib import Path, PurePosixPath

HERE=Path(__file__).resolve().parent
DELIVERY_REL=PurePosixPath('experiments/public-machines/followup/canonical-stream-capacity-v1/delivery-v1')
class VerificationError(Exception): pass
def require(ok,message):
    if not ok: raise VerificationError(message)
def digest(data:bytes)->str: return hashlib.sha256(data).hexdigest()
def parse(data:bytes,label):
    try: return json.loads(data)
    except Exception as exc: raise VerificationError(f'invalid JSON {label}: {exc}') from exc
def canonical_external(path):
    p=PurePosixPath(path); require(p.is_absolute() and p.as_posix()==path and all(x not in ('','.','..') for x in p.parts),f'noncanonical full sourcePath: {path}')
def repo_root(here):
    root=here.resolve()
    for _ in DELIVERY_REL.parts: root=root.parent
    require((root/Path(*DELIVERY_REL.parts)).resolve()==here.resolve(),'delivery moved outside expected repository-relative location')
    return root
def local_owned(root,rel):
    p=PurePosixPath(rel); require(not p.is_absolute() and p.as_posix()==rel and p.parts and all(x not in ('','.','..') for x in p.parts),f'invalid owned local path: {rel}')
    base=root.resolve(); out=(base/Path(*p.parts)).resolve()
    try: out.relative_to(base)
    except ValueError as exc: raise VerificationError(f'local path escapes repository: {rel}') from exc
    require(out.is_file(),f'owned file missing: {rel}'); return out
def verify_local_selection(here):
    here=here.resolve(); root=repo_root(here)
    delivery=parse((here/'DELIVERY.json').read_bytes(),'DELIVERY.json'); owner=parse((here/'OWNERSHIP.json').read_bytes(),'OWNERSHIP.json')
    producer=PurePosixPath(owner.get('producerWorktree',''))
    require(producer.is_absolute() and producer.as_posix()==owner.get('producerWorktree') and all(x not in ('','.','..') for x in producer.parts),'producer worktree path is not canonical')
    require(delivery.get('producerWorktree')==producer.as_posix(),'delivery producer root differs from ownership')
    require(owner.get('pathBase')==delivery.get('pathBase')=='repository-root-relative','ownership path base differs')
    local=owner.get('ownedPaths'); full=owner.get('producerOwnedPaths')
    require(isinstance(local,list) and isinstance(full,list) and local==sorted(local) and full==sorted(full) and len(local)==len(full)==owner.get('count'),'owned path selection/count differs')
    mapping={}
    for path in full:
        canonical_external(path); p=PurePosixPath(path)
        try: suffix=p.relative_to(producer)
        except ValueError as exc: raise VerificationError(f'owned path outside producer root: {path}') from exc
        rel=suffix.as_posix(); require(rel not in ('','.'),'empty producer path suffix')
        require(rel not in mapping,f'duplicate producer path suffix {rel}'); mapping[rel]=path
    require(sorted(mapping)==local,'producer and local path mappings differ')
    require(delivery.get('ownedPaths')==local and delivery.get('producerOwnedPaths')==full,'delivery/ownership list differs')
    self_path=(DELIVERY_REL/'DELIVERY.json').as_posix(); require(self_path in local,'DELIVERY.json absent from ownership')
    files=delivery.get('files',{}); require(set(files)==set(local)-{self_path},'delivery file list differs from ownership')
    for rel,meta in files.items():
        require(meta.get('sourcePath')==mapping[rel],f'full path join differs for {rel}')
        raw=local_owned(root,rel).read_bytes(); require((len(raw),digest(raw))==(meta.get('bytes'),meta.get('sha256')),f'owned file drift: {rel}')
    return delivery,owner,root

def load_helper(rows,result,archive):
    dep=result['verificationDependency']; row=rows.get(dep['sourcePath'])
    require(row is not None and row['sha256']==dep['sha256'],'retained fullcapacity verifier missing/hash mismatch')
    raw=archive.read(row['member']); require(digest(raw)==dep['sha256'],'retained verifier bytes changed')
    with tempfile.TemporaryDirectory(prefix='bendvy48-capacity-verifier-') as td:
        p=Path(td)/'verify_helper.py'; p.write_bytes(raw); spec=importlib.util.spec_from_file_location('retained_capacity_verify',p)
        helper=importlib.util.module_from_spec(spec); spec.loader.exec_module(helper); helper.VerificationError=VerificationError
        return helper

def verify_source_checks(rows,archive,result):
    binding=result['adoptionSourceCheck']; row=rows.get(binding['checksPath'])
    require(row is not None and row['sha256']==binding['checksSHA256'],'adoption source-check record missing/hash mismatch')
    checks=parse(archive.read(row['member']),'adoption checks')
    require(checks['baseCommit']==binding['baseCommit'] and checks['dependencySourceCommit']==binding['dependencySourceCommit'],'adoption source commit binding differs')
    require(checks['wrapper']['sha256']==binding['wrapperSHA256'] and checks['compiler']['sha256']==binding['compilerSHA256'],'adoption tool pin differs')
    names={}
    for item in checks['checks']:
        entry=item['entry']; require(row_for(rows,entry['path'],entry['sha256']) is not None,'adoption entry source absent/hash differs')
        require(item['exitCode']==0,f'adoption source check failed: {item["entry"]["path"]}')
        names[Path(entry['path']).parent.parent.name if 'ordinary-initialization' in entry['path'] else 'conditions']=item
        for field in ('stdout','stderr'):
            stream=item['streams'][field]; found=rows.get(stream['path'])
            require(found is not None and (found['bytes'],found['sha256'])==(stream['bytes'],stream['sha256']),f'adoption source-check {field} path/hash differs')
    require(len(checks['checks'])==2 and all(x['exitCode']==0 for x in checks['checks']),'expected two passing adoption checks')
    for section in ('selectedHelpers','unselectedDependencies'):
        for item in checks.get(section,[]): row_for(rows,item['path'],item['sha256'])
def row_for(rows,path,h):
    row=rows.get(path); require(row is not None and row['sha256']==h,f'exact source path/hash missing: {path}'); return row

def verify_preflight(rows,manifest,archive,result,helper):
    previous=result['preflightHistory']; require({x['backend'] for x in previous}=={'js','native'} and len(previous)==2,'preflight history roles differ')
    for item in previous:
        planrow=row_for(rows,item['planPath'],item['planSHA256']); plan=parse(archive.read(planrow['member']),f'{item["backend"]} preflight plan')
        helper.verify_plan_inputs(plan,rows,manifest,f'actual01-{item["backend"]}-preflight')
        require(len(plan.get('commands',[]))>0,'preflight plan no longer retains intended command list')
        if item['backend']=='js':
            require(item['status']=='INCOMPLETE' and item['commands']==0 and item['receiptPath'],'JS preflight classification changed')
            rr=row_for(rows,item['receiptPath'],item['receiptSHA256']); receipt=parse(archive.read(rr['member']),'actual01 JS preflight receipt')
            require(receipt['status']=='INCOMPLETE' and receipt['commands']==[] and receipt['guards']==[] and receipt['planSHA256']==item['planSHA256'],'actual01 JS must remain a no-execution preflight failure')
        else:
            require(item['status']=='NOT_EXECUTED' and item['commands']==0 and item['receiptPath'] is None and item['receiptSHA256'] is None,'actual01 Native must remain plan-only')

def verify_capacity_lineage(rows,archive,result):
    binding=result['sourceBinding']; normal_path=next(p for p in rows if p.endswith('/independent-oracle-v1/source-freeze.json'))
    mutant_path=next(p for p in rows if p.endswith('/independent-oracle-mutant-v1/source-freeze.json'))
    controls_path=next(p for p in rows if p.endswith('/controls-oracle-v1/source-freeze.json'))
    normal=parse(archive.read(rows[normal_path]['member']),'capacity normal freeze')
    mutant=parse(archive.read(rows[mutant_path]['member']),'capacity mutant freeze')
    controls=parse(archive.read(rows[controls_path]['member']),'capacity controls freeze')
    require(normal['producerCommit'].startswith('247b73fa3') and normal['queueCommit'].startswith('0d2da72c5'),'normal capacity source join differs')
    require(mutant['normalOracleCommit'].startswith('df3845cce'),'mutant does not bind the normal oracle commit')
    require(controls['producerCommit'].startswith('a3f3e799a') and controls['queueCommit'].startswith('0d2da72c5'),'controls source join differs')
    require(binding['capacityOracleCommits']=={'normal':'df3845cce','disabled-eviction-mutant':'87239af1c','controls':'73ecc7ae6'},'capacity oracle commit labels differ')

def verify_profile_diagnostics(rows,archive,result):
    binding=result['profileDiagnostics']
    planrow=row_for(rows,binding['planPath'],binding['planSHA256']); plan=parse(archive.read(planrow['member']),'profile capture plan')
    reviewrow=row_for(rows,binding['launchReviewPath'],binding['launchReviewSHA256']); review=archive.read(reviewrow['member']).decode('utf-8')
    runrow=row_for(rows,binding['orchestrationPath'],binding['orchestrationSHA256'])
    require(plan['transport']['expectedRawBytes']==binding['expectedRawBytes'] and plan['transport']['expectedRawSHA256']==binding['expectedRawSHA256'],'profile raw-output binding differs')
    require('Verdict: PASS before execution.' in review and planrow['sha256'] in review and runrow['sha256'] in review,'independent profile launch review does not bind the captured plan/orchestration')
    require('No timeout occurred in this cohort' in review and 'does not persist the attached partial Node stdout/stderr' in review,'profile timeout limitation missing')
    coordinatorrow=row_for(rows,binding['coordinatorReceiptPath'],binding['coordinatorReceiptSHA256']); coordinator=parse(archive.read(coordinatorrow['member']),'profile coordinator receipt')
    require(coordinator['status']=='PASS_BOUNDED_CPU_AND_SAMPLED_ALLOCATION_DIAGNOSTICS' and coordinator['planSHA256']==binding['planSHA256'],'profile coordinator receipt is not a passing capture for this plan')
    require(len(coordinator['commands'])==2 and {x['role'] for x in coordinator['commands']}=={'baseline','candidate'},'profile coordinator role inventory differs')
    for command in coordinator['commands']:
        require(command['exit']==0 and command['failure'] is None and command['validatedRawOracleSHA256']==binding['expectedRawSHA256'],'profile capture command did not complete against the full raw oracle')
    analysisrow=row_for(rows,binding['analysisPath'],binding['analysisSHA256']); analysis=parse(archive.read(analysisrow['member']),'profile analysis')
    require(binding['sampledAllocationBytes']=={k:analysis[k]['sampledAllocationBytes'] for k in ('baseline','candidate')},'sampled-allocation analysis values differ')
    require(binding['cpuSamples']=={k:analysis[k]['cpuSamples'] for k in ('baseline','candidate')},'CPU sample analysis values differ')
    require(binding['sampledAllocationBytes']=={'baseline':136924608,'candidate':32824456},'bounded sampled allocation values differ')
    require(result['performanceClaim'] is False and 'not timing acceptance' in binding['timeoutLimitation'] and 'not a physical allocation/RSS measurement' in binding['timeoutLimitation'],'diagnostic scope is overstated')
    expected_path=next(path for path in plan['pins'] if path.endswith('/expected.json'))
    expectedrow=row_for(rows,expected_path,plan['pins'][expected_path])
    expected_rows=[json.loads(x) for x in archive.read(expectedrow['member']).decode('utf-8').splitlines() if x.strip()]
    require(len(expected_rows)==1,'profile raw oracle must contain one complete output')
    expected_raw=expected_rows[0]['stdout'].encode('utf-8')
    artifacts=coordinator['profileArtifacts']
    for role in ('baseline','candidate'):
        rinfo=binding['profileReceipts'][role]; rr=row_for(rows,rinfo['path'],rinfo['sha256']); receipt=parse(archive.read(rr['member']),f'{role} profiler receipt')
        require(receipt['status']=='PASS' and receipt['iterations']==1 and receipt['expectedSHA256']==plan['pins'][expected_path],'inner profiler receipt is incomplete or uses another oracle')
        for mode in ('cpu','heap'):
            run=receipt['runs'][mode]; require(run['validatedApplications']==1 and run['limitSeconds']==5 and run['audit']['completed']==run['audit']['zeroExits']==1,'inner profiler mode did not finish its single application')
            artifact_path=f"/tmp/bendvy48-queue-profile-captures01/{role}/{mode}.stdout.gz"
            artifact=artifacts.get(artifact_path); require(artifact is not None,'complete profiled raw output absent')
            outrow=row_for(rows,artifact_path,artifact['sha256']); rawrow=json.loads(gzip.decompress(archive.read(outrow['member'])).decode('utf-8'))
            raw=rawrow['stdout'].encode('utf-8')
            require((len(raw),digest(raw))==(binding['expectedRawBytes'],binding['expectedRawSHA256']),f'{role}/{mode} profiled output differs from full semantic oracle')
            if expected_raw is not None: require(raw==expected_raw,f'{role}/{mode} profiled output bytes differ from retained expected text')
    for path,artifact in artifacts.items(): row_for(rows,path,artifact['sha256'])

def verify_root_adoption_recheck(rows,archive,result):
    binding=result['rootAdoptionRecheck']
    listrow=row_for(rows,binding['materializedPathsPath'],binding['materializedPathsSHA256']); paths=parse(archive.read(listrow['member']),'root materialized path list')
    require(len(paths)==binding['materializedPathCount']==80 and len(set(paths))==80,'root materialized path count differs')
    sources=binding['materializedSources']; require(len(sources)==80,'root materialized source hash inventory differs')
    expected_paths={f'/workspace/formal-proofs/bendvy/{p}' for p in paths}
    require({x['sourcePath'] for x in sources}==expected_paths,'root materialized source paths differ from list')
    ownershiprow=row_for(rows,binding['currentSourceOwnershipPath'],binding['currentSourceOwnershipSHA256'])
    ownership=parse(archive.read(ownershiprow['member']),'current root source ownership')
    require(ownership.get('format')=='bendvy-current-root-source-ownership-v1' and ownership.get('sourceRoot')=='/workspace/formal-proofs/bendvy','current root ownership manifest identity differs')
    require(ownership.get('sourceCount')==80 and ownership.get('baseCommit')=='4ec00cd43ef095660b74e84501aab4067b4eb576','current root ownership source count/base differs')
    require(ownership.get('pathListPath')==binding['materializedPathsPath'] and ownership.get('pathListSHA256')==binding['materializedPathsSHA256'],'current root ownership path-list binding differs')
    current_sources=ownership.get('sources'); require(current_sources==sources,'current root source hashes differ from ownership manifest')
    for item in sources:
        require(item['sourcePath'] in expected_paths and isinstance(item['bytes'],int) and item['bytes']>=0 and len(item['sha256'])==64,'current root source ownership row malformed')
    stdoutrow=row_for(rows,binding['sourceCheckStdoutPath'],binding['sourceCheckStdoutSHA256']); stderrrow=row_for(rows,binding['sourceCheckStderrPath'],binding['sourceCheckStderrSHA256'])
    require(binding['sourceCheckExit']==0 and b'ALL PROOFS CHECK' in archive.read(stdoutrow['member']),'root adoption entry source check is not recorded passing')
    # This is one entry check over a materialized source tree, not 80 independent checks.
    protectedrow=row_for(rows,binding['protected28Path'],binding['protected28SHA256']); protected=parse(archive.read(protectedrow['member']),'protected #28 reuse check')
    require(protected['status']=='PASS' and len(protected['checkedSources'])==binding['protected28CheckedSourceCount']==23,'protected #28 source-reuse check does not pass')
    require(protected['inventoryPath'] and protected['inventorySHA256']==binding['protected28InventorySHA256'],'protected #28 inventory binding differs')
    inventory_path=binding['protected28InventoryPath']; inventoryrow=row_for(rows,inventory_path,binding['protected28InventorySHA256'])
    require(inventoryrow['sourcePath'].endswith('/'+protected['inventoryPath']),'protected #28 inventory path differs')
    for item in protected['checkedSources']:
        row_for(rows,'/workspace/formal-proofs/bendvy/'+item['path'],item['sha256'])
    selectors=binding['sourceSelectors']; source=result['sourceBinding']; commits=source['capacityOracleCommits']
    require(source['candidateWorktreeHead'].startswith(selectors['capacity']) and commits['normal'].startswith(selectors['normalOracle']) and commits['disabled-eviction-mutant'].startswith(selectors['mutantOracle']) and commits['controls'].startswith(selectors['controlsOracle']) and source['adoptionWorktreeCommit'].startswith(selectors['adoption']),'root materialized source selectors differ')

def verify_evidence(here,negative=None):
    delivery,owner,root=verify_local_selection(here); result=parse((here/'RESULT.json').read_bytes(),'RESULT.json'); manifest=parse((here/'MANIFEST.json').read_bytes(),'MANIFEST.json')
    status='PASS_BOUNDED_CANONICAL_STREAM_CAPACITY_AND_ADOPTION_DELIVERY'
    require(delivery['status']==result['status']==status and result['fullIssueAcceptance']=='OPEN' and result['performanceClaim'] is False,'delivery overstates scope/performance')
    for filename,key in [('MANIFEST.json','manifest'),('RESULT.json','result'),('EVIDENCE.zip','archive')]:
        raw=(here/filename).read_bytes(); require((len(raw),digest(raw))==(delivery[key]['bytes'],delivery[key]['sha256']),f'{filename} package hash differs')
    filemap=delivery['files']; verifier_path=(DELIVERY_REL/'verify.py').as_posix(); require(digest((here/'verify.py').read_bytes())==filemap[verifier_path]['sha256'],'verifier file hash differs')
    rows={x['sourcePath']:x for x in manifest['logicalPaths']}; require(len(rows)==len(manifest['logicalPaths']),'duplicate exact sourcePath')
    objects={x['sha256']:x for x in manifest['objects']}; require(len(objects)==len(manifest['objects']),'duplicate content-addressed object')
    for h,obj in objects.items(): require(obj['member']==f'objects/{h}','noncanonical archive member')
    with zipfile.ZipFile(here/'EVIDENCE.zip','r') as archive:
        require(len(archive.namelist())==len(set(archive.namelist())) and set(archive.namelist())=={x['member'] for x in manifest['objects']},'archive membership differs')
        for item in manifest['logicalPaths']:
            canonical_external(item['sourcePath']); obj=objects.get(item['sha256']); require(obj is not None and (obj['member'],obj['bytes'])==(item['member'],item['bytes']),'logical path/object binding differs')
        helper=load_helper(rows,result,archive)
        for h,obj in objects.items():
            with archive.open(obj['member'],'r') as stream: size,actual=helper.hash_stream(stream)
            require((size,actual)==(obj['bytes'],h),f'archive object corrupt {h}')
        role_map={x['name']:x for x in result['roles']}
        expected_names={'canonical-capacity-js','canonical-capacity-native','no-eviction-mutant-js','capacity-controls-js','capacity-controls-native','adoption-initialization-js','adoption-initialization-native','adoption-conditions-js','adoption-conditions-native','profile-prerequisite-baseline-js','profile-prerequisite-candidate-js'}
        require(len(role_map)==len(result['roles']) and set(role_map)==expected_names,'qualified role inventory differs')
        verified={name:helper.verify_role(role,rows,manifest,archive) for name,role in role_map.items()}
        outputs={'canonical-capacity-js':(19367810,'6e89e6755cc5fddeb5bd992add71012ee0cd37e702c90071d1497bf4133051da'),'canonical-capacity-native':(19367810,'6e89e6755cc5fddeb5bd992add71012ee0cd37e702c90071d1497bf4133051da'),'no-eviction-mutant-js':(19367924,'886aa6f2a99eb132b2dbe376156b4578f7ca445553a59693f5012a092c79ece9'),'capacity-controls-js':(1760,'90b9066fe6169b855e771fc9e7fe10a3188ea585ea6baa5a8fb185a636717bb9'),'capacity-controls-native':(1760,'90b9066fe6169b855e771fc9e7fe10a3188ea585ea6baa5a8fb185a636717bb9'),'adoption-initialization-js':(105004,'f0d566ba6fa6c74efc28470d0ec3e406dcdc19ccd894a8b75e1329c6752089d6'),'adoption-initialization-native':(105004,'f0d566ba6fa6c74efc28470d0ec3e406dcdc19ccd894a8b75e1329c6752089d6'),'adoption-conditions-js':(17373,'7d8b3b10c2668436d0dcbe9e8f00ebbb54ba3e4290132c8198692e29774b932f'),'adoption-conditions-native':(17373,'7d8b3b10c2668436d0dcbe9e8f00ebbb54ba3e4290132c8198692e29774b932f'),'profile-prerequisite-baseline-js':(33072,'c9f4249293942059ddcb3acbad7d65e9279d2de464d06adf9b902a3f7aee6c43'),'profile-prerequisite-candidate-js':(33072,'c9f4249293942059ddcb3acbad7d65e9279d2de464d06adf9b902a3f7aee6c43')}
        for name,expected in outputs.items():
            role=role_map[name]; plan,receipt=verified[name]; require((role['outputBytes'],role['outputSHA256'])==expected,f'{name} output metadata differs')
            require((plan['oracleBytes'],plan['oracleSHA256'])==expected,f'{name} oracle metadata differs')
            consumer=next(c for c in receipt['commands'] if c['label']=='consumer'); output=rows[consumer['stdout']['path']]; oracle=rows[plan['oracle']]
            helper.compare_gzip(archive,oracle,output,expected[0],expected[1],name)
            require(consumer['stderr']['bytes']==0,f'{name} consumer stderr is nonempty')
        for a,b in [('canonical-capacity-js','canonical-capacity-native'),('capacity-controls-js','capacity-controls-native'),('adoption-initialization-js','adoption-initialization-native'),('adoption-conditions-js','adoption-conditions-native')]:
            pa,ra=verified[a]; pb,rb=verified[b]; require(pa['oracleSHA256']==pb['oracleSHA256'] and ra['commands'][-1]['stdout']['sha256']==rb['commands'][-1]['stdout']['sha256'],f'{a}/{b} backend pair differs')
        mutant_plan,mutant_receipt=verified['no-eviction-mutant-js']; require(mutant_receipt['completeNormalBaselineRejected'] is True,'capacity mutant baseline rejection absent')
        normal=rows[mutant_plan['normalOracle']]; mutant_output=rows[next(c for c in mutant_receipt['commands'] if c['label']=='consumer')['stdout']['path']]
        try: helper.compare_gzip(archive,normal,mutant_output,mutant_plan['normalOracleBytes'],mutant_plan['normalOracleSHA256'],'mutant normal baseline')
        except VerificationError: pass
        else: raise VerificationError('no-eviction mutant matches complete normal baseline')
        verify_preflight(rows,manifest,archive,result,helper); verify_source_checks(rows,archive,result); verify_capacity_lineage(rows,archive,result)
        verify_profile_diagnostics(rows,archive,result); verify_root_adoption_recheck(rows,archive,result)
        # Baseline/candidate are semantic prerequisites only and have identical complete output.
        profile_a=verified['profile-prerequisite-baseline-js'][0]; profile_b=verified['profile-prerequisite-candidate-js'][0]
        require(profile_a['oracleSHA256']==profile_b['oracleSHA256'] and profile_a['oracleBytes']==profile_b['oracleBytes'],'profile semantic prerequisites do not share the same oracle')
        # Full paths remain mandatory: JS and Native consumer streams share basename and bytes.
        jsrole=role_map['canonical-capacity-js']; native=role_map['canonical-capacity-native']; jr=verified['canonical-capacity-js'][1]; nr=verified['canonical-capacity-native'][1]
        jc=next(c for c in jr['commands'] if c['label']=='consumer'); nc=next(c for c in nr['commands'] if c['label']=='consumer')
        require(PurePosixPath(jc['stdout']['path']).name==PurePosixPath(nc['stdout']['path']).name and jc['stdout']['sha256']==nc['stdout']['sha256'],'wrong-parent negative precondition differs')
        if negative=='wrong-parent-receipt': helper.verify_stream(jc['stdout'],'consumer.stdout',jsrole['streamRoot'],rows,archive,path_override=nc['stdout']['path'])
        if negative=='wrong-parent-manifest':
            altered=dict(rows); altered.pop(jc['stdout']['path'],None); helper.verify_stream(jc['stdout'],'consumer.stdout',jsrole['streamRoot'],altered,archive)
    return {'status':status,'roles':len(role_map),'logicalPaths':len(rows),'objects':len(objects),'profileCaptureModes':4,'rootMaterializedPaths':80,'protected28Bindings':23,'fullPathNegativeControls':2,'performanceClaim':False,'fullIssueAcceptance':'OPEN'}

def selftest():
    verify_evidence(HERE)
    for name in ('wrong-parent-receipt','wrong-parent-manifest'):
        try: verify_evidence(HERE,name)
        except VerificationError: pass
        else: raise VerificationError(f'{name} negative control accepted')
    _,owner,root=verify_local_selection(HERE)
    with tempfile.TemporaryDirectory(prefix='bendvy48-capacity-relocation-') as td:
        moved_root=Path(td)
        for rel in owner['ownedPaths']:
            src=local_owned(root,rel); dest=moved_root/Path(rel); dest.parent.mkdir(parents=True,exist_ok=True); shutil.copyfile(src,dest)
        moved=moved_root/Path(*DELIVERY_REL.parts); verify_local_selection(moved)
        readme=moved_root/Path((DELIVERY_REL/'README.md').as_posix())
        with readme.open('ab') as stream: stream.write(b'local drift')
        try: verify_local_selection(moved)
        except VerificationError as exc: require('owned file drift' in str(exc),'relocation drift failed unexpectedly')
        else: raise VerificationError('relocated local drift accepted')
        try: local_owned(moved_root,'../outside')
        except VerificationError: pass
        else: raise VerificationError('path traversal accepted')
def main():
    try:
        if sys.argv[1:]==['--selftest']:
            selftest(); print('PASS_BOUNDED_CANONICAL_STREAM_CAPACITY_DELIVERY_SELFTEST')
        elif not sys.argv[1:]: print(json.dumps(verify_evidence(HERE),sort_keys=True))
        else: raise VerificationError('usage: python3 verify.py [--selftest]')
        return 0
    except (VerificationError,KeyError,OSError,ValueError,zipfile.BadZipFile) as exc:
        print(f'FAIL_BOUNDED_CANONICAL_STREAM_CAPACITY_DELIVERY: {exc}',file=sys.stderr); return 1
if __name__=='__main__': raise SystemExit(main())
