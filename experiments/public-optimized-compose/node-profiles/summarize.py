"""Summarize sampled call stacks; do not infer exact allocated bytes."""
import argparse
import json
from pathlib import Path
import re

parser = argparse.ArgumentParser()
parser.add_argument('directory', type=Path)
args = parser.parse_args()
directory = args.directory
def label(frame):
    name = re.sub(r'\$(\d{3})', lambda m: chr(int(m.group(1))), frame['functionName'])
    name = name.split('~')[0].rstrip('$')
    return name or '(anonymous at line ' + str(frame['lineNumber'] + 1) + ')'
def module(frame):
    name = label(frame)
    match = re.search(r'src/ecs/([^:]+):', name)
    if match:
        return 'ecs/' + match.group(1)
    if frame['functionName'] == '(garbage collector)':
        return 'GC'
    return 'other/runtime/observation'
def ranked(values):
    return [{'name': name, 'value': value} for name, value in sorted(values.items(), key=lambda x: -x[1])]
cpu = json.loads((directory / 'cpu.cpuprofile').read_text())
cpu_nodes = {n['id']: n for n in cpu['nodes']}
parents = {child: n['id'] for n in cpu['nodes'] for child in n.get('children', [])}
self_us, inclusive_us, module_us = {}, {}, {}
for node_id, duration in zip(cpu.get('samples', []), cpu.get('timeDeltas', [])):
    name = label(cpu_nodes[node_id]['callFrame'])
    self_us[name] = self_us.get(name, 0) + duration
    seen_names, seen_modules = set(), set()
    while node_id in cpu_nodes:
        frame = cpu_nodes[node_id]['callFrame']
        seen_names.add(label(frame))
        seen_modules.add(module(frame))
        node_id = parents.get(node_id)
    for key in seen_names:
        inclusive_us[key] = inclusive_us.get(key, 0) + duration
    for key in seen_modules:
        module_us[key] = module_us.get(key, 0) + duration
heap = json.loads((directory / 'heap.heapprofile').read_text())
heap_self, heap_inclusive, heap_modules = {}, {}, {}
# Maintain distinct ancestor names/modules, including recursive occurrences.
# This preserves attribution while avoiding repeated parsing of entire deep
# stacks for every node, and Python's recursion limit on sampled call trees.
active_names, active_modules = {}, {}
stack = [(heap['head'], False)]
while stack:
    node, leaving = stack.pop()
    name, group = label(node['callFrame']), module(node['callFrame'])
    if leaving:
        for counts, key in [(active_names, name), (active_modules, group)]:
            counts[key] -= 1
            if counts[key] == 0:
                del counts[key]
        continue
    active_names[name] = active_names.get(name, 0) + 1
    active_modules[group] = active_modules.get(group, 0) + 1
    size = node.get('selfSize', 0)
    heap_self[name] = heap_self.get(name, 0) + size
    for key in active_names:
        heap_inclusive[key] = heap_inclusive.get(key, 0) + size
    for key in active_modules:
        heap_modules[key] = heap_modules.get(key, 0) + size
    stack.append((node, True))
    stack.extend((child, False) for child in reversed(node.get('children', [])))
summary = {'scope': 'Exploratory sampled CPU microseconds and V8 sampled allocation attribution; inclusive rows overlap. Not exact allocation totals, causal proof or performance acceptance.',
           'cpuSamples': len(cpu.get('samples', [])), 'heapSamples': len(heap.get('samples', [])),
           'cpuSelfMicroseconds': ranked(self_us), 'cpuInclusiveMicroseconds': ranked(inclusive_us),
           'cpuModuleInclusiveMicroseconds': ranked(module_us),
           'heapSelfSampledBytes': ranked(heap_self), 'heapInclusiveSampledBytes': ranked(heap_inclusive),
           'heapModuleInclusiveSampledBytes': ranked(heap_modules)}
(directory / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps({k: summary[k][:10] for k in ['cpuModuleInclusiveMicroseconds', 'heapModuleInclusiveSampledBytes', 'heapSelfSampledBytes']}))
