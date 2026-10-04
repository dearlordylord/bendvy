"""Independent full-value finite operation oracle for declared structural inputs."""
def expected():
 out=[]
 for schema in ['motion','health']:
  def main(v):return ('position['+','.join(map(str,v))+'];frame=7' if schema=='motion' else 'vitals['+','.join(map(str,v))+'];reserve=9;class=2')
  aux='velocity[1,2,3,4];moving=true' if schema=='motion' else 'armor[1,2,3,4];grade=3'
  flag='selected=8' if schema=='motion' else 'tracked=8'
  def some(v):return 'None' if v is None else 'Some('+v+')'
  rows=[dict(id=1,main=[11,11,12,13],aux=aux,flag=None,added=1,changed=1),dict(id=2,main=[50,21,22,23],aux=None,flag=flag,added=1,changed=1),dict(id=3,main=None,aux=aux,flag=flag,added=0,changed=0),dict(id=4,main=[50,51,52,53],aux=None,flag=flag,added=1,changed=1),dict(id=6,main=[60,61,62,63],aux=None,flag=None,added=1,changed=1)]
  pending=[]
  def world():
   def row(r):return 'row('+','.join([str(r['id']),some(None if r['main'] is None else main(r['main'])),some(r['aux']),some(r['flag']),str(r['added']),str(r['changed'])])+')'
   def command(c):return ('main('+str(c[1])+','+main(c[2])+')' if c[0]=='main' else ('remove-main' if c[0]=='remove' else 'despawn')+'('+str(c[1])+')')
   return 'world(1,7,['+', '.join(map(row,rows))+'],['+', '.join(map(command,pending))+'],Some(ledger[201,101,102,103];epoch=4),On)'
  def apply(tick):
   changes=[]
   for c in pending:
    r=next((r for r in rows if r['id']==c[1]),None)
    if r is None:continue
    def event(name):changes.append(name+':1:'+str(r['id']))
    if c[0]=='main':
     if r['main'] is None:r['added']=tick;event('added')
     r['main']=c[2];r['changed']=tick;event('changed')
    elif c[0]=='remove':
     if r['main'] is not None:r['main']=None;r['added']=0;r['changed']=0;event('removed')
    else:
     if r['main'] is not None:event('removed')
     event('despawned');rows.remove(r)
   pending.clear();return '['+', '.join(changes)+']'
  rows[3]['main'][0]=51;rows[3]['changed']=2;pending += [('remove',1),('despawn',2)]
  out += [schema+':CLEANUP-pings=[3]',schema+':CLEANUP-before='+world(),schema+':CLEANUP-changes='+apply(3),schema+':CLEANUP-after='+world()]
  pending += [('main',i,list(range(v,v+4))) for i,v in [(4,71),(1,80),(3,30),(1,81),(2,90)]]
  out += [schema+':INSERTS-rejected=0',schema+':INSERTS-before='+world(),schema+':INSERTS-changes='+apply(4),schema+':INSERTS-after='+world()]
  pending += [('remove',3),('despawn',1),('despawn',4),('despawn',6),('despawn',3)]
  out += [schema+':DISPOSE-rejected=0',schema+':DISPOSE-before='+world(),schema+':DISPOSE-changes='+apply(5),schema+':DISPOSE-after='+world()]
 return '\n'.join(out)
