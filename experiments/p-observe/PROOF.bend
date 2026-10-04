import Base
import ./LAWS.bend as L
import ../p-observe-lookup/LAWS.bend as K
import ../p-observe-lookup/PROOF.bend as P
import ../p-observe-queries/LAWS.bend as Q
import ../p-observe-queries/PROOF.bend as QueryProof
import ../p-observe-flush/LAWS.bend as F
import ../p-observe-flush/PROOF.bend as FlushProof

import ../p-observe-schedule/LAWS.bend as N
import ../p-observe-schedule/PROOF.bend as ScheduleProof
import ../p-approved-owned-schedule/LAWS.bend as W
import ../p-approved-owned-schedule/PROOF.bend as OwnedProof

def L.lookup_full_exact(world,handle,selection):
  K.lookup_full_exact(world,handle,selection)

def L.query_any_complete_ordered(limit,world):
  Q.query_any_complete_ordered(limit,world)

def L.query_present_complete_ordered(limit,world):
  Q.query_present_complete_ordered(limit,world)

def L.query_absent_complete_ordered(limit,world):
  Q.query_absent_complete_ordered(limit,world)

def L.explicit_flush_independent(limit,world):
  F.explicit_flush_independent(limit,world)

def L.schedule_execution_exact(limit,world,steps):
  N.schedule_execution_exact(limit,world,steps)

def L.owned_runtime_schedule_correspondence(limit,world,steps):
  W.owned_runtime_schedule_correspondence(limit,world,steps)
