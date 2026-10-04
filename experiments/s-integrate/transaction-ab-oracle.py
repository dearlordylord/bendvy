"""Independent full-field expectations from the declared E2/E3 operation inputs."""
def expected():
 lines=[]
 for schema in ['motion','health']:
  def main(values):
   return ('position['+','.join(map(str,values))+'];frame=7' if schema=='motion' else 'vitals['+','.join(map(str,values))+'];reserve=9;class=2')
  aux='velocity[1,2,3,4];moving=true' if schema=='motion' else 'armor[1,2,3,4];grade=3'
  flag='selected=8' if schema=='motion' else 'tracked=8'
  def ledger(head):return 'ledger['+','.join(map(str,[head,101,102,103]))+'];epoch=4'
  def vector(x):return list(range(x,x+4))
  def row(i,m,a,f,added,changed):return dict(id=i,main=m,aux=a,flag=f,added=added,changed=changed)
  def some(v):return 'None' if v is None else 'Some('+v+')'
  def fmt_row(r):return 'row('+','.join([str(r['id']),some(r['main']),some(r['aux']),some(r['flag']),str(r['added']),str(r['changed'])])+')'
  def baseline_row(r):return str(r['id'])+'{'+';'.join([r['main'] or 'none',r['aux'] or 'none',r['flag'] or 'none','added='+str(r['added']),'changed='+str(r['changed'])])+'}'
  def spawn(i,v,f):return ('spawn('+str(i)+',bundle('+some(main(vector(v)))+',None,'+some(f)+'))','spawn:'+str(i)+'{'+main(vector(v))+';none;'+(f or 'none')+'}')
  def world(next,rs,ps,l):return 'world(1,'+str(next)+',['+', '.join(map(fmt_row,rs))+'],['+', '.join(p[0] for p in ps)+'],'+some(ledger(l))+',On)'
  def baseline(next,rs,ps,l):return 'ns=1;next='+str(next)+';rows=['+'|'.join(map(baseline_row,rs))+'];pending=['+'|'.join(p[1] for p in ps)+'];'+ledger(l)+';mode=On'
  rows=[row(1,main([11,11,12,13]),aux,flag,1,2),row(2,main(vector(20)),None,None,1,1),row(3,None,aux,flag,0,0)]
  pending=[spawn(4,50,flag),('remove-flag(1)','removeFlag:1')]
  lines+=['audit:'+schema+':A:attempt:1',schema+':A-pings=[1]',schema+':A='+world(5,rows,pending,101),schema+':A-baseline='+baseline(5,rows,pending,101)]
  body='['+', '.join([main([20,21,22,23]),main([30,21,22,23]),main([50,21,22,23]),some(ledger(201))])+']'
  lines+=['audit:'+schema+':B:attempt:2',schema+':B-fail:failure:7:escaped=1:5:pings=[]:body='+body,schema+':FAIL='+world(6,rows,pending,101),schema+':FAIL-baseline='+baseline(6,rows,pending,101)]
  rows[1]=row(2,main([50,21,22,23]),None,None,1,4)
  pending=pending+[spawn(6,60,None),('flag(2,'+flag+')','insertFlag:2{'+flag+'}')]
  lines+=['audit:'+schema+':B:attempt:3',schema+':B-retry:success:escaped=1:6:pings=[2]:body='+body,schema+':RETRY='+world(7,rows,pending,201),schema+':RETRY-baseline='+baseline(7,rows,pending,201)]
  rows[0]['flag']=None;rows[1]['flag']=flag
  rows+= [row(4,main(vector(50)),None,flag,7,7),row(6,main(vector(60)),None,None,7,7)]
  lines+= [schema+':APPLY='+world(7,rows,[],201),schema+':APPLY-again='+world(7,rows,[],201)]
 return '\n'.join(lines)
