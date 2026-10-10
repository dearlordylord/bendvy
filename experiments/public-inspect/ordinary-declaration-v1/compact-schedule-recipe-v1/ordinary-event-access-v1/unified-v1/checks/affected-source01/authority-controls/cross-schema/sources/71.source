import Base
type OtherSchema is Data:
  OtherSchema{}
type ReadRequest is Data:
  ReadRequest{reader: String,fail: Bool}
type Observation is Data:
  Observation{reader: String,values: List<&2,U32>,lagged: Bool}
type Error is Data:
  ReadFailed{observation: Observation}
  PublishFailed{}
type PublishRequest is Data:
  PublishRequest{value: U32,count: U32,second: Maybe<&2,U32>,fail: Bool}
