"""Independent complete refused foreign-registration observations; no backend input."""
import json
ACCESS=['component.Cells.write','resource.Owned.write','event.Ping.read','event.Ping.emit','machine.Flow.read','machine.Level.read','machine.Flow.next','transition.Flow.read','transition.Level.read']
def show(xs):return '['+', '.join(xs)+']'
def world(ns):
 stream='batches=[],positions=[],dropped=0,frameStart=0'
 return f'ns={ns};next=1;high=0;capacity=1;depth=0;live=[false];cells=[none]:stamps=[];owned=[3, 13];flow=Boot(pending=none,previous=none,changed=false);level=0(pending=none,previous=none,changed=false);flowStream={stream};levelStream={stream};frame=0;tick=0;hooks=[];locals=[{ns}:1:[0]];pingStream={stream};selector=0:0:false;attempts=[];deliveries=[];queue=0;registrations=[1:foreign-control:{show(ACCESS)}];nextSystem=2;componentClock=0;busEvents=[]'
def expected():
 target=world(2)
 rows=['rejected',target,target,f'1:1:foreign-control:{show(ACCESS)}:0',f'2:1:foreign-control:{show(ACCESS)}:0',world(1),'1:0:Boot>Play']
 return {'schemaA':rows,'schemaB':rows.copy()}
if __name__=='__main__':print(json.dumps(expected(),separators=(',',':')))
