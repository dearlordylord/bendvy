"""Independent common-semantic projection fixed before actual TS executable outputs."""
import json
from pathlib import Path
H=Path(__file__).resolve().parent
EXCLUDED={'foreign_refused','foreign_legitimate_retry','inactive_restored'}
def project(row):
 return {k:row[k] for k in ['component','resource','extraPresent','extraPayload','current','previous','locals','attempts','prefix','pendingStructural','structuralApplied','deliveries','requirements','missing','outcome']} | {'pending':None if row['pending'] is None else row['pending']['value']}
if __name__=='__main__':
 source=json.loads((H/'expected.json').read_text())['rows']
 out={'status':'INDEPENDENT_TS_COMMON_ORACLE_BEFORE_EXECUTABLE_OUTPUT','comparable':{schema:{name:project(row) for name,row in rows.items() if name not in EXCLUDED} for schema,rows in source.items()},'bendOnly':{schema:[name for name in rows if name in EXCLUDED] for schema,rows in source.items()},'scope':'42 common semantic records plus six unchanged mandatory Bend-only authority/restoration records. Representation-specific clocks/IDs/namespace/cursors remain full Bend checks and raw TS evidence; no fabrication.'}
 p=H/'ts-common-expected.json';assert not p.exists();p.write_text(json.dumps(out,indent=2)+'\n')
