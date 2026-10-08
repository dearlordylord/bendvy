"""Independent source-only whole canonical transaction/affine publication oracle.
All observation boundaries detach; no actual runtime output is read.
"""
from pathlib import Path
import copy,json
NONE={'None':{}}
def some(value):return {'Some':copy.deepcopy(value)}
def event(tag,cells):return {'tag':tag,'cells':copy.deepcopy(cells)}
EXISTING=event('existing',[71,72])
FIRST=event('first',[41,42]);SECOND=event('second',[51,52])
def stamp(id,added,changed):return {'id':id,'stamp':{'added':added,'changed':changed}}
def snapshot(payloads,stamps,clock,log,marks,pending,events):
 return copy.deepcopy({'metadata':{'namespace':1,'nextId':3,'highWater':2,'capacity':4,'depth':{'nat':2},'events':events,'registrations':[],'nextSystemId':1,'clock':clock},'live':[False,True,True,False],'column':{'supported':True,'slots':[NONE,some(payloads[0]),some(payloads[1]),NONE],'stamps':stamps},'log':log,'marks':marks,'pending':pending})
def owners(rejected=None,errors=None):return copy.deepcopy({'seedPrevious':[NONE,NONE],'rejected':rejected or [],'errors':errors or []})
def expected():
 seeded=snapshot([[11,12],[21,22]],[stamp(2,2,2),stamp(1,1,1)],2,[EXISTING],[7],0,[])
 success_before=snapshot([[101,102],[201,202]],[stamp(2,2,4),stamp(1,1,3)],4,[EXISTING,FIRST,SECOND],[7],1,[{'Unit':{}}])
 success_after=copy.deepcopy(success_before);success_after['pending']=0;success_after['marks']=[7,8,9]
 failed=snapshot([[11,12],[21,22]],[stamp(1,1,1),stamp(2,2,2)],4,[EXISTING],[7],0,[])
 def run(outcome,owned,recovered,before,after):return copy.deepcopy({'outcome':outcome,'owners':owned,'recovered':recovered,'beforeFlush':before,'afterFlush':after,'final':after})
 report={'seeded':{'world':copy.deepcopy(seeded),'owners':owners()},'seedRefused':{'world':copy.deepcopy(seeded),'owners':owners([[31,32]],[{'MissingEntity':{}}])},'success':run({'Success':{}},owners(),[],success_before,success_after),'failure':run({'Failure':{'error':'failed'}},owners(),[FIRST,SECOND],failed,failed),'foreign':run({'Failure':{'error':'foreign'}},owners([[301,302]],[{'MissingEntity':{}}]),[FIRST,SECOND],seeded,seeded)}
 # Detachment controls target the previously encountered mutable-alias failure.
 untouched=copy.deepcopy(report);success_after['marks'].append(999);EXISTING['cells'].append(999)
 assert report==untouched
 EXISTING['cells'].pop()
 assert report['failure']['beforeFlush']['column']['stamps'][0]['id']==1
 assert report['foreign']['beforeFlush']['metadata']['clock']==2
 return report
if __name__=='__main__':Path(__file__).with_name('expected.json').write_text(json.dumps(expected(),indent=2)+'\n')
