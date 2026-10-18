"""Reproduce historical small-launcher controls, not ECS memory acceptance."""
import hashlib,json,os,resource,signal,subprocess,sys,time
from pathlib import Path
plan=json.loads(Path(sys.argv[1]).read_text());cfg=plan['floorControls'];launcher=cfg['launcher'];payload=cfg['payload'];out=Path(cfg['output']);assert not out.exists()and not out.is_symlink()
def child(argv):
 start=time.monotonic();pid=os.posix_spawn(argv[0],argv,os.environ.copy(),setsid=True)
 while True:
  done,status,usage=os.wait4(pid,os.WNOHANG)
  if done:break
  if time.monotonic()-start>=5:
   os.killpg(pid,signal.SIGKILL);os.wait4(pid,0);raise RuntimeError('historical small control 5s deadline')
  time.sleep(.002)
 assert os.waitstatus_to_exitcode(status)==0
 return {'argv':argv,'outerWait4KiB':usage.ru_maxrss,'exitCode':0}
rows=[];retained=None
for mode in ['small-parent','retained-192MiB-parent']:
 if mode.startswith('retained'):
  retained=bytearray(192*1024*1024)
  for i in range(0,len(retained),4096):retained[i]=1
 for name,argv in [('true',['/bin/true']),('node-empty',[plan['tools']['node'],'-e','']),('touched32MiB',[payload])]:
  stats=out.parent/(mode+'-'+name+'.rss.json');assert not stats.exists()and not stats.is_symlink()
  direct=child(argv);via=child([launcher,str(stats),*argv]);raw=stats.read_bytes();value=json.loads(raw);assert value['exitCode']==0
  rows.append({'mode':mode,'child':name,'observerPeakKiB':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'direct':direct,'viaLauncher':via,'rssPath':str(stats),'rssSHA256':hashlib.sha256(raw).hexdigest(),'rss':value})
# Existing protocol's floor falsification: the three children must not all inherit
# the large retained observer's direct-wait4 floor. No ECS RSS threshold is set.
large=[r for r in rows if r['mode'].startswith('retained')];assert len(large)==3
assert all(r['rss']['childPeakRssKiB']<r['direct']['outerWait4KiB']for r in large)
assert len({r['rss']['childPeakRssKiB']for r in large})>1
result={'status':'RETAINED_OBSERVER_FLOOR_CONTROLS_PASS','scope':'six finite historical method controls only; no ECS memory threshold or ratios','rows':rows};out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
