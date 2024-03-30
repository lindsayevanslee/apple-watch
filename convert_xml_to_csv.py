#taken from: https://gist.github.com/hoffa/936db2bb85e134709cd263dd358ca309

import json
import sys
from xml.etree.ElementTree import iterparse

for _, elem in iterparse(sys.argv[1]):
    if elem.tag == "Record":
        print(json.dumps(elem.attrib))