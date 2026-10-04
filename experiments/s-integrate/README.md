# S-INTEGRATE shared vocabulary checkpoint

Draft/signature preparation only. Nominal full Type payloads and observation/result
records check; abstract owner-return callback forwarding checks. No concrete world,
factory, handle, transaction, queue, reader registry or runtime implementation is
supplied. No authority is fabricated by hiding public constructors. Payload
constructors grant no entity authority. See [contracts](contracts.md) for remaining
trusted joins and the reviewed [trace](../../docs/design/s-integrate-trace.md).

`LAWS-DRAFT.bend` has independently evaluable foreign/reader/capture observation
predicates with finite valid/perturbed inputs; `main` returns True. Its commented
law templates are unbound/unapproved. Strings stand for future lossless complete
encodings. This does not pass #19's subject-bound draft/falsification gate or prove
Type ownership, runtime refinement, rollback or allocator semantics.

Fresh checks: types/positive callbacks/predicates pass the existing five-second
checker wrapper; all eight extracted negatives fail with the intended diagnostics.
Positive pairs retain an opaque owner, use its declared nominal getter, return
rejected payload, store only Data views and invoke a closure once. Negative pairs
try doubling an owner, wrong nominal access, fabricated provider return, Type
payload as Data, double invocation undeclared write, cross-handle substitution and wrong Ledger token. These are interface
controls, not yet the actual integrated-provider E10 controls. No ECS proofs added.

Reproduce from repository root (Python standard library only):

```sh
python3 - <<'PY'
import pathlib,re,subprocess,tempfile
root=pathlib.Path.cwd(); here=root/'experiments/s-integrate'
wrapper=root/'experiments/t01/bend-check'
def check(path,negative=None,execute=False):
    command=[str(wrapper),str(path)]+([] if execute else ['--check-only'])
    result=subprocess.run(command,capture_output=True,text=True,timeout=6)
    output=result.stdout+result.stderr
    assert result.returncode==(1 if negative else 0),(path,output)
    if negative: assert negative in output,(path,negative,output)
    elif execute: assert 'True{}' in output,output
    else: assert 'ALL PROOFS CHECK' in output,output
for name in ['types.bend','interface-controls.bend','LAWS-DRAFT.bend']:
    check(here/name)
check(here/'LAWS-DRAFT.bend',execute=True)
text=(here/'interface-controls.bend').read_text()
fixtures=re.findall(r'# NEGATIVE ([^\n]+) / ([^\n]+)\n(.*?)# END',text,re.S)
assert len(fixtures)==8
with tempfile.TemporaryDirectory(dir=here,prefix='negative-') as directory:
    for name,diagnostic,body in fixtures:
        source='\n'.join(line[2:] for line in body.splitlines())+'\n'
        path=pathlib.Path(directory)/(name+'.bend'); path.write_text(source)
        check(path,diagnostic)
print('PASS: vocabulary, abstract signature controls, finite predicates, eight intended negatives')
PY
```

The subprocess watchdog does not extend the wrapper's five-second limit. Compiler
is Bend2.0.34; version/guide, Base and prior R-A/R-C1/T04 signatures were inspected.
Schema arrays' exact width4, real storage/provider return, Tx-private inverse capture,
publication/reader hooks and complete encoder bindings remain the next freeze;
there is no claim that forwarding alone integrates them. Keep root/reuse/Local/
destructive recovery/layout/performance gates. Original references and Tower Defense
are unchanged; no dependencies or unapproved law proofs were introduced.
