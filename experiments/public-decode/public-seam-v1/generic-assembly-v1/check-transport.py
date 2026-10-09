"""Source-current strict DTO controls plus preserved historical transport; no backend."""
import copy,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
path=HERE.parents[1]/'adoption-v1/qualification-v1/spine-report-v1/transport.py'
spec=importlib.util.spec_from_file_location('decode_strict_controls',path)
transport=importlib.util.module_from_spec(spec);exec(compile(path.read_bytes(),str(path),'exec'),transport.__dict__)
model=ROOT/'experiments/public-decode/public-seam-v1/oracle-v1/generic-assembly-v1/expected.json'
assert hashlib.sha256(model.read_bytes()).hexdigest()=='a0b2037dba1943acb7deb49f58007a72ff5d62821559744a8d1f9823c0a3e349'
value=json.loads(model.read_text());entry=HERE/'complete.bend';role='generic-assembly'
raw=transport.render(value,entry,True,role)
assert transport.parse(raw,entry,True,role)==value
rejections=[]
for name,mutate in [('missing-row',lambda y:y['second']['success']['result'].pop('rows')),('missing-owner',lambda y:y['recovery']['interleaved']['local'].pop('owners')),('wrong-candidate',lambda y:y['first'].__setitem__('$','WrongCandidate')),('extra-field',lambda y:y.__setitem__('ignored',0))]:
 changed=copy.deepcopy(value);mutate(changed)
 try:transport.render(changed,entry,True,role)
 except (AssertionError,KeyError):rejections.append(name)
 else:raise AssertionError(name)
for name,changed in [('trailing',raw+b' x'),('cross-nominal',raw.replace(b'first-public-fixture.Candidate',b'public-fixture.Candidate',1))]:
 assert changed!=raw
 try:transport.parse(changed,entry,True,role)
 except (AssertionError,ValueError):rejections.append(name)
 else:raise AssertionError(name)
old=ROOT/'experiments/public-decode/public-seam-v1/oracle-v1/full-assembly-v1/expected.json'
oldentry=HERE.parent/'full-assembly-v1/spine.bend';previous=json.loads(old.read_text())
oldraw=transport.render(previous,oldentry,True,'normal')
assert transport.parse(oldraw,oldentry,True,'normal')==previous
assert hashlib.sha256(oldraw).hexdigest()=='fa4cf1b57ae33edde49f83cd40410fabce873c51f114885fdce7fa9da9f337f1'
deferred=ROOT/'experiments/public-decode/public-seam-v1/oracle-v1/deferred-assembly-v1/expected.json'
assert hashlib.sha256(deferred.read_bytes()).hexdigest()=='8095a1eb678fcf3f9cf985ce33d9e779108f6041fbecdd7ac67cf8f94a2bac42'
dvalue=json.loads(deferred.read_text());dentry=HERE.parent/'deferred-assembly-v1/fixture.bend'
draw=transport.render(dvalue,dentry,True,'deferred-assembly')
assert transport.parse(draw,dentry,True,'deferred-assembly')==dvalue
for label,mutate in [('missing-barrier-owner',lambda y:y['lateMissing']['barrier']['mail'].pop('returned')),('missing-failed-packets',lambda y:y['failure']['instance']['value']['recoveries'][0].pop('packets')),('missing-foreign-output',lambda y:y['foreign']['result'].pop('outputs')),('missing-refusal',lambda y:y['invalid']['result']['outputs'][0].pop('owner'))]:
 changed=copy.deepcopy(dvalue);mutate(changed)
 try:transport.render(changed,dentry,True,'deferred-assembly')
 except (AssertionError,KeyError):rejections.append(label)
 else:raise AssertionError(label)
try:transport.parse(draw,dentry,True,'generic-assembly')
except (AssertionError,KeyError,ValueError):rejections.append('cross-role')
else:raise AssertionError('cross-role')
print(json.dumps({'status':'PASS','scope':'strict full DTO controls; no backend','genericRawBytes':len(raw),'genericRawSha256':hashlib.sha256(raw).hexdigest(),'deferredRawBytes':len(draw),'deferredRawSha256':hashlib.sha256(draw).hexdigest(),'rejections':rejections,'historicalNormalRawUnchanged':True,'backendChildren':0}))
