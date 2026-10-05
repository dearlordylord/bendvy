#!/usr/bin/env python3
"""Replay unchanged owned fixture/oracles on installed2.0.35; explicit version seam."""
import pathlib
source=pathlib.Path(__file__).resolve().parents[2]/'s-perf/candidate/owned-storage-run.py'
text=source.read_text()
old="assert 'bend 2.0.34' in ''.join(run(['bend','version']))"
assert text.count(old)==1
text=text.replace(old,"assert 'bend 2.0.35' in ''.join(run(['bend','version']))")
anchor=" for name,mutant in mutants.items():"
assert text.count(anchor)==1
text=text.replace(anchor,""" mutants.update({
 'fuse-wrong-leaf':source.replace('main,index,Some{value}', 'main,U32.add(index,1),Some{value}'),
 'fuse-drop-owner':source.replace('main,index,Some{value}', 'main,index,None{}'),
 'fuse-foreign':source.replace('hook_checked(S,M,A,F,L,Mode,O,U32.is_eq(namespace,foreign)', 'hook_checked(S,M,A,F,L,Mode,O,True{}')})
 for name,mutant in mutants.items():""")
exec(compile(text,str(source),'exec'),{'__file__':str(source),'__name__':'__main__'})
