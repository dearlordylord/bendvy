"""Whole source-only counterfactuals for sole v14 runtime defects."""
import copy,json
from pathlib import Path
import expected as M

def wrong_reader():
 v=M.expected()
 for schema in ['alpha','beta']:
  r=v[schema]['retry']['value']
  for index,fast,slow in [(1,2,0),(2,6,0),(3,7,0),(4,9,0),(5,9,0),(6,11,0),(7,12,0)]:
   positions=r['deliveries'][index]['positions'];positions[0]['cursor']=slow;positions[1]['cursor']=fast
  r['positions'][0]['cursor']=0
  # The never-advanced slow position prevents descriptor1 retirement.
  r['domains'][0]=copy.deepcopy(r['deliveries'][7]['domains'][0])
  cases=v[schema]['lifecycle']
  for name in ['activatedSkip','successfulDisposal']:
   f=cases[name]['final']['value'] if name=='activatedSkip' else cases[name]['value']
   for pos in f['positions']:pos['cursor']=8 if pos['id']==1 else 0
 return v

def premature():
 v=M.expected()
 for schema in ['alpha','beta']:
  r=v[schema]['retry']['value'];self_notice=M.failure(1,1);missing=M.failure(1,99);beta=M.failure(2,1)
  published=lambda:[M.domain(1,[M.batch(8,[self_notice]),M.batch(8,[missing])],[2,1]),M.domain(2,[M.batch(8,[beta])],[])]
  for i,fast,slow in [(0,2,None),(1,2,4),(2,9,4),(3,9,11),(4,14,11),(5,14,11),(6,14,18),(7,20,18)]:
   d=r['deliveries'][i];d['positions']=([M.position(2,slow,3)] if slow is not None else [])+[M.position(1,fast,1)]
   if i>=2:d['domains']=published()
   d['readings']=[M.reading(1,[self_notice,missing] if i in [2,3] else [])]
  r.update(positions=[M.position(2,18,3),M.position(1,20,1)],tick=20,frameStart=20,boundary=20,clock=20)
  cases=v[schema]['lifecycle']
  for name in ['activatedSkip','successfulDisposal']:
   f=cases[name]['final']['value'] if name=='activatedSkip' else cases[name]['value']
   f.update(tick=14,frameStart=8,clock=14)
   for domain in f['domains']:
    for batch in domain['queue']['front']:batch['tick']=8
   for pos in f['positions']:
    pos['registeredAt']={1:1,2:3,3:5}[pos['id']];pos['cursor']={1:14 if name=='activatedSkip' else 10,2:12,3:14}[pos['id']]
  m=v[schema]['mixed']['value']
  marks=m['marks']
  for i,clock in enumerate([2,2,4,6,8,12,12]):
   marks[i]['relationTick']=clock;marks[i]['worldClock']=clock
   if i in [2,3,4]:marks[i]['stamp']={'$':'Stamp','added':4,'changed':4}
  for i,cursor in [(0,0),(3,2),(4,6),(5,8)]:
   marks[i]['cursor']=M.some(cursor);stamp=marks[i]['stamp'];marks[i]['added']=M.some(stamp['added']>cursor);marks[i]['changed']=M.some(stamp['changed']>cursor)
  m['relationDomains'][0]['queue']['back'][0]['tick']=10
  m['relationPositions']=[M.position(1,12,1)];m['relationTick']=12;m['relationRegistry']['cursor']=12;m['clock']=12
  m['beforePartition'][-1]['event']['notice']['tick']=10
 return v
if __name__=='__main__':
 for name,model in [('wrong-reader-advance',wrong_reader),('premature-publication',premature)]:
  Path(__file__).with_name(name+'-expected.json').write_text(json.dumps(model(),indent=2)+'\n')
