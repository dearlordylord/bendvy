import pathlib,json,hashlib,sys,datetime
HERE=pathlib.Path(__file__).resolve().parent
FREEZE=pathlib.Path('/workspace/formal-proofs/bendvy-worktrees/observable-query-boundaries/experiments/public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/event-schedule-v1/reached-v1/FREEZE.json')
def sha(p):return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
f=json.loads(FREEZE.read_text());assert sha(FREEZE)=='3a69ac4c3676061b4eaeb0f7f26baf67a1c18cced358f07ad69e4d4ea3180be7'
mode=sys.argv[1];assert mode in ['apply','restore']
expected=f['normalSourceInventory'] if mode=='apply' else f['sourceInventory']
assert all(sha(p)==h for p,h in expected.items())
for name,o in f['candidateOverlay'].items():
 p=pathlib.Path(name);backup=HERE/'normal.bend.source'
 if mode=='apply':
  assert not backup.exists();backup.write_bytes(p.read_bytes());assert sha(o['path'])==o['sha256'];p.write_bytes(pathlib.Path(o['path']).read_bytes())
 else:
  assert sha(backup)==o['normalSHA256'];p.write_bytes(backup.read_bytes())
expected_after=f['sourceInventory'] if mode=='apply' else f['normalSourceInventory']
assert all(sha(p)==h for p,h in expected_after.items())
record={'action':mode,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'freezeSHA256':sha(FREEZE),'sourceCount':len(expected_after),'allExact':True}
target=HERE/(mode+'.json');assert not target.exists();target.write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record))
