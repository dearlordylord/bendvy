import os,sys,time
if sys.argv[1]=='raw':
 os.write(1,b'raw-out\n');os.write(2,b'raw-err\n')
else:
 child=os.fork()
 if child==0:
  os.setsid();os.write(1,('escaped:'+str(os.getpid())+'\n').encode());time.sleep(30)
 else:time.sleep(30)
