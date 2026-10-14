"""One exact reached host-effect mutation of a guarded production artifact."""
from pathlib import Path
import hashlib, os, stat, sys
source, expected, target = sys.argv[1:]
source, target = Path(source), Path(target)
if source.is_symlink() or not source.is_file():
    raise ValueError("regular source required")
raw = source.read_bytes()
if hashlib.sha256(raw).hexdigest() != expected:
    raise ValueError("qualified artifact changed")
anchor = b"return state.next++;"
if raw.count(anchor) != 1:
    raise ValueError("one exact production allocator anchor required")
changed = raw.replace(anchor, b"return 1;", 1)
fd = os.open(target, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
with os.fdopen(fd, "wb") as stream:
    if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode):
        raise ValueError("regular target required")
    stream.write(changed)
