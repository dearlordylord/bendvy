#!/usr/bin/env python3
"""Launch one packet through the canonical accepted engine, never directly."""
import argparse,json,pathlib,subprocess,datetime,os
import boundary,guard,snapshot,packet
ENV={'HOME':'/home/node','PATH':'/home/node/.bend/bin:/usr/local/bin:/usr/bin:/bin','LANG':'C.UTF-8','LC_ALL':'C.UTF-8'}

def accepted_plan(report,contract_digest,evaluator_identity):
    plan=report.get('decisionPlan',{})
    if plan.get('kind')!='decision-plan' or plan.get('contractDigest')!=contract_digest or not contract_digest or plan.get('evaluatorIdentity')!=evaluator_identity or not evaluator_identity:
        raise ValueError('canonical accepted contract/evaluator identity differs')
    if plan.get('capabilities',{}).get('run-packet')!='allowed' or plan.get('loopDisposition',{}).get('canRunPacket') is not True:
        raise ValueError('canonical state does not authorize a packet')
    return plan

def main():
    global ENV
    a=argparse.ArgumentParser();a.add_argument('--manifest',type=pathlib.Path,required=True);a.add_argument('--sha256',required=True);a.add_argument('--cwd',type=pathlib.Path,required=True);a.add_argument('--contract-digest',required=True);a.add_argument('--evaluator-identity',required=True);a.add_argument('--inspect-only',action='store_true');x=a.parse_args()
    if guard.sha(x.manifest)!=x.sha256:raise ValueError('reviewed manifest digest changed')
    declared=json.loads(x.manifest.read_text());allow=snapshot.editable(declared)
    m=boundary.verify(x.manifest,x.sha256,allow=allow);ENV=m['executionEnvironment'];packet.ENV=ENV;cli=pathlib.Path(m['canonicalCLI']);tools=m['tools']
    # This read is meaningful only after user acceptance/setup/new-segment.
    guard.deadline(30)
    text=packet.child([tools['node'],cli,'state','--cwd',x.cwd,'--report'],30,[])
    report=json.loads(text);plan=accepted_plan(report,x.contract_digest,x.evaluator_identity)
    if x.inspect_only:print(json.dumps({'status':'CANONICAL_ACCEPTED_LAUNCH_PREFLIGHT','contractDigest':plan['contractDigest'],'evaluatorIdentity':plan['evaluatorIdentity']}));return
    boundary.verify(x.manifest,x.sha256,allow=allow);guard.deadline(5)
    # next owns canonical packet execution/digest/budget enforcement; there are
    # no evaluator/check/command/env overrides and no alternate direct launch.
    command=[tools['node'],cli,'next','--cwd',x.cwd,'--compact']
    guard.enable_subreaper();prior=guard.child_pids(os.getpid())
    remaining=(guard.DEADLINE-datetime.datetime.now(datetime.timezone.utc)).total_seconds()-5
    if remaining<=0:raise ValueError('no global execution/cleanup allowance')
    process=subprocess.Popen(command,env=ENV,start_new_session=True)
    try:
        code=process.wait(timeout=remaining)
        if guard.child_pids(os.getpid())-prior:
            guard.cleanup_owned(process.pid,prior);raise ValueError('canonical runner left owned descendants')
        raise SystemExit(code)
    except subprocess.TimeoutExpired:
        try:guard.cleanup_owned(process.pid,prior)
        finally:
            try:process.wait(timeout=1)
            except subprocess.TimeoutExpired:pass
        raise ValueError('global canonical-launch deadline')

if __name__=='__main__':main()
