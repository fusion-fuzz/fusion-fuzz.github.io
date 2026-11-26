import configparser
parser = configparser.RawConfigParser()
parser.add_section('section1')
item = parser.popitem()
try:
    parser.popitem()
except KeyError:
    pass
else:
    raise AssertionError('Expected KeyError when popping from empty RawConfigParser')
fusion = item
from typing import get_args, Union, Tuple, List, Dict, Optional
def test_get_args_with_union():
    args = get_args(Union[int, fusion, float])
if __name__ == '__main__':
    test_get_args_with_union()
