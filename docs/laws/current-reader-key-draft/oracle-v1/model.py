"""Source-derived finite oracle; never reads candidate/spec outputs or Bend files."""
from dataclasses import dataclass, replace
import sys

VARIANTS = ('normal', 'generation-omission', 'failed-reader-advance',
            'dropped-metadata-loss', 'explicit-advance-zero')
EXISTING = ((1, 2, 1), (2, 4, 3))
DUPLICATE = EXISTING + ((1, 5, 4),)
MAX = 4294967295

@dataclass(frozen=True)
class Stream:
    domain: str = 'typed'
    batches: tuple = ((9, (1, 2)), (1, ()))
    positions: tuple = EXISTING
    next_reader: int = 9
    frame: int = 4
    boundary: int = 3
    capacity: int = 5
    dropped: int = 6


def complete(positions, reader, tick, success):
    # Define the output by membership and each input record's observable fields.
    result = tuple((rid, tick if success and rid == reader else cursor, registered)
                   for rid, cursor, registered in positions)
    if reader not in {rid for rid, _, _ in positions}:
        result = ((reader, tick if success else 0, max(0, tick - 1)),) + result
    return result


def show_list(items):
    return '[' + ', '.join(items) + ']'


def show_positions(positions):
    return show_list(':'.join(map(str, p)) for p in positions)


def show_stream(s):
    batches = show_list(f'{tick}:' + show_list(map(str, values))
                        for tick, values in s.batches)
    return (f'{s.domain};b={batches};p={show_positions(s.positions)};'
            f'next={s.next_reader};frame={s.frame};boundary={s.boundary};'
            f'capacity={s.capacity};dropped={s.dropped}')


def rows(variant):
    result = []
    def add(name, actual, expected):
        result.append((name, actual, expected))
    for name, left, right in (
            ('same', (1, 2), (1, 2)), ('generation', (1, 2), (1, 3)),
            ('index', (1, 2), (2, 2)), ('max', (MAX, MAX), (MAX, MAX))):
        expected = left == right
        actual = left[0] == right[0] if variant == 'generation-omission' else expected
        add('full_key_equality/' + name, str(actual), str(expected))
    for name, values, reader, tick, success in (
            ('existing-failure', EXISTING, 1, 8, False),
            ('absent-failure', EXISTING, 3, 8, False),
            ('duplicates-success', DUPLICATE, 1, 8, True),
            ('zero-boundary', ((0, 5, 7),), 0, 0, True)):
        expected = complete(values, reader, tick, success)
        actual = complete(values, reader, tick, success or variant == 'failed-reader-advance')
        add('selected_completion_positions/' + name,
            show_positions(actual), show_positions(expected))
    for name, reader, success in (
            ('existing-failure', 1, False), ('existing-success', 1, True),
            ('absent-failure', 3, False), ('absent-success', 3, True)):
        expected = replace(Stream(), positions=complete(EXISTING, reader, 8, success))
        actual = replace(Stream(), positions=complete(EXISTING, reader, 8,
                         success or variant == 'failed-reader-advance'),
                         dropped=0 if variant == 'dropped-metadata-loss' else 6)
        add('stream_completion_fields/' + name, show_stream(actual), show_stream(expected))
    for name, values, reader, tick in (
            ('existing', EXISTING, 1, 8), ('absent', EXISTING, 3, 8),
            ('duplicates', DUPLICATE, 1, 8), ('max-zero', ((MAX, 5, 7),), MAX, 0)):
        expected_positions = complete(values, reader, tick, True)
        actual_positions = tuple((rid, 0 if rid == reader else cursor, registered)
                                 for rid, cursor, registered in expected_positions
                                 ) if variant == 'explicit-advance-zero' else expected_positions
        add('stream_explicit_advance/' + name,
            show_stream(replace(Stream(), positions=actual_positions)),
            show_stream(replace(Stream(), positions=expected_positions)))
    return result


def stdout(variant):
    return ''.join('|'.join(row) + '\n' for row in rows(variant)) + '\n'


if __name__ == '__main__':
    variant = sys.argv[1] if len(sys.argv) == 2 else 'normal'
    if variant not in VARIANTS:
        raise SystemExit('unknown variant: ' + variant)
    sys.stdout.write(stdout(variant))
