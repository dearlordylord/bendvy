"""Complete feature observations; digests are transport checks, never semantic oracles."""
import json, pathlib
HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[1]
MODES = {0:'positive',1:'resource-missing',3:'service-missing',7:'duplicate',8:'condition-missing',9:'empty',11:'both-missing'}

def nested_records(block):
    records = []
    mode = None
    for line in block:
        label, body = line.split('|', 1)
        if label != 'retry':
            mode = int(label[4:])
        name = MODES[mode] + ('-retry' if label == 'retry' else '')
        fields = dict(item.split('=', 1) for item in body.split('|')[-1].split(';'))
        record = {'mode':name,'status':'missing' if body.startswith('missing:') else 'invalid' if body.startswith('invalid|') else 'ok'}
        for key in ['cw','rw','host','conditions','queue']:
            record[key] = int(fields[key])
        for key, source in [('events','events'),('trace','trace'),('component','cell')]:
            record[key] = json.loads(fields[source])
        record['resource'] = None if fields['resource'] == 'missing' else json.loads(fields['resource'])
        if mode != 7:
            requirement_text = body.split(':needs=',1)[1].split('|',1)[0]
            record['requirements'] = [{'S1':'service:Host','R1':'resource:Resource'}[x] for x in requirement_text.split(',') if x in ['S1','R1']]
            record['flattened'] = ['phase-empty'] if mode==9 else ['phase-before','B'] if mode==8 else ['phase-before','A','phase-inner','B']
        if record['status']=='missing':
            missing_text = body.split(':needs=',1)[0][len('missing:'):]
            record['missing'] = [{'kind':'service','name':'Host'} if x=='S1' else {'kind':'resource','name':'Resource'} for x in missing_text.split(',') if x in ['S1','R1']]
        records.append(record)
    return records

def validate(feature, backend, text, batches):
    lines = text.splitlines()
    if feature == 'nested':
        block = json.loads((HERE/'nested-expected.json').read_text())['nominalBlock']
        if backend == 'TS':
            expected = nested_records(block)
            assert len(lines)==2*batches
            for line in lines: assert json.loads(line)==expected, ('nested TS checkpoint mismatch',json.loads(line),expected)
        else:
            expected = (['schema-A']+block+['schema-B']+block)*batches
            assert lines==expected, 'Complete nested owner/metadata/checkpoint mismatch'
    elif feature == 'readers':
        expected = [json.loads((ROOT/'experiments/public-schedule-readers'/name).read_text()) for name in ['expected.json','added-expected.json']]
        assert len(lines)==2*batches
        assert [json.loads(line) for line in lines] == expected*batches, 'Complete composed reader checkpoint mismatch'
    elif feature == 'fragments':
        expected = ['12,11,:3,3,:1:9,:1:log=1,99|13,11,:3,3,:1:9,:0:log=1,99']*2 + ['rejected:10,11,:2,3,:log=0,99']*2
        assert lines==expected*batches, 'Complete fragment barrier/owner/service mismatch'
    else:
        raise ValueError(feature)
