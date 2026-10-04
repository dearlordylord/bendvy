#!/usr/bin/env python3
"""Lossless deferred records -> original full-value oracle, never expected records."""
import pathlib,sys,json,importlib.util,collections
R=pathlib.Path(__file__).resolve().parents[2]
s=importlib.util.spec_from_file_location('original_oracle',R/'experiments/s-integrate/measurement-failure-oracle.py');O=importlib.util.module_from_spec(s);s.loader.exec_module(O)
def normalized(output):
 effects=[];records=[];counts=[];timing=[]
 for line in output.splitlines():
  if line.startswith('{'):
   x=json.loads(line);assert set(x)=={'who','iteration','capture'};effects.append(x)
  elif line.startswith('FAILURE-DEFERRED:'):records.append(json.loads(line.removeprefix('FAILURE-DEFERRED:')))
  elif line.startswith('FAILURE-COUNTS:'):counts.append(line)
  elif line.startswith('FAILURE-TIMING:'):timing.append(int(line.removeprefix('FAILURE-TIMING:')))
  elif line.strip():raise AssertionError(('unexpected actual output',line))
 assert len(counts)==1 and len(timing)==1
 pending=collections.deque(effects);lines=[];events=[];observed=0
 for x in records:
  kind=x['kind']
  if kind=='FailureRead':lines.append('FAILURE-READ:'+':'.join(map(str,[x['iteration'],x['system'],x['count'],json.dumps(x['messages'],separators=(',',':')),'True' if x['lag'] else 'False',x['tick'],x['frame']])))
  elif kind=='FailureResult':lines.append('FAILURE-RESULT:'+x['label']+':'+json.dumps(x['outcome'],separators=(',',':')))
  elif kind=='FailureObserved':
   data={k:v for k,v in x.items() if k!='kind'};lines.append('FAILURE-OBSERVE:'+json.dumps(data,separators=(',',':')));lines.append('FAILURE-EVENTS:'+json.dumps(events,separators=(',',':')));events=[];observed+=1
  else:
   if kind=='OwnWrites':
    actual=pending.popleft();assert actual['who']==x['system'],('actual effect association',actual,x)
    lines.append(json.dumps(actual,separators=(',',':')))
   events.append(x)
 assert not pending and not events,('unconsumed complete records',len(pending),len(events));lines.extend(counts)
 return '\n'.join(lines),{'elapsed_milliseconds_diagnostic':timing[0],'deferred_records':len(records),'complete_observations':observed,'actual_audit_effects':len(effects)}
def validate(output,reference):
 text,metadata=normalized(output);result=O.validate(text,reference);return {'validation':result,'transport':metadata}
if __name__=='__main__':print(json.dumps(validate(pathlib.Path(sys.argv[1]).read_text(),json.loads(pathlib.Path(sys.argv[2]).read_text())),indent=2))
