"""Additive public-result projection of the accepted independent operation model."""
import copy
from pathlib import Path
import sys

SOURCE = Path(__file__).resolve().parents[3] / 'model'
sys.path.insert(0, str(SOURCE))
import common_model as C


class Observer(C.Observer):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.public_boundaries = []
        self.public_schedules = []
        self.public_calls = []

    def append_boundary(self, phase_name):
        super().append_boundary(phase_name)
        original = self.boundary_records[-1]
        self.public_boundaries.append({
            'kind': 'PublicBoundary',
            **{k: copy.deepcopy(original[k]) for k in
               ['iteration', 'phase', 'rows', 'pendingA', 'latestFailed', 'retryB', 'allFailed']}})

    def schedule(self, phase, steps, req, obs, failed=False):
        # Match the independent operation's typed alternatives; never parse a rendered Doc.
        system_ids = {0: [self.b_id, self.pub_id], 1: [self.a_id, self.b_id],
                      2: [self.pub_id], 3: [self.b_id], 4: [self.pub_id],
                      5: [], 6: [self.dispose_id]}[phase]
        barrier = phase in [5, 6]
        expected_steps = [f'System{{{i};0}}' for i in system_ids] + (['Barrier'] if barrier else [])
        expected_obs = [f'Ran{{{i}}}' for i in system_ids] + (['Applied'] if barrier else [])
        service = phase in [0, 1, 3]
        assert steps == expected_steps and obs == expected_obs
        assert req == (['Service{1}'] if service else [])
        assert failed == (phase == 1)
        self.public_schedules.append({
            'kind': 'Schedule', 'namespace': self.world.ns,
            'name': f'FailedTxn/phase{phase}',
            'steps': [{'kind': 'System', 'id': i, 'condition': 0} for i in system_ids]
                     + ([{'kind': 'Barrier'}] if barrier else []),
            'requirements': [{'kind': 'Service', 'id': 1}] if service else [],
            'failed': failed,
            'observations': [{'kind': 'Ran', 'id': i} for i in system_ids]
                            + ([{'kind': 'Applied'}] if barrier else [])})
        super().schedule(phase, steps, req, obs, failed)

    def do_dispose(self):
        statuses = []
        for key in [self.frame.pending_a, self.frame.retry_b]:
            assert key is not None
            index, generation = key
            allocator = self.world.allocator
            # Handles come from this world's actual reservation map. command_valid
            # accepts matching-generation Live or Pending, before deferred application.
            assert key in self.raw_actor_keys
            valid = (index < len(allocator.slots)
                     and allocator.slots[index].gen == generation
                     and allocator.slots[index].phase in ['Live', 'Pending'])
            statuses.append({'kind': 'Accepted'} if valid else
                            {'kind': 'Rejected', 'error': {'kind': 'MissingEntity'}})
        # Original model's phase6 application requires both accepted handles. The
        # supplied Success branch enqueues these commands; no finish-time validator
        # can change that outcome (transaction.finish_world). Barrier applies later.
        assert all(s['kind'] == 'Accepted' for s in statuses)
        self.public_calls.append({'kind': 'DisposePublic', 'iteration': self.frame.iteration,
                                  'statuses': statuses, 'outcome': {'kind': 'Success'}})
        super().do_dispose()

    def bend_public(self):
        return {'boundaries': self.public_boundaries,
                'schedules': self.public_schedules, 'calls': self.public_calls}


def ts_public(records):
    callbacks, publications, boundaries = [], [], []
    for record in records:
        kind = record['kind']
        if kind == 'Callback' and record['who'] == 'B':
            callbacks.append({'kind': 'CallbackPublic', 'who': 'B',
                              'iteration': record['iteration'],
                              'firstLagged': record['reading']['lagged'],
                              'writeReadbacks': [copy.deepcopy(w['value']) for w in record['writes']]})
        elif kind == 'Publications':
            publications.append({'kind': 'PublicationsPublic', 'iteration': record['iteration'],
                                 'mode': record['mode'], 'messages': copy.deepcopy(record['messages']),
                                 'lagged': record['lagged']})
        elif kind == 'Boundary':
            rows = {row['actor']: row for row in record['rows']}
            lookups = []
            for key in ['pendingA', 'latestFailed', 'retryB']:
                lookup = record[key]
                if lookup is None:
                    continue
                actor = lookup['actor']
                if actor in rows:
                    result = {'kind': 'Found', 'row': copy.deepcopy(rows[actor])}
                else:
                    # This query requires Main and optional Aux/Flag. Every live
                    # actor has Main; absent actors are therefore MissingEntity,
                    # not QueryMismatch. Keep that public error tag losslessly.
                    assert lookup['result']['kind'] == 'Missing'
                    result = {'kind': 'MissingEntity'}
                lookups.append({'actor': actor, 'result': result})
            boundaries.append({'kind': 'PublicBoundary', 'iteration': record['iteration'],
                               'phase': record['phase'], 'rows': copy.deepcopy(record['rows']),
                               'ledgers': [copy.deepcopy(record['ledger']) for _ in range(3)],
                               'lookups': lookups, 'allFailed': copy.deepcopy(record['allFailed'])})
    assert (len(callbacks), len(publications), len(boundaries)) == (129, 129, 256)
    return {'callbacks': callbacks, 'publications': publications, 'boundaries': boundaries}
