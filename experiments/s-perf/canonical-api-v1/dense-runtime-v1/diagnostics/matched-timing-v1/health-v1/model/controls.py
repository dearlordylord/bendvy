"""Finite complete-transport sensitivity controls; no production imports or execution."""
import copy,json
from pathlib import Path
from pilot_oracle import expected_common,natural,sized

def access(value,encode,missing=False):
    return [0] if missing else [1] if value is None else [2,*encode(value)]
def encode(final,audits,statuses):
    rows=sized(final['rows'],lambda r:natural(r['rawId'])+access(r['main'],lambda v:[*v['levels'],v['reserve'],v['class']])+access(r['aux'],lambda v:[*v['layers'],v['grade']])+access(r['flag'],lambda v:[v['group']]))
    return rows+[*final['ledger']['totals'],final['ledger']['epoch']]+sized(audits,lambda a:sized(a['values'],lambda x:[x])+[a['readsum']]+natural(a['updated']))+sized(statuses,lambda x:x)
def run():
    cells,fold,final,audits=expected_common();statuses=[[0] for _ in audits]
    assert encode(final,audits,statuses)==cells
    cases=[]
    def check(label,change):
        f,a,s=copy.deepcopy((final,audits,statuses));change(f,a,s)
        altered=encode(f,a,s);assert altered!=cells
        # Full validation rejects even when an unchanged forcing fold is transported.
        record={'tuple':altered,'fold':fold};assert record['tuple']!=cells
        cases.append(label)
    for key in ['reserve','class']:
        check(key,lambda f,a,s,key=key:f['rows'][0]['main'].__setitem__(key,f['rows'][0]['main'][key]+1))
    check('levels-nonfirst',lambda f,a,s:f['rows'][0]['main']['levels'].__setitem__(3,999))
    check('layers-nonfirst',lambda f,a,s:f['rows'][0]['aux']['layers'].__setitem__(2,999))
    check('grade',lambda f,a,s:f['rows'][0]['aux'].__setitem__('grade',999))
    check('group',lambda f,a,s:f['rows'][1]['flag'].__setitem__('group',999))
    check('ledger-tail',lambda f,a,s:f['ledger']['totals'].__setitem__(3,999))
    check('ledger-epoch',lambda f,a,s:f['ledger'].__setitem__('epoch',999))
    check('raw-id',lambda f,a,s:f['rows'][0].__setitem__('rawId',999))
    check('row-order',lambda f,a,s:f['rows'].reverse())
    check('audit-value',lambda f,a,s:a[0]['values'].__setitem__(1,999))
    check('audit-sum',lambda f,a,s:a[0].__setitem__('readsum',999))
    check('audit-count',lambda f,a,s:a[0].__setitem__('updated',999))
    check('audit-order',lambda f,a,s:a.reverse())
    check('status',lambda f,a,s:s.__setitem__(0,[2,99]))
    assert len({tuple(access(None,lambda x:[x],missing=True)),tuple(access(None,lambda x:[x])),tuple(access(7,lambda x:[x]))})==3
    return {'status':'PASS','finiteControls':cases+['Missing/Absent/Found-distinct'],'tupleValues':len(cells),'scope':'Finite model/complete-transport sensitivity, not subject execution or universal proof'}
if __name__=='__main__':print(json.dumps(run(),indent=2))
