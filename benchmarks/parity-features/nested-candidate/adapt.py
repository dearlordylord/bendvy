"""Draft staged actual spawn/allocator/barrier instrumentation; not yet accepted."""

def resources_field(text):
    # Exact authored constructor uses balanced braces; preserve every old field.
    output=[];position=0;count=0
    while True:
        start=text.find('Resources{',position)
        if start<0:output.append(text[position:]);break
        end=start+len('Resources{');depth=1
        while depth:
            if text[end]=='{':depth+=1
            elif text[end]=='}':depth-=1
            end+=1
        body=text[start+len('Resources{'):end-1]
        line=text[text.rfind('\n',0,start)+1:text.find('\n',start)]
        if 'resource:Slot' in body:extra='reservedIds:List<&2,U32>'
        elif 'slot(' in body:extra='[]'
        else:
            case=line.find('case ');colon=line.find(':',case) if case>=0 else -1
            in_pattern=case>=0 and (start-text.rfind('\n',0,start)-1)<colon
            extra='+reservedIds' if in_pattern else 'reservedIds'
        output.append(text[position:start]+ 'Resources{'+body+','+extra+'}')
        position=end;count+=1
    assert count==26,('Resources seam drift',count)
    return ''.join(output)

HELPERS='''def measured_populate(world:W.World<Schema,Store,Resources,U32>,handle:W.Handle<Schema>,payload:Unit) -> W.World<Schema,Store,Resources,U32>:
  world
def measured_record(world:W.World<Schema,Store,Resources,U32>,+id:U32) -> W.World<Schema,Store,Resources,U32>:
  match world:
    case W.World{+ns,+next,+high,live,+cap,+depth,store,Resources{resource,host,+writes,+calls,+conditions,retired,+trace,+reservedIds},+events,pending,+registrations,+nextSystem,+clock}: W.World{ns,next,high,live,cap,depth,store,Resources{resource,host,writes,calls,conditions,retired,trace,List.append(&2,U32,reservedIds,[id])},events,pending,registrations,nextSystem,clock}
def measured_finished(result:T.Returned<W.World<Schema,Store,Resources,U32>,Unit>) -> W.World<Schema,Store,Resources,U32>:
  match result:
    case T.Returned{world,_}: world
def measured_reserved(result:T.Tx<W.World<Schema,Store,Resources,U32>,U32> & W.Reservation<Schema>) -> W.World<Schema,Store,Resources,U32>:
  match result:
    case (T.Tx{world,undo,commands,events},W.Reserved{W.Handle{_,+id}}): measured_finished(Cmd.tx_finish(~Schema,~Store,~Resources,~U32,~Unit,T.Tx{measured_record(world,id),undo,commands,events},T.Success{}))
    case (tx,W.ReservationRejected{_}): measured_finished(Cmd.tx_finish(~Schema,~Store,~Resources,~U32,~Unit,tx,T.Success{}))
def measured_spawn(world:W.World<Schema,Store,Resources,U32>) -> W.World<Schema,Store,Resources,U32>:
  measured_reserved(Cmd.tx_spawn(~Schema,~Store,~Resources,~U32,~Unit,~measured_populate,T.begin(~W.World<Schema,Store,Resources,U32>,~U32,world),Unit{}))
'''

def adapt(text):
    text=resources_field(text)
    text=text.replace('import ../../src/ecs/world.bend as W','import ../../src/ecs/world.bend as W\nimport ../../src/ecs/commands.bend as Cmd\nimport ../../src/ecs/transaction.bend as T')
    point='def complete_side_effects('
    assert text.count(point)==1;text=text.replace(point,HELPERS+point)
    # complete_side_effects used to discard Resources, so retain instrumentation.
    old='live,+cap,+depth,store,_,+events,pending,+registrations,+nextSystem,+clock}, (resource,writes)'
    assert text.count(old)==1
    text=text.replace(old,'live,+cap,+depth,store,Resources{_,_,_,_,_,_,_,+reservedIds},+events,pending,+registrations,+nextSystem,+clock}, (resource,writes)')
    old='W.enqueue(~Schema,~Store,~Resources,~U32,W.event_publish('
    assert text.count(old)==1;text=text.replace(old,'measured_spawn(W.event_publish(')
    assert text.count(',[id]),w => w)')==1;text=text.replace(',[id]),w => w)',',[id]))')
    return text

