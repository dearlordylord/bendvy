import Base
import ../generic-assembly-v1/public-fixture.bend as Public
import ../generic-assembly-v1/first-public-fixture.bend as FirstPublic
import ../generic-assembly-v1/recovery-fixture.bend as Recovery

type Case is Data:Success{} Failure{} NoMatch{} Skip{}
type RecoveryCase is Data:RInterleaved{} REqualPosition{} RPending{} RSuccess{} RReserveRefused{} RInstallRefused{} RActivationRefused{}
type Item is Data:Second{label:Case,value:Public.Report} First{label:Case,value:FirstPublic.Report} Recovered{label:RecoveryCase,value:Recovery.Report}
def done_14(previous:List<&2,Item>,value:Item) -> List<&2,Item>:List.reverse(&2,Item,value <> previous)
def step_14(previous:List<&2,Item>) -> List<&2,Item>:done_14(previous,Recovered{RActivationRefused{},Recovery.run(Recovery.ActivationRefused{})})
def done_13(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_14(value <> previous)
def step_13(previous:List<&2,Item>) -> List<&2,Item>:done_13(previous,Recovered{RInstallRefused{},Recovery.run(Recovery.InstallRefused{})})
def done_12(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_13(value <> previous)
def step_12(previous:List<&2,Item>) -> List<&2,Item>:done_12(previous,Recovered{RReserveRefused{},Recovery.run(Recovery.ReserveRefused{})})
def done_11(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_12(value <> previous)
def step_11(previous:List<&2,Item>) -> List<&2,Item>:done_11(previous,Recovered{RSuccess{},Recovery.run(Recovery.Success{})})
def done_10(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_11(value <> previous)
def step_10(previous:List<&2,Item>) -> List<&2,Item>:done_10(previous,Recovered{RPending{},Recovery.run(Recovery.PendingControl{})})
def done_9(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_10(value <> previous)
def step_9(previous:List<&2,Item>) -> List<&2,Item>:done_9(previous,Recovered{REqualPosition{},Recovery.run(Recovery.EqualPosition{})})
def done_8(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_9(value <> previous)
def step_8(previous:List<&2,Item>) -> List<&2,Item>:done_8(previous,Recovered{RInterleaved{},Recovery.run(Recovery.Interleaved{})})
def done_7(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_8(value <> previous)
def step_7(previous:List<&2,Item>) -> List<&2,Item>:done_7(previous,First{Skip{},FirstPublic.run_skip()})
def done_6(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_7(value <> previous)
def step_6(previous:List<&2,Item>) -> List<&2,Item>:done_6(previous,First{NoMatch{},FirstPublic.run(False{},False{})})
def done_5(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_6(value <> previous)
def step_5(previous:List<&2,Item>) -> List<&2,Item>:done_5(previous,First{Failure{},FirstPublic.run(True{},True{})})
def done_4(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_5(value <> previous)
def step_4(previous:List<&2,Item>) -> List<&2,Item>:done_4(previous,First{Success{},FirstPublic.run(False{},True{})})
def done_3(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_4(value <> previous)
def step_3(previous:List<&2,Item>) -> List<&2,Item>:done_3(previous,Second{Skip{},Public.run_skip()})
def done_2(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_3(value <> previous)
def step_2(previous:List<&2,Item>) -> List<&2,Item>:done_2(previous,Second{NoMatch{},Public.run(False{},False{})})
def done_1(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_2(value <> previous)
def step_1(previous:List<&2,Item>) -> List<&2,Item>:done_1(previous,Second{Failure{},Public.run(True{},True{})})
def done_0(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_1(value <> previous)
def step_0(previous:List<&2,Item>) -> List<&2,Item>:done_0(previous,Second{Success{},Public.run(False{},True{})})
def main() -> List<&2,Item>:step_0([])
