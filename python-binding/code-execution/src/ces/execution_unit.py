"""Handles code executions
"""

import subprocess
import json
from ces.networking import packet
from ces.vfs_manager import VFSMgr, vfs_path_join
from ces.ast_checker import ASTChecker
import logging

logger = logging.getLogger(__name__)


class ExecutionUnit:
    """Execution unit to handle running python code safely

    Args:
        blacklist_fpath (str): Path to the yaml file containing list of
                dangerous code for ASTChecker
        vfs_dpath (str): Path to the directory for writing VFS to
        interpreter (str): Path to the python interpreter to use for running
                code

    Attributes:
        ast_checker (ASTChecker): AST checker for scanning VFSs
        vfs_mgr (VFSMgr): Virtual filesystem manager for managing VFS
                on the disk
        interpreter (str): Path to the python interpreter to run python code
    """

    def __init__(self, blacklist_fpath, vfs_dpath, interpreter):
        self.ast_checker = ASTChecker(blacklist_fpath)
        self.vfs_mgr = VFSMgr(vfs_dpath)
        self.interpreter = interpreter

    def scan_vfs(self, vfs_json):
        """Scans a VFS for dangerous code

        Scans a VFS with ASTChecker to find dangerous code
        and block writing file to disk if there's one

        Args:
            vfs_json (dict): Dictionary containing data of the
                    virtual filesystem to scan

        Returns:
            tuple: A tuple containing if the vfs contains dangerous
            code in the first element, and dictionary of files-error pairs
            in the second element
        """

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
        """Runs a python script on the disk

        Args:
            path (str): Absolute path to the python script to run

        Returns:
            tuple: A tuple with standard output as string in the
            first element and standard error as string in the
            second element
        """

        result = subprocess.run(
                [self.interpreter, path],
                capture_output=True,
                text=True)

        return (result.stdout, result.stderr)

    def handle_packet(self, pkt):
        """Handles incomming packets requesting code execution

        Args:
            pkt (Packet): Request packet containing the VFS and
                    the entry point (path is relative to the VFS)
                    as `vfs` and `entryPoint`

        Returns:
            Pakcet: If the scan failed, returns a 403
            packet containing the scan result, otherwise
            returns a 200 packet containing standard output
            and error as `stdout` and `stderr`
        """

        pkt_content = json.loads(pkt["content"])
        vfs_json = pkt_content["vfs"]
        entry_point = pkt_content["entryPoint"]

        (have_err, scan_res) = self.scan_vfs(vfs_json)
        if have_err:
            scan_res["ast_failed"] = True
            return packet.build_packet("/execution", "ast:fail", 403, scan_res)

        vfs_path = self.vfs_mgr.write_vfs(vfs_json)
        entry_path = vfs_path_join(vfs_path, entry_point)

        result = self.execute_script(entry_path)

        return packet.build_packet("/execution", "ces:ret:ok", 200, {
                "stdout": result[0],
                "stderr": result[1]})
