"""Authored full-state oracle, independent of execution output (22 finite cases)."""
def payload(name,values,target):return name+':'+''.join(str(v)+',' for v in values)+':'+target
def world(ns,values,stamps,resource,retired,next_id,clock,events):
 depth=1 if len(values)==1 else 2
 capacity=2 if depth==1 else 4
 live='0'+'1'*len(values)+'0'*(capacity-len(values)-1)
 return '/'.join(map(str,[ns,next_id,len(values),live,capacity,depth,''.join(v+';' for v in values)+''.join('none;' for _ in range(((len(values)-1).bit_length() and 2**(len(values)-1).bit_length() or 1)-len(values))),stamps,resource,''.join(v+';' for v in retired),str(events).replace(' ',''),0,'',1,clock]))
# Column owns index id-1, independently of live-array index id.
def expected(namespace_bypass=False):
 seed=payload('seed',[11,12],'1:1');queue=payload('queued',[31,32,33,34],'1:1');resource=payload('resource',[100,101],'null')
 foreign=world(2,[payload('seed',[21,22],'2:1')],'1:1:1;',payload('foreignresource',[300,301],'null'),[],2,1,[])
 lines=[]
 for i in range(11):
  target='2:1' if i<3 else '1:0' if i<6 else 'null' if i==10 else '1:1'
  owner=payload('incoming',[41,42,43,44],target)
  rawtarget='null' if target=='null' else 'handle:'+target
  canonical='{cells:[u32:41,u32:42,u32:43,u32:44,],name:str:incoming,target:'+rawtarget+',}'
  status='ok'+canonical;refused='none;';host='accepted'
  values=[seed,queue];stamps='2:2:2;1:1:1;';res=resource;retired=[];next_id=3;clock=2
  if i<6:
   status='$.target:same-world handle:'+rawtarget;refused=owner+';';host='not-attempted'
  elif i==6:
   values.append(owner);stamps='3:3:3;2:2:2;1:1:1;';next_id=4;clock=3
  elif i==7 or (i==9 and namespace_bypass):
   values[0]=owner;stamps='1:1:3;2:2:2;';retired=[seed];clock=3
  elif i in (8,10):res=owner;retired=[resource]
  else:refused=owner+';';host='MissingEntity'
  lines.append(status+'|'+refused+'|host:'+host+'|'+world(1,values,stamps,res,retired,next_id,clock,[77])+'|foreign:'+foreign+'|factory:3')
 return '\n'.join(lines*2)+'\n'
