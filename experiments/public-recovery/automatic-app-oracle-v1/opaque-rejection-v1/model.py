"""Independent complete opaque App admission refusal projection; no runtime input."""
def pair(seed):return f'node(leaf:{seed},leaf:{seed+1})'
def array(seed):return f'node(leaf:{pair(seed)},leaf:{pair(seed+2)})'
def schema(namespace):
    world=f'world{{namespace={namespace};nextId=1;highWater=0;live=leaf:False;capacity=1;depth=0;store={{Column{{values=leaf:none;stamps=[]}}}};resources={{target={array(20)};sameSibling={array(800)};otherSibling={pair(900)}}};events=[];pending=0;registrations=[1:prior-readonly-capture:[Payload]];nextSystemId=2;clock=0}}'
    previous=f'previous{{initial=Unit;prior{{namespace={namespace};id=1;name=prior-readonly-capture;access=[Payload];cursor=0;capture={pair(600)}}}}}'
    # Use.complete(D.description(raw Declaration)) is False before System.define.
    # Each refusal returns this actual BeforeApp plus the actual incoming Array.
    suffix='|app={world={'+world+'}|previous={'+previous+'}|recipe=Recipe|debug=True}|incomingCapture='+array(700)+'\n'
    return ''.join(label+suffix for label in ['before','first:rejected','repeat:rejected','terminal'])
def render():return ('Workshop\n'+schema(1)+'Garden\n'+schema(2)+'\n').encode()
def selftest():
    raw=render();assert raw.count(b'\n')==11 and raw.endswith(b'\n\n')
    assert raw.count(b'nextSystemId=2;clock=0')==8
    assert raw.count(b'incomingCapture=node(leaf:node(leaf:700,leaf:701),leaf:node(leaf:702,leaf:703))')==8
    assert raw.count(b':rejected|')==4
if __name__=='__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:sys.stdout.buffer.write(render())
