#!/usr/bin/env python3
"""Diagnose inherited wait4 RSS floor; no ECS performance acceptance."""
import hashlib,json,os,pathlib,resource,signal,subprocess,tempfile,time
HERE=pathlib.Path(__file__).resolve().parent

def child(args):
 started=time.monotonic();pid=os.posix_spawnp(str(args[0]),[str(x) for x in args],os.environ.copy(),setsid=True)
 while True:
  done,status,usage=os.wait4(pid,os.WNOHANG)
  if done:break
  if time.monotonic()-started>=5:
   os.killpg(pid,signal.SIGKILL);os.wait4(pid,0);raise RuntimeError('5s child deadline')
  time.sleep(.002)
 assert os.waitstatus_to_exitcode(status)==0
 return {'command':[str(x) for x in args],'wait4PeakRssKiB':usage.ru_maxrss,'seconds':time.monotonic()-started}

def main():
 os.sched_setaffinity(0,{5})
 result={'scope':'RSS collection-method diagnostic, not allocation or ECS workload measurements','cpuAffinity':sorted(os.sched_getaffinity(0)),'externalTimeAvailable':pathlib.Path('/usr/bin/time').exists(),'python':subprocess.check_output(['python3','--version'],text=True).strip(),'node':subprocess.check_output(['node','--version'],text=True).strip(),'launcherSha256':hashlib.sha256((HERE/'measurement-samples-rss-launcher.c').read_bytes()).hexdigest(),'probeSha256':hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest(),'rows':[]}
 with tempfile.TemporaryDirectory(prefix='rss-method-') as tmp:
  tmp=pathlib.Path(tmp);launcher=tmp/'launcher'
  subprocess.run(['clang','-std=c11','-O2',str(HERE/'measurement-samples-rss-launcher.c'),'-o',str(launcher)],check=True,timeout=120)
  # Fixed elementary RSS control: allocated and touched pages remain live until exit.
  payload=tmp/'payload.c';payload.write_text('#include <stdlib.h>\n#include <unistd.h>\nint main(){volatile char *p=malloc(32*1024*1024);if(!p)return 1;for(size_t i=0;i<32*1024*1024;i+=4096)p[i]=1;usleep(20000);return p[0]!=1;}\n')
  subprocess.run(['clang','-O2',str(payload),'-o',str(tmp/'payload')],check=True,timeout=120)
  retained=None
  for mode in ['small-parent','retained-192MiB-parent']:
   if mode.startswith('retained'):
    retained=bytearray(192*1024*1024)
    for i in range(0,len(retained),4096):retained[i]=1
   for name,command in [('true',['/bin/true']),('node-empty',['node','-e','']),('touched32MiB',[tmp/'payload'])]:
    direct=child(command);stats=tmp/'stats.json';launched=child([launcher,stats,*command]);inside=json.loads(stats.read_text())
    result['rows'].append({'parentMode':mode,'parentPeakRssKiB':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'child':name,'direct':direct,'viaSmallLauncher':launched,'launcherResult':inside})
 result['finding']='Direct posix_spawn/wait4 RSS must be assessed against retained-parent floor; low-address-space launcher isolates a freshly forked child.'
 (HERE/'measurement-samples-rss-probe-evidence.json').write_text(json.dumps(result,indent=2)+'\n')
 for r in result['rows']:print(r['parentMode'],r['child'],r['direct']['wait4PeakRssKiB'],r['launcherResult']['childPeakRssKiB'])
if __name__=='__main__':main()
