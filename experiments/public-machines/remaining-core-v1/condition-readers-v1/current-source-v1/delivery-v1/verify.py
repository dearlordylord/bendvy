#!/usr/bin/env python3
"""Portable package adapter; delegates plan/receipt/stream checks to the retained #43 verifier."""
from __future__ import annotations
import hashlib, importlib.util, json, shutil, sys, tempfile, zipfile
from pathlib import Path, PurePosixPath

HERE = Path(__file__).resolve().parent
DELIVERY_REL = PurePosixPath('experiments/public-machines/remaining-core-v1/condition-readers-v1/current-source-v1/delivery-v1')
class VerificationError(Exception): pass

def require(ok, message):
    if not ok: raise VerificationError(message)
def digest(data: bytes) -> str: return hashlib.sha256(data).hexdigest()
def parse_json(data: bytes, label: str):
    try: return json.loads(data)
    except Exception as exc: raise VerificationError(f'invalid JSON in {label}: {exc}') from exc
def canonical_external(path: str):
    p = PurePosixPath(path)
    require(p.is_absolute() and p.as_posix() == path and all(x not in ('', '.', '..') for x in p.parts), f'noncanonical full path: {path}')
def repo_root(here: Path):
    root = here.resolve()
    for _ in DELIVERY_REL.parts: root = root.parent
    require((root/Path(*DELIVERY_REL.parts)).resolve() == here.resolve(), 'delivery is not at its fixed repository-relative path')
    return root
def local_owned(root: Path, rel: str):
    p = PurePosixPath(rel)
    require(not p.is_absolute() and p.as_posix() == rel and p.parts and all(x not in ('', '.', '..') for x in p.parts), f'noncanonical local path: {rel}')
    base = root.resolve(); out = (base/Path(*p.parts)).resolve()
    try: out.relative_to(base)
    except ValueError as exc: raise VerificationError(f'local ownership escapes repository: {rel}') from exc
    require(out.is_file(), f'missing locally owned file: {rel}')
    return out
def verify_local_selection(here: Path):
    here = here.resolve(); root = repo_root(here)
    delivery = parse_json((here/'DELIVERY.json').read_bytes(), 'DELIVERY.json')
    owner = parse_json((here/'OWNERSHIP.json').read_bytes(), 'OWNERSHIP.json')
    producer = PurePosixPath(owner.get('producerWorktree', ''))
    require(producer.is_absolute() and producer.as_posix() == owner.get('producerWorktree') and all(x not in ('', '.', '..') for x in producer.parts), 'producer root is noncanonical')
    require(delivery.get('producerWorktree') == producer.as_posix(), 'delivery producer root differs')
    require(owner.get('pathBase') == delivery.get('pathBase') == 'repository-root-relative', 'ownership path base differs')
    local_paths = owner.get('ownedPaths'); producer_paths = owner.get('producerOwnedPaths')
    require(isinstance(local_paths,list) and isinstance(producer_paths,list) and local_paths == sorted(local_paths) and producer_paths == sorted(producer_paths) and len(local_paths) == len(producer_paths) == owner.get('count'), 'ownership list/count invalid')
    mapping = {}
    for source in producer_paths:
        canonical_external(source)
        full = PurePosixPath(source)
        try: suffix = full.relative_to(producer)
        except ValueError as exc: raise VerificationError(f'producer path outside worktree: {source}') from exc
        rel = suffix.as_posix()
        require(rel not in ('', '.') and rel not in mapping, f'duplicate/empty producer path suffix: {source}')
        mapping[rel] = source
    require(sorted(mapping) == local_paths, 'local and producer-owned paths do not map one-to-one')
    require(delivery.get('ownedPaths') == local_paths and delivery.get('producerOwnedPaths') == producer_paths, 'delivery and ownership maps differ')
    delivery_rel = (DELIVERY_REL/'DELIVERY.json').as_posix()
    require(delivery_rel in local_paths, 'DELIVERY.json missing from ownership')
    files = delivery.get('files',{})
    require(set(files) == set(local_paths)-{delivery_rel}, 'delivery file set differs from ownership')
    for rel, meta in files.items():
        require(meta.get('sourcePath') == mapping[rel], f'producer source path mismatch: {rel}')
        data = local_owned(root,rel).read_bytes()
        require((len(data),digest(data)) == (meta.get('bytes'),meta.get('sha256')), f'owned file drift: {rel}')
    return delivery,owner,root

