#!/usr/bin/env python3
import hashlib,importlib.util,json,pathlib,shutil,tempfile
H=pathlib.Path(__file__).resolve().parent;ROOT=H.parents[2];sp=importlib.util.spec_from_file_location('R',ROOT/'experiments/s-perf/occupancy-run.py');R=importlib.util.module_from_spec(sp);sp.loader.exec_module(R)
import argparse
cli=argparse.ArgumentParser();cli.add_argument('--prepared',type=pathlib.Path,required=True);args=cli.parse_args();assert args.prepared.is_absolute() and args.prepared.resolve()==args.prepared
base=args.prepared/'experiments/s-integrate';pins=json.loads((H/'source-bindings.json').read_text())['variant'];assert all(hashlib.sha256((base/n).read_bytes()).hexdigest()==v for n,v in pins.items())
controls={'read-positive':('import Base\nimport ./types.bend as T\ndef use(~Owner:Type,get:Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>,owner:Owner) -> Owner & T.Access<T.PositionView>:\n  get(owner,T.PositionToken{})\n',0,'ALL PROOFS CHECK'),'cross-schema':('import Base\nimport ./types.bend as T\ndef bad(~Owner:Type,get:Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>,owner:Owner) -> Owner & T.Access<T.PositionView>:\n  get(owner,T.VitalsToken{})\n',1,'T.VitalsToken'),'read-write':('import Base\nimport ./types.bend as T\nimport ./held-adapter.bend as HA\ndef bad(~Owner:Type,get:Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>,owner:Owner) -> Owner:\n  HA.motion_set_main0(owner,T.PositionToken{},0)\n',1,'bad~Owner'),'duplicate':('import Base\nimport ./types.bend as T\nimport ./cache.bend as C\ndef bad(owner:C.Cache<T.Vitals,T.VitalsView>) -> C.Cache<T.Vitals,T.VitalsView> & C.Cache<T.Vitals,T.VitalsView>:\n  (owner,owner)\n',1,'consumed more than once'),'reconstruct':('import Base\nimport ./types.bend as T\ndef bad(~Owner:Type,owner:Owner) -> Owner:\n  T.Position{[0:U32^2n],0}\n',1,'bad~Owner')}
e={'checkerLimitSeconds':5,'controls':{},'scope':'finite opaque-provider and affine negative controls; no universal authority proof'}
with tempfile.TemporaryDirectory(prefix='native-columns-negatives-') as td:
 root=pathlib.Path(td);shutil.copytree(base,root/'core')
 for name,(source,status,needle) in controls.items():
  p=root/'core'/f'{name}.bend';p.write_text(source);out=''.join(R.run(['taskset','-c','8','bend',p,'--check-only'],ok=status));assert needle in out;e['controls'][name]={'source':source,'sourceSha256':hashlib.sha256(source.encode()).hexdigest(),'exit':status,'output':out}
e['status']='FINITE_NEGATIVES_PASS';(H/'negative-evidence.json').write_text(json.dumps(e,indent=2)+'\n');print(e['status'])
