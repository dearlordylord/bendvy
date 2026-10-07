"""Independent full public requirements/per-system check observation oracle."""
def expected():
    observations = []
    for schema in ['Workshop', 'Garden']:
        for present in [False, True]:
            for index, label in enumerate(['empty', 'one', 'committed-before-check']):
                rows = [] if index == 0 else [{'id': 1, 'cells': [11, 11, 11, 14]}]
                score = [31, 31, 31, 34] if index == 2 else [21, 21, 21, 24]
                if present:
                    result = {'ok': True}
                    callbacks = [{'rows': rows, 'score': score}, {'rows': rows, 'score': score}]
                    ran = (index + 1) * 2
                else:
                    result = {'ok': False, 'error': {'kind': 'MissingRuntimeRequirements', 'requirements': [{'kind': 'resource', 'name': schema + '/CheckScore'}]}}
                    callbacks, ran = [], 0
                observations.append({'schema': schema, 'present': present, 'label': label,
                                     'result': result, 'callbacks': callbacks, 'ran': ran})
    return {'format': 1, 'application': 'InspectorPlainCheck', 'observations': observations}

if __name__ == '__main__':
    import json
    print(json.dumps(expected()))
