import gzip,hashlib,importlib.util,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location("typed",HERE/"transport.py");T=importlib.util.module_from_spec(spec);spec.loader.exec_module(T)
oracle=Path(sys.argv[1]);raworacle=gzip.decompress(oracle.read_bytes());expected=json.loads(raworacle)
transport=T.Transport(HERE.parent/"main.bend");kind=transport.resolve("Candidate",transport.entry,{})
raw=T.TERM.render_term([transport.inverse(expected,kind)])+"\n"
actual=transport.normalize(raw);T.TERM.strict_equal(actual,expected)
for malformed in ["[]", "[Candidate{None{}}]", "[Candidate{None{}}, Candidate{None{}}]"]:
 try:transport.normalize(malformed)
 except ValueError:pass
 else:raise AssertionError("Invalid root qualified")
# Full comparison must detect final schema owner mutation; no projection.
old=actual["result"]["value"]["beta"]["capacity"]["value"]["world"] if False else None
changed=json.loads(raworacle);changed["result"]["value"]["beta"]["capacity"]["value"]["world"]["clock"]+=1
try:T.TERM.strict_equal(actual,changed)
except ValueError:pass
else:raise AssertionError("Last capacity world changed without rejection")
compressed=gzip.compress(raw.encode(),mtime=0);(HERE/"synthetic.stdout.gz").write_bytes(compressed)
(HERE/"PREPARATION.json").write_text(json.dumps({"wholeOracleSHA256":hashlib.sha256(raworacle).hexdigest(),"wholeOracleBytes":len(raworacle),"fullTypedRoundtrip":True,"root":"exactly one Candidate Some","semanticOracleUnwrapped":True,"rawBytes":len(raw.encode()),"rawSHA256":hashlib.sha256(raw.encode()).hexdigest(),"sourceCount":len(transport.sources),"constructors":len(transport.constructors),"emptyMultipleNoneRejected":True,"lastWorldMutationRejected":True},indent=2)+"\n")
print("Complete singleton full typed roundtrip and controls PASS")
