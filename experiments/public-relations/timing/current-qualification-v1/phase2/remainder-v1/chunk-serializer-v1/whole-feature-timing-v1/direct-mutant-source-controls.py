"""No-child exact consuming mutations and unchanged nine full counteroracles."""
from pathlib import Path
import gzip,json,hashlib
HERE=Path(__file__).resolve().parent

def main():
 base=(HERE/'driver-direct.bend').read_text();last=(HERE/'driver-direct-last-leaf.bend').read_text();moved=(HERE/'driver-direct-moved-walk.bend').read_text()
 assert last==(HERE/'driver-last-leaf.bend').read_text().replace('import ../serialize.bend as Serialize','import ../serialize-direct.bend as Serialize')
 assert last.count('Mutant.mutate(20n,trace)')==1
 expected=base.replace('IO.bind(Unit,Unit,Boundary.complete(nodes,characters,sum),_ => encoded(Serialize.encode(population,trace)))','encoded(Serialize.encode(population,trace))')
 expected=expected.replace('forced(Phase2Force.force(population,trace),population,trace)','IO.bind(Unit,Unit,Boundary.complete(0,0,0),_ => forced(Phase2Force.force(population,trace),population,trace))')
 assert moved==expected and moved.count('Boundary.complete(')==1 and moved.count('Phase2Force.force(population,trace)')==1
 manifest=json.loads((HERE/'prepared/manifest.json').read_text());assert len(manifest['cases'])==9
 for case in manifest['cases']:
  positive=gzip.decompress((HERE/'prepared'/case['oracle']).read_bytes());assert hashlib.sha256(positive).hexdigest()==case['sha256'];normal=json.loads(positive)
  counter=gzip.decompress((HERE/'prepared'/('last-leaf-'+case['oracle'])).read_bytes());changed=json.loads(counter)
  assert sum(len(w['records']) for w in normal['roots'])==30 and normal['roots'][-1]['records'][-1]['systemResult'] is None
  normal['roots'][-1]['records'][-1]['systemResult']=1;assert changed==normal and counter!=positive
 print(json.dumps({'sourceMutations':'PASS','fullNineIndependentOracleBindings':9,'governingAnchor':['depth','256','16','0'],'normalNineScopePreserved':True,'movedEffectNotExtraMarker':True,'notBendRuntime':True}))
if __name__=='__main__':main()
