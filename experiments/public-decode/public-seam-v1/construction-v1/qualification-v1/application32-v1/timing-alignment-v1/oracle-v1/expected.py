"""Independent selected32 lifecycle model. Never reads execution/checker output.

The earlier independent codec/world model is reused as source-model code only;
new registration, receipts, logical observer and TS lifecycle fields are derived
here from the timing-alignment subject, not copied from retained output.
"""
import copy
import json
from pathlib import Path

ROOT = Path('/workspace/formal-proofs/bendvy')
PRIOR = ROOT / 'experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/oracle-v1/expected.py'
namespace = {'__name__': 'independent_prior', '__file__': str(PRIOR)}
exec(compile(PRIOR.read_bytes(), str(PRIOR), 'exec'), namespace)
c, raw, some = (namespace[k] for k in ('c', 'raw', 'some'))
inputs, input_view, owner = (namespace[k] for k in ('inputs', 'input_view', 'owner'))
CASES = namespace['CASES']
U = {'undefined': True}

def receipt(kind, system, target, payload):
    return c('Queued', kind=kind, system=system, namespace=1, id=target, payload=payload)

def marker_receipt():
    return receipt('insert', 'queue', 1, c('MarkerPayload', value=1))

def spawn_receipt(value, canonical):
    return receipt('spawn', 'application32', 2,
                   c('ComponentPayload', owner=owner(canonical, [111,222], value, True)))

def native_report(name, operation):
    value, _, canonical = inputs()[name]
    report = namespace['report'](name, operation)
    valid = name not in ('lateInvalid', 'nestedMissing')
    for phase in ('before', 'committed', 'barrier'):
        snapshot = report[phase]
        snapshot['meta']['registrations'] = [
            c('RegistrationMeta', id=3, name='application32', access=['Value','Resource','Marker']),
            c('RegistrationMeta', id=2, name='queue', access=['Marker']),
            c('RegistrationMeta', id=1, name='seed', access=['Value'])]
        snapshot['meta']['nextSystemId'] = 4
        receipts = [] if phase == 'barrier' else [marker_receipt()]
        if phase == 'committed' and valid and operation == 'spawn':
            receipts.append(spawn_receipt(value, canonical))
        snapshot['store']['receipts'] = receipts
    report['instance']['id'] = 3
    return report

def public_state(snapshot):
    slots = snapshot['store']['values']['slots']
    markers = snapshot['store']['marker']['slots']
    entities = []
    # World.live includes the reserved id0; columns are indexed id-1.
    for entity_id, live in enumerate(snapshot['live']):
        if entity_id and live:
            index = entity_id - 1
            entities.append(c('Entity', id=entity_id,
                value=copy.deepcopy(slots[index] if index < len(slots) else c('None')),
                marker=copy.deepcopy(markers[index] if index < len(markers) else c('None'))))
    receipts = snapshot['store']['receipts']
    pending = [c('Pending', kind=r['kind'], system=r['system'], target=r['id'],
                 payload=copy.deepcopy(r['payload'])) for r in receipts]
    physical = sum(2 if r['payload']['$'] == 'ComponentPayload' else 1 for r in receipts)
    return c('State', entities=entities, resource=copy.deepcopy(snapshot['resource']),
             pending=pending, logicalPendingCount=len(pending),
             receiptLoweringMatches=physical == snapshot['pending'])

def public_view(report):
    output = report['result']['output']['value']
    tag = output['$']
    if tag in ('Accepted', 'ResourceReplaced'):
        checked = c('Accepted', target=some(output['target']['id']) if tag == 'Accepted' else c('None'),
                    spawned=output.get('spawned', False), canonical=copy.deepcopy(output['canonical']))
    else:
        checked = c('Refused', input=copy.deepcopy(output['owner']) if tag == 'Refused' else some(copy.deepcopy(output['owner'])),
                    error=copy.deepcopy(output['error']) if tag == 'Refused' else c('Validation', error=copy.deepcopy(output['error'])))
    return c('View', original=copy.deepcopy(report['original']),
             before=public_state(report['before']), committed=public_state(report['committed']),
             barrier=public_state(report['barrier']), checked=checked)

def ts_owner(value, words=(111,222), flags=(True,False), original=None):
    return {'value':copy.deepcopy(value), 'original':copy.deepcopy(value if original is None else original),
            'sentinel':list(words), 'flags':list(flags)}

def ts_entity(entity_id, value, marker=False):
    return {'id':entity_id, 'components':{'Value':copy.deepcopy(value), **({'Marker':1} if marker else {})}, 'relations':{}}

def ts_dump(frame, tick, entities, resource, pending):
    return {'version':1, 'frame':frame, 'tick':tick, 'entityCount':len(entities),
            'entities':copy.deepcopy(entities), 'resources':{'Resource':copy.deepcopy(resource)},
            'machines':{}, 'pendingCommands':copy.deepcopy(pending)}

def ts_receipt(native):
    return {'kind':native['kind'], 'system':native['system'], 'target':native['id'],
            'payload':copy.deepcopy(native['payload'])}

