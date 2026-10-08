"""Portable development packet audit; no backend or complete delivery claim."""
import hashlib
import io
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent

def sha(data):
    return hashlib.sha256(data).hexdigest()

def same(actual, expected):
    assert type(actual) is type(expected)
    if isinstance(actual, dict):
        assert actual.keys() == expected.keys()
        for key in actual:
            same(actual[key], expected[key])
    elif isinstance(actual, list):
        assert len(actual) == len(expected)
        for left, right in zip(actual, expected):
            same(left, right)
    else:
        assert actual == expected

def main():
    selection = json.loads((HERE / 'DEVELOPMENT-FILES.json').read_bytes())
    assert set(selection) == {'scope', 'files'}
    for name, digest in selection['files'].items():
        assert sha((HERE / name).read_bytes()) == digest, name
    assert sha((HERE / 'independent-oracle.json').read_bytes()) == '04bc4311e5fa671cb6075c196d0aa08a94d4c87d3206d81dcd2b3a13069aaeb6'
    assert sha((HERE / 'independent-oracle-v2.json').read_bytes()) == '9682fe82bd7aa2cc54c9b6feb731616497231a6e8a8065fc7a40f1c68d4d9bcf'
    index = json.loads((HERE / 'development-evidence-index.json').read_bytes())['members']
    data = {}
    with tarfile.open(fileobj=io.BytesIO((HERE / 'development-evidence.tar.gz').read_bytes()), mode='r:gz') as archive:
        for member in archive:
            assert member.isfile() and not member.name.startswith('/') and '..' not in Path(member.name).parts
            assert member.name not in data
            data[member.name] = archive.extractfile(member).read()
    assert data.keys() == index.keys()
    assert {name: sha(value) for name, value in data.items()} == index
    def raw(path):
        # Recorded historical workspace path is provenance; archive is portable.
        name = path.split('/retained-codec-v1/', 1)[1]
        return data[name]
    def report(name):
        prefix = 'development/' + name + '/'
        receipt = json.loads(data[prefix + 'receipt.json'])
        assert not receipt.get('guardFailures')
        assert [row['label'] for row in receipt['commands']] == ['emit', 'consumer']
        assert [row['capSeconds'] for row in receipt['commands']] == [30, 5]
        assert receipt['environment']['BEND_NO_TELEMETRY'] == '1'
        assert '-c' in receipt['commands'][0]['argv'] and '5' in receipt['commands'][0]['argv']
        for row in receipt['commands']:
            assert row['exit'] == 0 and row['failure'] is None
            for stream in ('stdout', 'stderr'):
                content = raw(row[stream]['path'])
                assert sha(content) == row[stream]['sha256'] and len(content) == row[stream]['bytes']
        assert raw(receipt['commands'][1]['stderr']['path']) == b''
        frozen = receipt['sourceStage']
        for row in frozen['sources']:
            assert sha(raw(row['copy'])) == row['copySHA256']
        return receipt, json.loads(raw(receipt['commands'][1]['stdout']['path']))
    failed, failed_report = report('js-direct-v1')
    positive, positive_report = report('js-direct-v2')
    mutant, mutant_report = report('js-resource-mutant-v1')
    assert failed['status'] == mutant['status'] == 'INCOMPLETE'
    assert positive['status'] == 'DEVELOPMENT_PASS'
    expected = json.loads((HERE / 'independent-oracle-v2.json').read_bytes())
    same(positive_report, expected)
    for row in positive['sourceStage']['sources']:
        tail = row['source'].split('/retained-codec-v1/', 1)
        if len(tail) == 2 and '/' not in tail[1]:
            assert sha((HERE / tail[1]).read_bytes()) == row['sourceSHA256']
    failed_expected = json.loads((HERE / 'independent-oracle.json').read_bytes())
    for schema in ('Workshop', 'Garden'):
        failed_expected[schema]['afterValidation']['resources'][0]['result'] = {
            'Rejected': {'Invalid': {'path': '$', 'expected': 'literal', 'actual': [31, 33]}}}
    same(failed_report, failed_expected)
    causal = json.loads((HERE / 'independent-oracle-v2.json').read_bytes())
    for schema in ('Workshop', 'Garden'):
        for key in ('gateMetadataBefore', 'gateMetadataAfter'):
            causal[schema][key]['resource'] = {'ArrayValue': {'Integer': {}}}
        causal[schema]['firstValidation']['resources'][0]['result'] = {'Accepted': [27, 29]}
    same(mutant_report, causal)
    assert mutant_report != expected
    classification = json.loads(data['development/js-resource-mutant-v1/complete-diff.json'])
    assert classification['classification'] == 'REACHED_MUTANT_DETECTED'
    assert len(classification['completeDiffs']) == 12 and classification['exactCausalModelMatchesWholeActual']
    proposal = json.loads(data['development/resource-mutant-v1/proposal.json'])
    assert proposal['before'] != proposal['after']
    assert 'codec,project' in proposal['before'] and 'GD.ArrayValue{GD.Integer{}}' in proposal['after']
    assert sha(raw(proposal['changedFile'])) == proposal['afterSHA256']
    positive_save = next(row for row in positive['sourceStage']['sources']
                         if row['source'].endswith('/retained-codec-v1/save.bend'))
    before = raw(positive_save['copy'])
    assert sha(before) == proposal['beforeSHA256']
    assert before.decode().count(proposal['before']) == 1
    assert before.decode().replace(proposal['before'], proposal['after']).encode() == raw(proposal['changedFile'])
    assert data['development/resource-mutant-v1/source.stderr'] == b''
    assert data['development/resource-mutant-v1/source.stdout'].startswith(b'ALL PROOFS CHECK')
    assert data['development/source-v4.stderr'] == b'' and data['development/source-v4.stdout'].startswith(b'ALL PROOFS CHECK')
    print('PASS: selected development packet, complete positive oracle and reached resource-factory mutant; no delivery/tool/performance qualification')

if __name__ == '__main__':
    main()
