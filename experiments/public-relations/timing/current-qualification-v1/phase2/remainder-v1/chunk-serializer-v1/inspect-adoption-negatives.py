"""Source-only retained negative/reorder closure reconciliation; no child execution."""
from pathlib import Path, PurePosixPath
import hashlib, json, posixpath, re, tarfile
H = Path(__file__).resolve().parent
R = H.parents[6]
sha = lambda b: hashlib.sha256(b).hexdigest()
P = R / 'experiments/public-relations'
module = {'types.bend':'relation-types.bend','graph-core.bend':'relation-graph.bend','world-adapter.bend':'relation-commands.bend','providers.bend':'relation-providers.bend','cleanup-core.bend':'relation-cleanup.bend','reorder-core.bend':'relation-reorder-core.bend','reorder-adapter.bend':'relation-reorder.bend'}
imports = re.compile(r'^(\s*import\s+)(\S+)', re.M)
def target(rel):
    name = PurePosixPath(rel).name
    if rel.startswith('src/'):
        return R / rel
    if name in module:
        return R / 'src/ecs' / module[name]
    if name.startswith('relation-'):
        return R / 'src/ecs' / name
    return P / 'promotion-stage' / name

def canonical(data, rel, historic):
    def replace(m):
        name = m.group(2)
        if name == 'Base' or name.startswith('"'):
            return m.group(0)
        resolved = posixpath.normpath(str(PurePosixPath(rel).parent / name))
        mapped = target(resolved) if historic else (R / resolved).resolve()
        return m.group(1) + str(mapped.relative_to(R))
    return imports.sub(replace, data.decode())

specs = [('query',P/'promotion-capsules/query.tar.gz'),('lifetime',P/'promotion-capsules/lifetime.tar.gz'),('cleanupV5',P/'candidate-archives/production-candidate-v5.tar.gz'),('reorder',P/'evidence/reorder-1791361321007561029.tar.gz')]
cohorts = []
for name, path in specs:
    with tarfile.open(path) as archive:
        content = {m.name: archive.extractfile(m).read() for m in archive.getmembers() if m.isfile()}
    receipt_name, receipt = next((n,json.loads(b)) for n,b in content.items() if n.endswith('/receipt.json') and 'PASS' in json.loads(b).get('status','') and json.loads(b).get('negativeResults'))
    suffix = receipt['stages']['normal']['path'].split('/experiments/public-relations/',1)[1]
    prefix = receipt_name.rsplit('/',1)[0] + '/normal/'
    available = {n[len(prefix):]:b for n,b in content.items() if n.startswith(prefix)}
    for rel, digest in receipt['stages']['normal']['derivedInventory'].items():
        assert sha(available[rel]) == digest
    def closure(rel, found):
        if rel in found:
            return
        found.add(rel)
        data = available[rel]
        for m in imports.finditer(data.decode()):
            entry = m.group(2)
            if entry != 'Base' and not entry.startswith('"'):
                closure(posixpath.normpath(str(PurePosixPath(rel).parent / entry)), found)
    world_old = available['src/ecs/world.bend'].decode()
    world_new = (R/'src/ecs/world.bend').read_text()
    def blocks(text):
        markers = list(re.finditer(r'^(?:type|def)\s+([\w-]+)',text,re.M))
        return {m.group(1):text[m.start():markers[j+1].start() if j+1<len(markers) else len(text)].strip() for j,m in enumerate(markers)}
    old_blocks, new_blocks = blocks(world_old), blocks(world_new)
    changed_world = [k for k in old_blocks if old_blocks[k] != new_blocks.get(k)]
    authority = [k for k in old_blocks if old_blocks[k].startswith('type ') or k in ['namespace','from_handle','handle','get_namespace']]
    assert all(old_blocks[k] == new_blocks[k] for k in authority)
    world_join = {'historicalSHA256':sha(world_old.encode()),'currentSHA256':sha(world_new.encode()),'exactTypeAndAuthorityBlocks':{k:sha(old_blocks[k].encode()) for k in authority},'changedBodies':changed_world,'addedDefinitions':sorted(set(new_blocks)-set(old_blocks)),'scope':'Exact referenced nominal/affine type declarations and namespace authority bodies; changed registration/equality runtime is not historical current-execution acceptance.'}
    rows = []
    for negative in receipt['negativeResults']:
        entry = next(k for k in available if k.endswith('/'+negative['case']+'.bend'))
        found = set()
        closure(entry, found)
        joins = []
        for rel in sorted(found):
            current = target(rel)
            b = available[rel]
            current_rel = str(current.relative_to(R))
            state = 'MISSING_CURRENT'
            if current.is_file():
                actual = current.read_bytes()
                state = 'EXACT' if b == actual else 'IMPORT_RELOCATION' if canonical(b,rel,True)==canonical(actual,current_rel,False) else 'CHANGED_BODY'
            joins.append({'historicalPath':rel,'historicalSHA256':sha(b),'currentPath':current_rel,'currentSHA256':sha(current.read_bytes()) if current.is_file() else None,'state':state})
        rows.append({'case':negative['case'],'intendedDiagnostic':negative.get('intendedDiagnostic'),'intendedSourceSpan':negative.get('intendedSourceSpan'),'closure':joins,'unjoined':[j['currentPath'] for j in joins if j['state'] not in ('EXACT','IMPORT_RELOCATION')]})
    cohorts.append({'name':name,'archive':str(path.relative_to(R)),'archiveSHA256':sha(path.read_bytes()),'receiptMember':receipt_name,'receiptSHA256':sha(content[receipt_name]),'historicalStatus':receipt['status'],'worldTypeAuthorityJoin':world_join,'negatives':rows,'historicalReorderMutants':[{'case':x['case'],'backend':x['backend'],'witnessCount':len(x['witnesses']),'checkpointCount':x['checkpointCount']} for x in receipt.get('results',[]) if name=='reorder']})
(H/'adoption-negative-source-joins.json').write_text(json.dumps({'scope':'Finite source closure/import relocation only; no current execution/proof/tool acceptance transfer','cohorts':cohorts},indent=2)+'\n')
for c in cohorts:
    print(c['name'],len(c['negatives']),sorted({p for x in c['negatives'] for p in x['unjoined']}))
