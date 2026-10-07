import Base
def invalid() -> String: "\u{D800}"
def main() -> IO(Unit): IO.print(invalid())
