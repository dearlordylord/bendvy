import Base
import ./execution-composer-layout.bend as L
import ./execution-query-schema.bend as Routes

type Permission is Data:
  Unused{}
  ReadOnly{}
  Writable{}
type Entry is Data:
  Entry{route:L.Route,key:String,permission:Permission}
type Book<-S:Data,-full:L.Layout> is Data:
  Book{entries:List<&2,Entry>}
def combine(left:Permission,right:Permission) -> Permission:
  match left right:
    case Writable{} _:Writable{}
    case _ Writable{}:Writable{}
    case ReadOnly{} _:ReadOnly{}
    case _ ReadOnly{}:ReadOnly{}
    case _ _:Unused{}
def at_entry(permission:Permission,next:Permission,selected:Bool) -> Permission:
  match selected:
    case True{}:combine(permission,next)
    case False{}:next
def at(+route:L.Route,entries:List<&2,Entry>) -> Permission:
  match entries:
    case []:Unused{}
    case Entry{selected,_,permission} <> rest:at_entry(permission,at(route,rest),Routes.same_route(route,selected))
def valid(~full:L.Layout,entries:List<&2,Entry>) -> Bool:
  match entries:
    case []:True{}
    case Entry{+route,key,_} <> rest:Bool.and(L.valid(full,route),Bool.and(String.eq(L.key(full,route),key),valid(~full,rest)))
def conflict(left:Permission,right:Permission) -> Bool:
  match left right:
    case Unused{} _:False{}
    case _ Unused{}:False{}
    case ReadOnly{} ReadOnly{}:False{}
    case _ _:True{}
def conflicts(+right:List<&2,Entry>,left:List<&2,Entry>) -> Bool:
  match left:
    case []:False{}
    case Entry{route,_,permission} <> rest:Bool.or(conflict(permission,at(route,right)),conflicts(right,rest))
def compatible(~full:L.Layout,+left:List<&2,Entry>,+right:List<&2,Entry>) -> Bool:
  Bool.and(L.unique(full),Bool.and(valid(~full,left),Bool.and(valid(~full,right),Bool.not(conflicts(right,left)))))
def same(left:Permission,right:Permission) -> Bool:
  match left right:
    case Unused{} Unused{}:True{}
    case ReadOnly{} ReadOnly{}:True{}
    case Writable{} Writable{}:True{}
    case _ _:False{}
def writes(permission:Permission) -> Bool:
  match permission:
    case Writable{}:True{}
    case _:False{}
def uses(permission:Permission) -> Bool:
  match permission:
    case Unused{}:False{}
    case _:True{}
