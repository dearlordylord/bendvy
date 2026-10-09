"""Source-derived additive correction of the final TS JSON wire observation.

Never reads subject output. Existing clone() markers stay explicit; only the
un-cloned top-level undefined target is omitted by plain JSON.stringify.
"""
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
PRIOR=HERE/'expected.py'
assert hashlib.sha256(PRIOR.read_bytes()).hexdigest()=='292135ac8679d121dd17451c08381135d383691f85b44a1f6c56c1e3c9d039df'
model={'__name__':'prior_independent_source_model','__file__':str(PRIOR)}
exec(compile(PRIOR.read_bytes(),str(PRIOR),'exec'),model)

def expected():
    rows=model['expected']()['ts']
    omissions=[]
    for index,row in enumerate(rows):
        trace=row['value']['ts']
        if trace['operation']=='spawn' and trace['checked']['ok'] is False:
            assert row['$']=='Workshop' and trace['name'] in ('lateInvalid','nestedMissing')
            assert trace['target']=={'undefined':True}
            del trace['target']
            omissions.append(index)
    assert omissions==[11,15] and len(rows)==32
    return rows

if __name__=='__main__':
    rows=expected()
    (HERE/'ts-expected-v2.json').write_text(json.dumps(rows,indent=2)+'\n')
    (HERE/'ts-expected-v2.stdout').write_text(json.dumps(rows,separators=(',',':'),ensure_ascii=False)+'\n')
