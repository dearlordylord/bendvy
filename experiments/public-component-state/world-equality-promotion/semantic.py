#!/usr/bin/env python3
"""Use existing reviewed complete state gate unchanged inside isolated patch tree."""
import sys,pathlib,argparse,json,os
HERE=pathlib.Path(__file__).resolve().parent
import stage as promotion
sys.path.insert(0,str(HERE.parent/'timing'));import run as timing
# Reuse reviewed guard/tool/supervisor machinery; only the declared input inventory differs.
timing.stage.sources=promotion.sources
p=argparse.ArgumentParser();p.add_argument('--stage',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--preflight',action='store_true');p.add_argument('--cpu',type=int,default=5);a=p.parse_args();a.stage=a.stage.resolve();a.output=a.output.resolve();a.timing=False
h=timing.Harness(a)
try:
 h.refs();h.receipt['sourceScope']='Exact two-call patched World; unchanged reviewed full87-command public state gate in isolated tree; preflight admits no Native/performance';h.save()
 command=['env','PYTHONDONTWRITEBYTECODE=1','python3',h.tree/'experiments/public-component-state/run.py','--output',a.output/'complete-state','--cpu',str(a.cpu)]
 if a.preflight:command.append('--preflight')
 # The child retains per-command5/30/120/5 and descendant cleanup. Overall orchestration bound only.
 h.run('existing-full-state-gate',command,120 if a.preflight else 600)
 child=a.output/'complete-state/receipt.json';receipt=json.loads(child.read_text());expected='PASS_PREFLIGHT' if a.preflight else 'PASS_FINITE_SLICE'
 assert receipt['status'].startswith(expected),(receipt['status'],expected)
 h.receipt['childReceiptSHA256']=timing.digest(child);h.receipt['childStatus']=receipt['status'];h.receipt['childCommandCount']=len(receipt['commands']);h.pin(child)
 h.receipt['status']='PASS_PATCHED_FULL_STATE_PREFLIGHT' if a.preflight else 'PASS_PATCHED_FULL_STATE_SEMANTICS';h.guard();h.save();print(a.output)
except Exception as e:
 h.receipt['status']='FAILED';h.receipt['failure']=repr(e);h.save();raise
