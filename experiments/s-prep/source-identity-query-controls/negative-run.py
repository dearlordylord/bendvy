import pathlib,subprocess,json,os,signal,hashlib,argparse,shutil
from pins import verify
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);H=pathlib.Path(__file__).resolve().parent;files,pins,closure=verify(a.overlay);r={'status':'INCOMPLETE','scope':'Actual identity nominal Type/schema arguments and generic abstract-client quantities; no universal authority proof','source29':pins,'closure':closure,'cases':[]}
anchors=json.loads((H/'negative-anchors.json').read_text())
for name,needles in anchors.items():
 stage=a.output/name;stage.mkdir();[(stage/n).write_bytes(b) for n,b in files.items()];f=stage/'fixture.bend';f.write_bytes((H/(name+'.bend')).read_bytes());argv=['taskset','-c','10','bend',str(f),'--check-only'];child=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:o,e=child.communicate(timeout=15)
 except subprocess.TimeoutExpired:os.killpg(child.pid,signal.SIGKILL);child.communicate();r['failure']={'name':name,'status':'TIMEOUT','limitSeconds':15};(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');raise
 text=o+e;(a.output/(name+'.txt')).write_text(text);r['cases'].append({'name':name,'argv':argv,'limitSeconds':15,'fixtureSHA256':hashlib.sha256(f.read_bytes()).hexdigest(),'returncode':child.returncode,'diagnostic':text});(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');assert child.returncode==1 and 'SOME PROOFS FAIL' in text and 'Location: bad' in text,(name,text);assert all(x in text for x in needles),(name,needles,text)
r['status']='ALL_REQUESTED_INTENDED_TYPE_SCHEMA_QUANTITY_NEGATIVES_PASS';(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
