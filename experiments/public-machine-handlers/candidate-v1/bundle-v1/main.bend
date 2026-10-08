import Base
import types.bend as T
import application.bend as App
import observe.bend as O
import bundle.bend as B
import ../../../../src/ecs/world.bend as W

type Case is Data:
  Case{name:String,current:T.State,target:T.State,skip:Bool,extra:Bool,failure:U32,steps:U32,read:Bool,readBetween:Bool,restore:Bool,foreign:Bool}
def cases() -> List<&2,Case>:
  [Case{"boot_Play_queued",T.Boot{},T.Play{},False{},True{},0,0,False{},False{},False{},False{}},
   Case{"boot_Play_applied",T.Boot{},T.Play{},False{},True{},0,1,True{},False{},False{},False{}},
   Case{"boot_Pause_queued",T.Boot{},T.Pause{},False{},True{},0,0,False{},False{},False{},False{}},
   Case{"boot_Pause_applied",T.Boot{},T.Pause{},False{},True{},0,1,True{},False{},False{},False{}},
   Case{"self_queued_next",T.Boot{},T.Play{},False{},True{},0,2,True{},True{},False{},False{}},
   Case{"same_Boot_false",T.Boot{},T.Boot{},False{},True{},0,1,True{},False{},False{},False{}},
   Case{"same_Boot_true",T.Boot{},T.Boot{},True{},True{},0,1,True{},False{},False{},False{}},
   Case{"same_Play_false",T.Play{},T.Play{},False{},True{},0,1,True{},False{},False{},False{}},
   Case{"same_Play_true",T.Play{},T.Play{},True{},True{},0,1,True{},False{},False{},False{}},
   Case{"failed_exitBoot0",T.Boot{},T.Play{},False{},True{},2,1,False{},False{},False{},False{}},
   Case{"later_exitBoot0",T.Boot{},T.Play{},False{},True{},2,2,True{},False{},False{},False{}},
   Case{"failed_exitBoot1",T.Boot{},T.Play{},False{},True{},5,1,False{},False{},False{},False{}},
   Case{"later_exitBoot1",T.Boot{},T.Play{},False{},True{},5,2,True{},False{},False{},False{}},
   Case{"failed_transitionBootPlay",T.Boot{},T.Play{},False{},True{},6,1,False{},False{},False{},False{}},
   Case{"later_transitionBootPlay",T.Boot{},T.Play{},False{},True{},6,2,True{},False{},False{},False{}},
   Case{"failed_enterPlay1",T.Boot{},T.Play{},False{},True{},1,1,False{},False{},False{},False{}},
   Case{"later_enterPlay1",T.Boot{},T.Play{},False{},True{},1,2,True{},False{},False{},False{}},
   Case{"failed_enterPlay0",T.Boot{},T.Play{},False{},True{},4,1,False{},False{},False{},False{}},
   Case{"later_enterPlay0",T.Boot{},T.Play{},False{},True{},4,2,True{},False{},False{},False{}},
   Case{"missing_queued",T.Boot{},T.Play{},False{},False{},0,0,False{},False{},False{},False{}},
   Case{"inactive_missing",T.Boot{},T.Play{},False{},False{},0,1,False{},False{},False{},False{}},
   Case{"inactive_restored",T.Boot{},T.Play{},False{},False{},0,2,True{},False{},True{},False{}},
   Case{"foreign_refused",T.Boot{},T.Boot{},True{},True{},0,0,False{},False{},False{},True{}},
   Case{"foreign_legitimate_retry",T.Boot{},T.Boot{},True{},True{},0,1,True{},False{},False{},True{}}]

def maybe_read(~S:Data,app:App.Application<S>,yes:Bool) -> App.Application<S>:
  match yes:
    case False{}: app
    case True{}: App.read(~S,app)
def maybe_supply(~S:Data,app:App.Application<S>,yes:Bool) -> App.Application<S>:
  match yes:
    case False{}: app
    case True{}: App.supply(~S,app,True{})
def second_step(~S:Data,steps:U32,app:App.Application<S>,read:Bool,restore:Bool) -> App.Application<S>:
  match steps:
    case 2: maybe_read(~S,App.marker(~S,maybe_supply(~S,app,restore)),read)
    case _: maybe_read(~S,app,read)
