#!/usr/bin/env python3
"""Source-only actual typed-frame witness; event-only activation mutant is rejected."""
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
BATCH = {"tick":1,"count":1,"values":[FAILURE]}

def encode(value):
    return (json.dumps(value,separators=(",",":"))+"\n").encode()

class Model:
    def __init__(self, correct):
        self.correct = True
        self.event_activation = correct
        self.leaf_positions = []
        self.leaf_start = self.leaf_boundary = self.leaf_dropped = 0
        self.clock = self.route_tick = self.tick = self.start = self.boundary = 0
        self.events = copy.deepcopy(ORIGINALS)
        self.pending = 0
        self.cursor = self.removal_cursor = 0
        self.positions = []
        self.readers = []
        self.front = []
        self.back = []
        self.size = self.dropped = 0
        self.domain_exists = False
        self.journal = []
        self.message_batches = []

    def schedule_barrier(self):
        # The first real provider Tx succeeds and enqueues one closure. The
        # second has Failure77 and discards its staged closure. Barrier executes
        # just the first: same live entity is forbidden as hierarchy target.
        self.pending += 1
        staged_rollback = 1
        assert staged_rollback==1 and self.pending==1
        self.pending -= 1
        self.events.append(copy.deepcopy(FAILURE))
        assert self.clock==self.route_tick==self.tick==0

    def ingest(self, epoch):
        publications = [v["event"] for v in self.events if v["kind"]=="original"]
        fresh = publications[sum(len(v) for _,v in self.journal):]
        if fresh:
            self.journal.append((epoch,copy.deepcopy(fresh)))
            values = [{"kind":"original","event":v} for v in fresh if v["kind"]=="value"]
            if values:
                self.message_batches.append((epoch,values))
        failures = [v for v in self.events if v["kind"]=="relationFailure"]
        if failures:
            self.domain_exists = True
            self.back.insert(0,{"tick":epoch,"count":len(failures),"values":copy.deepcopy(failures)})
            self.size += len(failures)
        self.events = [v for v in self.events if v["kind"]!="relationFailure"]
        self.route_tick = self.tick = epoch

    def activate(self, epoch):
        # Existing standalone K.failed_clocked calls KRead.activate and
        # Ev.activate without update: active retention, unread cursor remains0.
        self.domain_exists = True
        if 1 not in self.readers:
            self.readers.insert(0,1)
        if not self.positions:
            self.positions.insert(0,{"id":1,"cursor":0,"registeredAt":epoch})

    def attempt(self, fail):
        self.ingest(max(1,self.route_tick,self.tick,self.clock))
        self.clock += 1
        self.route_tick += 1
        pos = self.positions[0] if self.positions else {"id":1,"cursor":0,"registeredAt":self.tick}
        relation_values = [v for batch in self.front+list(reversed(self.back))
                           if batch["tick"]>pos["cursor"] for v in batch["values"]]
        reading = {"key":1,"values":relation_values,
                   "lagged":max(pos["cursor"],pos["registeredAt"])<self.dropped}
        # Actual Leaf.reading snapshots before prepare activation or success.
        event_views=[]
        for reader_id in [1,2]:
            position=next((p for p in self.leaf_positions if p[0]==reader_id),
                          (reader_id,0,self.route_tick))
            values=[v for epoch,batch in self.message_batches if epoch>position[1] for v in batch]
            event_views.append({"values":values,"lagged":max(position[1],position[2])<self.leaf_dropped})
            if self.event_activation and not any(p[0]==reader_id for p in self.leaf_positions):
                self.leaf_positions.insert(0,(reader_id,0,max(0,self.route_tick-2)))
        view = {"query":[{"entity":HANDLE,"value":None}],
                "eventA":event_views[0],
                "eventB":event_views[1],
                "removals":[REMOVED],"relations":[reading]}
        if fail:
            if self.correct:
                self.activate(self.tick)
            assert self.cursor==self.removal_cursor==0
        else:
            for reader_id in [1,2]:
                if not any(p[0]==reader_id for p in self.leaf_positions):
                    self.leaf_positions.insert(0,(reader_id,0,max(0,self.route_tick-2)))
                self.leaf_positions[:]=[(i,self.route_tick-1 if i==reader_id else old,registered)
                                      for i,old,registered in self.leaf_positions]
            self.activate(self.tick)
            self.positions[0]["cursor"] = self.tick
            self.removal_cursor = len(self.events)
            self.ingest(self.route_tick)
            self.cursor = self.clock
        return view

    def frame(self):
        # frame_both first calls actual Leaf.frame at routeTick. Its hold boundary
        # is min(old leaf frameStart, all active leaf reader cursors). It frames
        # both histories but keep_publications preserves journal and World log.
        hold=self.leaf_start
        for _,cursor,_ in self.leaf_positions:
            hold=min(hold,cursor)
        while self.message_batches and self.message_batches[0][0]<=hold:
            epoch,_=self.message_batches.pop(0)
            self.leaf_dropped=max(self.leaf_dropped,epoch)
        self.leaf_boundary,self.leaf_start=self.leaf_start,self.route_tick
        # K.frame trims against OLD frameStart, then moves frameStart=tick,
        # boundary=old frameStart. Q.trim first normalizes back to front.
        if not self.front:
            self.front = list(reversed(self.back))
            self.back = []
        hold = self.start
        for position in self.positions:
            if position["id"] in self.readers:
                hold = min(hold,position["cursor"])
        while self.front and (self.front[0]["tick"]<=hold or self.size>65536):
            batch = self.front.pop(0)
            self.size -= batch["count"]
            self.dropped = max(self.dropped,batch["tick"])
        self.boundary,self.start = self.start,self.tick

    def snapshot(self):
        domains=[]
        if self.domain_exists:
            domains=[{"key":1,"readers":copy.deepcopy(self.readers),"queue":{
                "front":copy.deepcopy(self.front),"back":copy.deepcopy(self.back),
                "size":self.size,"dropped":self.dropped}}]
        return {"shared":{"routeTick":self.route_tick,"tick":self.tick,
                          "frameStart":self.start,"boundary":self.boundary,
                          "capacity":65536,"nextReader":2,
                          "positions":copy.deepcopy(self.positions),"domains":domains},
                "world":{"namespace":1,"clock":self.clock,"pending":self.pending,
                         "graph":{"edges":[],"inverses":[]},"events":copy.deepcopy(self.events)}}

    def row(self, phase, status, error=None, view=None):
        return {"phase":phase,"status":status,"error":error,"queryCursor":self.cursor,
                "view":copy.deepcopy(view),"state":self.snapshot()}

