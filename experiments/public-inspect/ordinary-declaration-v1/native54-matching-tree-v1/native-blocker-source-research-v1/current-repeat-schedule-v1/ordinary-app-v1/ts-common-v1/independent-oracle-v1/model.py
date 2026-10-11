"""Independent finite TS App JSON interpretation; no TS evaluation/output input."""
import json,copy

def system(placement,resource=False):
    queries=[] if resource else [{'slot':'position','reads':['Position','Position'],'writes':[],'optional':[],'with':[],'without':[],'added':[],'changed':[],'relations':[]}]
    return {'name':'SharedSystem','placements':[placement+'#0'],'queries':queries,'resources':{'reads':[],'writes':['Counter'] if resource else []},'events':{'reads':[],'writes':[]},'machines':{'reads':[],'next':[],'transitions':[],'transitionEvents':[]},'removed':[],'despawned':False,'relationFailures':[],'services':[],'when':[]}
def description():
    return {'version':1,'components':[{'name':n,'storage':'plain'} for n in ['Position','Unqueried']],'resources':[{'name':'Counter','storage':'plain','present':True}],'events':[],'relations':[],'machines':[],'services':[],'schedules':[{'name':n,'steps':[{'kind':'system','system':'SharedSystem'}]} for n in ['InspectApp','ResourceNotRun']],'systems':[system('InspectApp'),system('ResourceNotRun',True)],'access':{'components':[{'name':'Position','readers':['SharedSystem'],'writers':[]},{'name':'Unqueried','readers':[],'writers':[]}],'resources':[{'name':'Counter','readers':[],'writers':['SharedSystem']}],'events':[]},'lints':[]}
def rows():return [{'entity':1,'first':[42],'second':[42],'samePosition':True}]
def scenario(label):
    # Setup: first system tick1, applyDeferred tick2, both reserved ids installed.
    snapshots=[]
    for name,frame,tick in [('before1',1,3),('before2',1,4),('afterFirst',2,6),('between',2,7),('afterSecond1',3,9),('afterSecond2',3,10)]:
        snapshots.append({'label':name,'projection':{'rows':rows(),'counter':[10],'sameCounter':True},'dump':{'version':1,'frame':frame,'tick':tick,'entityCount':2,'entities':[{'id':1,'components':{'Position':[42]},'relations':{}},{'id':2,'components':{},'relations':{}}],'resources':{'Counter':[10]},'machines':{},'pendingCommands':[]},'population':{'entities':2,'components':{'Position':1,'Unqueried':0}},'description':description(),'streams':[]})
    return {'schema':label,'setupStatus':{'ok':True},'first':{'ok':True},'second':{'ok':True},'operational':[rows(),rows()],'observations':snapshots,'position':[42],'counter':[10]}
def expected():return (json.dumps([scenario('A'),scenario('Other')],separators=(',',':'))+'\n').encode()
if __name__=='__main__':
    import sys
    sys.stdout.buffer.write(expected())