def normal_run(~S:Data,steps:U32,app:App.Application<S>,read:Bool,between:Bool,restore:Bool) -> App.Application<S>:
  match steps:
    case 0: app
    case steps: second_step(~S,steps,maybe_read(~S,App.marker(~S,app),between),read,restore)
def render(~S:Data,pair:App.Application<S> & String) -> String:
  (_,text)=pair
  text
def prepared(~S:Data,app:App.Application<S>,current:T.State,target:T.State,skip:Bool,extra:Bool,failure:U32) -> App.Application<S>:
  App.queue(~S,App.failing(~S,App.supply(~S,App.initialized(~S,App.install_reader(~S,app),current),extra),failure),target,skip)
def foreign_text(~S:Data,source:App.Application<S> & String,target:App.Application<S> & String,result:String) -> String:
  match source target:
    case (_,sourceText), (_,targetText): "{\"source\":" ++ sourceText ++ ",\"target\":" ++ targetText ++ ",\"result\":" ++ O.quote(result) ++ "}"
def foreign_observed(~S:Data,result:App.ForeignResult<S>,steps:U32) -> String:
  match result steps:
    case App.ForeignRetained{source,target,B.ForeignBundle{}}, 1: foreign_text(~S,O.observe(~S,App.read(~S,App.marker(~S,source))),O.observe(~S,target),"ok")
    case App.ForeignRetained{source,target,B.ForeignBundle{}}, _: foreign_text(~S,O.observe(~S,source),O.observe(~S,target),"foreign")
    case _, _: "{\"error\":\"UnexpectedForeignOutcome\"}"
def target_created(~S:Data,source:App.Application<S>,steps:U32,result:App.Construction<S>) -> String:
  match result:
    case App.Constructed{_,target}: foreign_observed(~S,App.foreign(~S,source,App.install_reader(~S,target)),steps)
    case _: "{\"error\":\"TargetConstructionRefused\"}"
def choose_run(~S:Data,foreign:Bool,factory:W.Factory,app:App.Application<S>,steps:U32,read:Bool,between:Bool,restore:Bool) -> String:
  match foreign:
    case False{}: render(~S,O.observe(~S,normal_run(~S,steps,app,read,between,restore)))
    case True{}: target_created(~S,app,steps,App.create(~S,factory))
def created(~S:Data,descriptor:Case,result:App.Construction<S>) -> String:
  match descriptor result:
    case Case{_,current,target,skip,extra,failure,steps,read,between,restore,foreign}, App.Constructed{factory,app}:
      choose_run(~S,foreign,factory,prepared(~S,app,current,target,skip,extra,failure),steps,read,between,restore)
    case _, _: "{\"error\":\"ConstructionRefused\"}"
def created_after_a(~S:Data,descriptor:Case,result:App.Construction<T.SchemaA>) -> String:
  match result:
    case App.Constructed{factory,_}: created(~S,descriptor,App.create(~S,factory))
    case _: "{\"error\":\"PrefixConstructionRefused\"}"
def observation(~S:Data,offset:U32,descriptor:Case) -> String:
  match offset:
    case 0: created(~S,descriptor,App.create(~S,W.factory()))
    case _: created_after_a(~S,descriptor,App.create(~T.SchemaA,W.factory()))
def named(~S:Data,+offset:U32,+descriptor:Case) -> String:
  match descriptor:
    case Case{+name,current,target,skip,extra,failure,steps,read,between,restore,foreign}:
      "{\"name\":" ++ O.quote(name) ++ ",\"value\":" ++ observation(~S,offset,Case{name,current,target,skip,extra,failure,steps,read,between,restore,foreign}) ++ "}"
def rows(~S:Data,items:List<&2,Case>,+offset:U32) -> List<&2,String>:
  match items:
    case []: []
    case descriptor <> rest: named(~S,offset,descriptor) <> rows(~S,rest,offset)
def A_rows() -> String:
  List.show(&2,String,s => s,rows(~T.SchemaA,cases(),0))
def B_rows() -> String:
  List.show(&2,String,s => s,rows(~T.SchemaB,cases(),1))
