#!/usr/bin/env python3
"""Diagnostic emitted-C counters, not timing or a compiler modification."""
import argparse,json,pathlib,hashlib
from probe import run

def main():
 p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--cpu',type=int,default=10);a=p.parse_args();a.output.mkdir(exist_ok=False);r={'scope':'Whole elementary single-thread runtime counts, including IO; not core/profile/performance acceptance','cases':{}}
 for name in ('data','affine','snapshot'):
  src=a.input/(name+'.c');s=src.read_text();headers=('INLINE u64 heap_alloc(Env e, u32 cls) {','OUTLINE Term rfc_wrap(Env e, Term t, u32 cnt) {');assert all(s.count(h)==1 for h in headers)
  changed=s.replace(headers[0],'static u64 probe_allocs = 0, probe_rfc_wraps = 0;\n'+headers[0]+'\n  probe_allocs += 1;',1).replace(headers[1],headers[1]+'\n  probe_rfc_wraps += 1;',1)
  end='  io_sync();\n  return 0;';assert changed.count(end)==1
  changed=changed.replace(end,'  io_sync();\n  fprintf(stderr,"PROBE_ALLOCATIONS:%llu RFC_WRAPS:%llu\\n",(unsigned long long)probe_allocs,(unsigned long long)probe_rfc_wraps);\n  return 0;',1)
  target=a.output/(name+'.c');target.write_text(changed);case={'inputSHA256':hashlib.sha256(s.encode()).hexdigest(),'instrumentedSHA256':hashlib.sha256(changed.encode()).hexdigest(),'commands':[]}
  for argv,limit in [(['clang','-O3',str(target),'-o',str(target.with_suffix('.bin')),'-lm','-pthread'],120),([str(target.with_suffix('.bin')),'--threads','1','--gpu','off'],5)]:
   result=run(argv,limit,a.cpu);case['commands'].append(result)
   if result['exit']!=0:break
  case['pass']=len(case['commands'])==2 and result['exit']==0 and 'PROBE_ALLOCATIONS:' in result['output'];r['cases'][name]=case
 r['status']='ELEMENTARY_COUNTS_PASS' if all(c['pass'] for c in r['cases'].values()) else 'ELEMENTARY_COUNTS_FAIL';(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
if __name__=='__main__':main()
