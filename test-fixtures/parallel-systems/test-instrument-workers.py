import hashlib
import importlib.util
from pathlib import Path
import unittest


spec = importlib.util.spec_from_file_location(
    'instrument_workers', Path(__file__).with_name('instrument-workers.py')
)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

SOURCE = '''static u32             pool_size;
  WL_CASE(FID_BODY)
  {
    body();
  }
  WL_CASE(FID_SPLIT)
  {
    if (serial) {
      serial_body();
    } else {
      if (!seq) {
        native_body();
      }
    }
  }
  WL_CASE(FID_OBSERVER)
  {
    observe();
  }
static void* pool_work(void* arg) {
  work(arg);
}
int main() {
  io_sync();
  return 0;
}
'''


def plan(source=SOURCE):
    return {
        'workerLimit': 64,
        'sourceSha256': hashlib.sha256(source.encode()).hexdigest(),
        'groups': [{'name': 'body', 'cases': ['FID_BODY']}],
        'forks': [{'case': 'FID_SPLIT', 'anchor': '    } else {\n      if (!seq) {'}],
    }


class InstrumentationBoundary(unittest.TestCase):
    def test_marks_only_selected_semantic_case_and_native_fork(self):
        result = module.instrument(SOURCE, plan())
        self.assertEqual(result.count('    bendvy_diag_hit(0);'), 1)
        self.assertIn('WL_CASE(FID_BODY)\n  {\n    bendvy_diag_hit(0);', result)
        self.assertIn('WL_CASE(FID_OBSERVER)\n  {\n    observe();', result)
        self.assertIn('bendvy_diag_worker = (u32)(uintptr_t)arg;', result)
        self.assertIn('BENDVY_WORKERS body=%llx/%llu forks=%llu', result)

    def test_worker_mask_refuses_unrepresentable_limit(self):
        wrong = plan()
        wrong['workerLimit'] = 65
        with self.assertRaisesRegex(ValueError, '64-bit'):
            module.instrument(SOURCE, wrong)

    def test_changed_generated_source_refuses_instrumentation(self):
        with self.assertRaisesRegex(ValueError, 'source digest'):
            module.instrument(SOURCE + '\n', plan())

    def test_duplicate_semantic_case_refuses_instrumentation(self):
        duplicated = SOURCE + '\n  WL_CASE(FID_BODY)\n  {\n  }\n'
        with self.assertRaisesRegex(ValueError, 'expected one anchor'):
            module.instrument(duplicated, plan(duplicated))

    def test_fork_anchor_cannot_match_another_segment(self):
        wrong = plan()
        wrong['forks'][0]['case'] = 'FID_OBSERVER'
        with self.assertRaisesRegex(ValueError, 'expected one anchor'):
            module.instrument(SOURCE, wrong)

    def test_semantic_case_cannot_count_for_two_groups(self):
        wrong = plan()
        wrong['groups'].append({'name': 'another', 'cases': ['FID_BODY']})
        with self.assertRaisesRegex(ValueError, 'exactly one group'):
            module.instrument(SOURCE, wrong)


if __name__ == '__main__':
    unittest.main()
