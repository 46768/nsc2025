import subprocess
import json
import packet
import vfs
import logging

logger = logging.getLogger(__name__)


def handle_vfs_execution_pkt(pkt, interpreter, vfs_mgr):
    pkt_content = json.loads(str(pkt["content"]))
    vfs_json = json.loads(str(pkt_content["vfs"]))
    entry_point_file = str(pkt_content["entryPoint"])

    logger.info("""
Code execution data:
    vfs data: %s
    entry point: %s""", vfs_json, entry_point_file)

    vfs_path = vfs_mgr.write_vfs(vfs_json)
    entry_point_path = vfs.vfs_path_join(vfs_path, entry_point_file)

    result = execute_python_src(interpreter, entry_point_path)

    return packet.build_packet("ces:ret", json.dumps({
            "stdout": result[0],
            "stderr": result[1],
        }))


def execute_python_src(interpreter, entry_point):
    logger.info("""
Python execution info:
    interpreter: %s
    entry point: %s""", interpreter, entry_point)
    result = subprocess.run(
            [interpreter, entry_point],
            capture_output=True,
            text=True
    )

    return (result.stdout, result.stderr)
