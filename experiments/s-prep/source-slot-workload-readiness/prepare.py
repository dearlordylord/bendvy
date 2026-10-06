#!/usr/bin/env python3
"""Fail-closed original-workload transport to a frozen persistent Slot runtime."""
import argparse,hashlib,json,pathlib,re,shutil,subprocess
P=pathlib.Path;ROOT=P('/workspace/formal-proofs/bendvy');BASE=ROOT/'experiments/s-integrate'
p=argparse.ArgumentParser();p.add_argument('--source',type=P,required=True);p.add_argument('--output',type=P,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);core=a.output/'core';shutil.copytree(a.source/'experiments/s-integrate',core)
sha=lambda b:hashlib.sha256(b).hexdigest();m=json.loads((a.source/'overlay.json').read_text());pins=m['sources'];assert len(pins)==29 and all(sha((a.source/n).read_bytes())==v for n,v in pins.items());closure=sha(json.dumps(pins,sort_keys=True,separators=(',',':')).encode());assert closure=='4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c'
entries=['measurement-bend.bend','measurement-lifecycle.bend','measurement-readers.bend','measurement-failure-driver.bend','measurement-failure-tuple-driver.bend','measurement-samples-bend.bend','measurement-samples-readers.bend','measurement-lifecycle-timed.bend'];special={'measurement-failure-tuple-driver.bend':ROOT/'experiments/s-perf/failure-quiet-overlay/experiments/s-integrate/measurement-failure-driver.bend','failure-quiet-codec.bend':ROOT/'experiments/s-perf/failure-quiet-codec.bend'};quiet_base=ROOT/'experiments/s-perf/failure-quiet-overlay/experiments/s-integrate';special.update({'quiet-'+f.name:f for f in quiet_base.glob('measurement-*.bend')});special['failure-indexed-checks.bend']=ROOT/'experiments/s-perf/failure-indexed-checks.bend';extras={};seen=set();protected={P(x).name for x in pins}
def visit(name):
 if name in seen:return
 seen.add(name)
 # Measurement entry/core measurement module must be original authored fixture, not SC replacement.
 if name in protected and name!='measurement-bend.bend':return
 path=special.get(name,BASE/name);blob=subprocess.check_output(['git','-C',str(ROOT),'show','8250177:'+str(path.relative_to(ROOT))],timeout=5);assert path.read_bytes()==blob,'Protected fixture drift: '+name;extras[name]=blob
 for dep in re.findall(rb'^import \./(\S+\.bend)',blob,re.M):
  target=P(dep.decode()).name
  if (name=='measurement-failure-tuple-driver.bend' or name.startswith('quiet-')) and target.startswith('measurement-'):target='quiet-'+target
  visit(target)
 if name=='measurement-failure-tuple-driver.bend':visit('failure-quiet-codec.bend')
 if name=='quiet-measurement-failure-observe.bend':visit('failure-indexed-checks.bend')
for entry in entries:visit(entry)
rename={n:'workload-'+n for n in extras};names={module:set(re.findall(r'^def ([\w.]+)\(', (core/module).read_text(),re.M)) for module in ['host.bend','transaction-dispatch-adapters.bend','audited-invoker.bend']}
kinds={'Position':('prototype_slot_position_new','CP.PrototypeMotionMainSlot'),'Vitals':('prototype_slot_vitals_new','CP.PrototypeHealthMainSlot'),'MotionLedger':('motion_ledger_new','CC.Cache<T.MotionLedger,T.LedgerView>'),'HealthLedger':('health_ledger_new','CC.Cache<T.HealthLedger,T.LedgerView>')}
r={'status':'PREPARING','sourceClosureSHA256':closure,'sourcePins':pins,'originalPins':{n:sha(b) for n,b in extras.items()},'changes':{},'protectedAuthoredBodies':{},'route':'Persistent affine Main Slot / existing Slot Host and packed Tx services; original generic query and authored workload algorithms','entries':{n:rename[n] for n in entries}}
def defs(text):
 heads=list(re.finditer(r'^(?:def|type) ([\w.]+)',text,re.M));return {h[1]:text[h.start():heads[i+1].start() if i+1<len(heads) else len(text)] for i,h in enumerate(heads)}
def template_create(text):
 # Current I.create has seven explicit template arguments; preserve all remaining value arguments.
 start=0
 while (match:=re.search(r'\bI\.create\(',text[start:])):
  begin=start+match.end();end=begin;level=1
  while level:level+=(text[end]=='(')-(text[end]==')');end+=1
  inside=text[begin:end-1];parts=[];cut=0;depth=0
  for i,c in enumerate(inside):
   depth+=(c in '(<[{')-(c in ')>]}')
   if c==',' and depth==0:parts.append(inside[cut:i]);cut=i+1
  parts.append(inside[cut:]);assert len(parts)==9,parts
  changed=','.join(('~'+v if not v.startswith('~') else v) if i<7 else v for i,v in enumerate(parts));text=text[:begin]+changed+text[end-1:];start=begin+len(changed)+1
 return text
