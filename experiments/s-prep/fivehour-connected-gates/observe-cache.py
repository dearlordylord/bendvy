#!/usr/bin/env python3
"""Validate actual exported cache audits; absence is BLOCKED, never a pass."""
import argparse,json,hashlib
from pathlib import Path
REQUIRED=('construction','scalar-write','rollback','insert-main','spawn','growth','remove-main','flag-change','despawn')
def validate(records):
 seen=set()
 for record in records:
  assert record['schema'] in ('Motion','Health')
  assert record['capture'] in ('explicit-owner','regenerated-closure')
  assert record['component'] in ('Main','Ledger')
  assert record['raw']==record['cached'],'Stale cached payload: '+json.dumps(record)
  # Independent schema shape prevents an equal-but-truncated audit from passing.
  fields=({'coordinates','frame'} if record['schema']=='Motion' else {'levels','reserve','class'}) if record['component']=='Main' else {'totals','epoch'}
  assert set(record['raw'])==fields,'Incomplete component audit'
  vector='coordinates' if record['schema']=='Motion' else 'levels'
  if record['component']=='Ledger':vector='totals'
  assert set(record['raw'][vector])=={'a','b','c','d'},'Missing non-head fields'
  seen.add((record['schema'],record['capture'],record['boundary'],record['component']))
 required={(s,c,b,k) for s in ('Motion','Health') for c in ('explicit-owner','regenerated-closure') for b in REQUIRED for k in ('Main','Ledger')}
 missing=required-seen
 return {'status':'BLOCKED_MISSING_BOUNDARIES' if missing else 'FINITE_FULL_FIELD_CACHE_AUDITS_PASS','records':len(records),'missing':[list(x) for x in sorted(missing)],'scope':'Finite actual audit observations only; generic cache authority/refinement unproved'}
def main():
 p=argparse.ArgumentParser();p.add_argument('input',type=Path);p.add_argument('--evidence',required=True,type=Path);a=p.parse_args();result={'status':'INCOMPLETE'}
 try:
  records=[json.loads(x) for x in a.input.read_text().splitlines() if x.strip()];result=validate(records);result['inputSHA256']=hashlib.sha256(a.input.read_bytes()).hexdigest()
 except Exception as error:result.update(status='FAIL',error=repr(error));raise
 finally:a.evidence.write_text(json.dumps(result,indent=2)+'\n')
 return int(result['status']!='FINITE_FULL_FIELD_CACHE_AUDITS_PASS')
if __name__=='__main__':raise SystemExit(main())
