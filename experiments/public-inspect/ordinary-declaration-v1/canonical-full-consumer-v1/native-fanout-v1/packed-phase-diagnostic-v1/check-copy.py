"""Bounded source inverse/noncollision controls; never invokes compiler."""
import gzip,hashlib,json
from pathlib import Path
root=Path(__file__).resolve().parent
metadata=json.loads((root/'PATCHES.json').read_text())
manifest=Path(metadata['originalManifest']);originals=json.loads(manifest.read_text());item=next(x for x in originals['items'] if x['name']=='actual-packed-cli-source.js')
original=gzip.decompress((manifest.parent/item['object']).read_bytes())
assert hashlib.sha256(original).hexdigest()==metadata['originalSHA256'] and len(original)==333165
assert metadata['privatePrefix'].encode() not in original
text=(root/'packed-compiler.mjs').read_text()
assert hashlib.sha256(text.encode()).hexdigest()==metadata['copySHA256']
def valid(candidate):
    for patch in reversed(metadata['patches']):
        if candidate.count(patch['replacement'])!=1:return False
        candidate=candidate.replace(patch['replacement'],patch['original'])
    return candidate.encode()==original
assert valid(text)
mutants=[text.replace('BVY_PD_CHECK("memo_gc");','',1),text.replace('BVY_PD_CHECK("emit_body", fl.def);','',1),text.replace('process.exit(75);','process.exit(0);',1),text.replace('"/home/node/.bend/bend2"','"/tmp/other"',1),text+'\n'+metadata['patches'][1]['replacement'],text.replace('fl.sites.get(ck.k) === 1','fl.sites.get(ck.k) === 2',1),text.replace('BVY_PD_PHASE("compile_book", "exit");','',1),text.replace('function flat_call(fl, t) {','function flat_call(fl, t) { return false;',1)]
assert len(mutants)==8 and all(m!=text and not valid(m) for m in mutants)
print(json.dumps({'scope':'Source-only exact inverse, private-prefix noncollision and8 refusal controls','originalBytes':len(original),'originalSHA256':metadata['originalSHA256'],'copySHA256':metadata['copySHA256'],'patches':len(metadata['patches']),'refusals':len(mutants),'memoCheckpoint':'unique inserted entry','recursiveCheckpoint':'unique inserted emit_body entry'}))
