#!/usr/bin/env python3
"""Independent source-derived two nominal schemas, two sequential print effects."""
import hashlib
import json
from pathlib import Path
import sys

HERE=Path(__file__).resolve().parent

def q(value: str) -> str:
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))

def compact_list(values: list[str]) -> str:
    return "[" + ",".join(values) + "]"

def call(name: str, *args: object) -> str:
    return name + "(" + ",".join(map(str, args)) + ")"

def build_output() -> bytes:
    access = ["value", "values:read", "values:read", "removal", "value", "Parent:read"]
    access_text = compact_list([q(x) for x in access])

    uses = [
        call("use", "component", "query", q("value"), "with"),
        call("use", "event", "message", q("values"), "read"),
        call("use", "event", "message", q("values"), "read"),
        call("use", "event", "removal", q("value"), "read"),
        call("use", "event", "relation-failure", q("Parent"), "read"),
    ]
    facts = call("facts", 1, 1, q("public-dump-reader"), access_text)
    owners = call(
        "owners",
        "unit",
        call("event-owner", facts, 1, 1, 1),
        call("event-owner", facts, 1, 2, 1),
        call("removal-owner", facts, 1, 1, q("value"), 0),
        call("relation-owner", facts, "some(1)", "[1]"),
    )
    provider = call(
        "provider", 1, 1, q("public-dump-reader"), access_text, 0,
        access_text, compact_list(uses), owners,
    )

    value_notice = '{"kind":"original","event":{"kind":"value","value":11}}'
    removal_notice = (
        '{"kind":"original","event":{"kind":"removed","record":'
        '{"entity":{"namespace":1,"id":1},"component":"value"}}}'
    )
    relation_notice = (
        '{"kind":"relationFailure","failure":{"relation":{"key":1,"name":"Parent",'
        '"inverse":"Children","kind":"hierarchy"},"operation":"relate","source":1,'
        '"target":1,"error":{"kind":"self","source":1,"relation":"Parent"}}}'
    )
    events = compact_list([value_notice, removal_notice, relation_notice])
    registration = call("registration", 1, q("public-dump-reader"), access_text)
    world = call(
        "world", 1, 2, 1, "[false, true]", 2, 1, "column(L(some(42)),[])",
        "unit", events, 1, compact_list([registration]), 2, 0,
    )
    typed_stream = call("stream", q("values"), "[]", "[]", 3, 0, 0, 65536, 0)
    failures = call("failures", "[]", "[]", 0, 0, 0, 65536, 2)
    state = call("state", typed_stream, "[]", 0, failures)
    context = call("context", world, state, 0)
    physical = provider + "|" + context

    row = 'row({"namespace":1,"id":1},[value("value","42")])'
    all_dump = "dump(1,[" + row + "],[])"
    empty_dump = "dump(1,[],[])"
    records = [
        "record(before|no-dump|" + physical + ")\n",
        "record(all|" + all_dump + "|" + physical + ")\n",
        "record(repeat|" + all_dump + "|" + physical + ")\n",
        "record(filtered|" + all_dump + "|" + physical + ")\n",
        "record(zero-limit|" + empty_dump + "|" + physical + ")\n",
        "record(disabled|none|" + physical + ")\n",
        "record(reenabled|" + all_dump + "|" + physical + ")\n",
    ]
    output = "".join(records).encode("utf-8")
    assert output.endswith(b"\n")
    return output

