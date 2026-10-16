import Base
import ./state.bend as State
import ./consumer.bend as Consumer

# Each logical schema String is retained completely. IO.print adds one final newline.
def framed(name:String,value:String & String) -> String:
  match value:
    case (workshop,garden):name ++ "\nWorkshop\n" ++ workshop ++ "Garden\n" ++ garden
def required_out() -> String & String:
  (Consumer.scenario(~State.Workshop,~Consumer.link_required_out(~State.Workshop),~Consumer.parent_required_out(~State.Workshop),2n,"link_required_out","parent_required_out",31,100),Consumer.scenario(~State.Garden,~Consumer.link_required_out(~State.Garden),~Consumer.parent_required_out(~State.Garden),2n,"link_required_out","parent_required_out",47,200))
def optional_out() -> String & String:
  (Consumer.scenario(~State.Workshop,~Consumer.link_optional_out(~State.Workshop),~Consumer.parent_optional_out(~State.Workshop),3n,"link_optional_out","parent_optional_out",31,100),Consumer.scenario(~State.Garden,~Consumer.link_optional_out(~State.Garden),~Consumer.parent_optional_out(~State.Garden),3n,"link_optional_out","parent_optional_out",47,200))
def present_out() -> String & String:
  (Consumer.scenario(~State.Workshop,~Consumer.link_present_out(~State.Workshop),~Consumer.parent_present_out(~State.Workshop),2n,"link_present_out","parent_present_out",31,100),Consumer.scenario(~State.Garden,~Consumer.link_present_out(~State.Garden),~Consumer.parent_present_out(~State.Garden),2n,"link_present_out","parent_present_out",47,200))
def absent_out() -> String & String:
  (Consumer.scenario(~State.Workshop,~Consumer.link_absent_out(~State.Workshop),~Consumer.parent_absent_out(~State.Workshop),1n,"link_absent_out","parent_absent_out",31,100),Consumer.scenario(~State.Garden,~Consumer.link_absent_out(~State.Garden),~Consumer.parent_absent_out(~State.Garden),1n,"link_absent_out","parent_absent_out",47,200))
def required_in() -> String & String:
  (Consumer.scenario(~State.Workshop,~Consumer.link_required_in(~State.Workshop),~Consumer.parent_required_in(~State.Workshop),1n,"link_required_in","parent_required_in",31,100),Consumer.scenario(~State.Garden,~Consumer.link_required_in(~State.Garden),~Consumer.parent_required_in(~State.Garden),1n,"link_required_in","parent_required_in",47,200))
def optional_in() -> String & String:
  (Consumer.scenario(~State.Workshop,~Consumer.link_optional_in(~State.Workshop),~Consumer.parent_optional_in(~State.Workshop),3n,"link_optional_in","parent_optional_in",31,100),Consumer.scenario(~State.Garden,~Consumer.link_optional_in(~State.Garden),~Consumer.parent_optional_in(~State.Garden),3n,"link_optional_in","parent_optional_in",47,200))
def present_in() -> String & String:
  (Consumer.scenario(~State.Workshop,~Consumer.link_present_in(~State.Workshop),~Consumer.parent_present_in(~State.Workshop),1n,"link_present_in","parent_present_in",31,100),Consumer.scenario(~State.Garden,~Consumer.link_present_in(~State.Garden),~Consumer.parent_present_in(~State.Garden),1n,"link_present_in","parent_present_in",47,200))
def absent_in() -> String & String:
  (Consumer.scenario(~State.Workshop,~Consumer.link_absent_in(~State.Workshop),~Consumer.parent_absent_in(~State.Workshop),2n,"link_absent_in","parent_absent_in",31,100),Consumer.scenario(~State.Garden,~Consumer.link_absent_in(~State.Garden),~Consumer.parent_absent_in(~State.Garden),2n,"link_absent_in","parent_absent_in",47,200))
def main() -> IO(Unit):IO.print(framed("required_out",required_out()) ++ framed("optional_out",optional_out()) ++ framed("present_out",present_out()) ++ framed("absent_out",absent_out()) ++ framed("required_in",required_in()) ++ framed("optional_in",optional_in()) ++ framed("present_in",present_in()) ++ framed("absent_in",absent_in()))
