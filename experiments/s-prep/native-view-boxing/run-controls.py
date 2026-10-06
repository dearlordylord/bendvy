import sys,os,json,argparse,hashlib
from pathlib import Path
sys.path.insert(0,'/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates');import supervisor
p=argparse.ArgumentParser();p.add_argument('--core',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();os.sched_setaffinity(0,{9});root=a.output;root.mkdir(exist_ok=False);here=Path(__file__).resolve().parent
for template in here.glob('*.bend.in'):(root/template.name.removesuffix('.in')).write_text(template.read_text().replace('CORE',str(a.core.resolve())))
r={'scope':'Finite retained immutable snapshots plus affine/schema/read-only rejection controls; no universal refinement','commands':[],'corePins':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in a.core.glob('*.bend')}}
def run(argv,cap,positive=True):
 code,out=supervisor.execute(argv,cap);r['commands'].append({'argv':argv,'limitSeconds':cap,'exit':code,'output':out});(root/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');assert (code==0 if positive else code!=0),out[-1000:];return out
run(['bend',str(root/'snapshot-control.bend'),'--check-only'],15)
for name in ['duplicate-raw','data-raw','write-view','cross-schema']:run(['bend',str(root/(name+'.bend')),'--check-only'],5,False)
run(['bend',str(root/'snapshot-control.bend'),'-o',str(root/'snapshot-control.js')],30)
run(['bend',str(root/'snapshot-control.bend'),'-o',str(root/'snapshot-control.c')],30)
run(['clang','-O3',str(root/'snapshot-control.c'),'-o',str(root/'snapshot-control-native'),'-lm','-pthread'],120)
outputs={}
for role,argv in [('JS',['node',str(root/'snapshot-control.js')]),('Native',[str(root/'snapshot-control-native'),'--threads','1','--gpu','off'])]:
 outputs[role]=run(argv,5);(root/(role+'.observed.txt')).write_text(outputs[role])
assert outputs['JS']==outputs['Native'];assert outputs['JS']==(here/'snapshot-expected.txt').read_text();r['status']='RETAINED_SNAPSHOT_BOTH_SCHEMAS_ROOT_NESTED_JS_NATIVE_PASS_AND_FOUR_NEGATIVES_REJECT';(root/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(outputs['JS'])
