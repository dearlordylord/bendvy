#!/usr/bin/env python3
"""Two-schema raw swap full-cell/metadata/true-old diagnostic, not a proof."""
import argparse, hashlib, json, os, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'))
import supervisor
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--cpu',type=int,default=10);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{a.cpu})
r={'status':'INCOMPLETE','scope':'Four raw affine payload types, two sequential writes, full four cells and metadata, true old before each write; finite literals only','cpu':a.cpu,'commands':[],'cases':[]}
def command(argv,limit):
 entry={'argv':list(map(str,argv)),'limit':limit};r['commands'].append(entry)
 try:
  code,text=supervisor.execute(entry['argv'],limit);entry.update(exit=code,output=text[-2000:]);assert code==0;return text
 except Exception as error:entry['error']=repr(error);raise
try:
 pins=json.loads((a.overlay/'overlay.json').read_text())['sources'];assert len(pins)==29 and all(sha(a.overlay/n)==v for n,v in pins.items());r['runtimePins']=pins
 core=a.overlay/'experiments/s-integrate';source=(HERE/'literal-control.bend').read_text();source=source.replace('import ./types.bend','import '+str((core/'types.bend').resolve())).replace('import ./uncached-payload.bend','import '+str((core/'uncached-payload.bend').resolve()));driver=a.output/'control.bend';driver.write_text(source);r['driverSHA256']=sha(driver);r['fixtureSHA256']=sha(HERE/'literal-control.bend');r['oracleSHA256']=sha(HERE/'literal-expected.txt')
 command(['bend',driver,'--check-only'],15)
 expected=(HERE/'literal-expected.txt').read_text().strip()
 for backend,extension in [('JS','js'),('Native','c')]:
  generated=a.output/('control.'+extension);command(['bend',driver,'-o',generated],30);r.setdefault('generatedPins',{})[backend]=sha(generated)
  argv=['node',generated]
  if backend=='Native':
   binary=a.output/'control-native';command(['clang','-O3',generated,'-pthread','-lm','-o',binary],120);r['nativeBinarySHA256']=sha(binary);argv=[binary,'--threads','1','--gpu','off']
  observed=command(argv,5);(a.output/(backend+'.observed.txt')).write_text(observed);assert observed.strip()==expected;r['cases'].append({'backend':backend,'fullCellsMetadataAndTrueOldEqual':True,'outputSHA256':hashlib.sha256(observed.encode()).hexdigest()})
 r['status']='JS_AND_NATIVE_FULL_LITERAL_CONTROLS_PASS'
except Exception as error:r.update(status='FAILED',error=repr(error))
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r));sys.exit(0 if r['status']=='JS_AND_NATIVE_FULL_LITERAL_CONTROLS_PASS' else 1)