def derive(correct=True):
    m=Model(correct)
    m.schedule_barrier()
    rows=[m.row("after-real-barrier-before-first-callback","published")]
    first=m.attempt(True)
    rows.append(m.row("A-first-after-barrier","failed",7,first))
    m.frame()
    rows.append(m.row("frame-1","frame"))
    m.frame()
    rows.append(m.row("frame-2","frame"))
    assert m.positions==[{"id":1,"cursor":0,"registeredAt":1}]
    assert m.readers==[1] and m.front==[BATCH] and m.back==[]
    assert m.size==1 and m.dropped==0
    assert m.leaf_start==m.leaf_boundary==2
    assert m.journal==[(1,[VALUE,REMOVAL])]
    if correct:
        assert m.leaf_positions==[(2,0,0),(1,0,0)]
        assert m.message_batches==[(1,[ORIGINALS[0]])] and m.leaf_dropped==0
    else:
        assert m.leaf_positions==m.message_batches==[] and m.leaf_dropped==1
    retry=m.attempt(False)
    rows.append(m.row("retry","completed",None,retry))
    assert [r["queryCursor"] for r in rows]==[0,0,0,0,2]
    assert [r["state"]["world"]["clock"] for r in rows]==[0,1,1,1,2]
    assert [r["state"]["shared"]["routeTick"] for r in rows]==[0,2,2,2,3]
    assert [r["state"]["shared"]["tick"] for r in rows]==[0,1,1,1,3]
    assert [r["state"]["shared"]["frameStart"] for r in rows]==[0,0,1,1,1]
    assert [r["state"]["shared"]["boundary"] for r in rows]==[0,0,0,1,1]
    assert rows[0]["state"]["world"]["events"]==ORIGINALS+[FAILURE]
    assert all(r["state"]["world"]["events"]==ORIGINALS for r in rows[1:])
    assert m.journal==[(1,[VALUE,REMOVAL])]
    assert first["relations"][0]["values"]==[FAILURE]
    assert not first["relations"][0]["lagged"] and not retry["relations"][0]["lagged"]
    if correct:
        assert first==retry, "failed first read must survive two frames belowcapacity"
        assert m.positions==[{"id":1,"cursor":2,"registeredAt":1}]
        assert m.front==[BATCH] and m.size==1 and m.dropped==0
    else:
        assert retry["eventA"]["values"]==retry["eventB"]["values"]==[]
        assert not retry["eventA"]["lagged"] and not retry["eventB"]["lagged"]
        assert retry["relations"]==first["relations"]
        assert m.positions==[{"id":1,"cursor":2,"registeredAt":1}]
        assert m.leaf_positions==[(2,2,1),(1,2,1)]
    if correct:
        assert m.leaf_positions==[(2,2,0),(1,2,0)]
    assert m.front==[BATCH] and m.size==1 and m.dropped==0
    return encode({"mutation":{"committedQueue":"queued","committedOutcome":"success",
                               "rolledBackQueue":"queued","rolledBackOutcome":{"failure":77}},
                   "observations":rows})

def verify_pins():
    pins=json.loads((HERE/"source-pins.json").read_text())
    for path,expected in pins.items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==expected,path
    return len(pins)

if __name__=="__main__":
    correct,defect=derive(),derive(False)
    assert correct!=defect
    only_event_loss=json.loads(correct)
    for key in ["eventA","eventB"]:
        only_event_loss["observations"][-1]["view"][key]["values"]=[]
    assert only_event_loss==json.loads(defect), "mutant must isolate typed event loss"
    for name,data in [("expected.stdout",correct),("predicted-event-only-mutant.stdout",defect)]:
        if "--write" in sys.argv:
            (HERE/name).write_bytes(data)
        else:
            assert (HERE/name).read_bytes()==data
    count=verify_pins()
    print(json.dumps({"sourceFilesVerified":count,"expectedBytes":len(correct),
                      "expectedSHA256":hashlib.sha256(correct).hexdigest(),
                      "rejectedPredictionBytes":len(defect),
                      "rejectedPredictionSHA256":hashlib.sha256(defect).hexdigest(),
                      "stateInvariants":"passed"}))
