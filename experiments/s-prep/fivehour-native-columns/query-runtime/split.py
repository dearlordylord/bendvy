#!/usr/bin/env python3
"""Control-only schema split; retain exact original executable definitions."""
import pathlib,re,json,hashlib
H=pathlib.Path(__file__).resolve().parent
import argparse
a=argparse.ArgumentParser();a.add_argument('--prepared',type=pathlib.Path,required=True);cli=a.parse_args();assert cli.prepared.is_absolute() and cli.prepared.resolve()==cli.prepared
source=(cli.prepared/'experiments/s-integrate/measurement-bend.bend').read_text();driver=(H/'query-workload.bend').read_text()
def blocks(s):return list(re.finditer(r'^(def|type) (\w+)[\s\S]*?(?=^(?:def|type|import) |\Z)',s,re.M))
imports=lambda s:'\n'.join(re.findall(r'^import .*$',s,re.M))+'\n\n'
receipt={}
for schema in ['Motion','Health']:
 low=schema.lower();shared=['quad','keep','handle_client','first','sum','boolnum','clock_frame'];excluded=[low+'_'+suffix for suffix in ['print','dump','stop','measured','start']]
 selected=[m for m in blocks(source) if m[2] in shared or (m[2].lower().startswith(low) and m[2] not in excluded)]
 library=imports(source)+'\n'.join(m[0] for m in selected);(H/(low+'-control-workload.bend')).write_text(library)
 functions=[m[0] for m in blocks(driver) if m[2].startswith(low+'_') or m[2].startswith('raw_') or m[2] in ['parsed','args','main']]
 control=imports(driver).replace('import ./measurement-bend.bend as M','import ./control-workload.bend as M')+'\n'.join(functions)
 control=control.replace('choose(schema,sparse,count)',f'{low}_start(count,U32.is_eq(sparse,1))')
 (H/(low+'-query-workload.bend')).write_text(control)
 receipt[schema]={'originalDefinitions':[m[2] for m in selected],'byteIdenticalOriginalBlocks':True,'librarySha256':hashlib.sha256(library.encode()).hexdigest(),'driverSha256':hashlib.sha256(control.encode()).hexdigest(),'observations':'same raw full world + ordered raw query + raw full world after query, full64 original loops; no observations removed'}
(H/'split-source-bindings.json').write_text(json.dumps(receipt,indent=2)+'\n')
