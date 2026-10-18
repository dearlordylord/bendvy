"""Reuse the byte-identical generic physical state; no schema specialization."""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'lifecycle-motion64/model/source'))
from operations import World, Column, Transaction, Handle, Key, selftest
