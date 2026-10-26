"""Contract model: reject a foreign snapshot, retain the owner, then invoke once."""
from pathlib import Path
import runpy

query = runpy.run_path(str(Path(__file__).resolve().parents[1] / "parallel-query" / "oracle.py"))


def world(namespace, invoked):
    outputs = dict(query["INITIAL_OUTPUTS"])
    stamps = {}
    if invoked:
        for index in (1, 17):
            token, value = outputs[index]
            outputs[index] = token + 1, value + query["INPUTS"][index][1]
            stamps[index] = 1
    registrations = '[1:prepared-author:[input, output]]' if invoked else '[]'
    next_id = 2 if invoked else 1
    tick = 1 if invoked else 0
    return (f'namespace={namespace};allocator={{{query["allocator"](18)}}};'
            + f'input={query["column"](query["INPUTS"], {})};'
            + f'output={query["column"](outputs, stamps)};'
            + 'resource=800;events=0;legacy-pending=0;'
            + f'registrations={registrations};next={next_id};clock=0:{tick}:[];'
            + f'journal={{namespace={namespace};next-reader=1;active=[];channels=[]}}')


def scenario(original_namespace, foreign_namespace):
    before = (f'{original_namespace}:1:prepared-author:[input, output]:'
              + 'never:900:0:false')
    after = (f'{original_namespace}:1:prepared-author:[input, output]:'
             + '0:1:901:1')
    queue = '[' + ', '.join(
        f'{original_namespace}:{index}:0:{1000 + index}:{600 + index}'
        for index in (1, 17)
    ) + ']'
    return ('foreign=refused;foreign-status=[];retained=' + before
            + ';retry=invoked;retry-status=[1:error:query-body:[1:after-enqueue]]'
            + ';owner=' + after + ';queue=' + queue + ';receipts=[];original={'
            + world(original_namespace, True) + '};foreign={'
            + world(foreign_namespace, False) + '}')


if __name__ == '__main__':
    print('First=' + scenario(1, 2))
    print('Second=' + scenario(3, 4))
