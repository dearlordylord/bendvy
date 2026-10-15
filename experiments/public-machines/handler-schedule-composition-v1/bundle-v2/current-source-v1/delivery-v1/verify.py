#!/usr/bin/env python3
"""Offline verifier for the bounded current-source handler Bundle pair."""
from __future__ import annotations
import hashlib, importlib.util, json, shutil, sys, tempfile, zipfile
from pathlib import Path, PurePosixPath

HERE=Path(__file__).resolve().parent
DELIVERY_REL=PurePosixPath('experiments/public-machines/handler-schedule-composition-v1/bundle-v2/current-source-v1/delivery-v1')
class VerificationError(Exception): pass
def require(ok,message):
    if not ok: raise VerificationError(message)
def digest(raw:bytes)->str: return hashlib.sha256(raw).hexdigest()
def parse(raw:bytes,label):
    try:return json.loads(raw)
    except Exception as exc:raise VerificationError(f'invalid JSON {label}: {exc}') from exc
def canonical_external(path):
    p=PurePosixPath(path)
    require(p.is_absolute() and p.as_posix()==path and all(x not in ('','.','..') for x in p.parts),f'noncanonical full sourcePath: {path}')
def repo_root(here):
    root=here.resolve()
    for _ in DELIVERY_REL.parts:root=root.parent
    require((root/Path(*DELIVERY_REL.parts)).resolve()==here.resolve(),'delivery moved outside its repository-relative location')
    return root
def local_owned(root,rel):
    p=PurePosixPath(rel);require(not p.is_absolute() and p.as_posix()==rel and p.parts and all(x not in ('','.','..') for x in p.parts),f'invalid local owned path: {rel}')
    base=root.resolve();out=(base/Path(*p.parts)).resolve()
    try:out.relative_to(base)
    except ValueError as exc:raise VerificationError(f'local path escapes repository: {rel}') from exc
    require(out.is_file(),f'owned file missing: {rel}');return out
def verify_local_selection(here):
    here=here.resolve();root=repo_root(here)
    delivery=parse((here/'DELIVERY.json').read_bytes(),'DELIVERY.json');owner=parse((here/'OWNERSHIP.json').read_bytes(),'OWNERSHIP.json')
    producer=PurePosixPath(owner.get('producerWorktree',''))
    require(producer.is_absolute() and producer.as_posix()==owner.get('producerWorktree') and all(x not in ('','.','..') for x in producer.parts),'producer worktree path is not canonical')
    require(delivery.get('producerWorktree')==producer.as_posix(),'delivery producer root differs')
    require(owner.get('pathBase')==delivery.get('pathBase')=='repository-root-relative','owned path base differs')
    local=owner.get('ownedPaths');full=owner.get('producerOwnedPaths')
    require(isinstance(local,list) and isinstance(full,list) and local==sorted(local) and full==sorted(full) and len(local)==len(full)==owner.get('count'),'owned path selection/count differs')
    mapping={}
    for path in full:
        canonical_external(path);p=PurePosixPath(path)
        try:suffix=p.relative_to(producer)
        except ValueError as exc:raise VerificationError(f'owned path outside producer root: {path}') from exc
        rel=suffix.as_posix();require(rel not in ('','.') and rel not in mapping,'empty or duplicate producer path suffix');mapping[rel]=path
    require(sorted(mapping)==local,'producer and local path mappings differ')
    require(delivery.get('ownedPaths')==local and delivery.get('producerOwnedPaths')==full,'delivery ownership list differs')
    self_path=(DELIVERY_REL/'DELIVERY.json').as_posix();require(self_path in local,'DELIVERY.json absent from ownership')
    files=delivery.get('files',{});require(set(files)==set(local)-{self_path},'delivery file list differs from ownership')
    for rel,meta in files.items():
        require(meta.get('sourcePath')==mapping[rel],f'full path join differs for {rel}')
        raw=local_owned(root,rel).read_bytes();require((len(raw),digest(raw))==(meta.get('bytes'),meta.get('sha256')),f'owned file drift: {rel}')
    return delivery,owner,root

def row_for(rows,path,h=None):
    row=rows.get(path);require(row is not None,f'exact sourcePath absent from manifest: {path}')
    if h is not None:require(row['sha256']==h,f'exact sourcePath hash differs: {path}')
    return row