def ts_trace(root, operation, name):
    value, seed, canonical = inputs()[name]
    incoming = ts_owner(value)
    initial = ts_owner(9, (333,444), (False,True))
    resource = ts_owner(seed, (555,666), (False,True))
    before = ts_dump(2,3,[ts_entity(1,initial)],resource,[{'tag':'insert','system':'queue'}])
    after = copy.deepcopy(before); after.update(frame=3,tick=4)
    valid = name not in ('lateInvalid','nestedMissing')
    if valid:
        constructed = ts_owner(canonical, original=value)
        checked = {'ok':True, 'value':[{'kind':'component','name':'Value'},constructed] if operation == 'spawn' else copy.deepcopy(U)}
        if operation == 'insert': after['entities'][0]['components']['Value'] = constructed
        elif operation == 'resource': after['resources']['Resource'] = constructed
        else: after['pendingCommands'].append({'tag':'spawn','system':'application32'})
    else:
        checked = {'ok':False,'error':{'_tag':'DecodeError', 'path':'$[127]' if name == 'lateInvalid' else '$.items[1].value',
            'expected':'integer', 'actual':'late-invalid' if name == 'lateInvalid' else copy.deepcopy(U)}}
    flushed = copy.deepcopy(after); flushed.update(frame=4,tick=5)
    flushed['pendingCommands'] = []; flushed['entities'][0]['components']['Marker'] = 1
    if operation == 'spawn' and valid:
        flushed['entities'].append(ts_entity(2,checked['value'][1])); flushed['entityCount'] = 2
    receipts = [ts_receipt(marker_receipt())]
    after_receipts = copy.deepcopy(receipts)
    if operation == 'spawn' and valid: after_receipts.append(ts_receipt(spawn_receipt(value,canonical)))
    return {'root':root,'operation':operation,'name':name,'original':copy.deepcopy(incoming),
            'checked':checked,'incomingAfter':copy.deepcopy(incoming),'before':before,'after':after,'flushed':flushed,
            'beforeReceipts':receipts,'afterReceipts':after_receipts,'flushedReceipts':[],
            'target':None if operation == 'resource' else (2 if valid else copy.deepcopy(U)) if operation == 'spawn' else 1}

def ts_public(trace):
    def observed_owner(value):
        return c('View',raw=raw(value['value']),original=raw(value['original']),
                 words=copy.deepcopy(value['sentinel']),flags=copy.deepcopy(value['flags']))
    def state(dump, receipts):
        rows = [c('Entity',id=e['id'],value=some(observed_owner(e['components']['Value'])),
                  marker=some(e['components']['Marker']) if 'Marker' in e['components'] else c('None'))
                for e in dump['entities']]
        commands = dump['pendingCommands']
        return c('State',entities=rows,resource=observed_owner(dump['resources']['Resource']),
                 pending=[c('Pending',**copy.deepcopy(r)) for r in receipts],
                 logicalPendingCount=len(receipts),receiptLoweringMatches=
                 len(commands)==len(receipts) and all(command['tag']==r['kind'] and command['system']==r['system']
                                                   for command,r in zip(commands,receipts)))
    incoming=trace['incomingAfter']
    original=c('InputView',raw=raw(trace['original']['value']),words=trace['original']['sentinel'],flags=trace['original']['flags'])
    if trace['checked']['ok']:
        if trace['operation']=='spawn': canonical=trace['checked']['value'][1]['value']
        elif trace['operation']=='resource': canonical=trace['after']['resources']['Resource']['value']
        else: canonical=trace['after']['entities'][0]['components']['Value']['value']
        checked=c('Accepted',target=c('None') if trace['operation']=='resource' else some(trace['target']),
                  spawned=trace['operation']=='spawn',canonical=raw(canonical))
    else:
        error=trace['checked']['error']
        actual=c('Missing') if error['actual']==U else raw(error['actual'])
        checked=c('Refused',input=some(c('InputView',raw=raw(incoming['value']),words=incoming['sentinel'],flags=incoming['flags'])),
                  error=c('Validation',error=c('Invalid',path=error['path'],expected=error['expected'],actual=actual)))
    return c('View',original=original,before=state(trace['before'],trace['beforeReceipts']),
             committed=state(trace['after'],trace['afterReceipts']),barrier=state(trace['flushed'],trace['flushedReceipts']),checked=checked)

def expected():
    common, native, ts = [], [], []
    for root, operation in (('Workshop','insert'),('Workshop','spawn'),('Workshop','resource'),('Garden','insert')):
        for name in CASES:
            report = native_report(name,operation)
            view = public_view(report)
            common.append(c(root,operation=operation,name=name,value=view))
            native.append(c(root,operation=operation,name=name,value=c('Whole',public=copy.deepcopy(view),native=report)))
            trace=ts_trace(root,operation,name)
            observed=ts_public(trace)
            assert observed==view, (root,operation,name)
            ts.append(c(root,operation=operation,name=name,value={'public':observed,'ts':trace}))
    return {'common':common,'native':native,'ts':ts}

if __name__ == '__main__':
    directory = Path(__file__).parent
    models = expected()
    for role, model in models.items():
        (directory / (role + '-expected.json')).write_text(json.dumps(model,indent=2)+'\n')
    (directory / 'ts-expected.stdout').write_text(json.dumps(models['ts'],separators=(',',':'),ensure_ascii=False)+'\n')
    text = json.dumps(models['common'],separators=(',',':'),ensure_ascii=False)
    (directory / 'common-expected.stdout').write_text(json.dumps(text,ensure_ascii=False)+'\n')
    (directory / 'ts-common-expected.stdout').write_text(text+'\n')
