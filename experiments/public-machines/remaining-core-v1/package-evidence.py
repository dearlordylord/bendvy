"""Lossless packaging of terminal captures; never executes a child."""
from pathlib import Path
import hashlib,json,zipfile
HERE=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def archive(name,folders):
    members=[]
    with zipfile.ZipFile(HERE/name,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
        for folder in folders:
            for p in sorted(folder.rglob('*')):
                if p.is_file():
                    data=p.read_bytes();n=str(p.relative_to(HERE));z.writestr(n,data)
                    members.append(dict(path=n,bytes=len(data),sha256=sha(data)))
    return dict(path=name,sha256=sha((HERE/name).read_bytes()),bytes=(HERE/name).stat().st_size,members=members)
def main():
    source=sorted(p for p in HERE.iterdir() if p.is_dir() and '-source' in p.name)
    runtime=sorted(p for p in HERE.iterdir() if p.is_dir() and ('-js-v' in p.name or '-native-v' in p.name))
    assert len(source)==15 and len(runtime)==10
    sources=[]
    for p in source:
        result=json.loads((p/'result.json').read_text());post=json.loads((p/'post.json').read_text())
        assert post['unchanged'] and result['failure'] is None
        expected=1 if p.name in [f'A-source{x:02d}' for x in range(1,9)] or p.name.startswith('negative-') else 0
        assert result['exit']==expected
        sources.append(dict(attempt=p.name,exit=result['exit'],failure=result['failure'],postUnchanged=True))
    outcomes=[];commands=guards=0
    for p in runtime:
        receipt=json.loads((p/'receipt.json').read_text());plan=json.loads((p/'plan.json').read_text())
        assert receipt['status'] in ('COMPLETE_CONSUMER_DEVELOPMENT_PASS','COMPLETE_MUTANT_DEVELOPMENT_PASS')
        assert all(c['exit']==0 and c['failure'] is None for c in receipt['commands'])
        if plan['subject']=='mutant':assert receipt['completeNormalBaselineRejected'] is True
        commands+=len(receipt['commands']);guards+=len(receipt['guards'])
        outcomes.append(dict(attempt=p.name,status=receipt['status'],role=plan['role'],subject=plan['subject'],planSHA256=sha((p/'plan.json').read_bytes()),wholeOracleSHA256=receipt['wholeOracleSHA256'],oracleBytes=plan['oracleBytes'],completeNormalBaselineRejected=receipt.get('completeNormalBaselineRejected',False)))
    data=dict(scope='bounded private comparator-aware queue candidate; full48 remains open',sourceAttempts=sources,runtimeOutcomes=outcomes,commands=commands,guards=guards,archives=[archive('source-evidence-v1.zip',source),archive('runtime-evidence-v1.zip',runtime)],failedInfrastructureAttempts=[dict(action='preparation-adapter --help',result='IndexError before child/capture; no source evidence changed')],modelsRuntimeDerived=False,sharedSourceEdited=False)
    (HERE/'EVIDENCE.json').write_text(json.dumps(data,indent=2)+'\n')
if __name__=='__main__':main()
