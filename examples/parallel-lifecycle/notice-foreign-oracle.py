"""Independent reader-provenance model; systems admit in B, reader tokens belong to A.

A completes twice and B once, generating colliding genuine family sequences.
System retirement releases each actual Local. B freshly registers A's retained
Local, so reader-operation refusal cannot be masked by system admission refusal.
"""
from pathlib import Path
import runpy

model = runpy.run_path(str(Path(__file__).with_name('notice-scenario-oracle.py')))
shown = model['shown']
ACCESS = '[removed/output, removed/input, despawn]'


def author(namespace, state):
    return (f'{namespace}:1:author:[input, output]:0:{state["author_cursor"]}'
            + ';user=902:2;handles=' + state['handles'] + ';pending=[];receipts='
            + shown(state['receipts']))


def scenario(a_namespace, b_namespace):
    left = model['scenario'](a_namespace, 2, return_state=True)
    right = model['scenario'](b_namespace, 1, return_state=True)
    final = model['scenario'](b_namespace, 2, return_state=True)
    # Retirement removes actual system registrations, not the independently
    # registered journal readers, whose tokens are preserved in released Local.
    a_world = left['world'].replace(f'2:reader:{ACCESS}, ', '')
    a_identity = f'{a_namespace}:2:reader:{ACCESS}:0:5'
    old_b_identity = f'{b_namespace}:2:reader:{ACCESS}:0:3'
    foreign_history = (left['history'] + 'update=2/fast=refused/foreign-world'
                       + '/slow=refused/foreign-world/input=refused/foreign-world'
                       + '/despawn=refused/foreign-world;')
    # Ordinary body effects are retained. All actual A reader cursors remain
    # exactly 2/0/1/1; no operation reads or resets a cursor against B's sequence.
    reader = (f'token=703;runs=3;fast={a_namespace}:1:2;slow={a_namespace}:2:0;'
              + f'input={a_namespace}:3:1;despawn={a_namespace}:4:1;history='
              + foreign_history)
    b_world = final['world'].replace(f'2:reader:{ACCESS}', f'3:foreign-reader:{ACCESS}')
    b_world = b_world.replace('next=3;clock=', 'next=4;clock=')
    report = shown(['ran:1:[]', 'ran:3:' + foreign_history])
    b_result = (report + '|world=' + b_world + '|queue=[]|receipts='
                + shown(final['receipts']) + '|handles=' + final['handles']
                + '|user=902:2|cursor=0:4|peer={' + reader
                + '}:0:5|handler=901:2|unapplied=[]')
    return ('A={world=' + a_world + ';author=' + author(a_namespace, left)
            + ';handler=901:2;reports=' + ';'.join(left['reports'])
            + ';retired=' + a_identity + '};B-retired={identity=' + old_b_identity
            + ';local=' + right['reader'] + ';reports=' + ';'.join(right['reports'])
            + '};B-rebound={' + b_result + '}')


if __name__ == '__main__':
    print('Foreign=' + scenario(2, 3))
