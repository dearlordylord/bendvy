"""Failure-safe postguards and receipt finalization for new evidence cohorts."""
import json
from pathlib import Path


class GuardBoundary:
    """Run every postguard and preserve the primary exception, including cancellation."""
    def __init__(self, checks):
        self.checks = tuple(checks)
        self.failures = []

    def __enter__(self):
        return self

    def _check_all(self):
        self.failures = []
        for name, check in self.checks:
            try:
                check()
            except BaseException as error:
                self.failures.append((name, error))

    def __exit__(self, kind, primary, traceback):
        self._check_all()
        if primary is not None:
            for name, error in self.failures:
                primary.add_note(f'postguard {name}: {type(error).__name__}: {error}')
            return False
        if self.failures:
            first = self.failures[0][1]
            for name, error in self.failures[1:]:
                first.add_note(f'postguard {name}: {type(error).__name__}: {error}')
            raise first
        return False


class ReceiptBoundary(GuardBoundary):
    """Publish status only after postguards; retain an INCOMPLETE receipt on failure.

    The caller owns a JSON-serializable receipt, planned destination and named
    guards. Raw command logs stay outside this destination. A write failure is
    raised; it cannot be presented as a persisted receipt or successful cohort.
    """
    def __init__(self, receipt, path, checks):
        super().__init__(checks)
        self.receipt, self.path = receipt, Path(path)

    def __enter__(self):
        self.receipt['status'] = 'INCOMPLETE'
        return self

    def __exit__(self, kind, primary, traceback):
        self._check_all()
        if primary is not None or self.failures:
            self.receipt['status'] = 'INCOMPLETE'
            if primary is not None:
                self.receipt['error'] = f'{type(primary).__name__}: {primary}'
            self.receipt['guardFailures'] = [
                {'guard': name, 'error': f'{type(error).__name__}: {error}'}
                for name, error in self.failures
            ]
        if primary is None and self.failures:
            primary = self.failures[0][1]
        try:
            self.path.write_text(json.dumps(self.receipt, indent=2) + '\n')
        except BaseException as error:
            self.receipt['status'] = 'INCOMPLETE'
            if primary is not None:
                primary.add_note(f'receipt write: {type(error).__name__}: {error}')
            else:
                primary = error
        for name, error in self.failures:
            if primary is not None and error is not primary:
                primary.add_note(f'postguard {name}: {type(error).__name__}: {error}')
        if kind is not None:
            return False
        if primary is not None:
            raise primary
        if self.failures:
            raise self.failures[0][1]
        return False
