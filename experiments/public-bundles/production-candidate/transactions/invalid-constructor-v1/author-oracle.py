"""Literal source-derived expectations; lifecycle list-order correction recorded after interpreter comparison."""
from pathlib import Path
HERE=Path(__file__).resolve().parent
patched='[[501, 502]]@[1:1:6]|[[1041, 1042]]@[1:3:3]|[tag]@[1:4:4]|[17]@[1:5:5]'
replacement='[[1091, 1092]]@[1:1:8]|[[1101, 1102]]@[1:3:9]|[tag]@[1:4:10]|[27]@[1:5:11]'
prepared='True:[71, 72]/True:27/True:tag/True:[91, 92]:[101, 102]:[[111, 112]]/end'
rows=[]
for schema,start in [('A',1),('B',8)]:
 for offset,case in enumerate(['setup-before','invalid-spawn-before','invalid-spawn-after','invalid-spawn-retry','invalid-insert-before','invalid-insert-after','invalid-insert-retry']):
  ns=start+offset;cols=patched;clock=6;live='[False, True]';nextid=2;high=1;capacity=2;events='[]';context=2;raw='[]';installed=1;pending=1;errors='[null, null, null, null]'
  if case!='setup-before':
   context=3;valid='False' if 'spawn' in case else 'True';raw='[True:[11, 12]/'+valid+':17/True:tag/False:[31, 32]:[41, 42]:[[51, 52]]/end][]';errors='[null, bad-1, null, bad-3]' if 'spawn' in case else '[null, null, null, bad-3]'
  if case.endswith('after'):
   cols=replacement;clock=11;events='[43, 801, 802, 901, 902]';installed=2;pending=0
  if case.endswith('retry'):
   clock=16;events='[43, 801, 802, 901, 902]';context=4;raw='[]';installed=3;pending=0;errors='[null, null, null, null]'
   if 'spawn' in case:
    cols='[[1091, 1092], [1031, 1032]]@[2:12:13, 1:1:8]|[[1101, 1102], [1041, 1042]]@[2:14:14, 1:3:9]|[tag, tag]@[2:15:15, 1:4:10]|[27, 17]@[2:16:16, 1:5:11]';live='[False, True, True, False]';nextid=3;high=2;capacity=4
   else:cols='[[1031, 1032]]@[1:1:13]|[[1041, 1042]]@[1:3:14]|[tag]@[1:4:15]|[17]@[1:5:16]'
  order=', '.join(['0, 1, 2, 3']*context)
  row=f'{schema}-{case}={cols}|clock={clock}|live={live}|ns={ns}|next={nextid}|high={high}|capacity={capacity}|events={events}|context=[{context}, {context}, {context}, {context}]/[{order}]|raw={raw}|installed={installed}|quarantine=0|pending={pending}|errors={errors}'
  if case.endswith('before'):row+=f'|undo=1|txcommands=1|txevents=[43]|prepared=[{ns}:1:{prepared}][]'
  queues='[[[51, 52]]]'
  if case.endswith('after'):queues='[[[111, 112]], [[51, 52]]]'
  if case.endswith('retry'):queues='[[[51, 52]], [[111, 112]], [[51, 52]]]'
  row+='|installed-queues='+queues
  rows.append(row)
(HERE/'expected.stdout').write_text('\n'.join(rows)+'\n')