def parts(inside):
 result=[];start=0;depth=0
 for i,c in enumerate(inside):
  depth+=(c in '(<[{')-(c in ')>]}')
  if c==',' and depth==0:result.append(inside[start:i]);start=i+1
 result.append(inside[start:]);return result

def io_barriers(text,name):
 for fname,block in list(defs(text).items()):
  if not fname.endswith('_barrier'):continue
  if name not in ['measurement-bend.bend','measurement-lifecycle.bend','measurement-failure-host.bend','measurement-lifecycle-timed.bend']:continue
  head=block.splitlines()[0];result=head.split(' -> ')[-1][:-1]
  if result.startswith('IO('):continue
  lines=block.splitlines();line=next(x for x in reversed(lines) if x.strip());call=line.split(': ',1)[1] if 'case ' in line else line.strip();open_at=call.index('(');outer=call[:open_at];args=parts(call[open_at+1:-1]);effect=args[-1]
  assert effect.startswith(('H.','L.','apply(')),(fname,effect)
  if fname=='seed_barrier':
   input_type='Owner & R.Clock';head=head.replace('~apply:Owner -> R.Clock -> Owner & R.Clock','~apply:Owner -> R.Clock -> IO(Owner & R.Clock)')
  elif name=='measurement-lifecycle-timed.bend':input_type='L.'+('Motion' if fname.startswith('motion') else 'Health')+'State & R.Clock'
  else:input_type='H.prototype_slot_host_'+('Motion' if fname.startswith('motion') else 'Health')+'Host() & R.Clock'
  lifted='IO.bind('+input_type+','+result+','+effect+', pair => IO.pure('+result+','+outer+'('+','.join(args[:-1]+['pair'])+')))'
  replacement=block.replace(block.splitlines()[0],head[:-len(result)-1]+'IO('+result+'):',1).replace(call,lifted,1)
  text=text.replace(block,replacement,1)
 return text

def adapt(text,name):
 if name in ['measurement-failure-callbacks.bend','failure-quiet-codec.bend']:return text
 saved=[]
 while (match:=re.search(r'T\.(Position|Vitals|MotionLedger|HealthLedger)\{',text)):
  start=match.start();end=match.end();depth=1;assert not (text[text.rfind('\n',0,start)+1:start].lstrip().startswith('case ') and ':' not in text[text.rfind('\n',0,start)+1:start]),'Raw pattern needs explicit adapter: '+name
  while depth:assert end<len(text);depth+=(text[end]=='{')-(text[end]=='}');end+=1
  raw=text[start:end];tag='__RAW_'+str(len(saved))+'__';saved.append('CP.'+kinds[match[1]][0]+'('+raw+')');text=text[:start]+tag+text[end:]
 for kind,(_,typ) in kinds.items():text=re.sub(r'T\.'+kind+r'\b',typ,text)
 for i,raw in enumerate(saved):text=text.replace('__RAW_'+str(i)+'__',raw)
 for alias,module,prefix in [('H','host.bend','prototype_slot_host_'),('A','transaction-dispatch-adapters.bend','prototype_packed_'),('AI','audited-invoker.bend','prototype_slot_host_')]:
  for old in sorted(names[module],key=len,reverse=True):
   if prefix+old in names[module]:text=re.sub(r'\b'+alias+r'\.'+re.escape(old)+r'\b',alias+'.'+prefix+old,text)
 for stem,ops in [('position','prototype_slot_position'),('vitals','prototype_slot_vitals'),('motion_ledger','motion_ledger'),('health_ledger','health_ledger')]:
  for op in ['get','swap']:text=re.sub(r'\bP\.'+stem+'_'+op+r'\b','CP.'+ops+'_'+op,text)
 if name=='measurement-bend.bend':
  text=text.replace('-Owner:Type,-Aux:Type,get:Owner -> Unit -> Owner & Unit,ag:Aux -> Aux & Maybe<&2,Unit>', '~Owner:Type,~Aux:Type,~get:Owner -> Unit -> Owner & Unit,~ag:Aux -> Aux & Maybe<&2,Unit>')
 if name=='measurement-lifecycle-timed.bend':
  for lane,cap,slot,aux,flag,ledger,mode in [('motion','Motion','CP.PrototypeMotionMainSlot','Velocity','Selected','MotionLedger','MotionMode'),('health','Health','CP.PrototypeHealthMainSlot','Armor','Tracked','HealthLedger','HealthMode')]:
   world=f'S.World<T.{cap}Schema,{slot},T.{aux},T.{flag},CC.Cache<T.{ledger},T.LedgerView>,T.{mode}>';checked=f'CMD.CheckedApply<T.{cap}Schema,{slot},T.{aux},T.{flag},CC.Cache<T.{ledger},T.LedgerView>,T.{mode}>';key=lane+'_foreign_applied';block=defs(text)[key]
   block=block.replace('pair:'+world+' & List<&2,S.Change<T.'+cap+'Schema>>','pair:'+checked).replace('case (beta,_):','case CMD.Applied{beta,_}:')
   block=block.rstrip()+f'\n    case _: IO.die(D.Runtime<L.{cap}State,S.Handle<T.{cap}Schema>> & (K.System & K.System),4,"foreign barrier rejected")\n'
   text=text.replace(defs(text)[key],block,1)
  text=text.replace('CMD.apply(','CMD.apply_checked(')
 if name=='measurement-failure-invoker.bend':
  for lane,cap,raw,stem in [('motion','Motion','Position','position'),('health','Health','Vitals','vitals')]:
   slot='CP.Prototype'+cap+'MainSlot';tx=cap+'Tx()';handle='S.Handle<T.'+cap+'Schema>'
   marker='def '+lane+'_finish(';assert marker in text
   bridge=f'def {lane}_raw_spawn_result(result:T.Reservation<{tx},{handle},{slot}>) -> T.Reservation<{tx},{handle},T.{raw}>:\n  match result:\n    case T.Reserved{{owner,handle}}: T.Reserved{{owner,handle}}\n    case T.ReserveRejected{{owner,payload}}: T.ReserveRejected{{owner,CP.prototype_slot_{stem}_raw(payload)}}\ndef {lane}_raw_spawn(owner:{tx},payload:T.{raw}) -> T.Reservation<{tx},{handle},T.{raw}>:\n  {lane}_raw_spawn_result(AI.prototype_slot_host_{lane}_spawn_main(owner,CP.prototype_slot_{stem}_new(payload)))\n'
   text=text.replace('AI.prototype_slot_host_'+lane+'_spawn_main,',lane+'_raw_spawn,')
   text=text.replace(marker,bridge+marker,1)
 text=io_barriers(text,name)
 text=template_create(text)
 text=text.replace('import Base\n','import Base\nimport ./cache.bend as CC\nimport ./cached-payload.bend as CP\n',1)
 return text
