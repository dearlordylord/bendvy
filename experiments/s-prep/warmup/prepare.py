import pathlib,shutil,json,hashlib
H=pathlib.Path(__file__).resolve().parent;R=H.parents[2];P=R/'experiments/s-perf'
T=H/'materialized';shutil.rmtree(T,ignore_errors=True);shutil.copytree(P/'failure-quiet-overlay',T/'overlay')
for n in ['failure-quiet-codec.bend','failure-quiet-codec.mjs','failure-quiet-decode.mjs']:
 s=(P/n).read_text().replace('failure-quiet-overlay/','overlay/');(T/n).write_text(s)
p=T/'overlay/experiments/s-integrate/measurement-failure-driver.bend';s=p.read_text().replace('../../../failure-quiet-codec.bend','../../../failure-quiet-codec.bend')
# Existing relative import expects codec alongside overlay; retain directory depth.
s=s.replace('../../../failure-quiet-codec.bend','../../../failure-quiet-codec.bend')
for lane,SC in [('motion','Motion'),('health','Health')]:
 s=s.replace(f'def {lane}_timed(start:Nat,',f'def {lane}_timed(emit:Bool,start:Nat,')
 s=s.replace(f'def {lane}_ready(count:U32,',f'def {lane}_ready(emit:Bool,count:U32,')
 s=s.replace(f'def {lane}_start(+count:U32,',f'def {lane}_start(emit:Bool,+count:U32,')
 s=s.replace(f'ready => {lane}_ready(count,fuel,ready)',f'ready => {lane}_ready(emit,count,fuel,ready)')
 s=s.replace(f'{lane}_timed(start,{lane}_capture(final))',f'{lane}_timed(emit,start,{lane}_capture(final))')
 a=s.index(f'def {lane}_timed');b=s.index(f'def {lane}_ready',a)
 block=s[a:b].replace(f'def {lane}_timed(emit:Bool,',f'def {lane}_measured(')
 runtime=f'D.Runtime<F.{SC}Failure,S.Handle<T.{SC}Schema>>'
 extra=f'''def {lane}_warm_done(pair:{runtime} & List<&2,U32>) -> IO(Unit):
  match pair:
    case (_,tuple): IO.print("WARMUP-FOLD:" ++ U32.show(C.fold(tuple,0)))
def {lane}_timed(emit:Bool,start:Nat,pair:{runtime} & List<&2,U32>) -> IO(Unit):
  match emit:
    case False{{}}: {lane}_warm_done(pair)
    case True{{}}: {lane}_measured(start,pair)
'''
 s=s[:a]+block+extra+s[b:]
s=s.replace('case 0: motion_start(count,U32.to_nat(iterations))','case 0:\n      do IO<Unit>:\n        motion_start(False{},count,U32.to_nat(iterations))\n        motion_start(True{},count,U32.to_nat(iterations))').replace('case _: health_start(count,U32.to_nat(iterations))','case _:\n      do IO<Unit>:\n        health_start(False{},count,U32.to_nat(iterations))\n        health_start(True{},count,U32.to_nat(iterations))')
s=s.replace('def choose(schema:U32,count:U32,iterations:U32)', 'def choose(schema:U32,+count:U32,+iterations:U32)')
p.write_text(s)
# Codec imports are relative to materialized root, driver triple-parent import resolves overlay root.
shutil.copy(T/'failure-quiet-codec.bend',T/'overlay/failure-quiet-codec.bend')
q=(P/'failure-quiet-reference.mjs').read_text();a=q.index('const Main=');q=q[:a]+'function run(emit) {\n'+q[a:]
q=q.replace("console.log('FAILURE-FOLD:'+checksum);","console.log((emit?'FAILURE-FOLD:':'WARMUP-FOLD:')+checksum);")
q=q.replace("console.log('FAILURE-TIMING:'+elapsed);","if(emit) console.log('FAILURE-TIMING:'+elapsed);").replace("console.log('FAILURE-TUPLE:'+JSON.stringify(tuple));","if(emit) console.log('FAILURE-TUPLE:'+JSON.stringify(tuple));").replace("console.log('FAILURE-CAPTURE:'+JSON.stringify(captures));","if(emit) console.log('FAILURE-CAPTURE:'+JSON.stringify(captures));")
q+='\n}\nrun(false); run(true);\n';(T/'reference.mjs').write_text(q)
(H/'pins.json').write_text(json.dumps({str(x.relative_to(H)):hashlib.sha256(x.read_bytes()).hexdigest() for x in T.rglob('*') if x.is_file()},indent=2)+'\n')

shutil.copytree(P/'failure-indexed-overlay',T/'failure-indexed-overlay')
for n in ['failure-indexed-checks.bend','failure-indexed-service-guard.bend']: shutil.copyfile(P/n,T/n)

(H/'pins.json').write_text(json.dumps({str(x.relative_to(H)):hashlib.sha256(x.read_bytes()).hexdigest() for x in T.rglob('*') if x.is_file()},indent=2)+'\n')
