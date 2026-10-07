"""Portable raw receipt/log evidence only; no stage, target, ELF or environment."""
from pathlib import Path
import hashlib,io,json,tarfile
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
COHORTS={'normal':ROOT/'.artifacts/relations-public-trace-anchor-1791402105990165748','controls':ROOT/'.artifacts/relations-trace-forcing-controls-1791402115877298623','native':ROOT/'.artifacts/relations-public-trace-native-1791402236553880197'}
sha=lambda b:hashlib.sha256(b).hexdigest()
def main():
 out=HERE/'trace-evidence-v1';out.mkdir(exist_ok=True);assert not (out/'index.json').exists() and not (out/'objects.tar.gz').exists();files={};objects={};receipts={}
 for name,d in COHORTS.items():
  r=json.loads((d/'receipt.json').read_text());assert r['planSHA256']==sha((d/'plan.json').read_bytes());receipts[name]=r
  selected=[d/'receipt.json',d/'plan.json']
  for n,h in r['logs'].items():assert sha((d/n).read_bytes())==h;selected.append(d/n)
  if name=='native':
   selected.append(d/'prepare-receipt.json')
   for group in ['prepare-probes','execution-probes']:
    selected.extend(p for p in (d/group).iterdir() if p.suffix in ('.json','.stdout','.stderr'))
  for p in selected:
   assert p.name!='private-environment.json' and p.suffix in ('.json','.stdout','.stderr');key=name+'/'+str(p.relative_to(d));data=p.read_bytes();digest=sha(data);files[key]=digest;objects[digest]=data
 oracle=(ROOT/'experiments/public-relations/promotion-stage/application/next-version/v1/expected.json').read_bytes();digest=sha(oracle);files['oracle/expected.json']=digest;objects[digest]=oracle
 assert receipts['normal']['status']=='COMPLETE_PUBLIC_TRACE_ANCHOR_PASS_NOT_FAIR_TIMING_QUALIFIED';assert receipts['controls']['status']=='BOTH_JS_FORCING_BOUNDARY_FALSIFIERS_PASS_NO_TIMING_VERDICT';assert receipts['native']['status']=='COMPLETE30_NATIVE_TRACE_AND_BOTH_FORCING_FALSIFIERS_PASS_NO_TIMING_VERDICT'
 with tarfile.open(out/'objects.tar.gz','w:gz') as t:
  for digest,data in sorted(objects.items()):
   info=tarfile.TarInfo(digest);info.size=len(data);info.mtime=0;info.mode=0o644;t.addfile(info,io.BytesIO(data))
 (out/'index.json').write_text(json.dumps({'scope':'Finite full30 normal and two forcing falsifiers; source5/TS/JS/Native; no timing/scaling/core delivery','files':files,'objects':{k:len(v) for k,v in objects.items()},'archiveSHA256':sha((out/'objects.tar.gz').read_bytes()),'originalCohorts':{n:str(p) for n,p in COHORTS.items()},'excluded':'All private environments, generated code/binaries, source stages, caches and installed tool/library contents. Generated targets retained by hash only in original receipts.'},indent=2)+'\n');print(len(files),len(objects),(out/'objects.tar.gz').stat().st_size)
if __name__=='__main__':main()
