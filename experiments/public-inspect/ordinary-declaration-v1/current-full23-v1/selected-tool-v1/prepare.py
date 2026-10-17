#!/usr/bin/env python3
"""Materialize the exact reviewed CLI from the existing pinned ELF; no subprocesses."""
from pathlib import Path
import argparse
import hashlib
import json
import os

HERE = Path(__file__).resolve().parent

def digest(data):
    return hashlib.sha256(data).hexdigest()

def prepare(output):
    spec = json.loads((HERE / 'RECIPE.json').read_text())
    elf = Path(spec['elf']).read_bytes()
    if digest(elf) != spec['elfSHA256']:
        raise ValueError('pinned underlying ELF differs')
    prefix = bytes.fromhex(spec['embeddedPrefixHex'])
    if elf.count(prefix) != 1:
        raise ValueError('embedded CLI prefix must occur exactly once')
    at = elf.index(prefix)
    original = elf[at:at + spec['originalBytes']]
    if digest(original) != spec['originalSHA256']:
        raise ValueError('embedded original CLI differs')
    selected = original.decode()
    for patch in spec['patches']:
        if selected.count(patch['original']) != 1:
            raise ValueError('patch anchor must occur exactly once: ' + patch['name'])
        selected = selected.replace(patch['original'], patch['replacement'])
    if digest(selected.encode()) != spec['selectedCLISHA256']:
        raise ValueError('selected CLI differs')
    inverse = selected
    for patch in reversed(spec['patches']):
        if inverse.count(patch['replacement']) != 1:
            raise ValueError('inverse anchor must occur exactly once')
        inverse = inverse.replace(patch['replacement'], patch['original'])
    if inverse.encode() != original:
        raise ValueError('recipe inverse differs')
    resources = Path(spec['resourceRoot'])
    actual = {str(p.relative_to(resources)): digest(p.read_bytes())
              for p in sorted(resources.rglob('*')) if p.is_file()}
    if actual != spec['resourceFiles']:
        raise ValueError('pinned resource bytes or membership differ')
    compiler = output / 'compiler'
    compiler.mkdir(parents=True, exist_ok=True)
    cli = compiler / 'cli.mjs'
    if cli.exists():
        if cli.read_bytes() != selected.encode():
            raise ValueError('refuse to replace differing prepared CLI')
    else:
        fd = os.open(cli, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o644)
        with os.fdopen(fd, 'wb') as stream:
            stream.write(selected.encode())
    for name in spec['resourceAliases']:
        link, target = compiler / name, resources / name
        if link.is_symlink():
            if link.resolve(strict=True) != target.resolve(strict=True):
                raise ValueError('prepared resource alias differs')
        elif link.exists():
            raise ValueError('refuse to replace a non-alias resource')
        else:
            link.symlink_to(target, target_is_directory=target.is_dir())
    return {'scope': spec['scope'], 'elf': spec['elf'],
            'elfSHA256': spec['elfSHA256'], 'cli': str(cli.resolve()),
            'cliSHA256': digest(cli.read_bytes()),
            'recipeSHA256': digest((HERE / 'RECIPE.json').read_bytes()),
            'resourceRoot': str(resources), 'resourceCount': len(actual),
            'patches': len(spec['patches']), 'inversePASS': True,
            'commandsExecuted': False}

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=HERE / 'prepared')
    args = parser.parse_args()
    record = prepare(args.output.resolve())
    (args.output / 'PREPARED.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(record, indent=2))
