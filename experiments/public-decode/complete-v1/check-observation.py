#!/usr/bin/env python3
"""Whole structural observation joins; never drop fields or inject defaults."""
import argparse
import importlib.util
import json
import os
from pathlib import Path

HERE = Path(__file__).resolve().parent
PARSER = Path('/workspace/formal-proofs/bendvy/experiments/public-simulation/bend-v1/parse-report.py')
TYPED = Path('/workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend')
NAMES = ('array3','array128','array256','lateInvalid','struct64','nullableNull','nestedValid','nestedMissing')


def compare(stdout, expected, entry):
    spec = importlib.util.spec_from_file_location('decode_observation_parser', PARSER)
    parser = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(parser)
    raw = stdout.read_text()
    report = parser.parse(raw)
    assert parser.render(report) == raw.strip()
    prefix = os.path.relpath(TYPED.with_suffix(''), entry.parent) + '.'
    def constructor(value, name, count, module=None):
        assert set(value) == {'constructor','fields'}
        literal = name if module is None else module + '.' + name
        assert value['constructor'] == literal, (literal,value['constructor'])
        assert len(value['fields']) == count
        return value['fields']
    def term(value):
        assert set(value) == {'constructor','fields'}
        name = value['constructor']
        assert name.startswith(prefix), name
        name = name[len(prefix):]
        fields = value['fields']
        if name in ('Null','Missing'):
            assert fields == []
            return {name: {}}
        if name in ('Number','Text'):
            x, = fields
            return {name: x}
        if name in ('Array',):
            items, = fields
            return {name: [term(item) for item in items]}
        if name == 'Field':
            key, value = fields
            return {'Field': {'name': key, 'value': term(value)}}
        if name == 'Object':
            items, = fields
            return {'Object': [term(item) for item in items]}
        if name == 'Accepted':
            value, = fields
            return {'Accepted': term(value)}
        if name == 'Rejected':
            error, = fields
            return {'Rejected': term(error)}
        if name == 'Invalid':
            path, expected, actual = fields
            return {'Invalid': {'path': path, 'expected': expected, 'actual': term(actual)}}
        if name == 'FuelExhausted':
            path, = fields
            return {'FuelExhausted': {'path': path}}
        raise AssertionError(('Unexpected constructor', name))
    observations = constructor(report,'Report',8)
    actual = {}
    for name, value in zip(NAMES, observations):
        original, sentinel, checked = constructor(value,'Observation',3)
        assert isinstance(sentinel,list) and all(type(v) is int for v in sentinel)
        actual[name] = {'original':term(original),'sentinel':sentinel,'checked':term(checked)}
    def equal(a,b,path='$'):
        assert type(a) is type(b), ('Type mismatch',path,type(a),type(b))
        if isinstance(a,dict):
            assert set(a) == set(b), ('Object membership mismatch',path)
            for key in a:equal(a[key],b[key],path+'.'+key)
        elif isinstance(a,list):
            assert len(a) == len(b), ('List length mismatch',path,len(a),len(b))
            for index,(x,y) in enumerate(zip(a,b)):equal(x,y,path+'['+str(index)+']')
        else:
            assert a == b, ('Value mismatch',path,a,b)
    try:
        equal(actual,json.loads(expected.read_text()))
    except AssertionError as error:
        error.actual = actual
        raise
    return actual


if __name__ == '__main__':
    arguments = argparse.ArgumentParser(description=__doc__)
    arguments.add_argument('stdout',type=Path)
    arguments.add_argument('expected',type=Path)
    arguments.add_argument('entry',type=Path)
    args = arguments.parse_args()
    result = compare(args.stdout.resolve(),args.expected.resolve(),args.entry.resolve())
    print(json.dumps({'completeMatch':True,'cases':list(result)}))
