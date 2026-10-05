#!/usr/bin/env python3
"""Generated-JS allocation probe only; no Bend source or production compiler change."""
import argparse,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--input',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();text=a.input.read_text();before=hashlib.sha256(text.encode()).hexdigest();sites=[]
for suffix,field,access in [('motion_get','main','Found'),('motion_ledger','ledger','Some')]:
 pattern=r'function ([^\n]*held\$045adapter\$058'+suffix+r'\$)\(_owner_0, _token_0\) \{\n(.*?)\n\}'
 matches=list(re.finditer(pattern,text,re.S));assert len(matches)==1,suffix;m=matches[0];body=m[2]
 assert 'const _cached_0 = _t_0["cached"];' in body and 'const _t_0 = _owner_0["'+field+'"];' in body
 assert body.count('return ')==1 and '"fst": {$:' in body and '"raw": _raw_0, "cached": _cached_0' in body
 snd=re.search(r', "snd": (\{.*\})\};$',body);assert snd and ('types.Found' in snd[1] if access=='Found' else '"Some"' in snd[1])
 replacement='function '+m[1]+'(_owner_0, _token_0) {\n  const _cached_0 = _owner_0["'+field+'"]["cached"];\n  return {$: "Tuple", "fst": _owner_0, "snd": '+snd[1]+'};\n}'
 text=text[:m.start()]+replacement+text[m.end():];sites.append({'function':suffix,'removedObjectLiteralsPerCall':2,'oldBodySHA256':hashlib.sha256(body.encode()).hexdigest()})
a.output.write_text(text);a.output.with_suffix('.recipe.json').write_text(json.dumps({'scope':'Diagnostic emitted-code probe: preserve affine owner identity through reads; not Bend API/compiler adoption','inputSHA256':before,'outputSHA256':hashlib.sha256(text.encode()).hexdigest(),'sites':sites},indent=2)+'\n')