def load_helper(rows, manifest, archive, result):
    dep = result['verificationDependency']; path = dep['sourcePath']
    row = rows.get(path)
    require(row is not None and row['sha256'] == dep['sha256'], 'retained verifier helper missing/hash differs')
    raw = archive.read(row['member'])
    require(digest(raw) == dep['sha256'], 'retained verifier helper object differs')
    with tempfile.TemporaryDirectory(prefix='bendvy48-retained-verifier-') as td:
        p = Path(td)/'scheduled_followup_verify.py'; p.write_bytes(raw)
        spec = importlib.util.spec_from_file_location('bendvy_retained_verify',p)
        helper = importlib.util.module_from_spec(spec); spec.loader.exec_module(helper)
        # Let the retained helper's expected validation failures flow through
        # this verifier's public error type and self-tests.
        helper.VerificationError = VerificationError
        return helper

def check_successful_source_check(rows, archive, result):
    meta = result['successfulSourceCheck']; row = rows.get(meta['receiptSourcePath'])
    require(row is not None and row['sha256'] == meta['receiptSHA256'], 'successful source-check receipt missing/hash differs')
    record = parse_json(archive.read(row['member']),'successful source-check receipt')
    require(record['exit'] == 0 and record['entrySHA256'] == meta['entrySHA256'], 'source-check success or entry binding differs')
    parent = PurePosixPath(meta['receiptSourcePath']).parent
    index_path = str(parent/'source-checks.json'); index_row = rows.get(index_path)
    require(index_row is not None, 'source-check raw stream index missing')
    entry = parse_json(archive.read(index_row['member']),'source-check stream index')['successfulEntryCheck']
    require(entry['exit'] == record['exit'] and entry['entrySHA256'] == record['entrySHA256'], 'source-check stream index differs from receipt')
    for field in ('stdout','stderr'):
        m = entry[field]; path = str(parent/m['file']); r = rows.get(path)
        require(r is not None and (r['bytes'],r['sha256']) == (m['bytes'],m['sha256']), f'source-check {field} stream differs')
        require((r['bytes'],r['sha256']) == (meta[field+'Bytes'],meta[field+'SHA256']), f'source-check {field} summary differs')

def check_controls(rows, archive, result):
    m = result['typeAndAffineControls']; row = rows.get(m['checksPath'])
    require(row is not None and row['sha256'] == m['checksSHA256'], 'control checks inventory missing/hash differs')
    checks = parse_json(archive.read(row['member']),'type/affine checks')
    require(checks['coreCommit'] == m['coreSourceCommit'], 'control core source commit differs')
    require({x['name']:x['exit'] for x in checks['checks']} == {'positive':0,'cross-schema':1,'owner-duplicate':1}, 'positive/negative control status differs')
    base = PurePosixPath(m['checksPath']).parent
    for check in checks['checks']:
        source = next((p for p in rows if p.endswith('/'+check['source'])),None)
        require(source is not None and rows[source]['sha256'] == check['sourceSHA256'], f"{check['name']}: source hash differs")
        for field in ('stdout','stderr'):
            info=check['streams'][field]; path=str(base/info['retainedPath']); sr=rows.get(path)
            require(sr is not None and (sr['bytes'],sr['sha256']) == (info['bytes'],info['sha256']), f"{check['name']}/{field}: raw check stream differs")

