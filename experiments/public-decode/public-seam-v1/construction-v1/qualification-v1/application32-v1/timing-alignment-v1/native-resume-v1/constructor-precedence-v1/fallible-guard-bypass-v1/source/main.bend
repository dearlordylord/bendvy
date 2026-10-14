import Base
import ./fixture.bend as Input
import ./fallible-composition-v1/request-fixture.bend as Request
import ./ecs/decode-data.bend as D
import ./ecs/bundle-requests.bend as Commands
type Cases is Data:Cases{invalidCodec:Request.Report,acceptedCodec:Request.Report}
type Candidate is Data:Candidate{first:Cases,second:Cases}
def cases(~S:Data) -> Cases:Cases{Request.run(~S,~D.Integer{},Commands.Spawn{},D.Text{"wrong"}),Request.run(~S,~D.Integer{},Commands.Spawn{},D.Number{7})}
def main() -> Candidate:Candidate{cases(~Input.First),cases(~Input.Second)}
