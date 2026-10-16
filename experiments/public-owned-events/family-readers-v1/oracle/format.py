"""Literal formatting of frozen 21ddb0860 family-readers-v1 observations.

Pure rendering only: no scenario transition, allocator, cursor or retention model.
Schema is agreed with independent model author. Arrays are flattened physical
leaf order with power-of-two length; Crates payload adds one outer Array layer.
"""


def _bool(value):
    assert isinstance(value, bool)
    return 'True' if value else 'False'


def _list(values, render=str):
    # Primary Base List.show, including comma-space separator.
    return '[' + ', '.join(render(x) for x in values) + ']'


def _items(values, render):
    # Affine observer V.items; this is deliberately not List.show.
    return ''.join(render(x) + ';' for x in values) + '[]'


def _tuple(values):
    return '(' + ','.join(_bool(x) if isinstance(x, bool) else str(x) for x in values) + ')'


def _array(values, leaf=str):
    assert len(values) and len(values) & (len(values) - 1) == 0
    if len(values) == 1:
        return 'L(' + leaf(values[0]) + ')'
    middle = len(values) // 2
    return 'N(' + _array(values[:middle], leaf) + ',' + _array(values[middle:], leaf) + ')'


def _payload(payload, family):
    if family == 'Crates':
        return _array(payload, lambda row: _array(row))
    return _array(payload)


def _row(row, family):
    identity, payload = row
    return str(identity) + ':' + _payload(payload, family)


def _publication(record):
    # The actual ordinary family injection is a singleton at its typed leaf.
    family, identity = record['family'], record['id']
    assert family in ('Cargo', 'Alerts', 'Crates')
    if family == 'Cargo':
        return f'Pub(first=[{identity}],second=[])'
    inner = (f'Pub(first=[{identity}],second=[])' if family == 'Alerts'
             else f'Pub(first=[],second=[{identity}])')
    return f'Pub(first=[],second=[{inner}])'


def _batch(batch):
    tick, values = batch
    return f'({tick},{_list(values)})'


def _journal_batch(batch):
    tick, values = batch
    return f'({tick},{_list(values, _publication)})'


def _stream(stream):
    return (f'stream(domain={stream["domain"]},batches={_list(stream["batches"], _batch)},'
            f'positions={_list(stream["positions"], _tuple)},'
            f'statuses={_list(stream["statuses"], _tuple)},next={stream["next"]},'
            f'frameStart={stream["frameStart"]},boundary={stream["boundary"]},'
            f'capacity={stream["capacity"]},dropped={stream["dropped"]})')


def _column(rows):
    output = []
    for row in rows:
        assert len(row['components']) == 1
        name, value, changed, added = row['components'][0]
        assert name == 'Value'
        optional = 'None' if value is None else f'Some({value})'
        output.append(f'row{row["entity"]}={optional}@({added},{changed});')
    return ''.join(output)


def _meta(meta):
    identity, name, access = meta
    return f'({identity},{name},{_list(access)})'


def _world(world):
    log_text = []
    for family in ('Cargo', 'Alerts', 'Crates'):
        log = world['logs'][family]
        log_text.append(f'{family}=log(next={log["next"]},rows='
                        + _items(log['rows'], lambda row: _row(row, family)) + ')')
    return (f'world(ns={world["ns"]},next={world["next"]},high={world["high"]},'
            f'live={_array(world["live"], _bool)},capacity={world["capacity"]},'
            f'depth={world["depth"]},column={{{_column(world["column"])}}},'
            f'user={_array(world["user"])},' + ','.join(log_text)
            + f',events={_list(world["events"], _publication)},pending={world["pending"]},'
            f'regs={_list(world["regs"], _meta)},sid={world["sid"]},clock={world["clock"]})')


def render_runtime(runtime):
    family = ','.join(name + '=' + _stream(runtime['streams'][name])
                      for name in ('Cargo', 'Alerts', 'Crates'))
    assert runtime['owners'] == 'Unit'
    state = (f'state({family},owners={runtime["owners"]},'
             f'journal={_list(runtime["journal"], _journal_batch)},'
             f'journalSize={runtime["journalSize"]},frameStart={runtime["frameStart"]})')
    return f'runtime(tick={runtime["tick"]},{_world(runtime["world"])},{state})'


def _registry(meta):
    namespace, _ = meta['handle']
    return (f'({namespace},{meta["registry_id"]},{meta["name"]},'
            f'{_list(meta["access"])},cursor={meta["cursor"]})')


def _publisher(meta):
    namespace, _ = meta['handle']
    return (f'publisher(ns={namespace},id={meta["registry_id"]},name={meta["name"]},'
            f'access={_list(meta["access"])},cursor={meta["cursor"]})')


def _reader(meta):
    namespace, identity = meta['handle']
    return f'({namespace},{identity},{meta["registry_id"]})'


def render_args(args):
    projection = lambda p: f'({p[0]},{_list(p[1])})'
    return (f'args(fail={_bool(args["fail"])},values={_list(args["values"], projection)},'
            f'scratch={_array(args["scratch"])})')


def render_snapshot(label, runtime, foreign, publisher_meta, readers, args):
    # Source snapshot has no LF; its caller owns any following separator.
    text = (label + '|' + render_runtime(runtime) + '|foreign='
            + render_runtime(foreign) + '|publisher=' + _publisher(publisher_meta))
    for name in ('fast', 'slow', 'alerts', 'crates'):
        text += '|' + name + '=' + _reader(readers[name]) + ':' + _registry(readers[name])
    return text + '|args=' + render_args(args)


def render_retired(receipt):
    return 'retired(' + ','.join(
        family + '=' + _items(rows, lambda row: _row(row, family))
        for family, rows in zip(('Cargo', 'Alerts', 'Crates'), receipt, strict=True)) + ')'


def _literal_controls():
    # Small source-literal controls; no scenario or expected state assumptions.
    assert _array([True, False], _bool) == 'N(L(True),L(False))'
    assert _list([1, 2]) == '[1, 2]'
    assert _items([(7, [20, 21])], lambda r: _row(r, 'Cargo')) == '7:N(L(20),L(21));[]'
    assert _payload([[1, 2], [3, 4]], 'Crates') == 'N(L(N(L(1),L(2))),L(N(L(3),L(4))))'
    assert _column([{'entity': 8, 'components': [('Value', None, 9, 3)]}]) == 'row8=None@(3,9);'
    assert _publication({'family': 'Alerts', 'id': 2}) == 'Pub(first=[],second=[Pub(first=[2],second=[])])'
    assert _tuple((1, 2, 3, 4, False)) == '(1,2,3,4,False)'
    assert render_args({'fail': True, 'values': [(8, [90, 91])], 'scratch': (4, 2)}) == 'args(fail=True,values=[(8,[90, 91])],scratch=N(L(4),L(2)))'
    assert render_retired(([], [], [])) == 'retired(Cargo=[],Alerts=[],Crates=[])'


if __name__ == '__main__':
    _literal_controls()
    print('literal observer format controls passed')
