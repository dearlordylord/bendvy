"""Independent full source model; no execution-output input."""
import copy,importlib.util,json,gzip,hashlib
from pathlib import Path
HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('core_model',HERE.parent/'expected.py')
M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
def capacity(count=65537):
    # Same Wide.application used by lifecycle, with three successful initial
    # reads, then actual self failure plus count distinct missing targets.
    value=copy.deepcopy(M.lifecycle()['activatedSkip']['final']['value'])
    value['positions'][2]['cursor']=6 # ordinary success, not lifecycle.skip
    retained=[M.failure(2,target) for target in range(1000+max(0,count-65536),1000+count)]
    dropped=5 if count>65536 else 0
    alpha=M.failure(1,1)
    beta=M.reading(2,retained);beta['lagged']=2<dropped
    bothbeta=M.reading(2,retained);bothbeta['lagged']=3<dropped
    value['deliveries']=[[M.reading(1,[])],[M.reading(2,[])],[M.reading(1,[]),M.reading(2,[])],[M.reading(1,[alpha])],[beta],[M.reading(1,[alpha]),bothbeta]]
    value['domains']=[M.domain(1,[M.batch(5,[alpha])],[3,1],normalized=True),M.domain(2,[M.batch(5,[v]) for v in retained],[3,2],dropped,normalized=True)]
    for reg in value['registrations']:
        reg['access']={'alpha':['Parent:read'],'beta':['ParentB:read'],'both':['Parent:read','ParentB:read']}[reg['name']]
    return M.some(value)
def expected(count=65537):
    result=json.loads((HERE.parent/'declaration-adoption-v1/expected.json').read_text())
    for name in ('alpha','beta'): result['result']['value'][name]['capacity']=capacity(count)
    return result
if __name__=='__main__':
    digest=hashlib.sha256();size=0
    with gzip.GzipFile(filename='',mode='wb',fileobj=(HERE/'expected.json.gz').open('wb'),mtime=0) as out:
        for part in json.JSONEncoder(separators=(',',':'),ensure_ascii=False).iterencode(expected()):
            raw=part.encode();out.write(raw);digest.update(raw);size+=len(raw)
        out.write(b'\n');digest.update(b'\n');size+=1
    print(size,digest.hexdigest())
