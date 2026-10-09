"""Whole source-only graph/machine inventory oracle; no runtime inputs."""
import copy,json
from pathlib import Path
HERE=Path(__file__).resolve().parent

def expected(mutant=False):
 prior=json.loads((HERE.parent/'expected-v2.json').read_text())
 resource=json.loads((HERE.parent/'resource-expected-v2.json').read_text())
 descriptor={'key':7,'name':'Parent','inverseName':'Children','kind':{'Hierarchy':{}}}
 graph={'edges':[{'relation':copy.deepcopy(descriptor),'source':1,'target':2}], 'inverses':[{'relation':copy.deepcopy(descriptor),'target':2,'sources':[1]}]}
 slot={'Present':{'current':{'Boot':{}},'pending':{'Queued':{'value':{'Play':{}},'skipSame':False}},'previous':{'None':{}},'changed':False}}
 snapshot={'namespace':1,'nextId':3,'highWater':2,'capacity':4,'depth':{'nat':2},'liveBits':[False,True,True,False],'store':{'Unit':{}},'resource':{'array':{'length':{'nat':2},'values':[23,23]},'slot':slot,'graph':graph,'relation':copy.deepcopy(descriptor)},'events':[{'Unit':{}}],'pendingCount':1,'registrations':[],'nextSystemId':1,'clock':0}
 ordinary={'schema':[{'kind':{'Resource':{}},'key':'Gameplay','name':'Gameplay'}],'namespace':1,'name':'Update','steps':[{'Phase':{'name':'Update'}}],'systems':[]}
 description={'ordinary':ordinary,'relations':[] if mutant else [copy.deepcopy(descriptor)],'machines':[{'name':'Mode'}]}
 flushed=copy.deepcopy(snapshot);flushed['events'].append({'Unit':{}});flushed['pendingCount']=0
 report={'factoryNext':2,'reservations':[{'Reserved':{'handle':{'namespace':1,'id':1}}},{'Reserved':{'handle':{'namespace':1,'id':2}}}],'activations':[{'Accepted':{}},{'Accepted':{}}],'queueOutcome':{'Success':{}},'relationError':{'None':{}},'snapshots':[copy.deepcopy(snapshot),copy.deepcopy(snapshot),flushed],'descriptions':[{'Some':copy.deepcopy(description)},{'Some':copy.deepcopy(description)},{'None':{}}]}
 return {'inventory':prior,'resource':resource,'graphMachine':{'Reported':{'report':report}}}
if __name__=='__main__':
 for mutant,name in [(False,'expected.json'),(True,'drop-relations-expected.json')]:HERE.joinpath(name).write_text(json.dumps(expected(mutant),indent=2)+'\n')
