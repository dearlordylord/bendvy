"""No-child complete #42/#43 source and retained finite composition join."""
from pathlib import Path
import json,gzip,hashlib,importlib.util,sys
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
WORKER42=HERE.parents[4]
WORKER43=Path('/workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current')
MASTER=Path('/workspace/formal-proofs/bendvy')
ADOPTION=WORKER43/'experiments/public-relation-readers/current-adoption-v1/declaration-adoption-v1'
def sha(path):
 path=Path(path);assert path.is_file() and not path.is_symlink();return hashlib.sha256(path.read_bytes()).hexdigest()
def packed(path):return gzip.decompress(Path(path).read_bytes())
def main():
 closure=json.loads((ADOPTION/'SOURCE-CLOSURE.json').read_text());sources=closure['sourceSHA256'];canonical={}
 assert len(sources)==39
 for name,digest in sources.items():
  path=Path(name);assert sha(path)==digest
  if path.is_relative_to(WORKER43/'src/ecs'):
   relative=path.relative_to(WORKER43);assert sha(WORKER42/relative)==digest and sha(MASTER/relative)==digest;canonical[str(relative)]=digest
 assert len(canonical)==18
 result=json.loads((ADOPTION/'evidence-v1/RESULT.json').read_text());cohorts={};guards=0
 for role,row in result['cohorts'].items():
  mutation,backend=role.rsplit('-',1);label={'positive':'positive','wrong-reader-advance':'wrong-reader-advance','premature-publication':'premature-publication'}[mutation];directory=ADOPTION/'evidence-v1'/label/backend;manifest=json.loads((directory/'MANIFEST.json').read_text())
  members={}
  for member in manifest['members']:
   path=directory/member['gzip'];assert sha(path)==member['gzipSHA256'];raw=packed(path);assert len(raw)==member['bytes'] and hashlib.sha256(raw).hexdigest()==member['sha256'];members[member['name']]=raw
  plan=json.loads(members['plan.json']);receipt=json.loads(members['receipt.json']);assert hashlib.sha256(members['plan.json']).hexdigest()==row['planSHA256']==receipt['planSHA256'];assert row['status']=='DEVELOPMENT_PASS'
  assert all(command['exit']==0 and command['failure'] is None for command in receipt['commands'])
  raw=members['consumer.stdout'];assert len(raw)==row['stdoutBytes'] and hashlib.sha256(raw).hexdigest()==row['stdoutSHA256'];assert members['consumer.stderr']==b''
  for guard in receipt['guards']:
   guardraw=members[Path(guard['path']).name];assert hashlib.sha256(guardraw).hexdigest()==guard['sha256'];assert json.loads(guardraw)['unchanged'] is True;guards+=1
  transportpaths=[Path(name) for name in plan['pins'] if name.endswith('/transport-v1/transport.py')];assert len(transportpaths)==1;transportpath=transportpaths[0];assert sha(transportpath)==plan['pins'][str(transportpath)]
  inventory=json.loads(Path(plan['constructorInventory']).read_text());term=inventory['termParser'];assert sha(term['path'])==term['sha256']
  spec=importlib.util.spec_from_file_location('readonly_transport',transportpath);transport=importlib.util.module_from_spec(spec);spec.loader.exec_module(transport);current=transport.Transport(plan['entrypoint']);assert current.inventory()==inventory
  oracle=Path(plan['oracle']).read_bytes();assert hashlib.sha256(oracle).hexdigest()==plan['expectedSHA256']==row['wholeOracleSHA256'];observed=current.normalize(raw.decode());transport.TERM.strict_equal(observed,json.loads(oracle))
  cohorts[role]={'planSHA256':row['planSHA256'],'wholeOracleSHA256':row['wholeOracleSHA256'],'wholeStdoutSHA256':row['stdoutSHA256'],'wholeStdoutBytes':row['stdoutBytes'],'completeSourceDerivedObservation':True,'serializedGuards':len(receipt['guards']),'sourceInventoryFiles':len(inventory['sourceSHA256']),'baselineRejected':row['wholeBaselineRejected']}
 for mutation in ['positive','wrong-reader-advance','premature-publication']:
  assert cohorts[mutation+'-js']['wholeStdoutSHA256']==cohorts[mutation+'-native']['wholeStdoutSHA256']
 positiveplan=json.loads(packed(ADOPTION/'evidence-v1/positive/js/plan.json.gz'));whole=json.loads(Path(positiveplan['oracle']).read_bytes())['result']['value'];coverage={}
 for schema in ['alpha','beta']:
  report=whole[schema];retry=report['retry']['value'];foreign=report['foreign']['value'];assert len(retry['deliveries'])==8
  assert [x['name'] for x in retry['registrations']]==['slow','fast'];assert all(x['access']==['Parent:read'] for x in retry['registrations']);assert retry['returned']==[] and retry['events']==[] and retry['pendingCount']==0
  failed=retry['deliveries'][5];retried=retry['deliveries'][6];assert failed['who']=='slow' and failed['result']==77 and retried['who']=='slow' and retried['result']==0
  cursor=lambda delivery,who:next(p['cursor'] for p in delivery['positions'] if p['id']==who)
  assert cursor(failed,2)==7 and cursor(retried,2)==11 and cursor(failed,1)==cursor(retried,1)==9
  assert foreign['status']['$']=='MissingEntity' and foreign['before']==foreign['after']==1
  assert retry['left']==[11,12] and retry['right']==[21,22] and retry['baseline']==[301,302] and retry['fastPrivate']==[101,102] and retry['slowPrivate']==[201,202]
  coverage[schema]={'independentRegisteredReaders':['fast','slow'],'failedReaderCode':77,'slowCursorOnFailure':7,'slowCursorAfterRetry':11,'unaffectedFastCursor':9,'foreignQueueStatus':foreign['status']['$'],'foreignQueueBeforeAfter':[1,1],'allAffineOwnerObservationsRetained':True}
 output={'scope':'Finite current composition source/retained observation join only, not new execution/public promotion/full43capacity/#28/performance','sourceFiles':39,'canonical18IdenticalAcross43Worker42AndMaster':canonical,'cohorts':cohorts,'serializedGuards':guards,'coverage':coverage,'compilerChildren':0}
 print(json.dumps(output,indent=2))
if __name__=='__main__':main()
