#!/usr/bin/env python3
"""Strict structural parser for the pinned compiler's pure Data term report.

Preserves constructor paths, field order, integers versus Nats, all lists and
strings. It neither projects gameplay fields nor supplies missing defaults.
"""
import json
import re
import sys
from pathlib import Path

TOKEN = re.compile(r'\s*("(?:[^"\\]|\\.)*"|[0-9]+n?|[^\s{},\[\]]+|[{},\[\]])')

def parse(text):
    tokens = []
    at = 0
    while at < len(text):
        if not text[at:].strip():
            break
        matched = TOKEN.match(text, at)
        if not matched:
            raise ValueError(f"Unparsed byte at {at}")
        tokens.append(matched.group(1))
        at = matched.end()
    index = 0
    def take():
        nonlocal index
        if index >= len(tokens):
            raise ValueError("Truncated term")
        item = tokens[index]
        index += 1
        return item
    def fields(end):
        result = []
        if index < len(tokens) and tokens[index] == end:
            take()
            return result
        while True:
            result.append(value())
            punctuation = take()
            if punctuation == end:
                return result
            if punctuation != ',':
                raise ValueError(f"Expected comma or {end}, got {punctuation}")
    def value():
        token = take()
        if token == '[':
            return fields(']')
        if token.startswith('"'):
            return json.loads(token)
        if re.fullmatch(r'[0-9]+n?', token):
            return {'nat': int(token[:-1])} if token.endswith('n') else int(token)
        if token in '{}],':
            raise ValueError(f"Unexpected punctuation: {token}")
        if take() != '{':
            raise ValueError("Expected constructor fields")
        return {'constructor': token, 'fields': fields('}')}
    result = value()
    if index != len(tokens):
        raise ValueError("Trailing term tokens")
    return result

def render(value):
    if isinstance(value, list):
        return '[' + ', '.join(map(render, value)) + ']'
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, int):
        return str(value)
    if set(value) == {'nat'}:
        return str(value['nat']) + 'n'
    if set(value) == {'constructor', 'fields'}:
        return value['constructor'] + '{' + ', '.join(map(render, value['fields'])) + '}'
    raise ValueError('Unexpected report shape')

if __name__ == '__main__':
    source = Path(sys.argv[1]).read_text()
    report = parse(source)
    if render(report) != source.strip():
        raise ValueError('Whole-report byte roundtrip failed')
    print(json.dumps(report, indent=2, ensure_ascii=False))
