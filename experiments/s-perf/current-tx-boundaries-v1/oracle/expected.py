import json,sys
# Independent finite source model, not a rendering of candidate output.
def report(kind,count):
 u=c=e=0;rows=[]
 operations=([('commands.spawn_reserved',0,1,0),('commands.track_pending',1,0,0)]*count if kind=='seed' else [('component.tx_written',1,0,0),('resource.replace_join',1,0,0)]*count)
 for site,du,dc,de in operations:
  u+=du;c+=dc;e+=de;rows.append({'site':site,'delta':[du,dc,de],'current':[u,c,e],'peak':[u,c,e]})
 return {'kind':kind,'boundaries':rows,'terminal':[u,c,e],'consistent':True}
def expected(count=64,iterations=64):
 seed=report('seed',count);seed={'kind':seed['kind'],'namespace':1,'beginTick':0,'endTick':0,'appendTick':None,'boundaries':seed['boundaries'],'terminal':seed['terminal'],'consistent':seed['consistent']}
 seeded_clock=count+sum(i%3==0 for i in range(count))+sum(i%3==1 for i in range(count))
 reports=[{'iteration':None,'completion':'committed','tx':seed}]
 for i in range(iterations):
  row=report('query-loop',count);row={'kind':row['kind'],'namespace':1,'beginTick':seeded_clock+i*count,'endTick':seeded_clock+(i+1)*count,'appendTick':None,'boundaries':row['boundaries'],'terminal':row['terminal'],'consistent':row['consistent']}
  reports.append({'iteration':i,'completion':'committed','tx':row})
 return {'schema':'Motion','workloadCount':count,'iterations':iterations,'frame':None,'reports':reports}
if __name__=='__main__':
 print(json.dumps(expected(),separators=(',',':')))