def load_helper(rows,result,archive):
    dep=result['verificationDependency'];row=row_for(rows,dep['sourcePath'],dep['sha256']);raw=archive.read(row['member'])
    require(digest(raw)==dep['sha256'],'retained verifier bytes differ')
    with tempfile.TemporaryDirectory(prefix='bendvy48-bundle-helper-') as td:
        p=Path(td)/'verify_helper.py';p.write_bytes(raw);spec=importlib.util.spec_from_file_location('retained_bundle_verify',p)
        helper=importlib.util.module_from_spec(spec);spec.loader.exec_module(helper);helper.VerificationError=VerificationError
        return helper

def verify_evidence(here,negative=None):
    delivery,owner,root=verify_local_selection(here)
    result=parse((here/'RESULT.json').read_bytes(),'RESULT.json');manifest=parse((here/'MANIFEST.json').read_bytes(),'MANIFEST.json')
    status='PASS_BOUNDED_CURRENT_BUNDLE_JS_NATIVE_DELIVERY'
    require(delivery['status']==result['status']==status and result['fullIssueAcceptance']=='OPEN' and result['performanceClaim'] is False,'delivery overstates scope')
    for filename,key in [('MANIFEST.json','manifest'),('RESULT.json','result'),('EVIDENCE.zip','archive')]:
        raw=(here/filename).read_bytes();require((len(raw),digest(raw))==(delivery[key]['bytes'],delivery[key]['sha256']),f'{filename} package hash differs')
    files=delivery['files'];verifier_rel=(DELIVERY_REL/'verify.py').as_posix();require(digest((here/'verify.py').read_bytes())==files[verifier_rel]['sha256'],'verifier drift')
    rows={x['sourcePath']:x for x in manifest['logicalPaths']};require(len(rows)==len(manifest['logicalPaths']),'duplicate full sourcePath')
    objects={x['sha256']:x for x in manifest['objects']};require(len(objects)==len(manifest['objects']),'duplicate archive object')
    for h,obj in objects.items():require(obj['member']==f'objects/{h}','noncanonical archive member')
    with zipfile.ZipFile(here/'EVIDENCE.zip','r') as archive:
        members=archive.namelist();require(len(members)==len(set(members)) and set(members)=={x['member'] for x in manifest['objects']},'archive/object membership differs')
        for item in manifest['logicalPaths']:
            canonical_external(item['sourcePath']);obj=objects.get(item['sha256']);require(obj is not None and (obj['member'],obj['bytes'])==(item['member'],item['bytes']),'logical path/object join differs')
        helper=load_helper(rows,result,archive)
        for h,obj in objects.items():
            with archive.open(obj['member'],'r') as stream:size,actual=helper.hash_stream(stream)
            require((size,actual)==(obj['bytes'],h),f'archive object corrupt: {h}')
        role_map={x['name']:x for x in result['roles']}
        require(set(role_map)=={'bundle-js','bundle-native'} and len(role_map)==2,'expected exactly JS and Native roles')
        verified={name:helper.verify_role(role,rows,manifest,archive) for name,role in role_map.items()}
        oracle=result['historicalOracle'];oracle_row=row_for(rows,oracle['rawPath'],oracle['sha256']);gzip_row=row_for(rows,oracle['gzipPath'])
        expected=(21569,'39fa741680b22d0f0448f9a8f6c3fbc5a3b874608e4608d3f923deedb349a1a6')
        require((oracle['bytes'],oracle['sha256'])==expected,'historical oracle identity differs')
        import gzip
        require(gzip.decompress(archive.read(gzip_row['member']))==archive.read(oracle_row['member']),'historical oracle gzip/raw bytes differ')
        for name,role in role_map.items():
            plan,receipt=verified[name];require((role['outputBytes'],role['outputSHA256'])==expected,f'{name} output metadata differs')
            require(plan['oracleSHA256']==oracle['sha256'] and plan['oracleBytes']==oracle['bytes'],'plan does not bind the historical oracle')
            consumer=next(c for c in receipt['commands'] if c['label']=='consumer');stdout_row=row_for(rows,consumer['stdout']['path'],consumer['stdout']['sha256'])
            stderr_row=row_for(rows,consumer['stderr']['path'],consumer['stderr']['sha256'])
            require(stderr_row['bytes']==0,'consumer stderr is not empty')
            helper.compare_gzip(archive,gzip_row,stdout_row,expected[0],expected[1],name)
        jsrole=role_map['bundle-js'];nativerole=role_map['bundle-native'];jsreceipt=verified['bundle-js'][1];nativereceipt=verified['bundle-native'][1]
        jsout=next(c for c in jsreceipt['commands'] if c['label']=='consumer')['stdout'];nativeout=next(c for c in nativereceipt['commands'] if c['label']=='consumer')['stdout']
        require(jsout['sha256']==nativeout['sha256']==expected[1],'JS/Native outputs differ')
        binding=result['sourceBinding'];checksrow=row_for(rows,binding['checksPath'],binding['checksSHA256']);checks=parse(archive.read(checksrow['member']),'source checks')
        require(len(checks['literalBendClosure'])==binding['literalClosureCount']==34,'literal source closure count differs')
        require([item['exitCode'] for item in checks['checks']]==[1,0],'source-check history differs from recorded failed-then-passing checks')
        importrow=row_for(rows,binding['importJoinPath'],binding['importJoinSHA256']);import_join=parse(archive.read(importrow['member']),'import join')
        require(len(import_join['files'])==12,'import-join inventory differs')
        adoptionrow=row_for(rows,binding['rootAdoptionReportPath'],binding['rootAdoptionReportSHA256']);adoption=parse(archive.read(adoptionrow['member']),'root adoption report')
        require(adoption.get('status')=='PASS' and len(adoption['bindings'])==34,'root adoption report does not bind all 34 sources')
        for item in adoption['bindings']:
            row_for(rows,item['source'],item['sha256']);row_for(rows,item['currentPath'],item['sha256'])
        root_stdout=row_for(rows,binding['currentRootCheckStdoutPath'],binding['currentRootCheckStdoutSHA256'])
        row_for(rows,binding['currentRootCheckStderrPath'],binding['currentRootCheckStderrSHA256'])
        require(b'ALL PROOFS CHECK' in archive.read(root_stdout['member']),'root entry source check is not recorded passing')
        old_manifest=checks['oldOracleManifest'];row_for(rows,old_manifest['path'],old_manifest['sha256'])
        if negative=='wrong-parent':
            helper.verify_stream(jsout,'consumer.stdout',jsrole['streamRoot'],rows,archive,path_override=nativeout['path'])
    return {'status':status,'roles':2,'bytesPerOutput':21569,'outputSHA256':'39fa741680b22d0f0448f9a8f6c3fbc5a3b874608e4608d3f923deedb349a1a6','literalSources':34,'rootAdoptionBindings':34,'performanceClaim':False,'fullIssueAcceptance':'OPEN'}

