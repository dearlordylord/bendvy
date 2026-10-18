import json,sys
# Independent finite source model, not a rendering of candidate output.
def report(kind,count):
 u=c=e=0;rows=[]
 operations=([('commands.spawn_join',0,1,0),('commands.track_pending',1,0,0)]*count if kind=='seed' else [('component.write_join',1,0,0),('resource.replace_join',1,0,0)]*count)
 for site,du,dc,de in operations:
  u+=du;c+=dc;e+=de;rows.append({'site':site,'delta':[du,dc,de],'current':[u,c,e],'peak':[u,c,e]})
 return {'kind':kind,'boundaries':rows,'terminal':[u,c,e],'consistent':True}
def expected(count=64,iterations=64):
 return {'reports':[report('seed',count)]+[report('query-loop',count) for _ in range(iterations)]}
if __name__=='__main__':
 print(json.dumps(expected(),separators=(',',':')))
