"""Reuse the existing full oracle and constructor check with current-stage preparation."""
import importlib.util
from pathlib import Path

HERE = Path(__file__).resolve().parent
DELIVERY = HERE.parent
COMPARATOR_PATH = DELIVERY / 'compare.py'
SPEC = importlib.util.spec_from_file_location('ordinary_v7_current_base_compare', COMPARATOR_PATH)
BASE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(BASE)
BASE_PARSER_FUNCTIONS = BASE.parser_functions

# run-delivery.py loads prepare-current.py as the pinned ``prepare`` helper before
# loading this comparator.  Consequently the existing comparator's imported
# expected_stage() is the exact current-source generator while its full constructor
# and report validation remain unchanged.


def parser_functions():
    return BASE_PARSER_FUNCTIONS()


def stage_joins(stage):
    return BASE.stage_joins(stage)


def validate_report(raw, literal_to_neutral):
    # The existing delivery runner injects its pinned parser through this public
    # helper binding before validating JS and Native stdout.
    BASE.parser_functions = parser_functions
    return BASE.validate_report(raw, literal_to_neutral)