def selftest():
    verify_evidence(HERE)
    try:verify_evidence(HERE,'wrong-parent')
    except VerificationError:pass
    else:raise VerificationError('wrong-parent sourcePath was accepted')
    _,owner,root=verify_local_selection(HERE)
    with tempfile.TemporaryDirectory(prefix='bendvy48-bundle-relocation-') as td:
        moved=Path(td)
        for rel in owner['ownedPaths']:
            src=local_owned(root,rel);dst=moved/Path(rel);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)
        target=moved/Path(*DELIVERY_REL.parts);verify_local_selection(target)
        readme=moved/Path((DELIVERY_REL/'README.md').as_posix())
        with readme.open('ab') as stream:stream.write(b' drift')
        try:verify_local_selection(target)
        except VerificationError as exc:require('owned file drift' in str(exc),'relocation drift failed unexpectedly')
        else:raise VerificationError('relocated local drift accepted')
        try:local_owned(moved,'../outside')
        except VerificationError:pass
        else:raise VerificationError('path traversal accepted')
def main():
    try:
        if sys.argv[1:]==['--selftest']:selftest();print('PASS_CURRENT_BUNDLE_DELIVERY_SELFTEST')
        elif not sys.argv[1:]:print(json.dumps(verify_evidence(HERE),sort_keys=True))
        else:raise VerificationError('usage: verify.py [--selftest]')
        return 0
    except (VerificationError,KeyError,OSError,ValueError,zipfile.BadZipFile) as exc:
        print(f'FAIL_CURRENT_BUNDLE_DELIVERY: {exc}',file=sys.stderr);return 1
if __name__=='__main__':raise SystemExit(main())
