import Base
import ./alpha/consumer.bend as Alpha
import ./beta/consumer.bend as Beta
def main() -> Maybe<&2,Alpha.Report> & Maybe<&2,Beta.Report>:(Alpha.run(),Beta.run())
