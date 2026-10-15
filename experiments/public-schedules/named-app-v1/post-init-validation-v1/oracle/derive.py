#!/usr/bin/env python3
"""Independent source-only post-initialization rejection and compensation oracle."""
import copy
import hashlib
import json
import re
from pathlib import Path
import sys

HERE=Path(__file__).resolve().parent
ACCESS=['value','values:read','values:read','removal','value','Parent:read']
j=lambda value:json.dumps(value,separators=(',',':'))
call=lambda name,*values:name+'('+','.join(map(str,values))+')'
HANDLE={'namespace':1,'id':1}
VALUE={'kind':'original','event':{'kind':'value','value':11}}
REMOVAL={'kind':'original','event':{'kind':'removed','record':{'entity':HANDLE,'component':'value'}}}
FAILURE={'kind':'relationFailure','failure':{'relation':{'key':1,'name':'Parent','inverse':'Children','kind':'hierarchy'},'operation':'relate','source':1,'target':1,'error':{'kind':'self','source':1,'relation':'Parent'}}}

class Model:
    def __init__(self):
        self.events=copy.deepcopy([VALUE,REMOVAL,FAILURE])
        self.registrations=[]
        self.next_system=self.next_event=self.next_failure=1
        self.positions=[]
        self.domains=[]
        self.owners=[]
        self.descriptor=copy.deepcopy(ACCESS)
        self.declaration=None
        self.clock=self.route_tick=self.failure_tick=0

    def define_then_reject(self):
        # Actual Sys.register consumes one monotonic system ID before initialize.
        system_id=self.next_system
        self.next_system+=1
        self.registrations.insert(0,{'id':system_id,'name':'invalid-initialized','access':copy.deepcopy(self.descriptor)})
        # Initialize query Unit and both independent leaf event owners, removal
        # owner attached to registry ID, then independent keyed relation owner.
        self.owners.append(('query',None))
        for _ in range(2):
            self.owners.append(('event',self.next_event))
            self.next_event+=1
        self.owners.append(('removal',system_id))
        self.owners.append(('relation',self.next_failure))
        self.next_failure+=1
        initialized=copy.deepcopy(self.__dict__)
        assert self.owners==[('query',None),('event',1),('event',2),('removal',1),('relation',1)]
        # Trusted fixture validate_all returns owner/context unchanged and False.
        validated=False
        assert not validated and initialized==self.__dict__
        # Compensation calls actual dispose_provider: exact Sys registration
        # removal succeeds before RP.release. No callback prepare or ingestion.
        self.registrations=[]
        for kind,reader in self.owners:
            if kind=='event':
                self.positions=[p for p in self.positions if p[0]!=reader]
            elif kind=='removal':
                # Last removal registration gone: select_removal filters only
                # its matching original removal. Value and raw relation notice
                # are not selected by that operation.
                self.events=[v for v in self.events if v!=REMOVAL]
            elif kind=='relation':
                assert self.domains==[]
        self.owners=[]
        # definition_cleanup_result returns original descriptor/declaration.
        assert self.descriptor==ACCESS and self.declaration is None
        assert self.registrations==self.positions==self.domains==self.owners==[]
        assert (self.next_system,self.next_event,self.next_failure)==(2,3,2)
        assert self.events==[VALUE,FAILURE]
        assert self.clock==self.route_tick==self.failure_tick==0

    def render(self):
        # O.world renders full tree shape and all authoritative World fields.
        world=call('world',1,2,1,'[false, true]',2,1,'column(L(some(42)),[])',
                   'unit',j(self.events),0,'[]',self.next_system,self.clock)
        stream=call('stream',j('values'),'[]','[]',self.next_event,0,0,65536,0)
        failures=call('failures','[]','[]',self.failure_tick,0,0,65536,self.next_failure)
        return call('context',world,call('state',stream,'[]',0,failures),self.route_tick)

def derive():
    m=Model()
    before=m.render()
    assert m.events==[VALUE,REMOVAL,FAILURE]
    m.define_then_reject()
    after=m.render()
    assert before!=after
    # Observer context text is inserted as a raw constructor expression, not
    # JSON-quoted by main. Preserve exact source protocol without normalizing.
    result='{"before":'+before+',"status":"rejected-after-initialize","returnedAccess":'+j(m.descriptor)+',"returnedDeclaration":null,"after":'+after+'}'
    # Main has no embedded terminal LF; IO.print adds exactly one.
    return (result+'\n').encode()

def verify_pins():
    pins=json.loads((HERE/'source-pins.json').read_text())
    for path,expected in pins.items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==expected,path
    normalized=json.loads((HERE/'normalized-source-pins.json').read_text())
    for path,expected in normalized.items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==expected,path
    historical_root=Path('/workspace/formal-proofs/bendvy-worktrees/debug56-named-schedules')
    candidate_root=Path('/workspace/formal-proofs/bendvy-worktrees/ordinary-reader-composition-integration')
    for join in json.loads((HERE/'import-rewrite.json').read_text()):
        old=(historical_root/join['path']).read_bytes()
        new=(candidate_root/join['path']).read_bytes()
        assert hashlib.sha256(old).hexdigest()==join['beforeSHA256']
        assert hashlib.sha256(new).hexdigest()==join['afterSHA256']
        # Only actual import-prefix text changes. No declaration/function,
        # string literal, renderer or operation body is rewritten.
        rewritten=re.sub(rb'(?m)^(import )/tmp/[^ \n]+/src/ecs/',
                         rb'\g<1>../../../../src/ecs/',old)
        assert rewritten==new,join['path']
    for path,expected in pins.items():
        if '/src/ecs/' in path:
            relative=path.split('/src/ecs/',1)[1]
            actual=candidate_root/'src/ecs'/relative
            assert hashlib.sha256(actual.read_bytes()).hexdigest()==expected,path
    return len(pins),len(normalized)

if __name__=='__main__':
    data=derive()
    if '--write' in sys.argv:
        (HERE/'expected.stdout').write_bytes(data)
    else:
        assert (HERE/'expected.stdout').read_bytes()==data
    historical_count,normalized_count=verify_pins()
    print(json.dumps({'historicalSourceFilesVerified':historical_count,'normalizedSourceFilesVerified':normalized_count,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'stateInvariants':'passed'}))
