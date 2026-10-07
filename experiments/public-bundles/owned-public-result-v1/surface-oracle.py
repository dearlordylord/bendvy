"""Complete independent spawn/composition oracle, authored before execution.
No Bend output is parsed or used. Logical writes follow the five-field recursive
installer, receipt positions follow actual queued activation and ordinary FIFO.
"""
RAW_INITIAL='True:[11, 12]/True:17/True:tag/True:[31, 32]:[41, 42]:[[51, 52]]/end'
RAW_INVALID=RAW_INITIAL.replace('True:[31, 32]','False:[31, 32]')
RAW_REPLACE='True:[71, 72]/True:27/True:tag/True:[91, 92]:[101, 102]:[[111, 112]]/end'
COOK_INITIAL='[1011, 1012]/17/tag/[1031, 1032]:[1041, 1042]:[[51, 52]]/end'
COOK_REPLACE='[1071, 1072]/27/tag/[1091, 1092]:[1101, 1102]:[[111, 112]]/end'
ACCESS='[write:a, write:b, write:tag, write:value, bundle.spawn, bundle.insert]'
ERROR='ConstructionRefused:[null, null, null, bad-3]'
CASES=['spawn-insert-before','spawn-insert-after','spawn-insert-unwind','invalid-spawn-return','invalid-spawn-retry-before','invalid-spawn-retry-after','rollback-before','rollback-after','cleanup-before','cleanup-after']
def context(n):return str([n]*4)+'/'+str([0,1,2,3]*n)
def prepared(ns,cleanup):
 return '['+str(ns)+':2:'+str(3 if cleanup else 2)+':'+COOK_REPLACE+', '+str(ns)+':2:2:'+COOK_INITIAL+', receipt:'+str(ns)+':2]'
def row(ns,case):
 invalid=case.startswith('invalid-');refused=case=='invalid-spawn-return';failed=case.startswith('rollback-');cleanup=case.startswith('cleanup-')
 after=case.endswith('after') or case.endswith('unwind');unwind=case.endswith('unwind')
 cols='[[501, 502]]@[1:1:6]|[[1041, 1042]]@[1:3:3]|[tag]@[1:4:4]|[17]@[1:5:5]'
 clock=6;live='[False, True]' if refused else '[False, True, False, False]';events='[43]';raw='[]';installed=1;pending=2 if refused else 6 if cleanup else 5;errors='[null, null, null, null]';queues='[[[51, 52]]]'
 depth=1 if refused else 2;next_id=2 if refused else 3;high=1 if refused else 2;capacity=2 if refused else 4
 if failed:
  cols='[[1031, 1032]]@[1:1:2]|[[1041, 1042]]@[1:3:3]|[tag]@[1:4:4]|[17]@[1:5:5]'
  raw='['+RAW_REPLACE+']['+RAW_INITIAL+'][]';pending=1;events='[]'
  errors='[body-failed|caller-context='+context(2)+'|prepared='+prepared(ns,False)+']'
 if after:
  pending=0;events='[801, 802]' if failed else '[43, 801, 802, 901, 902]'
  if not failed and not refused:
   clock=11 if cleanup else 16;live='[False, True, False, False]' if cleanup else '[False, True, True, False]'
   if cleanup:
    cols='[[501, 502], absent]@[1:1:6]|[[1041, 1042], absent]@[1:3:3]|[tag, absent]@[1:4:4]|[17, absent]@[1:5:5]'
    installed=2;queues='[[[51, 52]], [[51, 52]]]';raw='['+RAW_REPLACE+'][]';errors='[insert-refusal]'
   elif unwind:
    cols='[[501, 502], [1031, 1032]]@[2:7:8, 1:1:6]|[[1041, 1042], [1041, 1042]]@[2:9:9, 1:3:3]|[tag, tag]@[2:10:10, 1:4:4]|[17, 17]@[2:11:11, 1:5:5]'
    installed=2;queues='[[[51, 52]], [[51, 52]]]';raw='['+RAW_REPLACE+'][]';errors='[unwound]'
   else:
    cols='[[501, 502], [1091, 1092]]@[2:7:13, 1:1:6]|[[1041, 1042], [1101, 1102]]@[2:9:14, 1:3:3]|[tag, tag]@[2:10:15, 1:4:4]|[17, 27]@[2:11:16, 1:5:5]'
    installed=3;queues='[[[111, 112]], [[51, 52]], [[51, 52]]]'
 prefix='Failed' if failed else 'Succeeded'
 text=f'{prefix}|{cols}|clock={clock}|live={live}|ns={ns}|next={next_id}|high={high}|capacity={capacity}|events={events}|context={context(1)}|raw={raw}|installed={installed}|quarantine=0|pending={pending}|errors={errors}|installed-queues={queues}|depth={depth}|registrations=[1:owned-commands:{ACCESS}]|nextSystem=2|registry={ns}:1:owned-commands:{ACCESS}:{0 if failed else 6}'
 if failed:return text
 first='refused:'+ERROR+':'+RAW_INVALID if refused else f'accepted:{ns}:2:True'
 second='none' if refused else f'accepted:{ns}:2:False';unused=RAW_REPLACE if refused else 'none'
 error=ERROR if invalid else 'none';returned=RAW_INVALID if invalid else '';calls=1 if refused else 3 if invalid else 2
 return text+f'|first={first}|second={second}|unsubmitted={unused}|first-refusal={error}|returned-before-retry={returned}|caller-context={context(calls)}|prepared='+('[]' if refused else prepared(ns,cleanup))
def expected():
 rows=[];ns=0
 for schema in ['A','B']:
  for case in CASES:ns+=1;rows.append(schema+'-'+case+'='+row(ns,case))
 return '\n'.join(rows)+'\n'
if __name__=='__main__':print(expected(),end='')
