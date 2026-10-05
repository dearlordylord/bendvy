#!/usr/bin/env python3
"""Prepare an isolated private Held template candidate, never a timing keep."""
import argparse
import hashlib
import importlib.util
import json
import pathlib
import re

HERE = pathlib.Path(__file__).resolve().parent
RECIPE = HERE.parent / 'fivehour-cache-integration/materialize.py'

def arguments(text):
    result, start, depth = [], 0, 0
    for i, char in enumerate(text):
        if char in '<({[': depth += 1
        elif char in '>)}]': depth -= 1
        elif char == ',' and depth == 0:
            result.append(text[start:i]); start = i + 1
    result.append(text[start:])
    return result

def prepare(destination, native=False, provider_only=False):
    spec = importlib.util.spec_from_file_location('held_recipe', RECIPE)
    recipe = importlib.util.module_from_spec(spec); spec.loader.exec_module(recipe)
    core = recipe.materialize(destination, native_payload=native)
    original = (core / 'held.bend').read_text()
    additions = []
    for name in ('main_read', 'main_write', 'ledger_read', 'ledger_write'):
        match = re.search(r'^def ' + name + r'\(', original, re.M)
        end = original.find('\ndef ', match.start() + 1)
        chunk = original[match.start():end if end >= 0 else len(original)]
        chunk = chunk.replace('def ' + name + '(', 'def ' + name + '_static(', 1)
        # Type parameters and trusted provider are all static specialization inputs.
        if not provider_only:
            chunk = re.sub(r'-(W|M|L|H|C|V):', r'~\1:', chunk)
        chunk = chunk.replace(',get:', ',~get:').replace(',swap:', ',~swap:')
        additions.append(chunk.rstrip())
    (core / 'held.bend').write_text(original.rstrip() + '\n\n' + '\n\n'.join(additions) + '\n')
    adapter = core / 'held-adapter.bend'; text = adapter.read_text(); count = 0
    pattern = r'H\.(main_read|main_write|ledger_read|ledger_write)\('
    offset = 0
    while (match := re.search(pattern, text[offset:])):
        begin = offset + match.start(); start = offset + match.end(); i = start; depth = 1
        while depth:
            depth += (text[i] == '(') - (text[i] == ')'); i += 1
        args = arguments(text[start:i-1]); static = 7 if match[1].endswith('read') else 6
        assert len(args) == (8 if static == 7 else 8)
        replacement = 'H.' + match[1] + '_static(' + ','.join('~' + arg if (n == static-1 if provider_only else n < static) else arg for n, arg in enumerate(args)) + ')'
        text = text[:begin] + replacement + text[i:]; offset = begin + len(replacement); count += 1
    assert count == 8
    adapter.write_text(text)
    pins = {str(p.relative_to(destination)): hashlib.sha256(p.read_bytes()).hexdigest() for p in pathlib.Path(destination).rglob('*.bend')}
    receipt = {'status': 'UNMEASURED_PRIVATE_TEMPLATE_CANDIDATE', 'sources': pins, 'originalHeldSHA256': hashlib.sha256(original.encode()).hexdigest(), 'providerCallSites': count, 'nativePayload': native, 'providerOnlyFrozen': provider_only}
    manifest_path = pathlib.Path(destination) / 'overlay.json'
    manifest = json.loads(manifest_path.read_text()); cache = manifest['cacheSpecialization']
    receipt['baselineRuntimeClosureSHA256'] = cache['runtimeClosureSHA256']
    cache['baselineRuntimeClosureSHA256'] = cache['runtimeClosureSHA256']
    cache['runtimeClosure'] = {name: pins[name] for name in cache['runtimeClosure']}
    cache['runtimeClosureSHA256'] = hashlib.sha256(json.dumps(cache['runtimeClosure'], sort_keys=True, separators=(',', ':')).encode()).hexdigest()
    for name in ('held.bend', 'held-adapter.bend'):
        key = 'experiments/s-integrate/' + name
        cache['specializedClosure'][key] = pins[key]
    cache['derivedPrivateVariant'] = 'held-static-provider-only-v1' if provider_only else 'held-static-trusted-provider-v1'
    manifest['sources'] = pins
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
    (pathlib.Path(destination) / 'cache-specialization.json').write_text(json.dumps(cache, indent=2) + '\n')
    (pathlib.Path(destination) / 'held-static-candidate.json').write_text(json.dumps(receipt, indent=2) + '\n')
    return core

if __name__ == '__main__':
    parser = argparse.ArgumentParser(); parser.add_argument('destination', type=pathlib.Path); parser.add_argument('--native-payload', action='store_true'); parser.add_argument('--provider-only', action='store_true'); args = parser.parse_args()
    print(prepare(args.destination, args.native_payload, args.provider_only))
