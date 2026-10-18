"""Reproduce complete source-state gold into a fresh directory, never subject output."""
from pathlib import Path
import argparse,gzip,hashlib,io,json
import common_model as C
from ts_model import full

SOURCE=Path(__file__).parent
sha=lambda raw:hashlib.sha256(raw).hexdigest()

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
    target=args.output;assert not target.exists(), 'Use a fresh output directory; frozen gold is immutable'
    target.mkdir(parents=True);spools=target/'spools';spools.mkdir()
    basis=json.loads((SOURCE/'SOURCE-BASIS.json').read_text())
    for name,h in basis['sourcePins'].items():assert sha((SOURCE/name).read_bytes())==h
    M=C.M;M.Model=C.Observer;real_path=Path
    M.Path=lambda value:spools/real_path(value).name if str(value).startswith('/tmp/failedtxn-oracle-ns-')else real_path(value)
    canonical=[];fixtures=[]
    for label,namespace in [('warmup',1),('measured',2)]:
        stream=io.StringIO();stream.write(label+'={');model,spool=M.setup_output(M.World(namespace),64,64,stream)
        for iteration in range(64):M.do_iteration(model,iteration)
        M.write_state('',model,stream,boundaries=spool);stream.write('}\n');spool.unlink()
        raw=stream.getvalue().encode();canonical.append(raw)
        records=model.completed();cells=C.tuple_records(records);fold=0
        for value in cells:fold=(fold*33+value)%2**32
        f={'role':label,'namespace':namespace,'records':records,'rawActorMap':model.raw_map(),'tuple':cells,'fold':fold,'callbacks':len(model.callback_records),'publications':len(model.publication_records),'boundaries':len(model.boundary_records),'phases':len(model.phase_records)}
        assert (len(records),len(cells),fold)==(965,3504864,615269452)
        assert (f['callbacks'],f['publications'],f['boundaries'],f['phases'],len(f['rawActorMap']))==(193,129,256,385,256)
        fixtures.append(f);(target/f'canonical-ns{namespace}.stdout.gz').write_bytes(gzip.compress(raw,mtime=0))
    raw=b''.join(canonical)
    assert len(raw)==38459780 and sha(raw)=='28595ef3734a1b4772e43d01b63806120db6c452207c31caaddd3d50cb45e3f0'
    assert fixtures[0]['tuple']==fixtures[1]['tuple']
    (target/'observer-fixtures.json.gz').write_bytes(gzip.compress(C.compact(fixtures).encode(),mtime=0))
    (target/'expected-common.json.gz').write_bytes(gzip.compress(C.compact({'tuple':fixtures[0]['tuple'],'fold':fixtures[0]['fold']}).encode(),mtime=0))
    outputs={}
    for role in ['bend','ts']:
        chunks=[]
        for i,label in enumerate(['WARMUP','SAMPLE']):
            f=fixtures[i];cells=json.dumps(f['tuple'])if role=='bend'else C.compact(f['tuple'])
            chunks.append(f"{label}\nFORCE:{f['fold']}\nTUPLE:{cells}\n".encode())
            if role=='bend':chunks.extend([('ACTORS:'+C.compact(f['rawActorMap'])+'\nCANONICAL-BEGIN\n').encode(),canonical[i],b'CANONICAL-END\n'])
            else:chunks.append(('FULL:'+C.compact(full(f))+'\n').encode())
        raw=b''.join(chunks);packed=gzip.compress(raw,mtime=0);(target/f'{role}-expected.stdout.gz').write_bytes(packed)
        outputs[role]={'bytes':len(raw),'sha256':sha(raw),'gzipSHA256':sha(packed)}
    assert outputs['bend']['bytes']==69682490 and outputs['bend']['sha256']=='a6d455cc821526cdd7813a4960894a5ed9f5780b35f1d6c842a83d69fe84cb1f'
    assert outputs['ts']['bytes']==36985248 and outputs['ts']['sha256']=='8cab96e40831d0bfa8225d36f671eed353f73d591dbbf563e61f8225ec805562'
    result={'status':'PASS','sourceBasisSHA256':sha((SOURCE/'SOURCE-BASIS.json').read_bytes()),'canonicalBytes':38459780,'canonicalSHA256':'28595ef3734a1b4772e43d01b63806120db6c452207c31caaddd3d50cb45e3f0','recordsPerWorld':965,'tupleValuesPerWorld':3504864,'fold':615269452,'oracles':outputs,'sourcePins':{p.name:sha(p.read_bytes())for p in SOURCE.glob('*.py')},'scope':'Independent complete source-state reproduction; no subject/compiler/timing or qualification run.'}
    (target/'PILOT-ORACLE-BASIS.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':main()
