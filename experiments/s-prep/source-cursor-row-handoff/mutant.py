#!/usr/bin/env python3
from pathlib import Path
import argparse,subprocess,sys
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();assert not a.output.exists();s=(H/'miniature.bend').read_text();old='Array.set(Maybe<M>,columns,U32.sub(id,1),Some{owner})';begin=s.index('def restore_rows(');end=s.index('def seal_taken(',begin);piece=s[begin:end];assert piece.count(old)==1;subject=a.output.parent/(a.output.name+'-subject.bend');assert not subject.exists();subject.write_text(s[:begin]+piece.replace(old,'columns')+s[end:]);subprocess.run([sys.executable,H/'run.py','--fixture',subject,'--counterexample','--output',a.output],check=True)
