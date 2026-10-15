"""Complete finite source model; final source freeze must precede oracle sealing."""
import gzip
import hashlib
import importlib.util
import json
from copy import deepcopy
from pathlib import Path

import debug
import observer
from scenario import Scenario
from stream import listing

HERE = Path(__file__).resolve().parent
FAST_NAME, SLOW_NAME = 'condition-readers-fast', 'condition-readers-slow'
LEVEL_NAME, FLOW_NAME = 'condition-level-changed', 'condition-flow-changed'
REGISTRATIONS = [(1, FAST_NAME, ['machine.Level.transition.read']),
                 (2, SLOW_NAME, ['machine.Flow.transition.read']),
                 (3, LEVEL_NAME, ['machine.Level.changed']),
                 (4, FLOW_NAME, ['machine.Flow.changed'])]
FAST_DESCRIPTION = ('(in_state(Flow) && ' + LEVEL_NAME + ')',
                    ['machine.Flow.current', 'machine.Level.changed'],
                    [('InState', 'Flow'), ('StateChanged', 1, 3, LEVEL_NAME, ['machine.Level.changed'])])
SLOW_DESCRIPTION = ('(!(in_state(Level)) || ' + FLOW_NAME + ')',
                    ['machine.Level.current', 'machine.Flow.changed'],
                    [('InState', 'Level'), ('StateChanged', 1, 4, FLOW_NAME, ['machine.Flow.changed'])])
CONDITIONS = [(1, FAST_DESCRIPTION), (2, SLOW_DESCRIPTION)]
STEPS = [(('System', 1, 0), []), (('System', 2, 0), [])]
PLACEMENTS = [('System', 0, 1, 1, FAST_NAME, 0, []),
              ('System', 1, 1, 2, SLOW_NAME, 0, [])]
CONDITION_PLACEMENTS = [(0, 1, 1, 0, FAST_DESCRIPTION), (1, 1, 2, 0, SLOW_DESCRIPTION)]


def applicability(source):
    main = (source / 'main.bend').read_text()
    trace = (source / 'trace.bend').read_text()
    systems = (source / 'systems.bend').read_text()
    guards = (source / 'guards.bend').read_text()
    assert 'Systems.register(~S,world)' in main
    assert 'world,"condition-level-changed"' in main
    assert 'world,"condition-flow-changed"' in main
    assert 'Schema.Schema{[]}' in main and 'Tree.Recipe{},True{}' in main
    assert '"ordinary-machine-condition-readers"' in main
    assert 'SP.Entry{Sch.System{fastId,0},[]},SP.Entry{Sch.System{slowId,0},[]}' in main
    assert '"condition-readers-fast",["machine.Level.transition.read"]' in systems
    assert '"condition-readers-slow",["machine.Flow.transition.read"]' in systems
    assert 'P.Play{}),Comp.state_changed' in guards
    assert 'P.High{})),Comp.state_changed' in guards
    assert 'append_level(~S,append_flow(~S,app,P.Pause{}),P.High{})' in trace
    assert 'append_flow(~S,app,P.Play{})' in trace
    for label in ['initial-run', 'flow-pause-level-high', 'flow-play-repeat']:
        assert '"' + label + '"' in trace
    # Callback observes active prior cursor and stores completion, then the real
    # Sys.run_tracked adopts the unchanged current World clock.
    assert 'St.observe(~P.Level,active,id,tick)' in systems
    assert 'St.complete(~P.Level,active,id,tick,True{})' in systems
    assert 'W.advance_clock' not in systems


