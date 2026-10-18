"""First Motion64 LC1 oracle from the independent actual-state operation model."""
import sys
from codec import encode_report
from records import report


if __name__ == '__main__':
    sys.stdout.buffer.write(encode_report(report(64, 64)))
