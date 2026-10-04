#!/usr/bin/env python3
"""Compile wrong private metric subjects; require actual oracle rejection and intact public output."""
import pathlib,tempfile,json,hashlib,sys
from replay import R,P,check,metrics,HERE

def main():
 e=[]
 with tempfile.TemporaryDirectory(prefix='prep22-tx-mutants-') as directory:
  root=pathlib.Path(directory);dest=R.materialize(root);P.prepare(dest);p=dest/'transaction.bend';original=p.read_text()
  changes={'commands-zero':('U32.show(count)','U32.show(0)'), 'events-zero':('Nat.show(List.length(&2,U32,pings))','Nat.show(0n)'), 'inverse-zero':('Nat.show(List.length(&2,Inverse<H>,undo))','Nat.show(0n)'), 'marks-zero':('Nat.show(List.length(&2,H,marks))','Nat.show(0n)'), 'unwind-zero':('Nat.show(List.length(&2,Inverse<H>,rest))','Nat.show(0n)'), 'mark-drain-zero':('Nat.show(List.length(&2,S.Handle<Schema>,rest))','Nat.show(0n)')}
  baseline=None
  for name,(old,new) in changes.items():
   assert old in original;p.write_text(original.replace(old,new));entry=dest/'measurement-failure-driver.bend';result={'name':name,'sourceSha256':hashlib.sha256(p.read_bytes()).hexdigest()}
   try:
    assert 'ALL PROOFS CHECK' in ''.join(R.run(['taskset','-c','8','bend',entry,'--check-only']));js=root/(name+'.js');R.run(['taskset','-c','8','bend',entry,'-o',js],30);text=R.run(['taskset','-c','8','node',js,'0','64','64'])[0]
    public='\n'.join(l for l in text.splitlines() if not l.startswith(('txdiag:','FAILURE-TIMING:')))
    if baseline is None:
     p.write_text(original);clean=root/'clean.js';R.run(['taskset','-c','8','bend',entry,'-o',clean],30);base=R.run(['taskset','-c','8','node',clean,'0','64','64'])[0];baseline='\n'.join(l for l in base.splitlines() if not l.startswith(('txdiag:','FAILURE-TIMING:')))
    assert public==baseline,'public observations changed'
    main=json.loads((HERE/'evidence.json').read_text());oracle=next(c for c in main['cases'] if c['workload']=='failure' and c['schema']=='Motion' and c['count']==64)['backends']['JS'];assert oracle['status']=='PASS'
    assert hashlib.sha256(public.encode()).hexdigest()==oracle['publicSha256'],'different public baseline'
    result['generatedJsSha256']=hashlib.sha256(js.read_bytes()).hexdigest()
    try:check(metrics(text),'failure')
    except AssertionError as exc:result.update(status='DETECTED',oracleFailure=str(exc),publicTraceMatch=True)
    else:result.update(status='SURVIVED',publicTraceMatch=True)
   except Exception as exc:result.update(status='INVALID_OR_UNAVAILABLE',error=str(exc))
   e.append(result);print(name,result['status'],flush=True);(HERE/'mutation-evidence.json').write_text(json.dumps(e,indent=2)+'\n')
 return any(x['status']!='DETECTED' for x in e)
if __name__=='__main__':sys.exit(main())
