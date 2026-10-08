"""Independent accepted-cleanup component-clock defect oracle; no runtime inputs."""
import copy

def expected(normal, scenario):
    result = copy.deepcopy(normal)
    for scene in result.values():
        for world, rows in scene['worlds'].items():
            for row in rows:
                label = row['label']
                delta = 0
                if scenario == 'post-consumption':
                    if world == 'A' and label in ('A-owned-cleanup', 'B-survivor-empty'):
                        delta = 1
                    if world == 'B' and label == 'B-owned-cleanup':
                        delta = 1
                elif scenario == 'failed-batch':
                    if world == 'A' and label in ('first-owned-cleanup', 'same-world-survivor-read'):
                        delta = 1
                    if world == 'A' and label == 'survivor-owned-cleanup':
                        delta = 2
                else:
                    raise ValueError(scenario)
                if delta:
                    row['fields']['componentClock'] = str(int(row['fields']['componentClock']) + delta)
    return result
