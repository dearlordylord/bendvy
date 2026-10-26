"""Expected observable Rust scenario state, without implementation imports."""
import json


def expected(admission):
    calls = ['write-error', 'after-error', 'after-disabled',
             'after-condition-error', 'after-refused']
    errors = ['system', 'condition']
    if admission == 'missing-resource':
        errors.append('system')
    return ''.join(json.dumps({
        'admission': admission, 'calls': calls * run, 'errors': errors * run,
        'local': run, 'run': run, 'value': run,
    }, sort_keys=True, separators=(',', ':')) + '\n' for run in [1, 2])


if __name__ == '__main__':
    import sys
    print(expected(sys.argv[1]), end='')
