#!/usr/bin/env python3
"""Linux/aarch64 process-delivered phase samples; no performance acceptance."""
import argparse, collections, hashlib, importlib.util, json, os, platform, signal, subprocess
from pathlib import Path

ROOT = Path('/workspace/formal-proofs/bendvy')
p = argparse.ArgumentParser()
p.add_argument('--schema', choices=['Motion', 'Health'], required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
assert platform.machine() == 'aarch64' and platform.system() == 'Linux'
a.output.mkdir(exist_ok=False)
sha = lambda path: hashlib.sha256(Path(path).read_bytes()).hexdigest()
build = Path('/tmp/bendvy-handoff-v8-' + a.schema.lower() + '-dense1024-build-r2')
source = build / 'batch.c'
receipt = json.loads((build / 'build.json').read_text())
assert receipt['status'] == 'BUILD_PASS'
assert sha(source) == receipt['artifacts']['batch.c']
reference = Path('/tmp/bendvy-handoff-v8-dense-' + a.schema.lower() + '-1024-r0/reference.mjs')
spec = importlib.util.spec_from_file_location('tools', ROOT / 'experiments/s-prep/source-handoff-dense-sizes/native/tool-pins.py')
tools = importlib.util.module_from_spec(spec); spec.loader.exec_module(tools)
toolpins = tools.snapshot()
r = dict(status='INCOMPLETE', schema=a.schema, sourceSHA256=sha(source),
         sourceClosure=receipt['sourceClosure'], originalBuildSHA256=sha(build/'build.json'),
         referenceSHA256=sha(reference), recipeSHA256=sha(__file__), toolPinsBefore=toolpins,
         scope='Perturbing Linux process-CPU samples delivered to arbitrary unblocked threads; no worker/time/acceptance attribution',
         commands=[], count=1024, iterations=64, batch=64)
env = os.environ.copy(); env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
def run(argv, cap, label):
    child = subprocess.Popen(['taskset', '-c', '11', *map(str, argv)], stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE, env=env, start_new_session=True)
    timed = False
    try: out, err = child.communicate(timeout=cap)
    except subprocess.TimeoutExpired:
        timed=True; os.killpg(child.pid, signal.SIGKILL); out, err=child.communicate()
    (a.output/(label+'.stdout')).write_bytes(out)
    (a.output/(label+'.stderr')).write_bytes(err)
    r['commands'].append(dict(argv=list(map(str,argv)), CPU=11, limitSeconds=cap,
                              exit=child.returncode, timeout=timed,
                              stdoutSHA256=hashlib.sha256(out).hexdigest(), stderrSHA256=hashlib.sha256(err).hexdigest()))
    assert not timed and child.returncode==0, (label, err[-1500:])
    return out.decode(), err.decode()

hook = r'''
#include <sys/time.h>
#include <ucontext.h>
#if !defined(__linux__) || !defined(__aarch64__)
#error unsupported phase sampler target
#endif
_Static_assert(ATOMIC_INT_LOCK_FREE == 2, "signal counter must be lock free");
_Static_assert(ATOMIC_LONG_LOCK_FREE == 2, "signal PC slot must be lock free");
#define PHASE_SAMPLE_CAP 16384u
static atomic_uint phase_sample_count, phase_sample_active;
static atomic_ulong phase_sample_pc[PHASE_SAMPLE_CAP];
static unsigned phase_sample_clocks;
static void phase_sample_signal(int sig, siginfo_t *info, void *context) {
  (void)sig; (void)info;
  if (!atomic_load_explicit(&phase_sample_active, memory_order_relaxed)) return;
  unsigned i = atomic_fetch_add_explicit(&phase_sample_count, 1, memory_order_relaxed);
  if (i < PHASE_SAMPLE_CAP) {
    unsigned long pc = ((ucontext_t*)context)->uc_mcontext.pc;
    atomic_store_explicit(&phase_sample_pc[i], pc, memory_order_release);
  }
}
static void phase_sample_start(void) {
  struct sigaction old, sa = {0};
  if (sigaction(SIGPROF, NULL, &old) || old.sa_handler != SIG_DFL) exit(81);
  sa.sa_sigaction = phase_sample_signal;
  sa.sa_flags = SA_SIGINFO | SA_RESTART;
  sigemptyset(&sa.sa_mask);
  if (sigaction(SIGPROF, &sa, NULL)) exit(82);
  struct itimerval timer = {{0,1000},{0,1000}};
  atomic_store_explicit(&phase_sample_active, 1, memory_order_relaxed);
  if (setitimer(ITIMER_PROF, &timer, NULL)) exit(83);
}
static void phase_sample_stop(void) {
  struct itimerval timer = {0};
  atomic_store_explicit(&phase_sample_active, 0, memory_order_relaxed);
  if (setitimer(ITIMER_PROF, &timer, NULL)) exit(84);
  unsigned count = atomic_load_explicit(&phase_sample_count, memory_order_relaxed);
  fprintf(stderr,"SAMPLE_COUNT:%u\n",count);
  for (unsigned i=0; i<count && i<PHASE_SAMPLE_CAP; ++i) {
    unsigned long pc=atomic_load_explicit(&phase_sample_pc[i], memory_order_acquire);
    fprintf(stderr,"SAMPLE_PC:%lx\n",pc);
  }
}
'''
try:
    text=source.read_text()
    marker='// Dialect\n'; assert text.count(marker)==1
    text=text.replace(marker,hook+'\n'+marker,1)
    old='Term io_now_run(Env e, Term* f, IoWork* w) {\n  return (Term)(io_tick() / 1000000);\n}'
    new='Term io_now_run(Env e, Term* f, IoWork* w) {\n  unsigned n = ++phase_sample_clocks;\n  if (n == 3) phase_sample_start();\n  if (n == 4) phase_sample_stop();\n  return (Term)(io_tick() / 1000000);\n}'
    assert text.count(old)==1; text=text.replace(old,new,1)
    derived=a.output/'sampled.c'; derived.write_text(text)
    r['derivedSHA256']=sha(derived)
    binary=a.output/'sampled-native'
    run([tools.WRAPPER, '-O3', '-g', '-no-pie', derived, '-pthread', '-lm', '-o', binary],120,'compile')
    run(['nm','-n',binary],5,'symbols')
    ts,_=run(['node',reference],5,'TS')
    native,stderr=run([binary,'--threads','1','--gpu','off'],5,'Native')
    observed=json.loads(ts)
    assert (observed['schema'],observed['count'],observed['iterations'],observed['batch'])==(a.schema,1024,64,64)
    spec=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py')
    validator=importlib.util.module_from_spec(spec); spec.loader.exec_module(validator)
    lines=[line for line in native.splitlines() if line.startswith('{')]; assert len(lines)==65
    for line, world in zip(lines,[observed['warmup'],*observed['samples']]):
        validator.validate(line,a.schema,False,1024,world)
        assert validator.normalized(json.loads(line),a.schema)==world['final']
    counts=[int(line.split(':')[1]) for line in stderr.splitlines() if line.startswith('SAMPLE_COUNT:')]
    assert len(counts)==1 and 0<counts[0]<16384
    pcs=[line.split(':')[1] for line in stderr.splitlines() if line.startswith('SAMPLE_PC:')]
    assert len(pcs)==counts[0]
    live=[pc for pc in pcs if int(pc,16)]
    assert live
    symbols,_=run(['addr2line','-f','-C','-e',binary,*['0x'+pc for pc in live]],5,'addresses')
    named=symbols.splitlines(); assert len(named)==2*len(live)
    sites=collections.Counter(zip(named[::2],named[1::2]))
    r.update(status='PHASE_SAMPLES_FULL65_PASS', fullWorlds=65, samples=counts[0],
             zeroPendingSlots=counts[0]-len(live), sampleIntervalRequestedUS=1000,
             sampleSites=[dict(function=f, location=l, samples=n) for (f,l),n in sites.most_common()],
             limit='Process-delivered signal samples, not exact durations, stacks, workers or comparison clocks. Inlining locations are diagnostic; library PCs may be unresolved.')
    tools.verify(toolpins)
    assert sha(source)==r['sourceSHA256'] and sha(reference)==r['referenceSHA256']
    r['sourceBytesStable']=True; r['toolPinsAfter']=tools.snapshot()
except Exception as e:
    r.update(status='FAIL', error=repr(e))
finally:
    r['artifacts']={str(f.name):sha(f) for f in a.output.iterdir() if f.is_file()}
    (a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps({key:r.get(key) for key in ['status','schema','samples','zeroPendingSlots','error']}))
raise SystemExit(0 if r['status']=='PHASE_SAMPLES_FULL65_PASS' else 1)
