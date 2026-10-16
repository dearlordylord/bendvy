import Base
import ./payload.bend as P
import ./system.bend as Sys
import ./scenario.bend as S
import ../../../src/ecs/world.bend as W
def tree(value:P.Tree) -> String:
  match value:
    case P.Leaf{x}:U32.show(x)
    case P.Node{a,b}:"(" ++ tree(a) ++ "," ++ tree(b) ++ ")"
def pack(value:P.Observation) -> String:
  match value:
    case P.Observation{a,b}:"{" ++ tree(a) ++ ";" ++ tree(b) ++ "}"
def live(value:S.Live) -> String:
  match value:
    case S.Leaf{x}:Bool.show(x)
    case S.Node{a,b}:"(" ++ live(a) ++ "," ++ live(b) ++ ")"
def text(value:String) -> String:
  value
def unit(value:Unit) -> String:
  "Unit"
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(~&2,~String,~text,access)
def owner(value:S.OwnerView) -> String:
  match value:
    case S.OwnerView{ns,id,name,access,capture}:U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(~&2,~String,~text,access) ++ ":" ++ pack(capture)
def world(value:S.WorldView) -> String:
  match value:
    case S.WorldView{ns,next,high,alive,cap,depth,resource,events,pending,regs,sid,clock}:"W{" ++ U32.show(ns) ++ "," ++ U32.show(next) ++ "," ++ U32.show(high) ++ "," ++ live(alive) ++ "," ++ U32.show(cap) ++ "," ++ Nat.show(depth) ++ "," ++ U32.show(resource) ++ "," ++ List.show(~&2,~Unit,~unit,events) ++ "," ++ U32.show(pending) ++ "," ++ List.show(~&2,~W.RegistrationMeta,~registration,regs) ++ "," ++ U32.show(sid) ++ "," ++ U32.show(clock) ++ "}"
def status(value:S.Status) -> String:
  match value:
    case S.Registered{}:"registered"
    case S.Success{}:"success"
    case S.Failure{Sys.Failed{}}:"failure:Failed"
    case S.Skipped{}:"skipped"
    case S.Refused{Sys.Args{delta,fail}}:"refused:" ++ U32.show(delta) ++ ":" ++ Bool.show(fail)
    case S.Removed{capture,id,valid}:"removed:" ++ pack(capture) ++ ":" ++ U32.show(id) ++ ":" ++ Bool.show(valid)
    case S.Broken{location}:"BROKEN:" ++ location
def snapshot(value:S.Snapshot) -> String:
  match value:
    case S.Snapshot{label,result,w,f,a,b}:label ++ "|" ++ status(result) ++ "|" ++ world(w) ++ "|" ++ world(f) ++ "|" ++ owner(a) ++ "|" ++ owner(b) ++ "\n"
def trace(values:List<&2,S.Snapshot>) -> String:
  match values:
    case []:""
    case row <> rest:snapshot(row) ++ trace(rest)
