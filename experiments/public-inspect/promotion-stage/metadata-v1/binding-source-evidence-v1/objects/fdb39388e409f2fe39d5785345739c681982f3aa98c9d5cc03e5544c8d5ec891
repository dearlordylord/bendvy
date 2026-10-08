"""Immutable raw command logs for new task runners; no process execution policy."""
from pathlib import Path
import hashlib


class CommandLogs:
    def __init__(self, directory, labels):
        self.directory = Path(directory)
        labels = tuple(labels)
        if len(set(labels)) != len(labels):
            raise ValueError('duplicate prospective command label')
        if any(not label or Path(label).name != label for label in labels):
            raise ValueError('command labels must be nonempty filenames')
        self.labels = frozenset(labels)
        self.hashes = {}
        self.guard()

    def guard(self):
        observed = {
            path.name: hashlib.sha256(path.read_bytes()).hexdigest()
            for suffix in ('*.stdout', '*.stderr')
            for path in self.directory.glob(suffix)
        }
        if observed != self.hashes:
            raise AssertionError('command log membership or bytes changed')

    def record(self, label, stdout, stderr):
        self.guard()
        if label not in self.labels:
            raise ValueError('command label was not planned')
        if not isinstance(stdout, bytes) or not isinstance(stderr, bytes):
            raise TypeError('record raw bytes; declare any merged capture separately')
        paths = [self.directory / (label + suffix) for suffix in ('.stdout', '.stderr')]
        if any(path.exists() for path in paths):
            raise AssertionError('command log already exists')
        for path, data in zip(paths, (stdout, stderr)):
            with path.open('xb') as stream:
                stream.write(data)
            self.hashes[path.name] = hashlib.sha256(data).hexdigest()
        self.guard()
        return dict(self.hashes)
