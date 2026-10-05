#!/usr/bin/env python3
"""Read-only boundary controls; no compiler, Node or measured packet."""
import argparse, datetime, json, pathlib, tempfile
from unittest.mock import patch
import boundary,guard
p=argparse.ArgumentParser();p.add_argument('--manifest',type=pathlib.Path,required=True);p.add_argument('--sha256',required=True);p.add_argument('--evidence',type=pathlib.Path,required=True);a=p.parse_args()
boundary.verify(a.manifest,a.sha256);killed=[]
with tempfile.TemporaryDirectory() as folder:
 root=pathlib.Path(folder); altered=root/'manifest.json';m=json.loads(a.manifest.read_text());m['batch']=15;altered.write_text(json.dumps(m))
 for label,path,digest in [('tampered-manifest',altered,a.sha256),('self-repinned-wrong-batch',altered,guard.sha(altered))]:
  try:boundary.verify(path,digest)
  except ValueError:killed.append(label)
  else:raise ValueError('control survived '+label)
 outside=root/'outside.bend';outside.write_text('import Base\n');entry=root/'inner.bend';entry.write_text('import '+str(outside)+'\n')
 try:guard.bend_closure(entry,[root/'allowed'])
 except ValueError:killed.append('escaped-absolute-import')
 else:raise ValueError('escaped source survived')
try:
 with patch.object(guard,'remaining',return_value=4):guard.deadline(5)
except ValueError:killed.append('deadline-insufficient-child-budget')
else:raise ValueError('deadline control survived')
with a.evidence.open('x') as f:json.dump({'status':'PREFLIGHT_SOURCE_PROTOCOL_IMPORT_DEADLINE_CONTROLS_PASS','manifestSHA256':a.sha256,'controls':killed,'noCompilerOrNodeExecuted':True},f,indent=2)
print('PREFLIGHT_CONTROLS_PASS')
