#!/usr/bin/env python3
"""Single Native module override, source-only materialization."""
import argparse,hashlib,importlib.util,json,pathlib,shutil
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--baseline',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();assert a.baseline.is_absolute() and a.output.is_absolute() and not a.output.exists()
 for f in [a.baseline,*a.baseline.rglob('*'),a.output,*a.output.parents]:assert not f.is_symlink(),f
 name='experiments/s-integrate/cached-payload.bend';assert sha(a.baseline/name)==sha(HERE/'baseline-cached-payload.bend')
 spec=importlib.util.spec_from_file_location('sig',ROOT/'experiments/s-prep/segment-run.py');sig=importlib.util.module_from_spec(spec);spec.loader.exec_module(sig);assert sig.signatures((a.baseline/name).read_text())==sig.signatures((HERE/'cached-payload.bend').read_text())
 before=json.loads((a.baseline/'overlay.json').read_text());assert all(sha(a.baseline/n)==h for n,h in before['sources'].items())
 shutil.copytree(a.baseline,a.output);(a.output/name).write_bytes((HERE/'cached-payload.bend').read_bytes());after=json.loads(json.dumps(before));after['sources'][name]=sha(a.output/name);changed=[n for n in after['sources'] if after['sources'][n]!=before['sources'][n]];assert changed==[name]
 after['derivedCandidate']='Direct Native nominal cached getters; other descriptive metadata historical';(a.output/'overlay.json').write_text(json.dumps(after,indent=2)+'\n')
 receipt={'baseline':str(a.baseline),'output':str(a.output),'changedSource':name,'sha256':sha(a.output/name),'beforeSources':before['sources'],'afterSources':after['sources'],'overlaySha256':sha(a.output/'overlay.json'),'publicSignaturesTypesImportsExact':True}
 (HERE/'materialization.json').write_text(json.dumps(receipt,indent=2)+'\n')
if __name__=='__main__':main()
