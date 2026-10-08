"""Independent authored complete fixture oracle; does not read actual output."""
import json
from pathlib import Path

def entity(identifier, values, name="Payload"):
    return {"id":identifier,"components":{name:values}}
def snapshot(changed=False):
    return {"version":1,"nextEntity":4,"entities":[entity(1,[11,13] if changed else [7,9]),entity(2,[17,19])],"resources":{"Settings":[31,33] if changed else [27,29]}}
def column(rows):
    return {"rows":rows+[{"id":3,"components":{}}],"firstStamp":{"added":0,"changed":0},"secondStamp":{"added":0,"changed":0}}
def owner(namespace,changed=False):
    return {"namespace":namespace,"nextId":4,"highWater":3,"capacity":4,"depth":2,"handles":[{"namespace":namespace,"id":1},{"namespace":namespace,"id":2}],"store":{"saved":column([entity(1,[11,13] if changed else [7,9]),entity(2,[17,19])]),"transient":column([entity(1,[107,109],"Scratch"),entity(2,[117,119],"Scratch")]),"codec":{"ArrayValue":{"Integer":{}}}},"resources":{"saved":[31,33] if changed else [27,29],"transient":[127,129],"codec":{"ArrayValue":{"Integer":{}}}},"events":[],"pendingCount":0,"registrations":[],"nextSystemId":1,"clock":0}
def validation(changed=False):
    def field(name,value): return {"name":name,"result":{"Accepted":value}}
    return {"entities":[{"id":1,"fields":[field("Payload",[11,13] if changed else [7,9])]},{"id":2,"fields":[field("Payload",[17,19])]}],"resources":[field("Settings",[31,33] if changed else [27,29])]}
def report(namespace):
    return {"before":owner(namespace),"firstOwner":owner(namespace),"secondOwner":owner(namespace),"first":snapshot(),"second":snapshot(),"after":snapshot(True),"firstValidation":validation(),"afterValidation":validation(True),"owner":owner(namespace,True)}
def expected():
    return {"Workshop":report(1),"Garden":report(2)}
if __name__ == "__main__":
    authored=Path(__file__).with_name("expected-consumer.json").read_bytes()
    reconstructed=(json.dumps(expected(),indent=2)+"\n").encode()
    assert reconstructed==authored
    print("Independent pre-output oracle bytes match")
