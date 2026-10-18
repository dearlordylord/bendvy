"""Complete source-derived Lifecycle Health report, bound by SOURCE-BASIS."""
import argparse
import sys
from operations import Transaction
from health_program import World, Program, handle, listing, selftest as program_selftest


def report(count=64, iterations=64, primary_namespace=1, foreign_namespace=2):
    world, foreign = World(primary_namespace), World(foreign_namespace)
    tx = Transaction(world)
    reservations = []
    for index in range(count):
        reservations.append(tx.spawn([[index, index + 1, index + 2, index + 3],
                                      [1, 2, 3, 4] if index % 3 == 0 else None,
                                      8 if index % 3 == 1 else None]))
    tx.finish()
    text = (f'LifecycleRuntime Health\ncount={count};iterations={iterations}\nseedOutcome=Success;reservations='
            + listing('Reserved(' + handle(value) + ')' for value in reservations) + '\n')
    text += 'seedPending={' + world.wire() + '}\n'
    world.barrier()
    text += 'seedApplied={' + world.wire() + '}\n'
    tx = Transaction(foreign)
    foreign_handle = tx.spawn([[999, 1000, 1001, 1002], None, None])
    tx.finish()
    text += 'foreignSeedOutcome=Success;reservation=Reserved(' + handle(foreign_handle) + ')\n'
    text += 'foreignPending={' + foreign.wire() + '}\n'
    foreign.barrier()
    text += 'foreignApplied={' + foreign.wire() + '}\n'
    assert foreign.component(foreign_handle)[0] == 'Found'
    text += 'foreignOwnLookup=Found\nforeignVerified={' + foreign.wire() + '}\n'
    program = Program(world, foreign, foreign_handle, count)
    text += 'registered={' + program.wire() + '}\n'
    for _ in range(iterations):
        program.step()
    text += 'final={' + program.wire() + '}\n'
    return (text + '\n').encode(), program


def selftest():
    assert program_selftest()
    raw, program = report()
    assert raw.startswith(b'LifecycleRuntime Health\ncount=64;iterations=64\n')
    assert raw.endswith(b'\n\n')
    assert raw.count(b';before={') == 384
    assert raw.count(b';after={') == 384
    assert program.world.clock == 235
    assert 'cursor' not in program.local(0)
    assert [row[0] for row in program.world.rows()] == program.world.main_handles()
    assert len(program.world.registrations) == 4 and program.world.next_system == 5
    assert program.foreign_world.clock == 1
    from health_shared import compare_program, selftest as shared_selftest
    assert shared_selftest()
    assert compare_program(program)['digest'] == 4169183990
    return True


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('count', nargs='?', type=int, default=64)
    parser.add_argument('iterations', nargs='?', type=int, default=64)
    parser.add_argument('--self-test', action='store_true')
    args = parser.parse_args()
    if args.self_test:
        assert selftest()
        print('PASS Lifecycle source-model selftests')
    else:
        sys.stdout.buffer.write(report(args.count, args.iterations)[0])
