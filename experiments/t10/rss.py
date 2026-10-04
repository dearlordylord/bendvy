#!/usr/bin/env python3
"""Linux per-child peak RSS via wait4; includes inherited pre-exec launcher RSS floor."""
import os,signal,sys,time
pid=os.fork()
if pid==0:
    output=os.open(os.devnull,os.O_WRONLY)
    os.dup2(output,1)
    os.execvp(sys.argv[1],sys.argv[1:])
deadline=time.monotonic()+14
while True:
    ended,status,usage=os.wait4(pid,os.WNOHANG)
    if ended:
        if os.waitstatus_to_exitcode(status)!=0:raise SystemExit('RSS child failed')
        print(int(usage.ru_maxrss));break
    if time.monotonic()>deadline:
        os.kill(pid,signal.SIGKILL);os.wait4(pid,0)
        raise SystemExit('RSS child exceeded 14 seconds')
    time.sleep(.02)
