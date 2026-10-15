#!/usr/bin/env python3
"""Independent source-only model of the frozen ordinary scheduled reader consumer."""
import copy
import hashlib
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
HANDLE = {"namespace":1,"id":1}
REMOVED = {"entity":HANDLE,"component":"value"}
VALUE = {"kind":"value","value":11}
REMOVAL = {"kind":"removed","record":REMOVED}
ORIGINALS = [{"kind":"original","event":x} for x in [VALUE,REMOVAL]]
FAILURE = {"kind":"relationFailure","failure":{"relation":{"key":1,"name":"Parent","inverse":"Children","kind":"hierarchy"},"operation":"relate","source":1,"target":1,"error":{"kind":"self","source":1,"relation":"Parent"}}}

class Model:
    def __init__(self):
        self.clock = self.tick = self.failure_tick = 0
        self.events = copy.deepcopy(ORIGINALS)
        self.graph = {"edges":[],"inverses":[]}
        self.pending = []
        self.journal = []
        self.messages = []
        self.failures = []
        # Affine provider state is retained by each ordinary registration.
        self.providers = {name:{"queryCursor":0,"removalCursor":0,
                               "leafIds":[1,2] if name=="A" else [3,4],
                               "relationId":1 if name=="A" else 2}
                          for name in ["A","B"]}
        self.positions = []
        self.failure_positions = []
        self.domain_readers = []

    def submit(self, success):
        # Namespace validation queues both calls; actual graph validation occurs
        # when the staged command executes. Failure discards the staged command.
        staged = ["self-relation"]
        old = copy.deepcopy(self.__dict__)
        if success:
            self.pending.extend(staged)
        else:
            assert self.__dict__ == old
        return "queued", "success" if success else {"failure":77}

    def barrier(self):
        for command in self.pending:
            assert command == "self-relation"
            # relation-graph.validation returns SelfRelationNotAllowed, retaining
            # graph; relation-commands.publish_relate appends one complete notice.
            self.events.append(copy.deepcopy(FAILURE))
        self.pending = []

    def ingest(self, epoch):
        publications = [x["event"] for x in self.events if x["kind"]=="original"]
        fresh = publications[sum(len(v) for _,v in self.journal):]
        if fresh:
            self.journal.append((epoch,copy.deepcopy(fresh)))
            values = [{"kind":"original","event":x} for x in fresh if x["kind"]=="value"]
            if values:
                self.messages.append((epoch,values))
        for notice in self.events:
            if notice["kind"]=="relationFailure":
                self.failures.append((epoch,copy.deepcopy(notice)))
        self.events = [x for x in self.events if x["kind"]!="relationFailure"]
        self.tick = self.failure_tick = epoch

    @staticmethod
    def cursor(positions, reader):
        return next((cursor for actual,cursor,_ in positions if reader==actual),0)

    @staticmethod
    def advance(positions, reader, cursor, registered):
        if not any(actual==reader for actual,_,_ in positions):
            positions.insert(0,(reader,0,registered))
        positions[:] = [(actual,cursor if actual==reader else old,reg)
                        for actual,old,reg in positions]

    def attempt(self, name, fail, phase):
        provider = self.providers[name]
        self.ingest(max(1,self.tick,self.failure_tick,self.clock))
        self.clock += 1
        self.tick += 1
        event_views = []
        for reader in provider["leafIds"]:
            cursor = self.cursor(self.positions,reader)
            values = [v for epoch,batch in self.messages if epoch>cursor for v in batch]
            event_views.append({"values":values,"lagged":False})
        relation_cursor = self.cursor(self.failure_positions,provider["relationId"])
        view = {"query":[{"entity":HANDLE,"value":None}],
                "eventA":event_views[0],"eventB":event_views[1],
                "removals":[x["event"]["record"] for x in self.events[provider["removalCursor"]:]
                            if x["kind"]=="original" and x["event"]["kind"]=="removed"],
                "relations":[{"key":1,"values":[v for epoch,v in self.failures if epoch>relation_cursor],"lagged":False}]}
        unchanged = copy.deepcopy((provider,self.positions,self.failure_positions,self.domain_readers))
        if fail:
            assert (provider,self.positions,self.failure_positions,self.domain_readers)==unchanged
        else:
            for reader in provider["leafIds"]:
                self.advance(self.positions,reader,self.tick-1,max(0,self.tick-2))
            provider["removalCursor"] = len(self.events)
            relation_id = provider["relationId"]
            if relation_id not in self.domain_readers:
                self.domain_readers.insert(0,relation_id)
            self.advance(self.failure_positions,relation_id,self.failure_tick,self.failure_tick)
            self.ingest(self.tick)
            provider["queryCursor"] = self.clock
        world = {"namespace":1,"clock":self.clock,"pending":len(self.pending),
                 "graph":copy.deepcopy(self.graph),"events":copy.deepcopy(self.events)}
        return {"phase":phase,"status":"failed" if fail else "completed",
                "error":7 if fail else None,"clock":self.clock,
                "queryCursor":provider["queryCursor"],"view":view,"world":world}

