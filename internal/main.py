from aip_site import cli

import sys

if __name__ == '__main__':
    if sys.argv[1] == "serve":
        cli.serve([sys.argv[2]])
    elif sys.argv[1] == "publish":
        cli.publish([sys.argv[2], sys.argv[3]])
