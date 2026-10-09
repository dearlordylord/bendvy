Bounded existing-binary PC diagnostic

The target is the exact retained Clang19 `-O0` Inspector binary, SHA256
`3a3a7028a3c0a09fd6f543a3460f5b8f785a3083f20516bf8bdc79d8de966156`.
No source change, rebuild, dependency or semantic acceptance is involved.

The existing guarded collector owns the heavy lock across each stage. A pinned
`nm -n -S --defined-only` command captures complete raw symbols. The sampler
checks every selected text symbol against the exact ELF symbol table, combines
executable PT_LOAD offsets with the actual binary inode/maps mapping, and keeps
all overlapping symbol matches without altering generated suffixes. Unmatched
PCs, including external libraries, remain explicit.

The sampler owns a fork/exec child, synchronizes on PTRACE_EVENT_EXEC, and uses
SEIZE/INTERRUPT/GETREGSET NT_PRSTATUS on every TID present in each `/proc/task`
enumeration. Raw records retain newly observed TIDs, enumeration membership,
maps, PC, stop overhead, unexpected stops and errors. Sampling every 10ms cannot
observe threads whose entire lifetime falls between enumerations. This is leaf
PC distribution, not stacks, call counts or unbiased execution-time evidence.
The AArch64 user_pt_regs PC is the 33rd U64, byte offset256; raw header bindings
are pinned in the plan. No privileged hardware profiler is installed.

The target's wall deadline is exactly five seconds, including sampling stops.
A timer kills the owned target at that boundary. The shared supervisor has a
separate ten-second envelope for sampler setup, capture and kill/reap cleanup;
this is not a larger subject runtime allowance. Pidfd SIGKILL, EXITKILL and shared
descendant cleanup cover failures and stopped threads. Sampling perturbation
and stop overhead are retained. Cleanup and partial raw publication execute on
failure, with complete raw recovery bytes if the samples file cannot publish.

The raw sample JSON and target stdout/stderr are bound before interpreting child
failure. The collector keeps INCOMPLETE receipts on failure. A captured diagnostic
does not require the historical whole oracle to pass and cannot close #54 or
qualify compiler adoption. The original O3 and O0 failed attempts remain intact.

Portable controls use syscall doubles and temporary non-executable files only:
register-read failure resumes an actual stop; unexpected stops refuse; interrupt
deadline never claims a stop; pidfd kill/cleanup/reap order; exact symbol ranges
and aliases; PT_LOAD/maps inode bias; exclusive publication; helper byte drift
before execution; failed profile child preserves partial artifact final guards.
No Inspector/profile child is permitted until independent exact-plan admission.
