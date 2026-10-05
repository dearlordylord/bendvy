#!/usr/bin/env python3
"""Read-only proposed scope audit, not manifest acceptance or Bend checking.

CLI requires --repo, --proposal and both --candidate logical/path bindings.
Proposal JSON: {"files": {logical: {"helpers": [exact def headers],
"types": [exact full private type declarations]}}}. No prefixes/wildcards.
Only exact supplied reviewed additions are allowed; public declarations/imports
remain baseline56b72f6. This structural guard is not a parser/kernel proof or
proof that a named helper is private; independent review remains mandatory.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location('segment_scope', HERE.parent/'segment-run.py')
_segment = importlib.util.module_from_spec(_spec);_spec.loader.exec_module(_segment)
FILES = tuple(_segment.EDITABLE)
BASELINE = '56b72f6'


def sha(data):return hashlib.sha256(data).hexdigest()


def confined(path):
    path = Path(path)
    if '..' in path.parts or not path.is_absolute() or path.resolve() != path or path.is_symlink():
        raise ValueError('symlink/traversal/nonabsolute path rejected')
    if not path.is_file():raise ValueError('regular existing file required')
    return path


def named(declarations, kind):
    result = {}
    for declaration in declarations:
        declaration = declaration.strip()
        match = re.match(r'(?:def|type)\s+([A-Za-z_][A-Za-z0-9_.]*)\b', declaration)
        if not match or match[1] in result:raise ValueError('invalid/duplicate '+kind+' name')
        result[match[1]] = declaration
    return result


def audit_text(original, candidate, allowed):
    if not isinstance(allowed, dict) or set(allowed) != {'helpers','types'}:raise ValueError('exact helpers/types allowlist required')
    for k in allowed:
        if not isinstance(allowed[k],list) or any(not isinstance(x,str) or '*' in x for x in allowed[k]):raise ValueError('literal declaration allowlist required')
    before = _segment.signatures(original);after = _segment.signatures(candidate)
    if before['imports'] != after['imports']:raise ValueError('public imports changed')
    for key,kind in [('definitions','helpers'),('types','types')]:
        old = named(before[key],key);new = named(after[key],key);extra = named(allowed[kind],kind)
        if set(old)&set(extra):raise ValueError('allowlist cannot replace baseline declaration')
        if any(new.get(k)!=v for k,v in old.items()):raise ValueError('baseline '+key+' changed')
        if {k:v for k,v in new.items() if k not in old} != extra:raise ValueError('added '+key+' differs from exact allowlist')
        # Addition cannot reorder original public declarations.
        if [k for k in new if k in old] != list(old):raise ValueError('baseline declaration order changed')
    return {'status':'PROPOSED_SCOPE_PASS','candidateSha256':sha(candidate.encode()),'baselineSha256':sha(original.encode())}


def audit(repo, proposal_path, candidates):
    repo = Path(repo)
    if not repo.is_absolute() or '..' in repo.parts or repo.resolve()!=repo:raise ValueError('repository symlink/traversal rejected')
    proposal_path = confined(proposal_path);raw = proposal_path.read_bytes();proposal=json.loads(raw)
    if not isinstance(proposal,dict) or set(proposal)!={'files'} or set(proposal['files'])!=set(FILES) or set(candidates)!=set(FILES):raise ValueError('exact two candidate/proposal bindings required')
    result={'baseline':BASELINE,'proposalSha256':sha(raw),'auditSha256':sha(Path(__file__).read_bytes()),'signatureImplementationSha256':sha((HERE.parent/'segment-run.py').read_bytes()),'accepted':False,'files':{}}
    for logical in FILES:
        path=confined(candidates[logical]);candidate=path.read_text();original=subprocess.check_output(['git','show',BASELINE+':'+logical],cwd=repo,timeout=5).decode()
        result['files'][logical]=dict(audit_text(original,candidate,proposal['files'][logical]),sourcePath=str(path))
    result['status']='PROPOSED_SCOPE_PASS';return result


def synthetic():
    baseline='import Base\ntype Public:\n  Public{x: U32}\ndef public(+x: U32) -> U32:\n  x\n'
    helper='def private_helper(+x: U32) -> U32:';state='type StructIdxState:\n  StructIdxState{slot: U32}'
    candidate=baseline.replace('def public',state+'\ndef public')+helper+'\n  x\n';allowed={'helpers':[helper],'types':[state]}
    cases={'positive':(candidate,allowed),'public-header-change':(candidate.replace('def public(+x: U32)','def public(+x: U64)'),allowed),'new-helper-unlisted':(candidate+ 'def other(+x: U32) -> U32:\n  x\n',allowed),'unsafe':(candidate+'  @unsafe\n',allowed),'public-type-change':(candidate.replace('Public{x: U32}','Public{x: U64}'),allowed),'top-level-control':(candidate+'run arbitrary\n',allowed),'private-signature-change':(candidate.replace(helper,helper.replace('U32','U64')),allowed)}
    receipt={'syntheticOnly':True,'accepted':False,'benchmarkExecuted':False,'controls':{}}
    for name,(text,allow) in cases.items():
        try:record=audit_text(baseline,text,allow)
        except ValueError as exc:record={'status':'REJECTED','reason':str(exc)}
        assert (record['status']=='PROPOSED_SCOPE_PASS')==(name=='positive');receipt['controls'][name]=record
    with tempfile.TemporaryDirectory(prefix='parity-scope-control-') as directory:
        root=Path(directory);target=root/'target';target.write_text(candidate);link=root/'link';link.symlink_to(target)
        for name,path in [('symlink',link),('traversal',root/'..'/root.name/'target')]:
            try:confined(path)
            except ValueError as exc:receipt['controls'][name]={'status':'REJECTED','reason':str(exc)}
            else:raise AssertionError(name+' survived')
    receipt['limitations']=__doc__;return receipt


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--synthetic',action='store_true');parser.add_argument('--repo');parser.add_argument('--proposal');parser.add_argument('--candidate',action='append',default=[]);args=parser.parse_args()
    if args.synthetic:
        if args.repo or args.proposal or args.candidate:parser.error('synthetic mode is separate')
        (HERE/'scope-synthetic-receipt.json').write_text(json.dumps(synthetic(),indent=2)+'\n');print('PASS synthetic scope controls; proposal only')
    else:
        if not args.repo or not args.proposal or len(args.candidate)!=2:parser.error('explicit repository, proposal and two logical=absolute candidate bindings required')
        bindings={}
        for binding in args.candidate:
            logical,path=binding.split('=',1)
            if logical in bindings:parser.error('duplicate candidate binding')
            bindings[logical]=path
        try:print(json.dumps(audit(args.repo,args.proposal,bindings),indent=2))
        except (ValueError,OSError,subprocess.SubprocessError) as exc:parser.exit(1,'REJECTED: '+str(exc)+'\n')
