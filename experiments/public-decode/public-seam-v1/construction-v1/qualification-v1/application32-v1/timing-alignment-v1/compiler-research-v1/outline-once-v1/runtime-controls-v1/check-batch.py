"""Source-current no-child check of twelve frozen plans and complete oracles."""
from pathlib import Path
import hashlib,json
HERE=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
index=json.loads((HERE/'INDEX.json').read_text());assert len(index['plans'])==12 and index['commands']==30
for row in index['plans']:
 path=Path(row['plan']);assert sha(path)==row['sha256'];plan=json.loads(path.read_text())
 assert all(sha(name)==digest for name,digest in plan['pins'].items())
 assert {str(p.relative_to(plan['stage'])):sha(p)for p in Path(plan['stage']).rglob('*.bend')}==plan['sourceInventory']
 assert {str(p.relative_to(plan['compilerAssets'])):sha(p)for p in Path(plan['compilerAssets']).rglob('*')if p.is_file()}==plan['compilerInventory']
 assert plan['compilerInventory']['comp.ts']=='1f139139ca08add93354823bb8ddddd6663294939c6433652351ddc2e749e548'
 assert not Path(plan['native']).exists() and not path.with_name('receipt.json').exists()
 assert [c['capSeconds']for c in plan['commands']]==([120,5]if row['mode']=='baseline'else[30,120,5])
 assert all(c['argv'][1:3]==['-c','5']for c in plan['commands'])
 assert plan['commands'][-1]['argv'][-4:]==['--threads','1','--gpu','off']
 if row['mode']=='baseline':assert sha(plan['generated'])==plan['baselineEvidence']['cSHA256']
 else:assert not Path(plan['generated']).exists()
 source=Path(plan['stage'])/plan['entryRelative'];expected=('\n'.join(line[2:]for line in source.read_text().splitlines()if line.startswith('#|'))+'\n').encode()
 oracle=Path(plan['oracle']);assert oracle.read_bytes()==expected and sha(oracle)==plan['oracleSHA256'] and len(expected)==plan['oracleBytes']
 collector=(HERE/'development.py').read_text()
 assert collector.index('actual interpreter differs before helpers')<collector.index("runner = load('task_runner'")
 assert collector.index("record['commands'].append(row)")<collector.index("target=Path(row[key]['path']);write_raw")
 assert "row[key]['unpublishedHex']=result[key].hex()" in collector and "exec(compile(source"in collector and 'exec_module'not in collector
print('PASS12plans/30commands/whole independent oracles/current source-tool-assets/absent runtimeoutputs; no child')