def check_root_recheck(rows, archive, result, plan, freeze, helper):
    meta = result['rootCanonicalSourceRecheck']; row=rows.get(meta['receiptSourcePath'])
    require(row is not None and row['sha256']==meta['receiptSHA256'],'root source receipt missing/hash differs')
    receipt=json.loads(archive.read(row['member']))
    inv=receipt['sourceInventory']; require(receipt['exit']==0 and len(inv)==68,'root source recheck did not pass 68-body closure')
    require(set(inv)==set(freeze['sourceInventory']),'root canonical source set differs from freeze')
    bridge_row=rows.get(meta['eofBridgePath']); require(bridge_row is not None and bridge_row['sha256']==meta['eofBridgeSHA256'],'EOF bridge evidence absent')
    bridge=json.loads(archive.read(bridge_row['member']))
    rel=bridge['path']; require(bridge['operation']=="new = old.rstrip(b'\\n') + b'\\n'",'EOF bridge operation differs')
    require(bridge['oldSHA256']==freeze['sourceInventory'][rel] and bridge['newSHA256']==inv[rel],'EOF bridge hashes do not explain the source recheck')
    for p,h in freeze['sourceInventory'].items():
        if p!=rel: require(inv[p]==h,f'unexpected canonical source delta: {p}')
        path=str(PurePosixPath('/workspace/formal-proofs/bendvy')/p); source=rows.get(path)
        require(source is not None and source['sha256']==inv[p],f'root source path missing/hash differs: {p}')
    old = next(p for p in plan['sourceInventory'] if p.endswith('/'+rel) and 'machines48-condition-readers-current' in p)
    new = '/workspace/formal-proofs/bendvy/'+rel
    oldrow=rows[old]; newrow=rows[new]
    olddata=archive.read(oldrow['member']); newdata=archive.read(newrow['member'])
    require(digest(olddata)==bridge['oldSHA256'] and digest(newdata)==bridge['newSHA256'] and newdata==olddata.rstrip(b'\n')+b'\n','main EOF bridge is not exact')
    require(inv[freeze['entrypoint']]==plan['sourceInventory'][plan['entrypoint']],'root entry hash differs')
    for field in ('stdout','stderr'):
        stream=rows.get(meta[field+'Path']); require(stream is not None and (stream['bytes'],stream['sha256'])==(meta[field+'Bytes'],meta[field+'SHA256']),f'root source-check {field} differs')

def check_protected28(rows,archive,result):
    m=result['protected28Reuse']; invrow=rows.get(m['recordPath'])
    require(invrow is not None and invrow['sha256']==m['recordSHA256'],'protected #28 inventory record missing')
    inventory=json.loads(archive.read(invrow['member']))
    checkrow=rows.get(m['currentSourceRecheckPath'])
    require(checkrow is not None and checkrow['sha256']==m['currentSourceRecheckSHA256'],'protected #28 source recheck receipt missing')
    check=json.loads(archive.read(checkrow['member']))
    require(check['status']=='PASS' and check['count']==23 and check['inventorySHA256']==digest(archive.read(invrow['member'])),'protected #28 23-path source recheck failed')
    require(inventory['artifactIdentity']['status']=='IDENTICAL' and inventory['count']==23 and inventory['sourceIdenticalCount']==22,'protected #28 historical identity scope differs')
    ar=rows.get(m['archivePath']); require(ar is not None and ar['sha256']==m['archiveSHA256']==inventory['retainedQualifiedNative']['archiveSHA256'],'protected #28 retained archive missing/hash differs')
    root=m['checkedSourceRoot']
    for source in check['checkedSources']:
        full=str(PurePosixPath(root)/source['path']); sr=rows.get(full)
        require(sr is not None and sr['sha256']==source['sha256'],f"protected #28 source mismatch: {source['path']}")