def derive():
    m = Model()
    committed_status,committed = m.submit(True)
    before_rollback = copy.deepcopy(m.__dict__)
    rollback_status,rolled_back = m.submit(False)
    assert m.__dict__==before_rollback and len(m.pending)==1
    mutation = {"committedQueue":committed_status,"committedOutcome":committed,
                "rolledBackQueue":rollback_status,"rolledBackOutcome":rolled_back}
    rows = [m.attempt("A",False,"pre-barrier-fast")]
    assert rows[0]["world"]["pending"]==1 and m.failures==[]
    assert rows[0]["view"]["relations"]==[{"key":1,"values":[],"lagged":False}]
    m.barrier()
    assert m.events==ORIGINALS+[FAILURE] and m.graph=={"edges":[],"inverses":[]}
    assert m.pending==[] and m.clock==1
    for name,fail,phase in [("A",True,"A-fail-after-barrier"),("A",False,"A-retry"),
                            ("A",False,"A-repeat"),("B",False,"B-first"),("B",False,"B-repeat")]:
        rows.append(m.attempt(name,fail,phase))
    assert [r["clock"] for r in rows]==[1,2,3,4,5,6]
    assert [r["queryCursor"] for r in rows]==[1,1,3,4,5,6]
    assert [r["world"]["pending"] for r in rows]==[1,0,0,0,0,0]
    assert rows[1]["view"]==rows[2]["view"], "failure must retain complete replay"
    assert len(m.failures)==1 and m.failures==[(2,FAILURE)]
    assert m.journal==[(1,[VALUE,REMOVAL])] and m.messages==[(1,[ORIGINALS[0]])]
    assert rows[4]["view"]["eventA"]["values"]==[ORIGINALS[0]]
    assert rows[4]["view"]["removals"]==[REMOVED]
    assert rows[4]["view"]["relations"][0]["values"]==[FAILURE]
    for i in [1,2,3,5]:
        assert rows[i]["view"]["eventA"]["values"]==[]
        assert rows[i]["view"]["eventB"]["values"]==[]
        assert rows[i]["view"]["removals"]==[]
    for i in [3,5]:
        assert rows[i]["view"]["relations"][0]["values"]==[]
    assert all(r["world"]["events"]==ORIGINALS and r["world"]["graph"]==m.graph for r in rows)
    assert m.positions==[(4,6,4),(3,6,4),(2,4,0),(1,4,0)]
    assert m.failure_positions==[(2,6,5),(1,4,1)]
    assert m.domain_readers==[2,1] and m.tick==m.failure_tick==7
    result={"mutation":mutation,"observations":rows}
    return (json.dumps(result,separators=(",",":"))+"\n").encode()

def verify_pins():
    pins=json.loads((HERE/"source-pins.json").read_text())
    for path,expected in pins.items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==expected,path
    return len(pins)

if __name__=="__main__":
    data=derive()
    if "--write" in sys.argv:
        (HERE/"expected.stdout").write_bytes(data)
    else:
        assert (HERE/"expected.stdout").read_bytes()==data
    count=verify_pins()
    print(json.dumps({"sourceFilesVerified":count,"bytes":len(data),"sha256":hashlib.sha256(data).hexdigest(),"stateInvariants":"passed"}))
