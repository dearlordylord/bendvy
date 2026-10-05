#!/usr/bin/env python3
"""Isolated single-file semantic candidate, never changes the running packet."""
import argparse,hashlib,json,pathlib,shutil
HERE=pathlib.Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--baseline',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args()
 assert a.baseline.is_absolute() and a.output.is_absolute() and not a.output.exists()
 assert not a.baseline.is_symlink()
 for f in a.baseline.rglob('*'):assert not f.is_symlink(),f
 shutil.copytree(a.baseline,a.output)
 target=pathlib.Path('experiments/s-integrate/uncached-payload.bend')
 assert sha(a.baseline/target)==sha(HERE/'baseline-payload.bend')
 (a.output/target).write_bytes((HERE/'uncached-payload.bend').read_bytes())
 original={str(f.relative_to(a.baseline)):sha(f) for f in a.baseline.rglob('*') if f.is_file()}
 after={str(f.relative_to(a.output)):sha(f) for f in a.output.rglob('*') if f.is_file()}
 changed=[k for k in original if original[k]!=after[k]];assert changed==[str(target)],changed
 metadata=a.output/'overlay.json';j=json.loads(metadata.read_text());j['sources'][str(target)]=sha(a.output/target);j['derivedCandidate']='Native raw intrinsic semantic candidate; other descriptive metadata historical';metadata.write_text(json.dumps(j,indent=2)+'\n')
 receipt={'baseline':str(a.baseline),'output':str(a.output),'changedFiles':changed,'before':original,'after':after,'metadata':'overlay.json source manifest refreshed; other descriptive recipe metadata historical', 'overlaySha256':sha(metadata)}
 (HERE/'materialization.json').write_text(json.dumps(receipt,indent=2)+'\n')
if __name__=='__main__':main()
