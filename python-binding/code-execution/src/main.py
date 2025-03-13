from ces.networking import network_interface as ces_net
from ces.networking.reverse_proxy import ReverseProxy
from ces.execution_unit import ExecutionUnit

import sys
import os
import logging


if len(sys.argv) != 5:
    fname = sys.argv[0]
    print(
        f"{fname}: Invalid usage: "
        + f"python3 {fname} port python-intepreter-path data-path "
        + "ast-blacklist-path")
    exit(1)

port = sys.argv[1]
interpreter_path = sys.argv[2]
data_path = sys.argv[3]
blacklist_fpath = sys.argv[4]

logging.basicConfig(
        filename=os.path.join(data_path, "server.log"),
        filemode='w',
        format="[%(levelname)s]"
        + "{%(asctime)s}"
        + "(%(name)s:%(filename)s:%(funcName)s:%(lineno)s): "
        + "%(message)s",
        encoding="ascii",
        level=logging.INFO)

vfs_dpath = os.path.join(data_path, "vfs_cache")
if not os.path.exists(vfs_dpath):
    os.mkdir(vfs_dpath)

rproxy = ReverseProxy()
execution_unit = ExecutionUnit(blacklist_fpath, vfs_dpath, interpreter_path)

rproxy.add_service("/execution")
rproxy.set_method("/execution", "request", execution_unit.handle_packet)

ces_net.start_server(port, rproxy)
