import Base
import ./alpha/consumer.bend as A
import ./beta/consumer.bend as B
def main() -> Maybe<&2,A.Report> & Maybe<&2,B.Report>:(A.run(),B.run())
