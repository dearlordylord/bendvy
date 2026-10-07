"""Finite raw-stream and detached-child controls for the shared runner."""
import os,sys,time
if sys.argv[1]=='raw':
 print('raw-out',flush=True);print('raw-err',file=sys.stderr,flush=True)
elif sys.argv[1]=='escape':
 child=os.fork()
 if child==0:
  os.setsid();print('escaped:'+str(os.getpid()),flush=True);time.sleep(30)
 else:
  time.sleep(30)
else:raise ValueError('unknown control')
