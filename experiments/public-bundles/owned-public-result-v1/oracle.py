"""Independent full finite fixture oracle, authored before backend execution.
Values follow constructor +1000, five installation writes, original journal
and FIFO event contracts. No Bend output is imported, parsed or sampled.
"""
from pathlib import Path
RAW_REPLACE="True:[71, 72]/True:27/True:tag/True:[91, 92]:[101, 102]:[[111, 112]]/end"
RAW_INVALID="True:[11, 12]/True:17/True:tag/False:[31, 32]:[41, 42]:[[51, 52]]/end"
RAW_REPAIRED=RAW_INVALID.replace("False:","True:")
ACCESS="[write:a, write:b, write:tag, write:value, bundle.insert]"
REG="[1:owned-request:"+ACCESS+"]"
def context(count):
 return str([count]*4)+"/"+str([0,1,2,3]*count)
def world(ns,*,phase="before",invalid=False,accepted=False,peer=False):
 # World payload owners, physical columns, all lifecycle stamps, events,
 # registry metadata and retained installed queue payloads are compared.
 if peer:
  arrays=((1031,1032),(1041,1042));value=17;clock=5;stamps=("1:1:2","1:3:3","1:4:4","1:5:5")
 elif phase=="after" and accepted:
  arrays=((1031,1032),(1041,1042)) if invalid else ((1091,1092),(1101,1102));value=17 if invalid else 27;clock=11;stamps=("1:1:8","1:3:9","1:4:10","1:5:11")
 else:
  arrays=((501,502),(1041,1042));value=17;clock=11 if phase=="unwind" and accepted else 6;stamps=("1:1:6","1:3:3","1:4:4","1:5:5")
 text=f"[{list(arrays[0])}]@[{stamps[0]}]|[{list(arrays[1])}]@[{stamps[1]}]|[tag]@[{stamps[2]}]|[{value}]@[{stamps[3]}]|clock={clock}|live=[False, True]|ns={ns}|next=2|high=1|capacity=2"
 events="[]" if peer else "[43]" if phase=="before" else "[43, 801, 802, 901, 902]"
 raw="["+(RAW_REPAIRED if invalid else RAW_REPLACE)+"][]" if phase=="unwind" and accepted else "[]"
 installed=2 if phase=="after" and accepted else 1
 queues="[[[51, 52]], [[51, 52]]]" if phase=="after" and accepted and invalid else "[[[111, 112]], [[51, 52]]]" if phase=="after" and accepted else "[[[51, 52]]]"
 pending=0 if peer or phase!="before" else 3 if accepted else 2
 errors="[unwound]" if phase=="unwind" and accepted else "[null, null, null, null]"
 return text+f"|events={events}|context={context(1)}|raw={raw}|installed={installed}|quarantine=0|pending={pending}|errors={errors}|installed-queues={queues}|depth=1|registrations={'[]' if peer else REG}|nextSystem={1 if peer else 2}"
def row(ns,name,*,peer_ns=None):
 invalid=name.startswith("invalid-")
 declaration=name=="undeclared-return"
 retry="retry" in name
 phase="unwind" if "unwind" in name else "after" if "after" in name else "before"
 error="UndeclaredDescriptor:component:a:a" if declaration else "ConstructionRefused:[null, null, null, bad-3]" if invalid else "MissingEntity"
 raw=RAW_INVALID if invalid else RAW_REPLACE
 result="accepted" if retry else "refused:"+error+":"+raw
 cooked="[1011, 1012]/17/tag/[1031, 1032]:[1041, 1042]:[[51, 52]]/end" if invalid else "[1071, 1072]/27/tag/[1091, 1092]:[1101, 1102]:[[111, 112]]/end"
 prepared="[1:"+cooked+"]" if retry else "[]"
 text=world(ns,phase=phase,invalid=invalid,accepted=retry)+f"|registry={ns}:1:owned-request:{ACCESS}:6|result={result}|first={error}|returned={raw}|caller-context={context(0 if declaration else 2 if retry else 1)}|prepared={prepared}"
 if peer_ns is not None: text+="|peer="+world(peer_ns,peer=True)
 return text
CASES=["missing-return","missing-retry-before","missing-retry-after","missing-retry-unwind","invalid-return","invalid-retry-before","invalid-retry-after","invalid-retry-unwind","undeclared-return","foreign-return","foreign-retry-after"]
def expected():
 rows=[];ns=0
 for schema in ["A","B"]:
  for name in CASES:
   ns+=1;receiver=ns;peer=None
   if name.startswith("foreign-"):ns+=1;peer=ns
   rows.append(schema+"-"+name+"="+row(receiver,name,peer_ns=peer))
 return "\n".join(rows)+"\n"
if __name__=="__main__":print(expected(),end="")
