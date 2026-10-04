#!/usr/bin/env python3
"""Freeze actual indexed runtime and replay diagnostic inspection controls."""
import hashlib,io,json,os,pathlib,re,signal,subprocess,tarfile,tempfile,time
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[1]
CAN=HERE/'occupancy-candidate'
def run(args,limit=5,ok=0):
 p=subprocess.Popen(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:out,err=p.communicate(timeout=limit)
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);p.communicate();raise
 assert p.returncode==ok,(args,p.returncode,out,err)
 return out,err

def materialize(tmp):
 archive=subprocess.check_output(['git','archive','a976667','experiments'],cwd=ROOT,timeout=5)
 tarfile.open(fileobj=io.BytesIO(archive)).extractall(tmp)
 dest=tmp/'experiments/s-integrate'
 for p in (HERE/'candidate').glob('*.bend'):
  if not p.name.startswith('owned-storage-'):(dest/p.name).write_bytes(p.read_bytes())
 for p in CAN.glob('*.bend'):(dest/p.name).write_bytes(p.read_bytes())
 return dest

def closure(entry,result=None):
 result=result or {};result[str(entry)]=hashlib.sha256(entry.read_bytes()).hexdigest()
 for name in re.findall(r'^import\s+(\S+)',entry.read_text(),re.M):
  if name.startswith('.'):
   p=(entry.parent/name).resolve()
   if str(p) not in result:closure(p,result)
 return result

def trace(text):return [line for line in text.splitlines() if line.startswith('trace:')]
def replace_body(source,name,body):
 start=source.index('def '+name+'(');end=source.find('\ndef ',start+1)
 if end<0:end=len(source)
 header=source[start:source.index('\n',start)]
 return source[:start]+header+'\n  '+body+'\n'+source[end:]

def validate_stream(text):
 lines=text.splitlines();metrics={};reads={}
 for line in lines:
  if line.startswith('trace:'):reads[line.split(':')[1]]=line
  elif line.startswith('metric:'):
   _,phase,data=line.split(':',2);metrics.setdefault(phase,[]).append(data)
 assert trace(text)==['trace:registered-zero:0:0:0:False:False:False','trace:failed1:4:2:1:False:False:False','trace:failed2:4:2:1:False:False:False','trace:late-failure:3:2:1:False:False:False','trace:retry-success:3:2:1:True:False:False']
 assert metrics['registered-zero'][1]=='readers=4:0:0:0:True:True:True:0:0:0:False:False:False;end'
 assert metrics['registered-zero'][2]=='holders=1:[0,end]|1:[0,end]|1:[0,end]'
 assert metrics['rear'][0]=='ping=4:4:0:0:2:4:4:True:True|removed=4:2:0:0:2:2:2:True:True|despawned=4:1:0:0:1:1:1:True:True'
 assert metrics['rear'][1]=='readers=end';assert metrics['rear'][2]=='holders=0:[end]|0:[end]|0:[end]'
 assert metrics['two-holders'][1]=='readers=2:3:0:0:True:True:True:4:2:1:False:False:False;1:2:0:0:True:True:True:4:2:1:False:False:False;end'
 assert metrics['two-holders'][2]=='holders=2:[0,0,end]|2:[0,0,end]|2:[0,0,end]'
 assert metrics['front'][0]=='ping=4:4:0:2:0:4:4:True:True|removed=4:2:0:0:2:2:2:True:True|despawned=4:1:0:0:1:1:1:True:True'
 retained='ping=4:3:5:1:0:3:3:True:True|removed=4:2:0:0:2:2:2:True:True|despawned=4:1:0:0:1:1:1:True:True'
 for phase in ['dropped','late','empty-unread-nonzero','skip']:assert metrics[phase][0]==retained
 assert metrics['dropped'][1]=='readers=2:3:0:0:True:True:True:3:2:1:True:False:False;1:2:0:0:True:True:True:3:2:1:True:False:False;end'
 assert metrics['late'][1]=='readers=3:6:0:0:True:True:True:3:2:1:False:False:False;2:3:0:0:True:True:True:3:2:1:True:False:False;1:2:0:0:True:True:True:3:2:1:True:False:False;end'
 assert metrics['empty-unread-nonzero'][1]=='readers=3:6:0:0:True:True:True:3:2:1:False:False:False;2:3:0:0:True:True:True:3:2:1:True:False:False;1:2:8:8:True:True:True:0:0:0:False:False:False;end'
 assert metrics['skip'][1]=='readers=3:6:0:0:True:True:True:3:2:1:False:False:False;2:3:0:8:True:True:True:0:2:1:False:False:False;1:2:8:8:True:True:True:0:0:0:False:False:False;end'
 assert metrics['skip'][2]=='holders=3:[0,8,8,end]|3:[0,0,8,end]|3:[0,0,8,end]'
 assert metrics['malformed']==['4:99:0:1:1:2:3:False:False']
 assert metrics['whole-batch']==['2:0:1:0:0:0:0:True:True'];assert metrics['unit-batches']==['2:2:1:2:0:2:2:True:True']
 assert len(lines)==32,len(lines)
 return {'checkpoints':len(lines),'publicReads':5,'physicalFinal':{'ping':3,'removed':2,'despawned':1,'holders':3},'emptyUnreadReader':1}

