"""Source-only finite TS present-resource public observations; no TS execution."""
import json

def description():
    return {"version":1,"components":[{"name":"Position","storage":"plain"}],
        "resources":[{"name":n,"storage":"plain","present":True} for n in ["FirstResource","SecondResource"]],
        "events":[],"relations":[],"machines":[],"services":[],
        "schedules":[{"name":"Setup","steps":[{"kind":"system","system":"Setup"},{"kind":"applyDeferred"}]}],
        "systems":[{"name":"Setup","placements":["Setup#0"],"queries":[],
            "resources":{"reads":[],"writes":[]},"events":{"reads":[],"writes":[]},
            "machines":{"reads":[],"next":[],"transitions":[],"transitionEvents":[]},
            "removed":[],"despawned":False,"relationFailures":[],"services":[],"when":[]}],
        "access":{"components":[{"name":"Position","readers":[],"writers":[]}],
            "resources":[{"name":n,"readers":[],"writers":[]} for n in ["FirstResource","SecondResource"]],"events":[]},"lints":[]}

def scenario(label):
    observations=[]
    # Runtime.tick begins frame1; Setup system advances tick1, barrier tick2.
    # Persistent inspect reads then advances tick3..6, with no new frame.
    for tick,name in enumerate(["before1","before2","after1","after2"],3):
        observations.append({"label":name,"projection":{"rows":[{"entity":1,"value":[42],"samePosition":True}],
            "first":[17],"second":[18],"sameFirst":True,"sameSecond":True,"distinctResources":True},
            "dump":{"version":1,"frame":1,"tick":tick,"entityCount":1,
                "entities":[{"id":1,"components":{"Position":[42]},"relations":{}}],
                "resources":{"FirstResource":[17],"SecondResource":[18]},"machines":{},"pendingCommands":[]},
            "population":{"entities":1,"components":{"Position":1}},"description":description(),"streams":[]})
    return {"schema":label,"setupStatus":{"ok":True},"observations":observations,
        "position":[42],"firstResource":[17],"secondResource":[18]}

def expected():
    return (json.dumps([scenario("A"),scenario("Other")],separators=(",",":"))+"\n").encode()

if __name__ == "__main__":
    import sys
    sys.stdout.buffer.write(expected())
