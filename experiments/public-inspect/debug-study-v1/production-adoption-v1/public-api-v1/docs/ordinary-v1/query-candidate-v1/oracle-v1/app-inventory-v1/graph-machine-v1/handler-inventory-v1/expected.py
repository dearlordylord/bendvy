"""Complete independent handler model, source-only before backend observations."""
import copy,hashlib,json
BASE_SHA="5bf8430e31c0893be536061067cd048d869e5c20b072c105450b4178679e7acb"
def expected(raw,mutant=False):
    assert hashlib.sha256(raw).hexdigest()==BASE_SHA
    previous=json.loads(raw)
    prior=previous["graphMachine"]["Reported"]["report"]
    names=["ExitMode","TransitionMode","EnterMode"]
    access=["machine:Mode:exit","machine:Mode:transition","machine:Mode:enter"]
    selectors=[{"ExitFrom":{"value":{"Boot":{}}}},{"TransitionPair":{"from":{"Boot":{}},"to":{"Play":{}}}},{"EnterTo":{"value":{"Play":{}}}}]
    entries=[{"selector":selectors[i],"requirements":[{"Resource":{"id":9}}],"registry":{"ordinal":10*(i+1),"namespace":1,"id":i+1,"name":names[i],"access":[access[i]],"cursor":0}} for i in range(3)]
    bundle={"namespace":1,"entries":entries}
    before=copy.deepcopy(prior["snapshots"][-1])
    before["registrations"]=[{"id":i+1,"name":names[i],"access":[access[i]]} for i in reversed(range(3))]
    before["nextSystemId"]=4
    before["pendingCount"]=1
    marker=copy.deepcopy(before)
    marker["events"]=[{"Unit":{}} for _ in range(6)]
    marker["resource"]["slot"]={"Present":{"current":{"Play":{}},"pending":{"NoPending":{}},"previous":{"Some":{"Boot":{}}},"changed":True}}
    barrier=copy.deepcopy(marker);barrier["events"].append({"Unit":{}});barrier["pendingCount"]=0
    description={"ordinary":copy.deepcopy(prior["descriptions"][0]["Some"]),"machine":"Mode","handlers":copy.deepcopy(bundle)}
    if mutant: description["handlers"]["entries"]=[]
    report={"factoryNext":2,"snapshots":[copy.deepcopy(before),copy.deepcopy(before),marker,barrier],"descriptions":[{"Some":copy.deepcopy(description)},{"Some":copy.deepcopy(description)},{"None":{}}],"status":{"Completed":{}},"owners":{"Returned":{"bundle":copy.deepcopy(bundle)}}}
    return {"Reported":{"report":{"previous":previous,"handlers":report}}}
if __name__=="__main__":
    import sys
    from pathlib import Path
    print(json.dumps(expected(Path(sys.argv[1]).read_bytes(),len(sys.argv)>2),indent=2))
