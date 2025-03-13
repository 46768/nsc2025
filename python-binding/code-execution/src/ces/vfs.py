import os
import shutil
import logging

logger = logging.getLogger(__name__)


def vfs_path_join(vfs_path, vfs_rel_path):
    return os.path.join(vfs_path, vfs_rel_path.removeprefix('/'))


class VFSMgr:
    def __init__(self, data_path):
        self.data_path = data_path

    def write_vfs(self, vfs):
        vfs_path = os.path.join(self.data_path, vfs["name"])

        # Clean up previous vfs build
        if os.path.exists(vfs_path):
            logger.info("Deleting previous vfs cache")
            shutil.rmtree(vfs_path)

        # BFS on the VFS to construct
        vfs_queue = ["/"]
        while len(vfs_queue):
            current_path = vfs_queue.pop(0)
            abs_path = vfs_path_join(vfs_path, current_path)
            block = vfs[current_path]
            if block["type"] == 1:  # Directory type
                vfs_queue.extend(block["content"].keys())
                if not os.path.exists(abs_path):
                    logger.info("Creating directory: %s", abs_path)
                    os.mkdir(abs_path)
            elif block["type"] == 0:  # File type
                logger.info("Writing to file: %s", abs_path)
                with open(abs_path, 'wb') as f:
                    f.write(bytes(block["content"], "ascii"))
                    f.close()

        return vfs_path