def verify_evidence(here: Path, negative=None):
    delivery, owner, root = verify_local_selection(here)
    result=parse_json((here/'RESULT.json').read_bytes(),'RESULT.json')
    manifest=parse_json((here/'MANIFEST.json').read_bytes(),'MANIFEST.json')
    status='PASS_BOUNDED_CURRENT_SOURCE_STATEFUL_CONDITION_COMPOSITION_DELIVERY'
    require(delivery['status']==result['status']==status and result['fullIssueAcceptance']=='OPEN' and result['performanceClaim'] is False,'delivery/result status overstates acceptance')
    for filename,key in [('MANIFEST.json','manifest'),('RESULT.json','result'),('EVIDENCE.zip','archive')]:
        raw=(here/filename).read_bytes(); require((len(raw),digest(raw))==(delivery[key]['bytes'],delivery[key]['sha256']),f'{filename} local hash differs')
    files=delivery['files']; vpath=(DELIVERY_REL/'verify.py').as_posix()
    require(digest((here/'verify.py').read_bytes())==files[vpath]['sha256'],'local verifier hash differs')
    rows={x['sourcePath']:x for x in manifest['logicalPaths']}; require(len(rows)==len(manifest['logicalPaths']),'duplicate full sourcePath')
    objects={x['sha256']:x for x in manifest['objects']}; require(len(objects)==len(manifest['objects']),'duplicate content-addressed object')
    for h,o in objects.items(): require(o['member']==f'objects/{h}','noncanonical object member')
    with zipfile.ZipFile(here/'EVIDENCE.zip','r') as archive:
        require(set(archive.namelist())=={o['member'] for o in manifest['objects']},'archive membership differs from object inventory')
        for item in manifest['logicalPaths']:
            canonical_external(item['sourcePath']); obj=objects[item['sha256']]
            require(obj['member']==item['member'] and obj['bytes']==item['bytes'],'logical path/object metadata differs')
        for h,obj in objects.items():
            with archive.open(obj['member'],'r') as f:
                raw=f.read(); size,actual=len(raw),digest(raw)
            require(size==obj['bytes'] and actual==h,f'archive object corrupt: {h}')
        helper=load_helper(rows,manifest,archive,result)
        role_map={r['name']:r for r in result['roles']}
        require(len(role_map)==len(result['roles']) and set(role_map)=={'ordinary-js','ordinary-native','eager-rhs-mutant-js'},'role set differs')
        verified={n:helper.verify_role(r,rows,manifest,archive) for n,r in role_map.items()}
        expected={'ordinary-js':(17373,'7d8b3b10c2668436d0dcbe9e8f00ebbb54ba3e4290132c8198692e29774b932f'),'ordinary-native':(17373,'7d8b3b10c2668436d0dcbe9e8f00ebbb54ba3e4290132c8198692e29774b932f'),'eager-rhs-mutant-js':(17373,'019301cd43b0e4f2303cc42aa5902d85118b2e40a0058831a3da54a3ac812be2')}
        for name,expected_output in expected.items():
            r=role_map[name]; require((r['outputBytes'],r['outputSHA256'])==expected_output,f'{name}: output bytes/hash differs')
            plan,receipt=verified[name]; consumer=next(c for c in receipt['commands'] if c['label']=='consumer')
            require(plan['oracleBytes']==r['oracleBytes'] and plan['oracleSHA256']==r['oracleSHA256'],'oracle role metadata differs')
            helper.compare_gzip(archive,rows[plan['oracle']],rows[consumer['stdout']['path']],r['oracleBytes'],r['oracleSHA256'],name)
        normal_plan,_=verified['ordinary-js']; native_plan,_=verified['ordinary-native']; mutant_plan,mutant_receipt=verified['eager-rhs-mutant-js']
        require(normal_plan['sourceInventory']==native_plan['sourceInventory'],'normal backend source inventories differ')
        require(len(normal_plan['sourceInventory'])==82 and len(mutant_plan['sourceInventory'])==82,'ordinary source path count differs')
        require(result['sourceBinding']['ordinaryLiteralImportPaths']==82 and result['sourceBinding']['ordinaryDistinctSourceBodies']==68,'normal source path/body count differs')
        require(result['sourceBinding']['mutantLiteralImportPaths']==82 and result['sourceBinding']['mutantDistinctSourceBodies']==68,'mutant source path/body count differs')
        require(mutant_receipt['completeNormalBaselineRejected'] is True,'mutant complete baseline rejection absent')
        baseline=rows[mutant_plan['normalOracle']]
        out=rows[next(c for c in mutant_receipt['commands'] if c['label']=='consumer')['stdout']['path']]
        try: helper.compare_gzip(archive,baseline,out,mutant_plan['normalOracleBytes'],mutant_plan['normalOracleSHA256'],'mutant normal baseline')
        except helper.VerificationError: pass
        else: raise VerificationError('eager-RHS mutant matches the complete normal baseline')
        check_successful_source_check(rows,archive,result)
        check_controls(rows,archive,result)
        freeze_row=next(x for x in manifest['logicalPaths'] if x['sourcePath'].endswith('/independent-oracle-v1/source-freeze.json'))
        freeze=parse_json(archive.read(freeze_row['member']),'normal oracle freeze')
        check_root_recheck(rows,archive,result,normal_plan,freeze,helper)
        check_protected28(rows,archive,result)
        # Same basename and bytes cannot be substituted across source parents.
        js_role=role_map['ordinary-js']; native_role=role_map['ordinary-native']
        js_receipt=verified['ordinary-js'][1]; native_receipt=verified['ordinary-native'][1]
        jc=next(c for c in js_receipt['commands'] if c['label']=='consumer'); nc=next(c for c in native_receipt['commands'] if c['label']=='consumer')
        require(PurePosixPath(jc['stdout']['path']).name==PurePosixPath(nc['stdout']['path']).name and jc['stdout']['sha256']==nc['stdout']['sha256'],'wrong-parent precondition differs')
        if negative=='wrong-parent-receipt': helper.verify_stream(jc['stdout'],'consumer.stdout',js_role['streamRoot'],rows,archive,path_override=nc['stdout']['path'])
        if negative=='wrong-parent-manifest':
            altered=dict(rows); altered.pop(jc['stdout']['path'],None)
            helper.verify_stream(jc['stdout'],'consumer.stdout',js_role['streamRoot'],altered,archive)
    return {'status':status,'literalImportPaths':82,'uniqueSourceBodies':68,'qualifiedRoles':3,'fullPathNegativeControls':2,'performanceClaim':False,'fullIssueAcceptance':'OPEN'}

