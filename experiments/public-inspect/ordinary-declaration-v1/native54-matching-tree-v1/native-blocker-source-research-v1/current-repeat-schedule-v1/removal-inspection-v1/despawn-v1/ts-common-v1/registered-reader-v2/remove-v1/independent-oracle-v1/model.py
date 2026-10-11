"""Independent finite TS lifecycle/public-debug interpretation; no TS execution."""
import json
from pathlib import Path
def query(slot,name):return {'slot':slot,'reads':[name],'writes':[],'optional':[],'with':[],'without':[],'added':[],'changed':[],'relations':[]}
def system(name,placement,reader=False):return {'name':name,'placements':[placement],'queries':[query('position','Position'),query('other','OtherPosition')] if reader else [],'resources':{'reads':['Resource'] if reader else [],'writes':[]},'events':{'reads':[],'writes':[]},'machines':{'reads':[],'next':[],'transitions':[],'transitionEvents':[]},'removed':['Position','OtherPosition'] if reader else [],'despawned':reader,'relationFailures':[],'services':[],'when':[]}
def description():return {'version':1,'components':[{'name':n,'storage':'plain'} for n in ['Position','OtherPosition']],'resources':[{'name':'Resource','storage':'plain','present':True}],'events':[],'relations':[],'machines':[],'services':[],'schedules':[{'name':'Mutation','steps':[{'kind':'system','system':'Mutation'}]},{'name':'Flush','steps':[{'kind':'applyDeferred'}]},{'name':'Read','steps':[{'kind':'system','system':'RemovalReader'}]}],'systems':[system('Mutation','Mutation#0'),system('RemovalReader','Read#0',True)],'access':{'components':[{'name':n,'readers':['RemovalReader'],'writers':[]} for n in ['Position','OtherPosition']],'resources':[{'name':'Resource','readers':['RemovalReader'],'writers':[]}],'events':[]},'lints':[]}
def projection(operation,present,applied,changes):
    gone=applied and operation=='despawn'
    return {'position':[] if applied else [{'entity':1,'value':[42],'sameOwner':True}],'other':[{'entity':1,'value':[43],'sameOwner':True}] if present and not gone else [],'resource':[17],'sameResource':True,'removedPosition':[1] if changes else [],'removedOther':[1] if changes and gone and present else [],'despawned':[1] if changes and gone else []}
def scenario(label,operation,present):
    snapshots=[]
    timing=[('registeredBeforePublication',2,4),('before1',2,5),('before2',2,6),('queuedBeforeBarrier',3,8),('afterBarrier',4,10),('repeatAfterBarrier',4,11),('afterOperational',5,13),('repeatAfterOperational',5,14)]
    for i,(name,frame,tick) in enumerate(timing):
        applied=i>=4;gone=applied and operation=='despawn'
        components={}
        if not applied:components['Position']=[42]
        if present and not gone:components['OtherPosition']=[43]
        snapshots.append({'label':name,'projection':projection(operation,present,applied,i==4),'dump':{'version':1,'frame':frame,'tick':tick,'entityCount':0 if gone else 1,'entities':[] if gone else [{'id':1,'components':components,'relations':{}}],'resources':{'Resource':[17]},'machines':{},'pendingCommands':[{'tag':operation,'system':'Mutation'}] if i==3 else []},'population':{'entities':0 if gone else 1,'components':{'Position':0 if applied else 1,'OtherPosition':1 if present and not gone else 0}},'description':description(),'streams':[]})
    result={'schema':label,'operation':operation,'presentOther':present,'handle':1,'setupStatus':{'ok':True},'initialReadStatus':{'ok':True},'queuedStatus':{'ok':True},'flushStatus':{'ok':True},'readStatus':{'ok':True},'operational':[projection(operation,present,False,False),projection(operation,present,True,True)],'observations':snapshots,'position':[42]}
    if present:result['other']=[43]
    result['resource']=[17]
    return result
def expected():
    operation=Path(__file__).resolve().parent.parent.name.split('-v1')[0]
    return (json.dumps([scenario('A',operation,True),scenario('Other',operation,operation=='remove')],separators=(',',':'))+'\n').encode()
if __name__=='__main__':
    import sys
    sys.stdout.buffer.write(expected())
