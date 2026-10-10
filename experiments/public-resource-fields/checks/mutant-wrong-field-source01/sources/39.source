"""Exact installed cohort configuration candidate; no child or discovery execution."""
import hashlib
import json
from pathlib import Path

CLANG_ROOT = '/tmp/bendvy-clang19-diagnostic/root'
Z3_ROOT = '/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu'
RESOURCE_ROOTS = ('/home/node/.bend/bend2', CLANG_ROOT, Z3_ROOT)
TOOL_PATHS = {
    # Preserve the measured compiler when the installed alias is upgraded.
    'bend': '/home/node/.bend/bin/bend-2.0.35',
    'node': '/home/node/.local/share/mise/installs/node/24.20.0/bin/node',
    'taskset': '/usr/bin/taskset',
    'shell': '/bin/sh',
    'bash': '/bin/bash',
    'env': '/usr/bin/env',
    'clang': CLANG_ROOT + '/usr/lib/llvm-19/bin/clang',
    'clangWrapper': '/tmp/bendvy-clang19-diagnostic/clang19',
    'linker': '/usr/bin/ld',
    'ldd': '/usr/bin/ldd',
}
# Clang -### selected these inputs. The two scripts' explicit GROUP inputs are
# retained as well; this is reached input evidence, not a complete search closure.
LINK_INPUTS = (
    '/lib/aarch64-linux-gnu/Scrt1.o',
    '/lib/aarch64-linux-gnu/crti.o',
    '/lib/aarch64-linux-gnu/crtn.o',
    '/usr/lib/gcc/aarch64-linux-gnu/12/crtbeginS.o',
    '/usr/lib/gcc/aarch64-linux-gnu/12/crtendS.o',
    '/usr/lib/gcc/aarch64-linux-gnu/12/libgcc.a',
    '/usr/lib/gcc/aarch64-linux-gnu/12/libgcc_s.so',
    '/usr/lib/aarch64-linux-gnu/libgcc_s.so.1',
    '/usr/lib/aarch64-linux-gnu/libm.so',
    '/usr/lib/aarch64-linux-gnu/libpthread.a',
    '/usr/lib/aarch64-linux-gnu/libc.so',
    '/usr/lib/aarch64-linux-gnu/libc.so.6',
    '/usr/lib/aarch64-linux-gnu/libc_nonshared.a',
    '/lib/ld-linux-aarch64.so.1',
)
HEADER_SEARCH = (
    CLANG_ROOT + '/usr/lib/llvm-19/lib/clang/19/include',
    '/usr/local/include',
    '/usr/lib/gcc/aarch64-linux-gnu/12/../../../../aarch64-linux-gnu/include',
    '/usr/include/aarch64-linux-gnu', '/include', '/usr/include',
)
LINK_SEARCH = ('/usr/lib/gcc/aarch64-linux-gnu/12',
               '/lib/aarch64-linux-gnu', '/usr/lib/aarch64-linux-gnu',
               '/lib', '/usr/lib')


def environment():
    """The same explicit mapping must reach every compiler/runtime/probe role."""
    return {
        'HOME': '/home/node', 'PATH': '/usr/bin:/bin',
        'LANG': 'C', 'LC_ALL': 'C', 'TZ': 'UTC',
        'BEND_NO_TELEMETRY': '1', 'BENDVY_CLANG19_ROOT': CLANG_ROOT,
        'LD_LIBRARY_PATH': CLANG_ROOT + '/usr/lib/aarch64-linux-gnu:'
            + CLANG_ROOT + '/usr/lib/llvm-19/lib:' + Z3_ROOT,
    }


def file_binding(literal):
    path = Path(literal)
    resolved = path.resolve(strict=True)
    if not resolved.is_file():
        raise ValueError('expected an installed input file')
    return {'literal': str(path), 'resolved': str(resolved),
            'sha256': hashlib.sha256(resolved.read_bytes()).hexdigest()}


def candidate():
    """Preparation only: existing Inputs/resource guards consume these scopes.

    Do not substitute PinnedTools: the installed resolver inventory is unadmitted.
    Discovery/launch/final guards and semantic receipts remain the runner's job.
    """
    bindings = [file_binding(p) for p in dict.fromkeys(
        (*TOOL_PATHS.values(), *LINK_INPUTS,
         '/home/node/.local/share/mise/installs/node/24/bin/node'))]
    for root in RESOURCE_ROOTS:
        if not Path(root).is_dir():
            raise FileNotFoundError(root)
    env = environment()
    return {
        'status': 'PREPARED_CONFIGURATION_NOT_EXECUTION_ADMISSION',
        'environment': env,
        'environmentSha256': hashlib.sha256(json.dumps(env, sort_keys=True,
            separators=(',', ':'), ensure_ascii=True).encode()).hexdigest(),
        'tools': {name: str(Path(path).resolve(strict=True))
                  for name, path in TOOL_PATHS.items()},
        'discoveryTools': {name: str(Path(path).resolve(strict=True))
                           for name, path in TOOL_PATHS.items()
                           if name not in ('clangWrapper', 'ldd')},
        'toolAndReachedLinkBindings': bindings,
        'resourceRoots': list(RESOURCE_ROOTS),
        'inputFiles': sorted({value['resolved'] for value in bindings}),
        'toolVerification': 'ordinary full snapshot/verify; no PinnedTools adoption',
        'sourceGuardPreparation': 'Use existing task_runner.Inputs(files=inputFiles) '
            'and owned-tool-pins recursive resource_roots; no new guard implementation',
        'observedHeaderSearch': [{'literal': p, 'resolved': str(Path(p).resolve()),
                                  'present': Path(p).exists()} for p in HEADER_SEARCH],
        'observedLinkSearch': list(LINK_SEARCH),
        'readyScope': 'Explicit environment and exact installed/reached link file '
            'bindings for review; no discovery, header scan or backend run',
        'remaining': [
            'Freeze all source/oracle/raw/helper/current resource membership guards '
            'and ordinary full discovery before any actual child.',
            'Validate tool/input alias chains, wrapper identity and exact file bytes '
            'at actual launch and terminal boundaries.',
            'Generated C consumed headers, header search absence/membership, GCC '
            'version selection, linker search candidates/scripts and actual default '
            'linker script are not a closed compiler input scope.',
            'Generated Native ELF and runtime resolution are not yet available.',
            'This explicit environment changes no performance baseline; paired '
            'performance needs its own unchanged admitted contract.',
        ],
    }
