"""Strict reached-control observations, not numerical performance decisions."""
import json
JS_ORDER = ['clock','main','late','teardown','clock','clock','printer','bytes','clock','out1','bytes','out2']
C_ORDERS = {'positive':'clock,task,main,late,teardown,clock,printer,clock,', 'hoisted':'task,main,late,teardown,clock,clock,printer,clock,', 'included':'clock,task,main,late,teardown,printer,clock,clock,'}
def validate(control, stdout, stderr):
    if control == 'JS':
        value = json.loads(stdout)
        if stderr or value != {'status':'CONTROL_PASS','positive':JS_ORDER,'refused':['hoisted-main','included-printer'],'stdout':'Complete{17}\n'}: raise ValueError('whole JS reached sequence mismatch')
        return
    if stdout != b'Complete{17}\n': raise ValueError('complete control stdout mismatch')
    lines = stderr.decode().splitlines()
    # Negative control deliberately adds a leading newline before its witness.
    if control != 'positive':
        if len(lines) != 3 or lines[1] != '': raise ValueError('negative witness framing')
        lines.pop(1)
    if len(lines) != 2: raise ValueError('whole Native reached sequence mismatch')
    metric = json.loads(lines[0])
    if set(metric) != {'simulationNs','transportNs'} or any(type(v) is not str or not v.isdecimal() for v in metric.values()): raise ValueError('timer metric type')
    label = 'CONTROL_PASS:' if control == 'positive' else 'CONTROL_REFUSED:'
    if lines[1] != label + C_ORDERS[control]: raise ValueError('whole Native reached witness mismatch')
