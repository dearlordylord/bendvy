"""Full closed-fixture oracle authored from public inputs before Bend execution.

The two systems are registered before the updater (ids 1, 2, 3). Each actual
check executes inside its own one-step schedule for external diagnostic output.
The driver clears only diagnostic text before Check.run; that entire preloaded
World, including every diagnostic field, must be retained by the actual check.
No output is read from a backend or used to construct this oracle.
"""
import json

SCHEMAS = ('Workshop', 'Garden')
PHASES = ('empty', 'one', 'committed-before-check')

def tree(values):
    if len(values) == 1:
        return 'L(' + values[0] + ')'
    middle = len(values) // 2
    return 'N(' + tree(values[:middle]) + ',' + tree(values[middle:]) + ')'

def cells(values):
    return '[' + ', '.join(map(str, values)) + ']'

def snapshot(phase, score):
    rows = '[]' if phase == 'empty' else '[1:1:[11, 11, 11, 14]]'
    return 'rows=' + rows + '|score=' + cells(score)

def world(schema, phase, present, diag_snapshot='', ran=0, checks=0):
    # Factory creation, actual reserve/activate, and ordinary component replace
    # fix all of these values. A component write advances the real clock once.
    seeded = phase != 'empty'
    live = 'N(L(false),L(true))' if seeded else 'L(false)'
    column = 'L(Some(' + tree(['11', '11', '11', '14']) + '))' if seeded else 'L(None)'
    stamps = '[1:1:1]' if seeded else '[]'
    score = [31, 31, 31, 34] if phase == 'committed-before-check' else [21, 21, 21, 24]
    resource = 'Present(' + tree(list(map(str, score))) + ')' if present else 'Absent'
    diagnostic = ('snapshot={' + diag_snapshot + '};before={};after={};same=false;allowed=false;ran='
                  + str(ran) + ';checks=' + str(checks))
    registrations = '[' + ', '.join([
        '3:' + schema + '/Update:[score:write]',
        '2:' + schema + '/Second:[diagnostic:write]',
        '1:' + schema + '/First:[diagnostic:write]',
    ]) + ']'
    return ('ns=1;next=' + ('2' if seeded else '1') + ';high=' + ('1' if seeded else '0')
            + ';live=' + live + ';capacity=' + ('2' if seeded else '1') + ';depth=' + ('1' if seeded else '0')
            + ';store=Column(' + column + ';stamps=' + stamps + ');resource=(score=' + resource
            + ';diagnostic=(' + diagnostic + '));events=[];pending=[];registrations=' + registrations
            + ';nextSystem=4;clock=' + ('1' if seeded else '0'))

def expected():
    lines = []
    for schema in SCHEMAS:
        lines.extend([schema, 'Absent'])
        for phase in PHASES:
            before = world(schema, phase, False)
            lines.extend([phase, 'before=' + before, 'after=' + before,
                          'result=MissingRuntimeRequirements:[' + schema + '/CheckScore]|ran=0|checks=0|observations=[]'])
        lines.append('Present')
        ran = checks = 0
        for phase in PHASES:
            lines.append(phase)
            score = [31, 31, 31, 34] if phase == 'committed-before-check' else [21, 21, 21, 24]
            observed = snapshot(phase, score)
            for system_id in (1, 2):
                checks += 1
                before = world(schema, phase, True, observed, ran, checks)
                ran += 1
                lines.extend(['observations=[Ran:' + str(system_id) + ']',
                              'snapshot=' + observed + '|allowed=true|same=true|ran=' + str(ran) + '|checks=' + str(checks),
                              'before=' + before, 'after=' + before])
    return '\n'.join(lines) + '\n'

EXPECTED = expected()
if __name__ == '__main__':
    print(json.dumps(EXPECTED))
