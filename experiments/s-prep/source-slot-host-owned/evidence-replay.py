#!/usr/bin/env python3
"""Verify compact archived source/commands/outputs; optional safe reconstruction."""
import argparse,json,hashlib,pathlib,tarfile
H=pathlib.Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--extract',type=pathlib.Path);a=p.parse_args();m=json.loads((H/'evidence/manifest.json').read_text());archive=H/'evidence'/m['archive'];assert hashlib.sha256(archive.read_bytes()).hexdigest()==m['archiveSHA256']
with tarfile.open(archive,'r:gz') as t:
 objects={}
 for member in t.getmembers():
  assert member.isfile() and member.name.startswith('objects/') and len(member.name)==72
  b=t.extractfile(member).read();digest=member.name[8:];assert hashlib.sha256(b).hexdigest()==digest;objects[digest]=b
 assert len(objects)==m['uniqueObjects']
 for name,digest in m['files'].items():
  path=pathlib.PurePosixPath(name);assert not path.is_absolute() and '..' not in path.parts;assert digest in objects
 if a.extract:
  a.extract.mkdir(exist_ok=False)
  for name,digest in m['files'].items():
   f=a.extract/name;f.parent.mkdir(parents=True,exist_ok=True);f.write_bytes(objects[digest]);f.chmod(m['modes'][name])
print(json.dumps({'status':'ARCHIVE_HASH_AND_ALL_OBJECTS_PASS','files':len(m['files']),'objects':len(objects),'closure':m['closure']},indent=2))
