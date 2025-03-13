"""
Handles code executions
"""
import subprocess
import json
from ces.networking import packet
from ces.vfs import VFSMgr, vfs_path_join
from ces.ast_checker import ASTChecker
import logging

logger = logging.getLogger(__name__)


class ExecutionUnit:
    def __init__(self, blacklist_fpath, vfs_dpath, interpreter):
        self.ast_checker = ASTChecker(blacklist_fpath)
        self.vfs_mgr = VFSMgr(vfs_dpath)
        self.interpreter = interpreter

    def scan_vfs(self, vfs_json):
        have_err = False
        err_dict = {}

        for file_name, file_data in vfs_json.items():
            if file_name == "name":
                continue
            # Type 0 is file type
            if file_name.endswith(".py") and file_data["type"] == 0:
                logger.info("Checking file: %s", file_name)
                (ast_have_err, ast_res) = self.ast_checker.check_source(
                        file_data["content"])
                have_err = have_err or ast_have_err
                if ast_have_err:
                    err_dict[file_name] = ast_res

        return (have_err, err_dict)

    def execute_script(self, path):
        result = subprocess.run(
                [self.interpreter, path],
                capture_output=True,
                text=True)

        return (result.stdout, result.stderr)

    def handle_packet(self, pkt):
        pkt_content = json.loads(pkt["content"])
        vfs_json = pkt_content["vfs"]
        entry_point = pkt_content["entryPoint"]

        (have_err, scan_res) = self.scan_vfs(vfs_json)
        if have_err:
            return packet.build_packet("/execution", "ast:fail", 403, scan_res)

        vfs_path = self.vfs_mgr.write_vfs(vfs_json)
        entry_path = vfs_path_join(vfs_path, entry_point)

        result = self.execute_script(entry_path)

        return packet.build_packet("/execution", "ces:ret:ok", 200, {
                "stdout": result[0],
                "stderr": result[1]})
