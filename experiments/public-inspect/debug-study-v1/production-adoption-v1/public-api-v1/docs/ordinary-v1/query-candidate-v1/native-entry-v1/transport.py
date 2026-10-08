#!/usr/bin/env python3
"""Strict fixture-only single-category transport, preserving the complete nested join."""
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('complete_debug_parser', HERE.parent / 'parse-scenario.py')
PARSER = importlib.util.module_from_spec(spec)
spec.loader.exec_module(PARSER)
CATEGORIES = ('plain', 'transient', 'constructed')


def normalize(raw, inventory, join, category):
    if category not in CATEGORIES:
        raise ValueError('Unknown partition category')
    term = PARSER.parse_term(raw)
    if not isinstance(term, dict) or set(term) != {'constructor', 'fields'}:
        raise ValueError('Partition requires exact Data report')
    if inventory['constructors'].get(term['constructor']) != 'Output.Report':
        raise ValueError('Partition requires exact report constructor; explicit failure refused')
    if type(term['fields']) is not list or len(term['fields']) != 1:
        raise ValueError('Partition report requires exactly one ScenarioReport')
    # Only the fixture transport root changes; every nested typed field is checked
    # by the independently reviewed full parser. No observations are fabricated.
    lifted = {'constructor': term['constructor'], 'fields': term['fields'] * 3}
    complete = PARSER.normalize(lifted, inventory['constructors'], join)
    PARSER.strict_equal(complete['plain'], complete['transient'])
    PARSER.strict_equal(complete['plain'], complete['constructed'])
    result = complete['plain']
    if result['category'] != category:
        raise ValueError('Wrong actual category for partition')
    return result


def aggregate(raw_by_category, inventories, join, expected):
    if set(raw_by_category) != set(CATEGORIES) or set(inventories) != set(CATEGORIES):
        raise ValueError('All three exact partitions required')
    result = {category: normalize(raw_by_category[category], inventories[category], join, category)
              for category in CATEGORIES}
    PARSER.strict_equal(result, expected)
    return result
