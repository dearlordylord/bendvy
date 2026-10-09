from pathlib import Path
import json,hashlib,gzip,shutil,types,sys
root=Path('/workspace/formal-proofs/bendvy');h=Path('/workspace/formal-proofs/bendvy-worktrees/parity-54-layout-provenance/experiments/public-inspect/closed-owner-carrier-v1/recursive-owner-v1/layout-followup-v1/leaf-lift-v1/chunked-output-v1');out=Path('/tmp/bendvy-inspect54-chunk-backend02');out.mkdir();assets=out/'compiler';shutil.copytree('/tmp/bendvy-outline-once-runtime-controls02/compiler',assets);(assets/'emit.mts').unlink()
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
assert sha(assets/'comp.ts')=='1f139139ca08add93354823bb8ddddd6663294939c6433652351ddc2e749e548'
text=f'''import * as fs from 'node:fs';
import * as Bend from '{assets}/bend.ts';
import * as Comp from '{assets}/comp.ts';
const [entry,output]=process.argv.slice(2);
if(!entry||!output||fs.existsSync(output))throw new Error('entry and absent output required');
const book=Bend.book_nil(),seen=new Map<string,string|null>();
await Bend.book_load(book,entry,'',seen);Bend.book_valid(book);if(book.hols)throw new Error('incomplete source');
const text=Comp.compile_book(book),fd=fs.openSync(output,fs.constants.O_WRONLY|fs.constants.O_CREAT|fs.constants.O_EXCL|fs.constants.O_NOFOLLOW,0o600);
try{{if(!fs.fstatSync(fd).isFile())throw new Error('C descriptor not regular');fs.writeFileSync(fd,text);fs.fsyncSync(fd);}}finally{{fs.closeSync(fd);}}
''';(h/'emit.mts').write_text(text);(assets/'emit.mts').write_text(text)
def load(n,p):m=types.ModuleType(n);m.__file__=str(p);exec(compile(p.read_bytes(),str(p),'exec'),m.__dict__);return m
cfg=load('cfg',root/'experiments/public-simulation/delivery-v1/installed-config.py');helper=load('helper',root/'scripts/task_runner.py');dev=load('dev',h/'development.py')
tools={'python':str(Path(sys.executable).resolve()),'bend':'/home/node/.bend/bin/bend-2.0.35','node':'/home/node/.local/share/mise/installs/node/24.20.0/bin/node','taskset':'/usr/bin/taskset','clangWrapper':'/tmp/bendvy-clang19-diagnostic/clang19','clangBinary':'/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'}
index=[]
for name,role in [('normal','js'),('normal','native'),('drop','js'),('reorder','js')]:
 stage=h/('stage'if name=='normal'else'mutant-'+name);inventory={str(p.relative_to(stage)):sha(p)for p in stage.rglob('*.bend')};closure=dev.validate_imports(stage,inventory);oracle=h/('complete-expected.txt.gz'if name=='normal'else'expected-'+name+'.txt.gz');raw=gzip.decompress(oracle.read_bytes());folder=out/(name+'-'+role);folder.mkdir();generated=folder/('scenario.c'if role=='native'else'scenario.js');native=folder/'scenario.native';entry=stage/'output-io-main.bend'
 pins={str(stage/k):v for k,v in inventory.items()}
 extra=[*map(Path,tools.values()),h/'development.py',h/'prepare.py',h/'emit.mts',h/'source-inventory.json',h/'DELTA.json',h/'SOURCE-CHECK.json',h/'complete-expected.txt.gz',oracle,h/'test-preparation.py',h/'test-chunks.py',h/'test-source-preservation.py',h/'check-source.py',root/'scripts/task_runner.py',root/'scripts/evidence_boundary.py',root/'experiments/public-simulation/delivery-v1/installed-config.py',*assets.rglob('*')]
 extra+=[p for p in (h/'source-checks-current').iterdir()if p.is_file()]+[p for p in (h/'source-checks-mutants').iterdir()if p.is_file()]
 pins.update({str(p):sha(p)for p in extra if p.is_file()})
 commands=[{'label':'emit','argv':[tools['taskset'],'-c','5',tools['node'],str(assets/'emit.mts'),str(entry),str(generated)]if role=='native'else[tools['taskset'],'-c','5',tools['bend'],str(entry),'-o',str(generated)],'capSeconds':30}]
 if role=='native':commands+=[{'label':'build','argv':[tools['taskset'],'-c','5',tools['clangWrapper'],'-O3',str(generated),'-o',str(native),'-pthread','-lm'],'capSeconds':120}]
 commands+=[{'label':'consumer','argv':[tools['taskset'],'-c','5',str(native),'--threads','1','--gpu','off']if role=='native'else[tools['taskset'],'-c','5',tools['node'],str(generated)],'capSeconds':5}]
 plan={'scope':'Complete23-grant chunk serialization '+name+' '+role+' semantic development only; Native copied uninstrumented outlined compiler, no installed compiler/performance/#54 closure','role':role,'stage':str(stage),'entrypoint':str(entry),'sourceInventory':inventory,'importClosure':closure,'pins':pins,'resourceRoots':helper.Inputs(directories=cfg.RESOURCE_ROOTS).expected,'compilerAssets':str(assets),'compilerInventory':{str(p.relative_to(assets)):sha(p)for p in assets.rglob('*')if p.is_file()},'environment':cfg.environment(),'cwd':str(h),'oracle':str(oracle),'oracleSHA256':hashlib.sha256(raw).hexdigest(),'oracleBytes':len(raw),'generated':str(generated),'native':str(native),'tools':tools,'commands':commands}
 if name!='normal':plan['baselineOracle']=str(h/'complete-expected.txt.gz')
 path=folder/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');index.append({'name':name,'role':role,'plan':str(path),'sha256':sha(path),'launchArgv':[tools['python'],str(h/'development.py'),str(path),sha(path)]})
(h/'INDEX.json').write_text(json.dumps({'status':'UNADMITTED_UNEXECUTED','plans':index},indent=2)+'\n');print([(x['name'],x['role'],x['sha256'])for x in index])