METADATA='''def measured_handle(handle:W.Handle<Schema>) -> String:
  match handle:
    case W.Handle{_,id}: U32.show(id)
def measured_probe_finished(result:T.Returned<W.World<Schema,Store,Resources,U32>,Unit>,+id:U32) -> W.World<Schema,Store,Resources,U32> & U32:
  match result:
    case T.Returned{world,_}: (world,id)
def measured_probe_reserved(result:T.Tx<W.World<Schema,Store,Resources,U32>,U32> & W.Reservation<Schema>) -> W.World<Schema,Store,Resources,U32> & U32:
  match result:
    case (tx,W.Reserved{W.Handle{_,+id}}): measured_probe_finished(Cmd.tx_finish(~Schema,~Store,~Resources,~U32,~Unit,tx,T.Success{}),id)
    case (tx,W.ReservationRejected{_}): measured_probe_finished(Cmd.tx_finish(~Schema,~Store,~Resources,~U32,~Unit,tx,T.Success{}),0)
def measured_probe(world:W.World<Schema,Store,Resources,U32>) -> W.World<Schema,Store,Resources,U32> & U32:
  measured_probe_reserved(Cmd.tx_spawn(~Schema,~Store,~Resources,~U32,~Unit,~measured_populate,T.begin(~W.World<Schema,Store,Resources,U32>,~U32,world),Unit{}))
def measured_after(observed:W.World<Schema,Store,Resources,U32> & List<&2,W.Handle<Schema>>,+text:String,+id:U32) -> W.World<Schema,Store,Resources,U32> & String:
  (world,+handles)=observed
  (world,text ++ ";probeId=" ++ U32.show(id) ++ ";afterLive=" ++ List.show(&2,W.Handle<Schema>,measured_handle,handles))
def measured_probed(probed:W.World<Schema,Store,Resources,U32> & U32,+text:String) -> W.World<Schema,Store,Resources,U32> & String:
  (world,+id)=probed
  measured_after(W.handles(~Schema,~Store,~Resources,~U32,W.barrier(~Schema,~Store,~Resources,~U32,world)),text,id)
def measured_before(observed:W.World<Schema,Store,Resources,U32> & List<&2,W.Handle<Schema>>,+text:String) -> W.World<Schema,Store,Resources,U32> & String:
  match observed:
    case (W.World{+ns,+next,+high,live,+cap,+depth,store,Resources{resource,host,+writes,+calls,+conditions,retired,+trace,+reservedIds},+events,pending,+registrations,+nextSystem,+clock},+handles): measured_probed(measured_probe(W.World{ns,next,high,live,cap,depth,store,Resources{resource,host,writes,calls,conditions,retired,trace,reservedIds},events,pending,registrations,nextSystem,clock}),text ++ ";reserved=" ++ List.show(&2,U32,U32.show,reservedIds) ++ ";beforeLive=" ++ List.show(&2,W.Handle<Schema>,measured_handle,handles) ++ ";published=" ++ List.show(&2,U32,U32.show,events))
def measured_observe(observed:W.World<Schema,Store,Resources,U32> & String) -> W.World<Schema,Store,Resources,U32> & String:
  (world,text)=observed
  measured_before(W.handles(~Schema,~Store,~Resources,~U32,world),text)
def world_snapshot(world:W.World<Schema,Store,Resources,U32>) -> W.World<Schema,Store,Resources,U32> & String:
  measured_observe(measured_original_snapshot(world))
'''

def instrument(text):
    text=adapt(text)
    seam='def world_snapshot(world:'
    assert text.count(seam)==1;text=text.replace(seam,'def measured_original_snapshot(world:')
    point='def repaired_slot('
    assert text.count(point)==1;text=text.replace(point,METADATA+point)
    return text

def ts(source):
    from workloads import replace_once
    source=replace_once(source,'queue=0,component=', 'queue=0,reserved=[],component=')
    source=replace_once(source,'commands.spawn(G.Command.spawn());queue++;','reserved.push(commands.spawn(G.Command.spawn()).value);queue++;')
    point=" const q=G.Query({selection:{cells:G.Query.write(Cells)}});"
    observer=''' const alive=G.Inspector('live',{queries:{all:G.Query({selection:{}})}},({queries})=>queries.all.each().map(({entity})=>entity.id.value));
 const actualEvents=G.Inspector('published',{events:{stream:G.System.readEvent(Event)}},({events})=>[...events.stream.all()]);
 let probeId=0;
 const probe=G.System('allocator-probe',{},({commands})=>{probeId=commands.spawn(G.Command.spawn()).value;});
 function observe(record){
  const beforeLive=rt.inspect(alive);
  const published=rt.inspect(actualEvents);
  assert.equal(rt.tick(G.Schedule(probe,G.Schedule.applyDeferred())).ok,true);
  const afterLive=rt.inspect(alive);
  return Object.assign(record,{reserved:[...reserved],beforeLive,published,probeId,afterLive});
 }
'''
    source=replace_once(source,point,observer+point)
    source=replace_once(source,"output.push({mode,status:'invalid',cw,rw,host,conditions,events,queue,trace,component,resource});return;","output.push(observe({mode,status:'invalid',cw,rw,host,conditions,events,queue,trace,component,resource}));return;")
    source=replace_once(source,'output.push(structuredClone(record));','output.push(structuredClone(observe(record)));')
    source=replace_once(source,'output.push(retry);','output.push(observe(retry));')
    return source