def validate_tx(text):
 world='7:2:1:1:1:1:1:1:1';stages=[('begin','0:0:0:0'),('write1','0:0:1:1'),('write2','0:0:2:2'),('ledger','0:0:3:2'),('command1','1:0:3:2'),('command2','2:0:3:2'),('ping1','2:1:3:2'),('ping2','2:2:3:2'),('before-failure','2:3:3:2')]
 expected=['metric:initial:world='+world]+['metric:'+phase+':world='+world+'|tx='+stats for phase,stats in stages]+['trace:failure:pings=0','metric:after-failure:world='+world,'trace:restored:10,10,10,10:7','metric:before-success:world='+world+'|tx=1:1:0:0','trace:success:pings=1','metric:published:world=7:2:1:2:1:1:1:1:1','trace:before-barrier:10,10,10,10:7']
 assert text.splitlines()==expected,(text,expected)
 return {'checkpoints':len(expected),'pendingBeforeFailure':1,'pendingAfterFailure':1,'pendingAfterSuccess':2,'stagedCommandPeak':2,'stagedPingPeak':3,'inversePeak':3,'markPeak':2}

def main():
 run(['bend','version']);run(['bend','guide']);evidence={'scope':'finite diagnostic control replay, actual indexed owner inspection; no workload occupancy acceptance','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'cpu':8,'controls':{},'mutants':[]}
 with tempfile.TemporaryDirectory(prefix='occupancy-') as directory:
  root=pathlib.Path(directory);dest=materialize(root);original={p.name:p.read_bytes() for p in dest.glob('*.bend')}
  evidence['sources']={str(pathlib.Path(p).relative_to(root)):value for entry in ['occupancy-control.bend','occupancy-tx-control.bend'] for p,value in closure(dest/entry).items()}
  def reset():
   for name,data in original.items():(dest/name).write_bytes(data)
  def build(entry,name):
   assert 'ALL PROOFS CHECK' in ''.join(run(['taskset','-c','8','bend',dest/entry,'--check-only']))
   c=root/(name+'.c');js=root/(name+'.js');binary=root/name
   run(['taskset','-c','8','bend',dest/entry,'-o',c],30);run(['taskset','-c','8','bend',dest/entry,'-o',js],30);run(['taskset','-c','8','clang','-O3',c,'-o',binary,'-pthread','-lm'],120)
   native=run(['taskset','-c','8',binary,'--threads','1','--gpu','off'])[0];javascript=run(['taskset','-c','8','node',js])[0];assert native==javascript
   return native
  outputs={}
  for name,entry,validator in [('streams','occupancy-control.bend',validate_stream),('tx','occupancy-tx-control.bend',validate_tx)]:
   text=build(entry,name);evidence['controls'][name]=validator(text);outputs[name]=text;(HERE/('occupancy-'+name+'-observed.txt')).write_text(text)
   source=(dest/entry).read_text()
   if name=='streams':source=replace_body(source,'snapshot','IO.pure(State,state)')
   else:
    source=replace_body(source,'snapshot_tx','IO.pure(Tx(),tx)');source=replace_body(source,'snapshot_world','IO.pure(World(),world)')
   (dest/entry).write_text(source);plain=build(entry,name+'-plain');assert trace(plain)==trace(text);evidence['controls'][name]['uninstrumentedTraceMatch']=True;reset()
  source=(dest/'occupancy.bend').read_text()
  mutants={
   'omit-rear':source.replace('batches(V,rear)','BatchStats{0,0,0,True{}}'),
   'stale-size':source.replace('U32.is_eq(cached,U32.add(fv,rv))','True{}'),
   'lost-holder':source.replace('reader_stats(Schema,P,key,interests,state,logs) <> reader_records(Schema,P,logs,tail)','reader_records(Schema,P,logs,tail)'),
   'cursor-kind':source.replace('view_unread(W.Handle<Schema>,last,removed)','view_unread(W.Handle<Schema>,stream,removed)'),
   'ignore-registration':source.replace('U32.max(position,registered)','position'),
   'hardcoded-final-zero':source.replace('U32.show(physical)','U32.show(0)')}
  for name,mutant in mutants.items():
   assert mutant!=source;(dest/'occupancy.bend').write_text(mutant);text=build('occupancy-control.bend',name);assert trace(text)==trace(outputs['streams'])
   caught=False
   try:validate_stream(text)
   except AssertionError:caught=True
   assert caught,name;evidence['mutants'].append({'name':name,'compiledNativeJs':True,'publicTraceUnchanged':True,'detectedBoth':True});reset()
  helper='''\ndef pending_as_staged(stats: TxStats,world: WorldStats) -> TxStats:\n  match stats world:\n    case TxStats{_,pings,inverse,marks} WorldStats{_,_,_,pending,_,_,_,_,_}: TxStats{pending,pings,inverse,marks}\n'''
  (dest/'occupancy.bend').write_text(source+helper)
  entry=dest/'occupancy-tx-control.bend';entry.write_text(entry.read_text().replace('O.format_tx(stats)','O.format_tx(O.pending_as_staged(stats,ws))').replace('case (world,ws):','case (world,+ws):'))
  text=build(entry.name,'staged-as-pending');assert trace(text)==trace(outputs['tx']);caught=False
  try:validate_tx(text)
  except AssertionError:caught=True
  assert caught;evidence['mutants'].append({'name':'staged-as-pending','compiledNativeJs':True,'publicTraceUnchanged':True,'detectedBoth':True})
 evidence['status']='PASS';(HERE/'occupancy-control-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n');print(json.dumps({'status':'PASS','controls':evidence['controls'],'mutants':len(evidence['mutants'])}))
if __name__=='__main__':main()