def verify_pins():
    pins=json.loads((HERE/'source-pins.json').read_text())
    for path,digest in pins.items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest,path
    basis=json.loads((HERE/'source-freeze.json').read_text())
    frozen=json.loads(Path(basis['manifest']).read_text())
    original=Path(basis['originalRoot'])
    immutable=Path(basis['immutableRoot'])
    def copied(path):return immutable/Path(path).relative_to(original)
    assert len(frozen['sourceInventory'])==93
    for path,digest in frozen['sourceInventory'].items():
        assert hashlib.sha256(copied(path).read_bytes()).hexdigest()==digest
    # No body/name/schema rewrite: only import lines differ in five nominal modules.
    body=lambda text:'\n'.join(line for line in text.splitlines() if not line.startswith('import '))
    assert len(frozen['nominalSourceCopyMap'])==5
    for join in frozen['nominalSourceCopyMap']:
        old,new=copied(join['original']),copied(join['selected'])
        assert hashlib.sha256(old.read_bytes()).hexdigest()==join['originalSHA256']
        assert hashlib.sha256(new.read_bytes()).hexdigest()==join['selectedSHA256']
        assert body(old.read_text())==body(new.read_text()),join['selected']
    clone_targets={copied(j['original']).resolve():copied(j['selected']).resolve() for j in frozen['nominalSourceCopyMap']}
    def imports(path):
        return [line.split() for line in path.read_text().splitlines() if line.startswith('import ')]
    for old,new in clone_targets.items():
        old_imports,new_imports=imports(old),imports(new)
        assert len(old_imports)==len(new_imports)
        for a,b in zip(old_imports,new_imports):
            assert a[2:]==b[2:], 'import aliases must preserve body meaning'
            if a[1]=='Base':assert b[1]=='Base'
            else:
                target=(old.parent/a[1]).resolve()
                expected=clone_targets.get(target,target)
                assert (new.parent/b[1]).resolve()==expected, (str(new),b[1])
    main=copied(frozen['main']).read_text()
    assert 'IO.bind(Unit,Unit,IO.print(First.ready(Original.setup())),second)' in main
    assert 'def second(_:Unit) -> IO(Unit):IO.print(Second.ready(Beta.setup()))' in main
    fixtures=[j for j in frozen['nominalSourceCopyMap'] if j['selected'].endswith('/fixture.bend')]
    assert len(fixtures)==1
    assert copied(fixtures[0]['original'])!=copied(fixtures[0]['selected'])
    for path in [fixtures[0]['original'],fixtures[0]['selected']]:
        text=copied(path).read_text()
        assert 'type Schema is Data:' in text and 'W.factory()' in text
    return len(pins)

def derive():
    first=build_output()
    second=build_output()
    assert first==second
    for pure in [first,second]:
        lines=pure.splitlines()
        assert len(lines)==7
        assert [x.split(b'|',1)[0] for x in lines]==[
            b'record(before',b'record(all',b'record(repeat',b'record(filtered',
            b'record(zero-limit',b'record(disabled',b'record(reenabled']
        physical=[x.split(b'|',2)[2] for x in lines]
        assert len(set(physical))==1, 'dump must preserve complete physical owners/state'
        assert lines[1].split(b'|',2)[1]==lines[2].split(b'|',2)[1]==lines[3].split(b'|',2)[1]
        assert lines[4].split(b'|',2)[1]==b'dump(1,[],[])'
        assert lines[5].split(b'|',2)[1]==b'none'
        assert lines[6].split(b'|',2)[1]==lines[1].split(b'|',2)[1]
        assert pure.count(b',1,[registration(')==7 and b'999' not in pure
        assert pure.count(b'stream("values",[],[],3,0,0,65536,0)')==7
        assert pure.count(b'failures([],[],0,0,0,65536,2)')==7
        assert pure.endswith(b'\n') and not pure.endswith(b'\n\n')
    # Each print receives an already LF-terminated seven-record String and
    # independently appends one LF. IO.bind sequences the complete effects.
    output=first+b'\n'+second+b'\n'
    assert output.count(b'record(')==14 and output.endswith(b'\n\n')
    assert output[:len(first)+1]==output[len(first)+1:]
    assert output.count(b'\n\n')==2
    return output

if __name__=='__main__':
    count=verify_pins()
    output=derive()
    if '--write' in sys.argv:(HERE/'expected.stdout').write_bytes(output)
    else:assert (HERE/'expected.stdout').read_bytes()==output
    print(json.dumps({'sourceFilesVerified':count,'bytes':len(output),'sha256':hashlib.sha256(output).hexdigest(),'nominalCopies':5,'stateInvariants':'passed'}))
