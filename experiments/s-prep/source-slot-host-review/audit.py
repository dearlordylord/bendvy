#!/usr/bin/env python3
"""Independent source/fixture normalization; lexical edges are not runtime proof."""
import argparse,hashlib,json,pathlib,re
p=argparse.ArgumentParser();p.add_argument('--candidate',type=pathlib.Path,required=True);p.add_argument('--adapted',type=pathlib.Path);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();here=pathlib.Path(__file__).resolve().parent;baseline=json.loads((here/'baseline-pins.json').read_text());base=pathlib.Path(baseline['sourceRoot']);sha=lambda b:hashlib.sha256(b).hexdigest();digest=lambda x:sha(json.dumps(x,sort_keys=True,separators=(',',':')).encode());r={'status':'INCOMPLETE','scope':'Independent exact-source and original-fixture binding; static source review, not dynamic/universal acceptance','recipeSHA256':sha(pathlib.Path(__file__).read_bytes()),'originalPrefixes':{},'normalizedCopies':{},'fixtures':{}}
def save():a.output.write_text(json.dumps(r,indent=2)+'\n')
def blocks(s):
 starts=list(re.finditer(r'^(?:def|type) ([A-Za-z0-9_]+)',s,re.M));out={}
 for i,m in enumerate(starts):
  assert m[1] not in out,'Duplicate top-level declaration';out[m[1]]=s[m.start():starts[i+1].start() if i+1<len(starts) else len(s)]
 return out
def normalize(s):
 s=s.replace('prototype_slot_host_','').replace('CP.PrototypeMotionMainSlot','CC.Cache<T.Position,T.PositionView>').replace('CP.PrototypeHealthMainSlot','CC.Cache<T.Vitals,T.VitalsView>')
 for lane,raw in [('position','position'),('vitals','vitals')]:
  for op in ('new','get'):s=s.replace('CP.prototype_slot_'+lane+'_'+op,'CP.'+raw+'_'+op)
 return re.sub(r'\b(A|TA)\.prototype_packed_(motion_|health_)',r'\1.\2',s).strip()
try:
 manifest=json.loads((a.candidate/'overlay.json').read_text());pins=manifest['sources'];assert len(pins)==29 and set(pins)==set(baseline['sources']);assert all(sha((a.candidate/n).read_bytes())==h for n,h in pins.items());assert all(sha((base/n).read_bytes())==h for n,h in baseline['sources'].items());cache=json.loads((a.candidate/'cache-specialization.json').read_text());assert cache==manifest['cacheSpecialization'];assert all(cache[k]==pins and cache[k+'SHA256']==digest(pins) for k in ('runtimeClosure','specializedClosure'));r.update(candidateClosureSHA256=digest(pins),sourcePins=pins,changedModules=[])
 for n,h in pins.items():
  old=(base/n).read_text();new=(a.candidate/n).read_text()
  if h==baseline['sources'][n]:continue
  assert pathlib.Path(n).stem in ('systems','structural-invoker','audited-invoker','host'),'Unexpected runtime edit';assert new.startswith(old),'Original prefix changed';r['changedModules'].append(n);r['originalPrefixes'][n]={'originalSHA256':sha(old.encode()),'preservedBytes':len(old.encode())};od=blocks(old);nd=blocks(new);rows=[]
  for name,body in nd.items():
   if not name.startswith('prototype_slot_host_'):continue
   original=name.removeprefix('prototype_slot_host_');assert original in od;assert normalize(body)==od[original].strip(),f'Algorithm/body changed: {n}:{name}'
   assert 'SC.' not in body and 'measurement' not in body;rows.append({'private':name,'original':original,'privateBlockSHA256':sha(body.encode()),'originalNormalizedSHA256':sha(od[original].strip().encode())})
  r['normalizedCopies'][n]=rows
 assert len(r['changedModules'])==4
 assert sum(map(len,r['normalizedCopies'].values()))==174,'Unexpected clone inventory'
 if a.adapted:
  adaptation=json.loads((a.adapted/'adaptation.json').read_text());assert adaptation['sourcePins']==pins and adaptation['sourceClosureSHA256']==digest(pins);core=a.adapted/'core';original_root=pathlib.Path('/workspace/formal-proofs/bendvy/experiments/s-integrate')
  for n in ('host-fixture.bend','host-preflight.bend'):
   original=(original_root/n).read_text();assert sha(original.encode())==adaptation['originalFixturePins'][n];text=(core/n).read_text();assert sha(text.encode())==adaptation['changes'][n]['adaptedSHA256'];raw=text
   wrappers=['prototype_slot_position_new','prototype_slot_vitals_new','motion_ledger_new','health_ledger_new'];pattern=r'CP\.('+'|'.join(wrappers)+r')\('
   while (hit:=re.search(pattern,text)):
    at=hit.end();i=at;depth=1
    while depth:
     assert i<len(text);depth+=(text[i]=='(')-(text[i]==')');i+=1
    assert re.match(r'T\.(Position|Vitals|MotionLedger|HealthLedger)\{',text[at:i-1]);text=text[:hit.start()]+text[at:i-1]+text[i:]
   for typ,oldtyp in [('CP.PrototypeMotionMainSlot','T.Position'),('CP.PrototypeHealthMainSlot','T.Vitals'),('CC.Cache<T.MotionLedger,T.LedgerView>','T.MotionLedger'),('CC.Cache<T.HealthLedger,T.LedgerView>','T.HealthLedger')]:text=text.replace(typ,oldtyp)
   for oldname,newname in adaptation['hostMapping'].items():text=re.sub(r'\bH\.'+re.escape(newname)+r'\b','H.'+oldname,text)
   text=text.replace('import ./cache.bend as CC\n','').replace('import ./cached-payload.bend as CP\n','');assert text==original,f'Authored fixture/preflight changed: {n}'
   r['fixtures'][n]={'normalizedByteExact':True,'originalSHA256':sha(original.encode()),'adaptedSHA256':sha(raw.encode())}
  r['adaptationSHA256']=sha((a.adapted/'adaptation.json').read_bytes())
 r['status']='SOURCE29_PREFIX174_NORMALIZATION_AND_FIXTURE_BINDING_PASS'
except Exception as e:r.update(status='FAIL',error=repr(e));raise
finally:save()
