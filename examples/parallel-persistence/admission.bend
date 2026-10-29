import Base
import ./declarations.bend as Ordinary
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-restore-admission.bend as Restore

# Actual retained nominal schemas admit incoming detached snapshots. Admission
# does not claim constructors, publication, or resumed execution have occurred.
def alpha(input:Saved.Snapshot<Ordinary.Alpha>) -> Plan.Schema<Ordinary.Alpha,Ordinary.components(~Ordinary.Alpha),Ordinary.resources(~Ordinary.Alpha)> & (Saved.Snapshot<Ordinary.Alpha> & Restore.Admission):
  Restore.prepare(~Ordinary.Alpha,~Ordinary.components(~Ordinary.Alpha),~Ordinary.resources(~Ordinary.Alpha),Ordinary.schema(~Ordinary.Alpha),input)
def beta(input:Saved.Snapshot<Ordinary.Beta>) -> Plan.Schema<Ordinary.Beta,Ordinary.components(~Ordinary.Beta),Ordinary.resources(~Ordinary.Beta)> & (Saved.Snapshot<Ordinary.Beta> & Restore.Admission):
  Restore.prepare(~Ordinary.Beta,~Ordinary.components(~Ordinary.Beta),~Ordinary.resources(~Ordinary.Beta),Ordinary.schema(~Ordinary.Beta),input)
