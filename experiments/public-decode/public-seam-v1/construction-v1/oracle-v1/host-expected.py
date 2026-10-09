"""Independent Standard Schema fixture model derived without executing Node."""
import copy,json
from pathlib import Path
undefined={'kind':'undefined'};symbol={'kind':'symbol','description':'opaque-path'}
issue=[{'message':'same-owner','path':[symbol]}]
async_issue=[{'message':'Asynchronous validation is not supported: descriptor constructors run synchronously'}]
def expected():
 names=['transform','undefined','null','empty-issues','nested-issues','resolved-promise','rejected-promise','thenable']
 results=[{'ok':True,'value':{'count':8}},{'ok':True,'value':undefined},{'ok':True,'value':None},{'ok':False,'error':[]},{'ok':False,'error':[{'message':'nested','path':['items',1,{'key':'value'},{'key':symbol},symbol]}]},{'ok':False,'error':async_issue},{'ok':False,'error':async_issue},{'ok':True,'value':9}]
 rows=[{'name':n,'sameFunctions':True,'result':copy.deepcopy(r)}for n,r in zip(names,results)]
 raw=lambda n:{'$':'Number','value':n}
 valid=[{'$':'Missing'},{'$':'Null'},raw(0),raw(0xffffffff),{'$':'SignedInteger','negative':True,'magnitude':2**48-1},{'$':'Float','value':1.100000023841858},{'$':'Binary64','high':0x80000000,'low':0},{'$':'Text','value':'x'},{'$':'Utf16Text','units':[0xd800]},{'$':'Boolean','value':False},{'$':'Handle','namespace':2,'id':1},{'$':'Array','items':[raw(1)]},{'$':'Object','fields':[{'$':'Field','name':'x','value':raw(7)}]}]
 return {'host':copy.deepcopy(rows),'ts':copy.deepcopy(rows),'issueIdentity':{'host':True,'ts':True},'dispatch':[{'index':i,'host':{'ok':True,'value':v},'ts':{'ok':True,'value':v}}for i,v in enumerate(['decode','fallback','nonfunction-fallback'])],'thrown':[{'name':n,'same':True}for n in ('host','ts')],'typed':{'accepted':{'ok':True,'value':raw(8)},'acceptedFrozen':True,'refused':{'ok':False,'input':raw(7),'error':{'$':'Text','value':'same-owner'},'issues':issue},'detached':True,'unchanged':True,'issuesIdentity':True},'representation':{'valid':[{'raw':r,'same':True}for r in valid],'invalid':[{'index':i,'rejected':True}for i in range(11)]},'badProviders':[{'name':n,'rejected':True}for n in ('output','issues')]}
if __name__=='__main__':Path(__file__).with_name('host-expected.json').write_text(json.dumps(expected(),indent=2)+'\n')
