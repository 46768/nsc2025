import os
import subprocess
import vfs


class CodeExecutioner:
    def __init__(self, interpreter, data_path):
        self.interpreter = interpreter
        self.data_path = data_path

    def execute_vfs(self, vfs_json, entry_point):
        write_path = os.path.join(self.data_path, str(vfs_json["name"]))
        entry_point_path = os.path.join(write_path, entry_point)
        vfs.write_vfs(vfs_json, write_path)

        out = subprocess.check_output([self.interpreter, entry_point_path])

        return out
