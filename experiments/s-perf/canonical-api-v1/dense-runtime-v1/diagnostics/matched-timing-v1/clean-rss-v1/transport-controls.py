"""Finite reached refusal controls for this leaf's RSS sidecar parser."""
from pathlib import Path
import json,subprocess,sys,tempfile
verifier=Path(__file__).with_name('verify-sidecars.py')
with tempfile.TemporaryDirectory(prefix='clean-rss-transport-')as name:
 d=Path(name);rss=d/'rss';a=d/'a';b=d/'b';p=d/'plan.json';p.write_text(json.dumps({'cleanChildRSS':{'path':str(rss)},'clockSidecars':[{'path':str(a)},{'path':str(b)}]}))
 def run(mode,code):
  r=subprocess.run([sys.executable,str(verifier),mode,str(p)],capture_output=True);assert (r.returncode==0)==(code==0),(mode,r.returncode,r.stderr)
 run('fresh',0);a.write_text('0\n');b.write_text('1\n')
 valid={'launcherPeakRssKiB':1,'childPeakRssKiB':2,'exitCode':0}
 for label,value in [('valid',valid),('negative',{**valid,'childPeakRssKiB':-1}),('boolean',{**valid,'childPeakRssKiB':True}),('child-failure',{**valid,'exitCode':1}),('missing',{'childPeakRssKiB':2,'exitCode':0})]:
  rss.write_text(json.dumps(value)+'\n');run('verify',0 if label=='valid'else 1);print(label,'PASS')
 rss.write_text(json.dumps(valid)+'\n');run('fresh',1);print('existing-refused PASS')
 rss.unlink();rss.symlink_to(a);run('verify',1);run('fresh',1);print('symlink-refused PASS')
