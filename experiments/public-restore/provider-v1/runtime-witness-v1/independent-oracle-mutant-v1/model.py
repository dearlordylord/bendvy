"""Finite source-derived detached-constructor model; no runtime output input."""
import gzip
import hashlib
import json
import os
from pathlib import Path

HERE = Path(__file__).resolve().parent

def ctor(name, *args):
    return name + '{' + ', '.join(args) + '}'

def derive():
    freeze = json.loads((HERE / 'SOURCE-FREEZE.json').read_text())
    sources = json.loads(gzip.decompress((HERE / 'sources.json.gz').read_bytes()))
    for path, digest in freeze['sourceInventory'].items():
        assert hashlib.sha256(sources[path].encode()).hexdigest() == digest
    entry = freeze['entrypoint']
    witness = sources[str(Path(entry).with_name('witness-mutant.bend'))]
    provider = sources[str(Path(entry).with_name('provider.bend'))]
    assert '(declaration,host(context,Decl.codec(' in provider
    for expression in ['Context{ANode{ALeaf{111},ALeaf{222}}}',
                       'Issues{error,ANode{ALeaf{501},ALeaf{502}}}',
                       'Payload{ALeaf{value}}', 'run(D.Boolean{True{}})',
                       'run(D.Text{"invalid original"})',
                       'Complete.decode_owner(~D.Raw,~raw_project,codec,original)',
                       'Refused{context,original,error}']:
        assert expression in witness, expression
    typed = next(p for p in sources if p.endswith('/public-decode/typed.bend'))
    assert 'case BoolValue{} _: Stop{Invalid{path,"boolean",raw}}' in sources[typed]
    # book_load uses internal ':', then Bend.name_key replaces it with '.'.
    # show_val prints constructor fields with comma-space and one final LF.
    ns = os.path.relpath(typed, Path(entry).parent).removesuffix('.bend') + '.'
    tree = lambda values: ctor('Leaf', str(values[0])) if len(values) == 1 else ctor('Node', *(ctor('Leaf', str(v)) for v in values))
    assert "Context{Array.set(U32,sentinel,0,112)}" in witness
    assert "constructed(corrupted(context),Complete.decode_owner" in witness
    # Array.set at zero changes only the left leaf of this two-leaf owner.
    context = tree([112, 222])
    # Complete BoolValue decoding accepts Boolean unchanged; allocation then
    # constructs one affine leaf. Projection reads that same leaf and validates
    # it through the retained declaration's BoolValue recipe.
    boolean = ctor(ns + 'Boolean', ctor('True'))
    accepted = ctor('Accepted', context, ctor('Leaf', ctor('True')),
                    ctor(ns + 'Accepted', boolean))
    # Text fails BoolValue at '$'. Original Raw survives the failure receipt,
    # and constructor adds its concrete Issues sentinel without changing error.
    raw = ctor(ns + 'Text', json.dumps('invalid original'))
    error = ctor(ns + 'Invalid', json.dumps('$'), json.dumps('boolean'), raw)
    refused = ctor('Refused', context, raw, error, tree([501, 502]))
    return (ctor('Report', accepted, refused) + '\n').encode()

if __name__ == '__main__':
    import sys
    sys.stdout.buffer.write(derive())
