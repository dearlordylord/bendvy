"""Prepare only the next cache/loader metadata stage; no child or tree scan."""
import gzip
import hashlib
import json
from pathlib import Path
import types
HERE=Path(__file__).resolve().parent
sha=lambda raw:hashlib.sha256(raw).hexdigest()
def prepare():
    evidence=HERE/'metadata-evidence-v4';manifest=json.loads((evidence/'MANIFEST.json').read_text());raws={}
    for row in manifest['members']:
        packed=(evidence/row['archive']).read_bytes();assert sha(packed)==row['archiveSHA256'];raw=gzip.decompress(packed);assert sha(raw)==row['sha256'];raws[row['source']]=raw
    oldpath='/tmp/bendvy63-loader-metadata-plan-v4.json';assert sha(raws[oldpath])=='27830e5ea5d1b81fa6d02a65e1e0ce2f1c3d19241a9354714f9694d931c2824f'
    old=json.loads(raws[oldpath]);pins=dict(old['pins'])
    # Reuse exact executed root collector/helpers, not older worker modules/pyc.
    for path,digest in pins.items():assert sha(Path(path).read_bytes())==digest,('Prior input changed',path)
    helper=Path('/workspace/formal-proofs/bendvy/experiments/public-simulation/delivery-v1/prepare-metadata.py')
    module=types.ModuleType('actual_metadata_preparation');module.__file__=str(helper)
    source=helper.read_bytes();assert sha(source)==pins[str(helper)];exec(compile(source,str(helper),'exec'),module.__dict__)
    output=Path('/tmp/bendvy63-loader-paths-v5');assert not output.exists()and not output.is_symlink()
    ldconfig=Path('/sbin/ldconfig');resolved=ldconfig.resolve(strict=True);assert resolved.is_file();pins[str(resolved)]=sha(resolved.read_bytes())
    pins[str(Path(__file__).resolve())]=sha(Path(__file__).read_bytes())
    for file in ['MANIFEST.json','LOADER-SEARCH.json','verify.py']:
        path=evidence/file;pins[str(path.resolve())]=sha(path.read_bytes())
    taskset=old['commands'][0]['argv'][0];loader=old['commands'][-1]['argv'][3]
    commands=[]
    def command(label,args):
        commands.append({'label':label,'argv':[taskset,'-c','5',*args],'capSeconds':5,'stdout':str(output/(label+'.stdout')),'stderr':str(output/(label+'.stderr'))})
    command('ldconfig-cache',[str(resolved),'-p'])
    for subject in old['commands']:
        if subject['label']in ['loader','loader-help']:continue
        command(subject['label']+'-loader-list',[loader,'--list',subject['argv'][-1]])
    # Explicit sanitized plan mapping only; never inherited environment diagnostics.
    command('loader-auxv',[loader,'--list-diagnostics'])
    literals=old['namespaceLiterals']+[str(ldconfig),str(resolved)]
    namespace=module.namespace_state(literals)
    return {'scope':'Read-only current cache, declared-tool loader lists and sanitized auxiliary metadata; no target main or compiler workload',
      'status':'PREPARED_NOT_EXECUTED','outputRoot':str(output),'commands':commands,'pins':pins,
      'python':old['python'],'environment':old['environment'],'lock':old['lock'],
      'namespaceLiterals':literals,'namespace':namespace,
      'collector':'/workspace/formal-proofs/bendvy/experiments/public-simulation/delivery-v1/collect-metadata.py',
      'actualPriorPlanSHA256':sha(raws[oldpath]),'closedResolverQualified':False,
      'nextBoundary':'Review actual cache/loaded paths before naming transitive readelf targets; no search-directory recursive scan'}
if __name__=='__main__':print(json.dumps(prepare(),indent=2))
