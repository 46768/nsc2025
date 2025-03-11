"""
Handles code executions
"""
import subprocess
import json
import packet
import vfs
import logging

logger = logging.getLogger(__name__)


def check_vfs_safety(vfs, ast_checker):
    have_err = False
    err_dict = {}

    for file_name, file_data in vfs.items():
        # Type 0 is file type
        if file_name.endswith(".py") and file_data["type"] == 0:
            logger.info("Checking file: %s", file_name)
            (ast_have_err, ast_res) = ast_checker.check_source(
                    file_data["content"])
            have_err = have_err or ast_have_err
            if ast_have_err:
                err_dict[file_name] = ast_res

    return (have_err, err_dict)


def handle_vfs_execution_pkt(pkt, interpreter, vfs_mgr, ast_checker):
    pkt_content = json.loads(pkt["content"])
    vfs_json = json.loads(pkt_content["vfs"])
    entry_point_file = pkt_content["entryPoint"]

    logger.info("""
Code execution data:
    vfs data: %s
    entry point: %s""", vfs_json, entry_point_file)

    (ast_failure, ast_result) = check_vfs_safety(vfs_json, ast_checker)
    if ast_failure:
        return packet.build_packet(
                "ces:ret:ast:fail",
                json.dumps(ast_result))

    vfs_path = vfs_mgr.write_vfs(vfs_json)
    entry_point_path = vfs.vfs_path_join(vfs_path, entry_point_file)

    result = execute_python_src(interpreter, entry_point_path)

    return packet.build_packet(
            "ces:ret:ok",
            {
                "stdout": result[0],
                "stderr": result[1],
            })


def execute_python_src(interpreter, entry_point):
    logger.info("""
Python execution info:
    interpreter: %s
    entry point: %s""", interpreter, entry_point)
    result = subprocess.run(
            [interpreter, entry_point],
            capture_output=True,
            text=True)

    return (result.stdout, result.stderr)
