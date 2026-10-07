import {Schema,Descriptor as D} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
for(const root of ['Workshop','Other']) {
 const Position=D.Component()('Position'),Velocity=D.Component()('Velocity'),Score=D.Resource()('Score'),Tick=D.Event()('Tick'),Logger=D.Service()('Logger');const loggerCells=[0,99];let target;let retainedEvents=[];const outputs=[];
 const left=Schema.fragment({components:{Position}}),right=Schema.fragment({components:{Velocity},resources:{Score},events:{Tick}});
 const G=Schema.bind(left,right,Schema.defineRoot(root));const rt=G.Runtime.make({services:G.Runtime.services(G.Runtime.service(Logger,{cells:loggerCells,log(){loggerCells[0]++;}})),resources:{Score:0}});
 const tick=(...systems)=>{let result=rt.tick(G.Schedule(...systems));if(!result.ok)throw Error(JSON.stringify(result));};
 const seed=G.System('seed',{},({commands})=>{target=commands.spawn(G.Command.spawn([Position,{cells:[10,11]}],[Velocity,{cells:[2,3]}]));});
 const q=G.Query({selection:{a:G.Query.write(Position),b:G.Query.write(Velocity)}});
 const work=G.System('compose',{queries:{q},resources:{score:G.System.writeResource(Score)},events:{tick:G.System.writeEvent(Tick)},services:{logger:G.System.service(Logger)}},({queries,resources,events,services,commands})=>{for(const {data}of queries.q.each()){const a=data.a.get(),b=data.b.get();data.a.set({cells:[a.cells[0]+b.cells[0],a.cells[1]]});data.b.set({cells:[b.cells[0]+1,b.cells[1]]});}resources.score.set(1);events.tick.emit(9);services.logger.log();commands.insert(target,[Position,{cells:[13,11]}]);});
 const observe=G.System('observe',{queries:{q},resources:{score:G.System.readResource(Score)},events:{tick:G.System.readEvent(Tick)}},({queries,resources,events})=>{const row=queries.q.each()[0];if(!row)return;const {data}=row;const current=events.tick.all();if(current.length)retainedEvents=current;outputs.push(data.a.get().cells.join(',')+',:'+data.b.get().cells.join(',')+',:'+resources.score.get()+':'+retainedEvents.join(',')+',:'+(outputs.length===0?1:0)+':log='+loggerCells.join(','));});tick(observe);tick(seed);tick(G.Schedule.applyDeferred());tick(work);tick(observe);tick(G.Schedule.applyDeferred());tick(observe);console.log(outputs.join('|'));
}
// Actual invalid authoring refuses before initialization or any service call.
for(const root of ['Workshop','Other']){
 let calls=0;const Position=D.Component()('Position'),OtherPosition=D.Component()('Position');
 try{Schema.bind(Schema.fragment({components:{Position}}),Schema.fragment({components:{OtherPosition}}),Schema.defineRoot(root));calls++;throw Error('collision accepted');}
 catch(e){if(!e.message.startsWith('Duplicate descriptor name:'))throw e;}
 if(calls!==0)throw Error('collision effect');console.log('rejected:10,11,:2,3,:log=0,99');
}
