#!/usr/bin/env python3
import tempfile,pathlib,json,hashlib,sys
from replay import R,P,HERE
SUBJECTS={
 'duplicate-affine-list':('import Base\ndef duplicate(-C: Type,values: List<C>) -> List<C> & List<C>:\n  (values,values)\n','consumed more than once'),
 'undeclared-ledger-token':('import Base\nimport ./types.bend as T\ndef forbidden(-Owner: Type,get: Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>,owner: Owner) -> Owner & T.Access<T.PositionView>:\n  get(owner,T.MotionLedgerToken{})\n','T.PositionToken'),
 'write-through-read-function':('import Base\nimport ./types.bend as T\ndef write(-Owner: Type,set: Owner -> T.PositionToken -> U32 -> Owner,owner: Owner) -> Owner:\n  set(owner,T.PositionToken{},9)\ndef forbidden(-Owner: Type,get: Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>,owner: Owner) -> Owner:\n  write(Owner,get,owner)\n','expected'),
 'cross-schema-tx':('import Base\nimport ./types.bend as T\nimport ./storage.bend as S\nimport ./transaction.bend as X\nimport ./transaction-dispatch-adapters.bend as A\ndef wrong(owner: X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>) -> X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & T.Access<T.VitalsView>:\n  A.health_read_main(owner,T.VitalsToken{})\n','T.HealthSchema'),
 'opaque-meter-reconstruction':('import Base\nimport ./transaction.bend as X\ndef steal(-Owner: Type,owner: Owner) -> String:\n  match owner:\n    case X.Tx{_,_,_,_,_,_,meter}: meter\n','expected'),
}
def main():
 evidence=[]
 with tempfile.TemporaryDirectory(prefix='prep22-tx-negatives-') as directory:
  dest=R.materialize(pathlib.Path(directory));P.prepare(dest)
  for name,(text,needle) in SUBJECTS.items():
   entry=dest/(name+'.bend');entry.write_text(text)
   out,err=R.run(['taskset','-c','8','bend',entry,'--check-only'],ok=1);assert needle in out+err and 'SOME PROOFS FAIL' in out+err
   evidence.append({'name':name,'status':'REJECTED','source':text,'sourceSha256':hashlib.sha256(text.encode()).hexdigest(),'checker':out+err})
 (HERE/'negative-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n');print('PASS',len(evidence))
if __name__=='__main__':sys.exit(main())
