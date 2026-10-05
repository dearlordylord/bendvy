#!/usr/bin/env python3
"""Replay twelve actual joined-host mutants against an immutable indexed overlay."""
import argparse
import datetime
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import sys
import types

ROOT = Path(__file__).resolve().parents[3]
BASE = ROOT/'experiments/s-integrate'

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def stamp():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()

class RetainedFolder:
    def __init__(self,path):
        self.path=path
    def __enter__(self):
        self.path.mkdir()
        return str(self.path)
    def __exit__(self,*_):
        return False

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--overlay',type=Path,required=True)
    parser.add_argument('--output-dir',type=Path,required=True)
    parser.add_argument('--cpu',type=int,default=10)
    args=parser.parse_args()
    os.sched_setaffinity(0,{args.cpu})
    args.output_dir.mkdir(parents=True,exist_ok=False)
    manifest=json.loads((args.overlay/'overlay.json').read_text())
    assert all(sha(args.overlay/path)==value for path,value in manifest['sources'].items()),'overlay drift'
    scratch=args.output_dir/'closure'
    shutil.copytree(args.overlay/'experiments/s-integrate',scratch)
    # Tooling is byte-identical to the authoritative semantic gate.
    for name in ('trace-decode.py','trace-compare.py'):
        shutil.copyfile(BASE/name,scratch/name)
    spec=importlib.util.spec_from_file_location('indexed_actual_host_mutations',BASE/'host-mutations.py')
    M=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(M)
    M.HERE=scratch
    M.ROOT=ROOT
    M.tempfile=types.SimpleNamespace(TemporaryDirectory=lambda prefix:RetainedFolder(args.output_dir/'work'))
    mutations=[]
    for label,file,before,after,channel in M.MUTATIONS:
        if label=='reversed-command-FIFO':
            before='batch(Schema,M,A,F,List.reverse(&1,S.Command<M,A,F>,pending),namespace,tick,Running{rows,[]})'
            after='batch(Schema,M,A,F,pending,namespace,tick,Running{rows,[]})'
        elif label=='implicit-flush':
            before='run(W,H,presence,invoke,barrier,transition,nodes,Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode})'
            after='IO.bind(Runtime<W,H>,Dispatched<W,H>,deferred(W,H,barrier,Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}),state => run(W,H,presence,invoke,barrier,transition,nodes,state))'
        elif label=='query-order':
            before='(S.Rows{main,aux,metadata,capacity,depth,high},List.reverse(&2,O,values))'
            after='(S.Rows{main,aux,metadata,capacity,depth,high},values)'
        mutations.append((label,file,before,after,channel))
    M.MUTATIONS=mutations
    metadata={'status':'INCOMPLETE','startedAt':stamp(),'overlayManifestSHA256':sha(args.overlay/'overlay.json'),
              'overlay':manifest,'nativeOptimization':'O0','nativeWorkers':1,'gpu':'off','cpuAffinity':[args.cpu],
              'isolation':'affinity only; machine is not exclusively reserved','purpose':'semantic mutation evidence; not comparative timing',
              'limitsSeconds':{'checker':5,'runtime':5,'codegen':30,'clang':120},
              'runnerSHA256':sha(Path(__file__)),'originalRunnerSHA256':sha(BASE/'host-mutations.py'),
              'decoderSHA256':sha(BASE/'trace-decode.py'),'comparatorSHA256':sha(BASE/'trace-compare.py'),
              'adaptedMutations':mutations,'commands':[],
              'mechanicalPathSeam':'Relocated wrapper ROOT uses parents[3] instead of parents[2]',
              'queryOrderSeam':'Full indexed-finalization tuple targets actual struct_idx_finish, not retained unused read_rows_finish'}
    original_command=M.command
    def logged_command(command,expected=0,timeout=5):
        number=len(metadata['commands'])+1
        log=args.output_dir/f'command-{number:03d}.txt'
        entry={'command':list(map(str,command)),'expectedExit':expected,'limitSeconds':timeout,
               'startedAt':stamp(),'outputFile':log.name}
        metadata['commands'].append(entry)
        try:
            result=original_command(command,expected=expected,timeout=timeout)
            log.write_text(result)
            entry.update(status='PASS',outputSHA256=sha(log),finishedAt=stamp())
            return result
        except Exception as error:
            log.write_text(str(error)+'\n')
            entry.update(status='FAIL',error=str(error),outputSHA256=sha(log),finishedAt=stamp())
            raise
        finally:
            (args.output_dir/'protocol.json').write_text(json.dumps(metadata,indent=2)+'\n')
    M.command=logged_command
    M.build.__globals__['command']=logged_command
    semantic=args.output_dir/'semantic-evidence.json'
    oldargv=sys.argv
    sys.argv=['host-mutations.py','--stage','complete','--optimization','O0','--cpu',str(args.cpu),'--output',str(semantic)]
    try:
        M.main()
        result=json.loads(semantic.read_text())
        assert len(result['mutants'])==12
        assert len(result['original'])==2 and all(x['fullSelectedChannelsEqual'] for x in result['original'])
        assert all(len(m['observations'])==2 and all(x['compiling'] for x in m['observations']) for m in result['mutants'])
        assert all(sha(args.overlay/path)==value for path,value in manifest['sources'].items()),'overlay drift'
        metadata.update(status='PASS',semanticEvidenceSHA256=sha(semantic))
    except Exception as error:
        metadata.update(status='FAIL',error=str(error))
    finally:
        sys.argv=oldargv
    metadata['finishedAt']=stamp()
    (args.output_dir/'protocol.json').write_text(json.dumps(metadata,indent=2)+'\n')
    print(metadata['status'],metadata.get('error'),flush=True)
    return int(metadata['status']!='PASS')

if __name__=='__main__':
    sys.exit(main())
