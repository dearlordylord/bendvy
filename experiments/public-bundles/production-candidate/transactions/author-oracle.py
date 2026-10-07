"""Independent literal transaction oracle; no Bend execution/import."""
from pathlib import Path
HERE=Path(__file__).resolve().parent
raw='[True:[71, 72]/True:27/True:tag/True:[91, 92]:[101, 102]:[[111, 112]]/end][]'
packet='True:[71, 72]/True:27/True:tag/True:[91, 92]:[101, 102]:[[111, 112]]/end'
seed='[[1031, 1032]]@[1:1:2]|[[1041, 1042]]@[1:3:3]|[tag]@[1:4:4]|[17]@[1:5:5]'
patched='[[501, 502]]@[1:1:6]|[[1041, 1042]]@[1:3:3]|[tag]@[1:4:4]|[17]@[1:5:5]'
replaced='[[1091, 1092]]@[1:1:8]|[[1101, 1102]]@[1:3:9]|[tag]@[1:4:10]|[27]@[1:5:11]'
def row(case,ns):
 cols=patched;clock=6;live='[False, True]';events='[]';context=2;returned='[]';installed=1;pending=1;errors='[null, null, null, null]'
 if case in ['frame-missing','foreign-receiver']:returned=raw;errors='[immediate-refusal]'
 elif case in ['failed-before','failed-after']:cols=seed;returned=raw;errors='[body-failed]'
 elif case=='commit-before':events='[43]';pending=3
 elif case=='commit-after':cols=replaced;clock=11;events='[43, 801, 802, 901, 902]';pending=0;installed=2
 elif case in ['hostile-cold','foreign-sender']:cols=seed;clock=5;context=1;pending=0
 elif case!='frame-prepared':raise ValueError(case)
 if case=='failed-after':events='[801, 802]';pending=0
 if case=='hostile-cold':live='[False, False]';installed=0;errors='[quarantined]'
 order='['+', '.join(map(str,[0,1,2,3]*context))+']'
 text=f'{cols}|clock={clock}|live={live}|ns={ns}|next=2|high=1|capacity=2|events={events}|context=[{context}, {context}, {context}, {context}]/{order}|raw={returned}|installed={installed}|quarantine=0|pending={pending}|errors={errors}'
 if case.startswith('frame-') or case=='foreign-receiver':text+='|undo=1|txcommands=1|txevents=[43]|prepared='+('['+str(ns)+':1:'+packet+'][]' if case=='frame-prepared' else '[]')
 if case in ['failed-before','failed-after','commit-before','commit-after']:
  outcome='Failed' if case.startswith('failed') else 'Succeeded';text=f'{outcome}|disposed=True|registry={ns}:1:bundle.tx:[write:a, write:b, write:tag, write:value, bundle.insert, bundle.spawn]:0|next-system=2|registrations=0|'+text
 if case=='hostile-cold':
  cold=[f'pending({ns}:1:absent@0:0,MissingEntity)',f'pending({ns}:1:[1011, 1012]@1:1,MissingEntity)',f'pending({ns}:1:absent@0:0,MissingEntity)',f'pending({ns}:1:absent@0:0,MissingEntity)',f'head-pending({ns}:1:absent@0:0)','tail-payload(end)'];text+='|cold='+'|'.join(cold)+'|queued=[[51, 52]]|constructor-inverse=consumed-terminally-unapplied'
 return text
rows=[];ns=0
for schema in ['A','B']:
 for case in ['frame-prepared','frame-missing','failed-before','failed-after','commit-before','commit-after','hostile-cold']:ns+=1;rows.append(schema+'-'+case+'='+row(case,ns))
rows.extend(['A-foreign-receiver='+row('foreign-receiver',16),'A-foreign-sender='+row('foreign-sender',15)])
# Two inserted packs surround one ordinary deferred Value99 write. The ordinary
# command reads Value27 after the first installer and before the second.
for schema,ns in [('A',17),('B',18)]:
 rows.append(schema+'-interleaved-fifo='+f'[[1191, 1192]]@[1:1:14]|[[1201, 1202]]@[1:3:15]|[tag]@[1:4:16]|[37]@[1:5:17]|clock=17|live=[False, True]|ns={ns}|next=2|high=1|capacity=2|events=[43, 801, 802, 901, 902, 27]|context=[3, 3, 3, 3]/[0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3]|raw=[]|installed=3|quarantine=0|pending=0|errors=[null, null, null, null]')