def selftest():
    verify_evidence(HERE)
    for negative in ('wrong-parent-receipt','wrong-parent-manifest'):
        try: verify_evidence(HERE,negative)
        except VerificationError: pass
        else: raise VerificationError(f'{negative} was accepted')
    _,owner,root=verify_local_selection(HERE)
    with tempfile.TemporaryDirectory(prefix='bendvy48-composition-relocation-') as td:
        moved_root=Path(td)
        for rel in owner['ownedPaths']:
            src=local_owned(root,rel); dest=moved_root/Path(rel); dest.parent.mkdir(parents=True,exist_ok=True); shutil.copyfile(src,dest)
        moved=moved_root/Path(*DELIVERY_REL.parts); verify_local_selection(moved)
        changed=moved_root/Path((DELIVERY_REL/'README.md').as_posix())
        with changed.open('ab') as f: f.write(b'local drift')
        try: verify_local_selection(moved)
        except VerificationError as exc: require('owned file drift' in str(exc),'relocation drift rejection reason differs')
        else: raise VerificationError('relocated local file drift was accepted')
        try: local_owned(moved_root,'../outside')
        except VerificationError: pass
        else: raise VerificationError('local ownership path traversal was accepted')
def main():
    try:
        if sys.argv[1:]==['--selftest']:
            selftest(); print('PASS_BOUNDED_CURRENT_SOURCE_STATEFUL_CONDITION_COMPOSITION_DELIVERY_SELFTEST')
        elif not sys.argv[1:]: print(json.dumps(verify_evidence(HERE),sort_keys=True))
        else: raise VerificationError('usage: python3 verify.py [--selftest]')
        return 0
    except (VerificationError,KeyError,OSError,ValueError,zipfile.BadZipFile) as exc:
        print(f'FAIL_BOUNDED_CURRENT_SOURCE_STATEFUL_CONDITION_COMPOSITION_DELIVERY: {exc}',file=sys.stderr); return 1
if __name__=='__main__': raise SystemExit(main())
