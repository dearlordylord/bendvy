"""No-child source-derived reconciliation; historical acceptance remains INCOMPLETE."""
import hashlib,json,runpy,sys
from pathlib import Path
sys.dont_write_bytecode=True
H=Path(__file__).resolve().parent
R=H.parents[3]
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def strict(x):
 if isinstance(x,dict):return ("dict",tuple((k,strict(v)) for k,v in sorted(x.items())))
 if isinstance(x,list):return ("list",tuple(map(strict,x)))
 return (type(x).__name__,x)
def check():
 old=R/'.artifacts/inspector-relation55-boundary-io-1791441401493444111'
 plan=old/'plan.json';receipt=old/'receipt.json'
 assert sha(plan)=='be67bdcdc49377484a83d628f6a98222fe400a3719dbf24f48dfa306c038862c'
 assert sha(receipt)=='747c6c45d6a5be6bd1261e01e2efb791b86e5810321d41c2540831406b750d6c'
 p=json.loads(plan.read_text());r=json.loads(receipt.read_text())
 assert r['status']=='INCOMPLETE' and r['guardFailures']==[]
 assert len(p['commands'])==len(r['commands'])==1
 c=p['commands'][0];rc=r['commands'][0]
 assert c['label']==rc['label']=='boundary-io' and c['seconds']==rc['seconds']==5
 assert c['argv']==rc['argv'] and c['argv'][-1]==str(H/'boundary-io.bend')
 assert rc['exit']==0 and rc['failure'] is None
 assert set(r['logs'])=={'boundary-io.stdout','boundary-io.stderr'}
 assert r['planSHA256']==sha(plan)
 for name,digest in r['logs'].items():assert sha(old/name)==digest
 assert sha(p['privateEnvironment'])==p['environmentSHA256']
 # Historical guards completed in the immutable receipt; report present drift,
 # never silently claim all historical installed/config/tool bytes current.
 drift={name:{'historical':digest,'current':sha(name) if Path(name).is_file() else None} for name,digest in p['pins'].items() if not Path(name).is_file() or sha(name)!=digest}
 configurationDrift={}
 for name,historical in p['configuration'].items():
  path=Path(name)
  current={'kind':'file','SHA256':sha(path)} if path.is_file() else {'kind':'directory'} if path.is_dir() else {'kind':'absent'}
  if current!=historical:configurationDrift[name]={'historical':historical,'current':current}
 installed=Path('/home/node/.bend/bend2')
 membership={str(path.relative_to(installed)):str(path.resolve()) for path in sorted(installed.rglob('*')) if path.is_file()}
 membershipDrift={name:{'historical':p['installedMembership'].get(name),'current':membership.get(name)} for name in sorted(set(p['installedMembership'])|set(membership)) if p['installedMembership'].get(name)!=membership.get(name)}
 delta=json.loads((H/'oracle-v2-source-delta.json').read_text())
 for name,digest in delta['sources'].items():assert sha(H/name)==digest
 joins=json.loads((H/'source-joins.json').read_text())
 for row in joins['files']:assert sha(row['source'])==sha(H/row['copy'])==row['SHA256']
 model=runpy.run_path(str(H/'author-oracle-v2.py'),run_name='reviewed_source_model')
 expected={'schemas':[model['schema']('Workshop',0),model['schema']('Garden',100)],'scope':'finite relation Inspector development fixture; no full55 qualification'}
 assert strict(expected)==strict(json.loads((H/'expected-relations-v2.json').read_text()))
 text=(old/'boundary-io.stdout').read_text();actual,end=json.JSONDecoder().raw_decode(text)
 notice=(H.parent/'pinned-bend-notice.bytes').read_bytes()
 assert text[end:].encode() in (b'\n',b'\n'+notice)
 assert (old/'boundary-io.stderr').read_bytes() in (b'',notice)
 assert strict(actual)==strict(expected)
 original=json.loads((H/'expected-relations.json').read_text());dif=[]
 def walk(a,b,path=''):
  assert type(a)==type(b)
  if isinstance(a,dict):
   assert a.keys()==b.keys()
   for k in a:walk(a[k],b[k],path+'/'+k)
  elif isinstance(a,list):
   assert len(a)==len(b)
   for i,(x,y) in enumerate(zip(a,b)):walk(x,y,path+'/'+str(i))
  elif a!=b:dif.append([path,a,b])
 walk(original,expected)
 assert strict(dif)==strict(delta['differencesOldToV2']) and len(dif)==24
 assert sum(len(phase['queries']) for subject in actual['schemas'] for phase in subject['phases'])==192
 ts=R/'.artifacts/inspector-relation55-ts-1791440748625764734'
 assert sha(ts/'plan.json')==p['actualTSPlanSHA256'] and sha(ts/'receipt.json')==p['actualTSReceiptSHA256']
 tr=json.loads((ts/'receipt.json').read_text())
 assert tr['status']=='DEVELOPMENT_ACTUAL_TS_RELATION192_PASS_NOT_FULL55'
 tp=json.loads((ts/'plan.json').read_text())
 assert len(tr['commands'])==1 and isinstance(tp['command'],dict)
 tc=tr['commands'][0];pc=tp['command']
 assert tc['label']==pc['label']=='ts-relations' and tc['seconds']==pc['seconds']==5
 assert tc['argv']==pc['argv'] and tc['exit']==0 and tc['failure'] is None and tc['fullOracleMatched'] is True
 assert tr.get('guardFailures',[])==[] and tr['planSHA256']==sha(ts/'plan.json')
 assert set(tr['logs'])=={'ts-relations.stdout','ts-relations.stderr'}
 for name,digest in tr['logs'].items():assert sha(ts/name)==digest
 return {'status':'DERIVED_MODEL_V2_FULL192_MATCH_NOT_FULL55','historicalReceiptStatus':'INCOMPLETE','historicalPlanSHA256':sha(plan),'historicalReceiptSHA256':sha(receipt),'modelDeltaSHA256':sha(H/'oracle-v2-source-delta.json'),'oracleV2SHA256':sha(H/'expected-relations-v2.json'),'sourceJoinsSHA256':sha(H/'source-joins.json'),'historicalRaw':r['logs'],'actualTSReceiptSHA256':sha(ts/'receipt.json'),'currentHistoricalPinDrift':drift,'currentHistoricalConfigurationDrift':configurationDrift,'currentHistoricalInstalledMembershipDrift':membershipDrift,'environmentScope':'Read-only present drift reporting only; immutable historical plan/postguards remain the runtime authority, no fresh current environment qualification','scope':'No child or historical receipt relabel; finite IO development reconciliation only; no standalone/Native/proof/performance/adoption/full55 claim'}
if __name__=='__main__':
 result=check()
 destination=H/'reconciliation-v2.json'
 assert not destination.exists(),'immutable reconciliation already exists'
 destination.write_text(json.dumps(result,indent=2)+'\n')
 print(destination)
