"""Portable read/hash-only diagnostic evidence verifier. No executable children."""
import pathlib,json,hashlib,tarfile,collections,re
HERE=pathlib.Path(__file__).resolve().parent;index=json.loads((HERE/'index.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest()
assert sha((HERE/'objects.tar.gz').read_bytes())==index['objectsSHA256']
with tarfile.open(HERE/'objects.tar.gz','r:gz') as archive:
 members={m.name:m for m in archive.getmembers()};assert len(members)==len(archive.getmembers()) and all(m.isfile() and re.fullmatch('objects/[0-9a-f]{64}',m.name) for m in members.values())
 required={r['object'] for r in index['records'].values() if r['kind']=='archived'};assert set(members)=={'objects/'+d for d in required}
 for member in archive.getmembers():assert sha(archive.extractfile(member).read())==member.name.split('/',1)[1]
 for name,r in index['records'].items():
  if r['kind']=='archived':assert r['object']==r['sha256'] and members['objects/'+r['object']].size==r['bytes']
  else:assert r['kind']=='hash-only' and r['reason'] in ['private environment bytes excluded','binary/tool bytes excluded']
 def data(name):
  r=index['records'][str(name)];assert r['kind']=='archived';b=archive.extractfile(members['objects/'+r['object']]).read();assert sha(b)==r['sha256'] and len(b)==r['bytes'];return b
 def parsed(name):return json.loads(data(name))
 def pin(name,digest):assert index['records'][str(name)]['sha256']==digest
 parsedRoles={}
 for role,descriptor in index['roles'].items():
  pin(descriptor['plan'],descriptor['planSHA256']);pin(descriptor['receipt'],descriptor['receiptSHA256']);p=parsed(descriptor['plan']);r=parsed(descriptor['receipt']);parsedRoles[role]=(p,r,descriptor)
  assert r['planSHA256']==descriptor['planSHA256'] and r['status']==descriptor['status'] and r.get('guardFailures',[])==[]
  assert p['seconds']==descriptor['seconds'] and p['command'][:3]==['/usr/bin/taskset','-c','5']
  root=descriptor['plan'].split('/.artifacts/',1)[0];out=pathlib.PurePosixPath(descriptor['plan']).parent
  node='/home/node/.local/share/mise/installs/node/24.20.0/bin/node'
  if role=='source':expected=['/usr/bin/taskset','-c','5',root+'/scripts/bend-check',str(pathlib.PurePosixPath(p['stage'])/'output-adapter.bend')]
  elif role=='orderedControls':expected=['/usr/bin/taskset','-c','5',node,str(out/'controls.mjs')]
  elif role in ['cpuOriginal','cpuCached']:expected=['/usr/bin/taskset','-c','5',node,str(out/'profile-host.mjs'),p['target'],str(out/'diagnostic.c'),str(out)]
  elif role=='heapDeadline':expected=['/usr/bin/taskset','-c','5',node,str(out/'heap-host.mjs'),p['target'],str(out/'diagnostic.c'),str(out)]
  else:expected=['/usr/bin/taskset','-c','5',node,*(['--trace-gc-nvp'] if role=='gcDeadline' else []),str(out/'driver.mjs'),p['target'],str(out/'diagnostic.c')]
  assert p['command']==expected
  for argument in [expected[0],expected[3],expected[4] if role not in ['source','gcDeadline'] else expected[5] if role=='gcDeadline' else expected[4]]:
   assert argument in p['inputs'] and index['records'][argument]['sha256']==p['inputs'][argument]
  if role not in ['source','orderedControls']:
   assert p['target']==str(pathlib.PurePosixPath(p['stage'])/'output-workshop-io.bend')
   assert p['targetSHA256']==p['stageInventory']['output-workshop-io.bend']
  if 'stageInventory' in p:
   prefix=p['stage'].rstrip('/')+'/'
   assert {name[len(prefix):]:record['sha256'] for name,record in index['records'].items() if name.startswith(prefix)}==p['stageInventory']
   for name,digest in p['stageInventory'].items():pin(prefix+name,digest);data(prefix+name)
  for link,target in p.get('symlinks',{}).items():
   linkpath=pathlib.PurePosixPath(link);assert linkpath==out/'compiler'/linkpath.name
   assert target=='/home/node/.bend/bend2/'+linkpath.name and linkpath.name in ['base.bend','effs']
   if linkpath.name=='base.bend':assert data(link)==data(target)
   else:
    snapshot=p['inputs'][target];assert isinstance(snapshot,dict)
    for relative,digest in snapshot.items():pin(str(pathlib.PurePosixPath(target)/relative),digest);data(str(pathlib.PurePosixPath(target)/relative))
  rawset=set(r.get('captured',r.get('logs',{})))
  assert {pathlib.PurePosixPath(name).name for name in index['records'] if pathlib.PurePosixPath(name).parent==out and pathlib.PurePosixPath(name).suffix in ['.raw','.c','.cpuprofile','.heapprofile']}==rawset
  assert rawset==({'stdout.raw','stderr.raw','child.stdout.raw','child.stderr.raw','protocol.raw','profile-reply.raw','profile-derived.cpuprofile'} if role in ['cpuOriginal','cpuCached'] else {'stdout.raw','stderr.raw','child.stdout.raw','child.stderr.raw','protocol.raw'} if role=='heapDeadline' else {'stdout.raw','stderr.raw'})

  assert p['environmentSHA256']==index['records'][p['environment']]['sha256']
  if r['status']=='INCOMPLETE':assert r['failure']=='child deadline' and r['exit'] is None
  else:assert r['failure'] is None and r['exit']==0
  for name,digest in p['inputs'].items():
   if isinstance(digest,dict):
    for relative,value in digest.items():pin(str(pathlib.PurePosixPath(name)/relative),value)
   else:pin(name,digest)
  for name,digest in r.get('captured',r.get('logs',{})).items():pin(str(pathlib.PurePosixPath(descriptor['receipt']).parent/name),digest);data(str(pathlib.PurePosixPath(descriptor['receipt']).parent/name))
 p,r,d=parsedRoles['source'];base=pathlib.PurePosixPath(d['receipt']).parent;assert len(data(base/'stdout.raw'))==58 and sha(data(base/'stdout.raw'))==p['expectedStdoutSHA256'];assert sha(data(base/'stderr.raw')) in p['allowedStderrSHA256']
 p,r,d=parsedRoles['orderedControls'];base=pathlib.PurePosixPath(d['receipt']).parent;assert data(base/'stdout.raw')==data(p['expected']) and data(base/'stderr.raw')==b'';assert len(json.loads(data(p['expected'])))==24
 totals={}
 for role in ['cpuOriginal','cpuCached']:
  p,r,d=parsedRoles[role];base=pathlib.PurePosixPath(d['receipt']).parent
  assert set(r['captured'])=={'stdout.raw','stderr.raw','child.stdout.raw','child.stderr.raw','protocol.raw','profile-reply.raw','profile-derived.cpuprofile'}
  reply=parsed(base/'profile-reply.raw');profile=reply['result']['profile'];assert profile==parsed(base/'profile-derived.cpuprofile')
  nodes={n['id']:n for n in profile['nodes']};assert len(nodes)==r['profileNodes'] and len(profile['samples'])==r['profileSamples']==len(profile['timeDeltas'])
  count=collections.Counter()
  for sample,delta in zip(profile['samples'],profile['timeDeltas']):count[nodes[sample]['callFrame']['functionName']]+=delta
  totals[role]={k:count[k] for k in ['(garbage collector)','lay_eq','lay_json','term_key','memo']}
  events=[json.loads(line) for line in data(base/'protocol.raw').splitlines()];assert any(e['event']=='profile-captured' for e in events) and any(e['event']=='owned-child-close' and e['signal']=='SIGTERM' for e in events)
  sends=[json.loads(e['message']) for e in events if e['event']=='send'];assert [s['method'] for s in sends]==p['protocolAllowlist']
  endpoint=[e['url'] for e in events if e['event']=='owned-loopback-endpoint'];assert len(endpoint)==1 and endpoint[0].startswith('ws://127.0.0.1:')
  phase=data(base/'child.stderr.raw');assert b'compile-book-enter' in phase and b'compile-book-exit' not in phase
  del nodes,profile,reply,events
 assert totals['cpuOriginal']=={'(garbage collector)':7937667,'lay_eq':5404809,'lay_json':0,'term_key':1082768,'memo':940699}
 assert totals['cpuCached']=={'(garbage collector)':11272474,'lay_eq':5520,'lay_json':46571,'term_key':1392901,'memo':1172855}
 p,r,d=parsedRoles['heapDeadline'];base=pathlib.PurePosixPath(d['receipt']).parent;assert set(r['captured'])=={'stdout.raw','stderr.raw','child.stdout.raw','child.stderr.raw','protocol.raw'}
 events=[json.loads(line) for line in data(base/'protocol.raw').splitlines()];sends=[json.loads(e['message']) for e in events if e['event']=='send'];assert [v['method'] for v in sends]==p['protocolAllowlist'];assert sends[1]['params']=={'samplingInterval':32768,'includeObjectsCollectedByMajorGC':True,'includeObjectsCollectedByMinorGC':True};assert not any(e['event']=='receive' and json.loads(e['raw']).get('id')==4 for e in events)
 p,r,d=parsedRoles['gcDeadline'];base=pathlib.PurePosixPath(d['receipt']).parent;events=[]
 for line in data(base/'stdout.raw').decode().splitlines():
  match=re.match(r'\[[^]]+\]\s+(\d+) ms: (.*)',line);assert match;events.append(dict(re.findall(r'([\w.]+)=([^ ]+)',match[2])))
 assert len(events)==347 and collections.Counter(e['gc'] for e in events)=={'s':340,'mc':7};assert round(sum(float(e['pause']) for e in events),1)==10233.7 and int(events[-1]['end_object_size'])==3766470392
 for role in ['cacheDeadline','orderedDeadline']:
  p,r,d=parsedRoles[role];base=pathlib.PurePosixPath(d['receipt']).parent;assert set(r['captured'])=={'stdout.raw','stderr.raw'} and data(base/'stdout.raw')==b'';assert b'compile-book-enter' in data(base/'stderr.raw') and b'compile-book-exit' not in data(base/'stderr.raw')
print(json.dumps({'status':'PORTABLE_DIAGNOSTIC_BYTE_EVIDENCE_PASS','records':len(index['records']),'objects':len(required),'roles':len(index['roles']),'scope':index['scope']}))
