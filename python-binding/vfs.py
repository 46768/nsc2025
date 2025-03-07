import os


class VFSMgr:
    def __init__(self, data_path):
        self.data_path = data_path

    def write_vfs(self, vfs):
        vfs_path = os.path.join(self.data_path, vfs["name"])

        # BFS on the VFS to construct
        vfs_queue = ["/"]
        while len(vfs_queue):
            current_path = vfs_queue.pop(0)
            abs_path = os.path.join(vfs_path, current_path)
            block = vfs[current_path]
            if block["type"] == 0:  # Directory type
                vfs_queue.extend(block["content"].keys())
                os.mkdir(abs_path)
            elif block["type"] == 1:  # File type
                with open(abs_path, 'wb') as f:
                    f.write(block["content"])
                    f.close()