try:
 for name,blob in extras.items():
  old=blob.decode();new=adapt(old,name.removeprefix('quiet-'))
  if name=='measurement-failure-tuple-driver.bend' or name.startswith('quiet-'):
   for dep in extras:
    if dep.startswith('quiet-'):new=new.replace('import ./'+dep.removeprefix('quiet-')+' as ','import ./'+dep+' as ')
  if name=='quiet-measurement-failure-observe.bend':new=new.replace('import ../../../failure-indexed-checks.bend as FV','import ./failure-indexed-checks.bend as FV')
  if name=='failure-indexed-checks.bend':new=re.sub(r'import \./failure-indexed-overlay/experiments/s-integrate/(\S+\.bend) as ',r'import ./\1 as ',new)
  if name=='measurement-failure-tuple-driver.bend':new=new.replace('import ../../../failure-quiet-codec.bend as C','import ./workload-failure-quiet-codec.bend as C')
  if name=='failure-quiet-codec.bend':new=re.sub(r'import \./failure-quiet-overlay/experiments/s-integrate/(\S+\.bend) as ',r'import ./\1 as ',new)
  for dep,dest in rename.items():new=new.replace('import ./'+dep+' as ','import ./'+dest+' as ')
  # Completely preserve the original generic failed callback module, including imports.
  if name=='measurement-failure-callbacks.bend':assert new==old
  if name=='measurement-bend.bend':
   before=defs(old);after=defs(new)
   for body in [x for x in before if re.match(r'(motion|health)_body',x)]:assert before[body]==after[body],body;r['protectedAuthoredBodies'][body]=sha(before[body].encode())
  (core/rename[name]).write_text(new);r['changes'][name]={'originalSHA256':sha(blob),'adaptedSHA256':sha(new.encode())}
 assert all(sha((core/P(n).name).read_bytes())==v for n,v in pins.items())
 r['status']='PREPARED_TRANSPORT_ONLY';r['extraPins']={f.name:sha(f.read_bytes()) for f in core.glob('*.bend') if f.name not in protected}
except BaseException as e:r['status']='PREPARATION_BLOCKED';r['error']=repr(e);raise
finally:(a.output/'adaptation.json').write_text(json.dumps(r,indent=2)+'\n')
