import Base
import ../notice-positive-core.bend as Core

def duplicate(+reader:Core.Reader(~Core.First)) -> Core.Reader(~Core.First) & Core.Reader(~Core.First):(reader,reader)
