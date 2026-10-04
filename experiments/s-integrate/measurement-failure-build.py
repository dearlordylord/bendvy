#!/usr/bin/env python3
"""Diagnostic correctness build; O0, no performance acceptance."""
import pathlib,sys
sys.path.insert(0,str(pathlib.Path(__file__).resolve().parent.parent/'t05'))
from run import command
here=pathlib.Path(__file__).resolve().parent;folder=pathlib.Path('/tmp/bendvy-measurement-failure');folder.mkdir(exist_ok=True)
p=here/'measurement-failure-driver.bend'
assert 'ALL PROOFS CHECK' in command([here.parent/'t01'/'bend-check',p,'--check-only'])
command(['bend',p,'-o',folder/'driver.c'],timeout=30)
command(['clang','-std=c11','-O0',folder/'driver.c','-lpthread','-lm','-o',folder/'driver-native'],timeout=120)
command(['bend',p,'-o',folder/'driver.js'],timeout=30)
print('FAILURE DIAGNOSTIC BUILD PASS')
