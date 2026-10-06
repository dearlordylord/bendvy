#!/usr/bin/env python3
"""Compiling direct-swap true-old/wrong-cell controls on every raw payload type."""
import argparse,hashlib,json,os,shutil,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'))
import supervisor
p=argparse.ArgumentParser();p.add_argument('--overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--cpu',type=int,default=8);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{a.cpu})
sha=lambda b:hashlib.sha256(b).hexdigest()
r={'status':'INCOMPLETE','scope':'Finite compiling true-old and wrong-cell witnesses for four direct raw swap helpers; no proofs/full22/adoption','cpu':a.cpu,'runnerSHA256':sha(Path(__file__).read_bytes()),'commands':[],'cases':[]}
def command(argv,limit):
    code,out=supervisor.execute(list(map(str,argv)),limit)
    r['commands'].append({'argv':list(map(str,argv)),'limitSeconds':limit,'exit':code,'outputSHA256':sha(out.encode())})
    assert code==0,out[-1000:]
    return out
try:
    manifest=json.loads((a.overlay/'overlay.json').read_text())['sources']
    assert len(manifest)==29 and {str(p.relative_to(a.overlay)):sha(p.read_bytes()) for p in a.overlay.rglob('*.bend')}==manifest
    r['runtimePins']=manifest
    expected=(HERE/'literal-expected.txt').read_text().splitlines()
    for mutation in ['true-old','wrong-cell']:
        stage=a.output/mutation;shutil.copytree(a.overlay,stage)
        core=stage/'experiments/s-integrate';payload=core/'uncached-payload.bend';source=payload.read_text()
        before='},old)' if mutation=='true-old' else 'Array.set(U32,array,0,value)'
        after='},0)' if mutation=='true-old' else 'Array.set(U32,array,1,value)'
        sites=[]
        for stem in ['position','vitals','motion_ledger','health_ledger']:
            name='prototype_direct_'+stem+'_swap'
            start=source.index('def '+name+'(');end=source.index('\ndef ',start+1)
            block=source[start:end];assert block.count(before)==1
            assert source[source.index('def '+stem+'_swap('):].split('\ndef ',1)[0].count(name+'(')==1
            source=source[:start]+block.replace(before,after,1)+source[end:];sites.append(name)
        payload.write_text(source)
        driver=stage/'control.bend';text=(HERE/'literal-control.bend').read_text().replace('import ./types.bend','import '+str((core/'types.bend').resolve())).replace('import ./uncached-payload.bend','import '+str(payload.resolve()));driver.write_text(text)
        command(['bend',driver,'--check-only'],15)
        for backend in ['JS','Native']:
            generated=stage/('control.js' if backend=='JS' else 'control.c');command(['bend',driver,'-o',generated],30)
            argv=['node',generated]
            if backend=='Native':
                binary=stage/'control-native';command(['clang','-O3',generated,'-pthread','-lm','-o',binary],120);argv=[binary,'--threads','1','--gpu','off']
            observed=command(argv,5);(a.output/(mutation+'-'+backend+'.txt')).write_text(observed);lines=observed.splitlines();assert len(lines)==4
            for got,want in zip(lines,expected):
                assert got.split()[0]==want.split()[0] and got!=want
                if mutation=='true-old':assert 'old1=0 old2=0' in got and got.split(' cells=')[1]==want.split(' cells=')[1]
                else:assert got.split(' cells=')[1].split()[0]!=want.split(' cells=')[1].split()[0] and got.split(' cells=')[1].split(' ',1)[1]==want.split(' cells=')[1].split(' ',1)[1]
            r['cases'].append({'mutation':mutation,'backend':backend,'sites':sites,'allFourIntendedWitnesses':True,'mutantSourceSHA256':sha(source.encode()),'outputSHA256':sha(observed.encode())})
    r['status']='ALL_FOUR_DIRECT_SWAP_WITNESSES_BOTH_BACKENDS_PASS'
except Exception as e:r.update(status='FAIL',error=repr(e))
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r));sys.exit(0 if r['status']=='ALL_FOUR_DIRECT_SWAP_WITNESSES_BOTH_BACKENDS_PASS' else 1)
