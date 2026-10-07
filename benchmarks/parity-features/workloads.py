"""Exact staged application adaptations, separate from current authored controls."""
import pathlib
FEATURES = {
    'nested': {'directory': 'public-nested-provision', 'entry': 'main.bend'},
    'readers': {'directory': 'public-schedule-readers', 'entry': 'driver.bend'},
    'fragments': {'directory': 'public-schema-fragments', 'entry': 'main.bend'},
}

def replace_once(text, old, new):
    assert text.count(old) == 1, ('adaptation seam drift', old)
    return text.replace(old, new)

def adapt_nested(text):
    # Common TS work rejects missing resources but has no resource-only repair.
    # Keep original supplemental repair implementation, selecting refusal-only
    # when any missing Resource is observed. Service-only retries are unchanged.
    point = 'def provision_result('
    helpers = '''def measured_resource_missing(items:List<&2,P.Requirement<Schema>>) -> Bool:
  match items:
    case []: False{}
    case P.Resource{_} <> _: True{}
    case _ <> rest: measured_resource_missing(rest)
def measured_refusal_only(schedule:Sch.Schedule<Schema,Store,Resources,U32,Owners> & String,world:W.World<Schema,Store,Resources,U32> & String,+requirements:List<&2,P.Requirement<Schema>>,+missing:List<&2,P.Requirement<Schema>>) -> String:
  (_,ownertext)=schedule
  (_,text)=world
  "missing:" ++ needs(missing) ++ ":needs=" ++ needs(requirements) ++ "|owners=" ++ ownertext ++ "|" ++ text
def measured_refusal(schedule:Sch.Schedule<Schema,Store,Resources,U32,Owners> & String,world:W.World<Schema,Store,Resources,U32> & String,+requirements:List<&2,P.Requirement<Schema>>,+missing:List<&2,P.Requirement<Schema>>,resourceMissing:Bool) -> String:
  match resourceMissing:
    case True{}: measured_refusal_only(schedule,world,requirements,missing)
    case False{}: refusal_observed(schedule,world,requirements,missing)
'''
    assert text.count(point) == 1
    text = text.replace(point, helpers + point)
    return replace_once(text,
        'case P.Missing{P.Provisioned{schedule,needs},world,missing}: refusal_observed(schedule_snapshot(schedule),world_snapshot(world),needs,missing)',
        'case P.Missing{P.Provisioned{schedule,needs},world,+missing}: measured_refusal(schedule_snapshot(schedule),world_snapshot(world),needs,missing,measured_resource_missing(missing))')

def nested_ts(source):
    source = source[:source.index("for(const mode of ['positive'")]
    source = replace_once(source, ' output.push(record);', ''' output.push(structuredClone(record));
 if(mode==='service-missing'||mode==='condition-missing'){
  supplied.Host=()=>{host++;};
  const retried=rt.tryTick(plan);
  const retry={mode:mode+'-retry',status:retried.ok?'ok':'missing',requirements,flattened,cw,rw,host,conditions,events:[...events],queue,trace:[...trace],component:rt.inspect(cellsInspector)[0],resource:rt.inspect(resourceInspector)};
  if(!retried.ok)retry.missing=retried.error.requirements;
  output.push(retry);
 }
''')
    return source + "\nfor(const mode of ['positive','resource-missing','service-missing','duplicate','condition-missing','empty','both-missing'])scenario(mode);\nconsole.log(JSON.stringify(output));\n"

def bend_entry(feature, batches):
    imports = 'import Base\nimport ./timing.bend as Bench\n'
    if feature == 'nested':
        imports += 'import ../experiments/public-nested-provision/app.bend as A\nimport ../experiments/public-nested-provision/other.bend as B\n'
        selected = [0, 1, 3, 7, 8, 9, 11]
        body = '\\n'.join('case'+str(i)+'|'+'" ++ X.scenario('+str(i)+') ++ "' for i in selected)
        # Each nominal schema retains the authored complete observations.
        a = ('"schema-A\\n' + body + '"').replace('X.scenario', 'A.scenario')
        b = ('"schema-B\\n' + body + '"').replace('X.scenario', 'B.scenario')
        call = f'IO.bind(Unit,Unit,Bench.capture({a}),u => Bench.capture({b}))'
    elif feature == 'fragments':
        imports += 'import ../experiments/public-schema-fragments/application.bend as A\ntype Workshop is Data:\n  Workshop{}\ntype Other is Data:\n  Other{}\n'
        call = 'Bench.capture(A.run(~Workshop) ++ "\\n" ++ A.run(~Other) ++ "\\n" ++ A.invalid(~Workshop) ++ "\\n" ++ A.invalid(~Other))'
    else:
        imports += 'import ../experiments/public-schedule-readers/driver.bend as A\nimport ../experiments/public-schedule-readers/added-controls.bend as B\n'
        call = 'IO.bind(Unit,Unit,A.main(),u => B.main())'
    return imports + f'''def repeat(fuel:Nat) -> IO(Unit):
  match fuel:
    case 0n: Bench.end()
    case 1n+rest: IO.bind(Unit,Unit,{call},u => repeat(rest))
def main() -> IO(Unit):
  IO.bind(Unit,Unit,Bench.begin(),u => repeat({batches}n))
'''


def callable_ts(source):
    # Move original application statements, unmodified and in authored order,
    # into a fresh callable lifecycle; static pinned API imports stay outside.
    import re
    imports = []
    body = []
    for line in source.splitlines():
        if re.match(r"^import .+ from .+;$", line):
            imports.append(line)
        else:
            body.append(line)
    assert imports, 'No reference imports found'
    return '\n'.join(imports) + '\nexport function run(){\n' + '\n'.join(body) + '\n}\n'