for schema,ns,after in [('A',19,False),('A',20,True),('B',21,False),('B',22,True)]:
 cols=seed if after else '[absent]@[]|[absent]@[]|[absent]@[]|[absent]@[]'
 rows.append(f'{schema}-pending-'+('after' if after else 'before')+'='+f'{cols}|clock={5 if after else 0}|live=[False, {"True" if after else "False"}]|ns={ns}|next=2|high=1|capacity=2|events=[]|context=[1, 1, 1, 1]/[0, 1, 2, 3]|raw=[]|installed={1 if after else 0}|quarantine=0|pending={0 if after else 2}|errors=[null, null, null, null]')
for schema,ns in [('A',23),('B',24)]:
 rows.append(f'{schema}-cleanup-refusal='+f'[absent]@[]|[absent]@[]|[absent]@[]|[absent]@[]|clock=6|live=[False, False]|ns={ns}|next=2|high=1|capacity=2|events=[43, 801, 802, 901, 902]|context=[2, 2, 2, 2]/[0, 1, 2, 3, 0, 1, 2, 3]|raw={raw}|installed=1|quarantine=0|pending=0|errors=[insert-refusal]')
for schema,ns in [('A',25),('B',26)]:
 rows.append(f'{schema}-cleanup-retry='+f'[absent, [1091, 1092]]@[2:7:8]|[absent, [1101, 1102]]@[2:9:9]|[absent, tag]@[2:10:10]|[absent, 27]@[2:11:11]|clock=11|live=[False, False, True, False]|ns={ns}|next=3|high=2|capacity=4|events=[43, 801, 802, 901, 902]|context=[3, 3, 3, 3]/[0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3]|raw=[]|installed=2|quarantine=0|pending=0|errors=[null, null, null, null]')
initial_packet='True:[11, 12]/True:17/True:tag/True:[31, 32]:[41, 42]:[[51, 52]]/end'
second_packet='True:[171, 172]/True:37/True:tag/True:[191, 192]:[201, 202]:[[211, 212]]/end'
for schema,ns,case in [('A',27,'before'),('A',28,'after'),('A',29,'failed'),('B',30,'before'),('B',31,'after'),('B',32,'failed')]:
 cols='[absent]@[]|[absent]@[]|[absent]@[]|[absent]@[]';clock=0;live='[False, False]';events='[]';pending=4;installed=0;returned='[]';errors='[null, null, null, null]';status='Succeeded'
 if case=='after':cols='[[1191, 1192]]@[1:1:7]|[[1201, 1202]]@[1:3:8]|[tag]@[1:4:9]|[37]@[1:5:10]';clock=10;live='[False, True]';events='[801, 802]';pending=0;installed=2
 if case=='failed':events='[801, 802]';pending=0;status='Failed';returned='['+second_packet+']['+initial_packet+'][]';errors='[body-failed]'
 rows.append(f'{schema}-unified-pending-{case}='+f'{status}|disposed=True|registry={ns}:1:bundle.tx:[write:a, write:b, write:tag, write:value, bundle.insert, bundle.spawn]:0|next-system=2|registrations=0|{cols}|clock={clock}|live={live}|ns={ns}|next=2|high=1|capacity=2|events={events}|context=[2, 2, 2, 2]/[0, 1, 2, 3, 0, 1, 2, 3]|raw={returned}|installed={installed}|quarantine=0|pending={pending}|errors={errors}')
for schema,sender,receiver in [('A',33,34),('B',35,36)]:
 rows.append(f'{schema}-pending-foreign-receiver='+f'{seed}|clock=5|live=[False, True]|ns={receiver}|next=2|high=1|capacity=2|events=[801, 802]|context=[2, 2, 2, 2]/[0, 1, 2, 3, 0, 1, 2, 3]|raw={raw}|installed=1|quarantine=0|pending=0|errors=[immediate-refusal]')
 rows.append(f'{schema}-pending-foreign-sender='+row('foreign-sender',sender))
(HERE/'expected.stdout').write_text('\n'.join(rows)+'\n')