def derive(source):
    applicability(source)
    app = Scenario()
    app.initialize('flow', 'Play')
    app.initialize('level', 'Low')
    fast_cursor = slow_cursor = 0
    fast_last = slow_last = None
    rows, timeline = [], []
    for index, label in enumerate(['initial-run', 'flow-pause-level-high', 'flow-play-repeat']):
        if index == 1:
            app.insert('flow', 'Pause')
            app.insert('level', 'High')
        elif index == 2:
            app.insert('flow', 'Play')
        observations = []
        if app.fast_guard().value:
            fast_last = app.level.stream.read(1, app.clock)
            app.level.stream.complete(1, app.clock)
            fast_cursor = app.clock
            observations.append(('Ran', 1))
        else:
            observations.append(('Skipped', 1))
        if app.slow_guard().value:
            slow_last = app.flow.stream.read(2, app.clock)
            app.flow.stream.complete(2, app.clock)
            slow_cursor = app.clock
            observations.append(('Ran', 2))
        else:
            observations.append(('Skipped', 2))
        fast = (1, 1, FAST_NAME, ['machine.Level.transition.read'], fast_cursor, 1, 1, fast_last)
        slow = (1, 2, SLOW_NAME, ['machine.Flow.transition.read'], slow_cursor, 1, 2, slow_last)
        owner_text = observer.owners(fast, slow)
        guard_text = observer.bindings(app, 1, 2, (1, 3, LEVEL_NAME, ['machine.Level.changed']),
                                       (1, 4, FLOW_NAME, ['machine.Flow.changed']))
        world_text = observer.world(app, REGISTRATIONS)
        body_bindings = [(1, 1, FAST_NAME, ['machine.Level.transition.read'], fast_cursor, FAST_NAME, []),
                         (1, 2, SLOW_NAME, ['machine.Flow.transition.read'], slow_cursor, SLOW_NAME, [])]
        application = ([], body_bindings, world_text, [world_text])
        schedule = (application, 1, 'ordinary-machine-condition-readers', STEPS)
        view = ((schedule, PLACEMENTS), CONDITIONS, CONDITION_PLACEMENTS)
        rows.append(label + ':status=finished;schedule=' + debug.schedule_observations(observations)
                    + ';owners=' + owner_text + ';conditions=' + guard_text + ';debug=' + debug.debug(view) + '\n')
        timeline.append(deepcopy(dict(label=label, clock=app.clock, flow=app.flow.__dict__, level=app.level.__dict__,
                                      fastChanged=app.fast_changed_level.__dict__, slowChanged=app.slow_changed_flow.__dict__,
                                      fastCursor=fast_cursor, slowCursor=slow_cursor,
                                      fastLast=fast_last, slowLast=slow_last, observations=observations)))
    assert [item['clock'] for item in timeline] == [2, 4, 5]
    assert [item['fastChanged']['revision'] for item in timeline] == [1, 1, 2]
    assert [item['slowChanged']['revision'] for item in timeline] == [0, 2, 3]
    assert timeline[1]['fastCursor'] == 2 and timeline[2]['fastCursor'] == 5
    assert timeline[1]['fastLast'] == (['initial:Low'], False)
    assert timeline[2]['fastLast'] == (['initial:High'], False)
    assert timeline[1]['level']['stream'].batches == timeline[2]['level']['stream'].batches == [(4, 'initial:High')]
    assert timeline[0]['slowChanged']['cursor'] == 0
    assert all(item['flow']['previous'] is item['level']['previous'] is None for item in timeline)
    return ''.join(rows), timeline


def selftest():
    import conditions
    import scenario
    import stream
    conditions.selftest()
    scenario.selftest()
    stream.selftest()
    observer.selftest()
    debug.selftest()
    freeze = json.loads((HERE / 'source-freeze.json').read_text())
    for path, expected in json.loads((HERE / 'source-pins.json').read_text()).items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest() == expected, path
    source = Path(freeze['snapshot']) / Path(freeze['entrypoint']).parent
    entry = (Path(freeze['snapshot']) / freeze['entrypoint']).read_text()
    assert 'def main() -> String:' in entry
    assert 'Trace.trace(~P.SchemaA) ++ Trace.trace(~P.SchemaB)' in entry
    assert 'IO.print' not in entry
    text, timeline = derive(source)
    assert text.count('\n') == 3
    assert all(character == '\n' or 32 <= ord(character) <= 126 for character in text)
    wire = (json.dumps(text + text) + '\n').encode()
    assert wire.count(b'\n') == 1 and wire.endswith(b'\\n"\n')
    # Independently reproduce the retained historical oracle before reuse of
    # its stream/list conventions. This is Python model execution, no backend.
    legacy = HERE.parent.parent / 'model.py'
    spec = importlib.util.spec_from_file_location('historical_condition_model', legacy)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    historical = module.render()
    assert historical == gzip.decompress((legacy.parent / 'A-expected.stdout.gz').read_bytes())
    assert hashlib.sha256(historical).hexdigest() == 'ab4bc9d3df7f6a92b4163efab168ec97bfaed8a3f90e00be5dba0237c5d4e5d7'
    return wire, timeline


if __name__ == '__main__':
    wire, timeline = selftest()
    (HERE / 'expected.stdout').write_bytes(wire)
    (HERE / 'expected.stdout.gz').write_bytes(gzip.compress(wire, mtime=0))
    digest = hashlib.sha256(wire).hexdigest()
    (HERE / 'expected.sha256').write_text(digest + '  expected.stdout\n')
    (HERE / 'timeline.json').write_text(json.dumps(timeline, default=lambda value: value.__dict__, indent=2) + '\n')
    print('PASS', len(wire), digest)
