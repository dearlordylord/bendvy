"""Finite static descriptor evidence; verification launches no child."""
from pathlib import Path
import argparse,hashlib,json
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
ROLES={'reader-source':'1791430827586471528','lens-routing-source':'1791430863197059208','metadata-order-source':'1791430948164463067','retainer-source':'1791430976698082937','reader-cli':'1791431327981771305','lens-routing-cli':'1791431338936435872','metadata-order-cli':'1791431349581375867','retainer-cli':'1791431356069652545','old-reader-proposal':'1791431306738381605'}
OUT=HERE/'core-adoption-controls-cli-evidence-v1'
def sha(data):return hashlib.sha256(data).hexdigest()
def prepare():
 assert not OUT.exists();OUT.mkdir();objects=OUT/'objects';objects.mkdir();records={}
 def add(key,path):
  data=path.read_bytes();digest=sha(data);target=objects/digest
  if not target.exists():target.write_bytes(data)
  records[key]=digest
 for role,stamp in ROLES.items():
  base=ROOT/'.artifacts'/('inspect54-metadata-source-'+stamp);plan=json.loads((base/'plan.json').read_text());add(role+'/plan.json',base/'plan.json');index=Path(plan['sourceArchive']);add(role+'/source-archive.json',index)
  for source,record in json.loads(index.read_text()).items():
   obj=Path(record['object']);assert sha(obj.read_bytes())==record['sha256'];add(role+'/archived-source/'+source,obj)
  if (base/'receipt.json').exists():
   receipt=json.loads((base/'receipt.json').read_text());add(role+'/receipt.json',base/'receipt.json')
   for name,digest in receipt['logs'].items():assert sha((base/name).read_bytes())==digest;add(role+'/'+name,base/name)
 add('model.json',HERE/'core-adoption-proposal-v1/remaining-controls-v1/MODELS-AND-JOINS.json')
 (OUT/'index.json').write_text(json.dumps({'format':1,'records':records,'roles':ROLES,'scope':'Current-root copied-core compilingreader/lens/order mutations and actualCLI complete75/8/8 independentdefect oracles with12/4/8 semanticdifferences, actualretainer20 genuinefailed/skipped/success/disposal completeoracle. Oldunexecutedreaderproposal preservedhistory. No emittedJSNative/proof/generaltruth/adoption/full54; privateenv/tools/binaries excluded.'},indent=2)+'\n');print(sha((OUT/'index.json').read_bytes()))
def verify():
 index=json.loads((OUT/'index.json').read_text());records=index['records']
 def raw(key):return (OUT/'objects'/records[key]).read_bytes()
 def data(key):return json.loads(raw(key))
 for key,digest in records.items():assert sha(raw(key))==digest,key
 for role in ROLES:
  plan=data(role+'/plan.json');assert sha(raw(role+'/source-archive.json'))==plan['sourceArchiveSHA256']
  for source,record in data(role+'/source-archive.json').items():assert sha(raw(role+'/archived-source/'+source))==record['sha256']
  if role+'/receipt.json' in records:
   receipt=data(role+'/receipt.json');assert receipt['planSHA256']==sha(raw(role+'/plan.json'))
   for name,digest in receipt['logs'].items():assert sha(raw(role+'/'+name))==digest
 assert 'old-reader-proposal/receipt.json' not in records
 model=data('model.json');assert sha(raw('model.json'))=='06b17fa8043cd06614d780a638b64f0b33f900afe3ad6c7c44e4a5563a834ef9'
 for subject,count in [('reader',75),('lens-routing',8),('metadata-order',8),('retainer',20)]:
  for suffix in ['source','cli']:
   r=data(subject+'-'+suffix+'/receipt.json');assert len(r['commands'])==1 and r['commands'][0]['exit']==0 and r['commands'][0]['failure'] is None
  plan=data(subject+'-cli/plan.json');join=plan['sourceJoin'];assert join['planSHA256']==sha(raw(subject+'-source/plan.json'));assert join['receiptSHA256']==sha(raw(subject+'-source/receipt.json'));assert join['sourceArchiveSHA256']==sha(raw(subject+'-source/source-archive.json'))
  sourceArchive=data(subject+'-source/source-archive.json');cliArchive=data(subject+'-cli/source-archive.json')
  for source,digest in join['qualifiedClosure'].items():assert sourceArchive[source]['sha256']==cliArchive[source]['sha256']==digest
  if subject=='reader':expected=model['reader']['independentDefectIOString'];baseline=model['reader']['originalIOString'];rows=model['reader']['semanticDifferenceRows']
  elif subject=='retainer':expected=model['retainer']['IOString'];baseline=None;rows=[]
  else:
   chosen=next(x for x in model['closedState'] if x['name']==subject);expected=chosen['independentFullIOString'];baseline=plan['baselineIOString'];rows=[i for i,(a,b) in enumerate(zip(expected.splitlines(),baseline.splitlines())) if a!=b];assert len(rows)==chosen['expectedDifferentSemanticRows']
  actual=raw(subject+'-cli/'+subject+'-cli-io.stdout');assert actual==expected.encode();assert plan['baselineIOString']==baseline and plan['expectedDifferentRows']==rows
  observed=data(subject+'-cli/receipt.json')['oracleResults'][subject];assert observed['actualSHA256']==observed['expectedSHA256']==sha(actual);assert observed['records']==count and observed['exactIOFinalLF'] is True
  if baseline is not None:assert [i for i,(a,b) in enumerate(zip(actual.decode().splitlines(),baseline.splitlines())) if a!=b]==rows
 print('NO_CHILD_CURRENT_ROOT_CONTROLS_CLI_PASS',len(records),'records',len(set(records.values())),'objects')
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');a=p.parse_args()
if a.prepare:prepare()
else:verify()
