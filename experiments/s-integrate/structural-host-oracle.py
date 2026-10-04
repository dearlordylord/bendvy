"""Exact full fixture fields from declared setup inputs, independent of actual output."""
import json
j=lambda v:json.dumps(v,separators=(',',':'))
def expected():
 out=[]
 for n in ['motion','health']:
  def main(x):return ('position['+','.join(map(str,range(x,x+4)))+'];frame=7' if n=='motion' else 'vitals['+','.join(map(str,range(x,x+4)))+'];reserve=9;class=2')
  flag='selected=8' if n=='motion' else 'tracked=8'
  view='world(1,2,[row(1,Some('+main(10)+'),None,Some('+flag+'),1,1)],[main(1,'+main(80)+')],Some(ledger[100,101,102,103];epoch=4),On)'
  event={'kind':'ReadDone','step':'fixture','system':'probe','frame':2,'tick':7,'outcome':{'kind':'Success'},'messageLag':False,'removedLag':False,'despawnedLag':False}
  # The actual setup APIs register reader at7, begin advances to8, complete stores8.
  metadata='|ping=16:1:0:[]:[7:1:['+j({'code':9})+']]|removed=16:1:0:[]:[8:1:[1:1]]|despawned=16:1:0:[]:[8:1:[1:1]]|bindings=[local:1:1]|host=alpha:E10:'+j({'kind':'SystemFailure','system':'prior','code':7})+':['+j(event)+']|registry=2:1:probe:B:True:True:False:True:'+j({'a':2,'b':0,'c':0,'d':0})+';|audit=True|readers=[1:True:[1]:True:7:8:8]|clock=8:2:1:3|style=regenerated|escaped=[1:1]|observations=[reserved:'+j({'kind':'Missing'})+']|next=Some(False)'
  text=view+metadata
  out += [n+':foreign=2:1',n+':before='+text,n+':rejected-payload='+main(90),n+':after='+text,n+':unchanged=True',n+':returned-audit']
 return '\n'.join(out)
