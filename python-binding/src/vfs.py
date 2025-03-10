"""
Virtual file system manager for converting vfs jsons into files on the disk
"""
import os
import shutil
import logging

logger = logging.getLogger(__name__)


def vfs_path_join(vfs_path, vfs_rel_path):
    """
    Joins the vfs's root path with a vfs local path to get
    absolute path in the vfs (absolute to the real fs)

    Args:
        vfs_path (str): absolute path to the written vfs root
        vfs_rel_path (str): vfs local path

    Returns:
        (str): The absolute path (real fs) to the vfs local path
    """
    return os.path.join(vfs_path, vfs_rel_path.removeprefix('/'))


class VFSMgr:
    """
    A VFS disk manager for managing and writing vfs to disk
    """

    def __init__(self, data_path):
        """
        Initialize a manager with the given data directory path

        Args:
            data_path (str): absolute path to the directory
        """
        logger.info(f"""
Initializing VFS Manager:
    vfs data path: {data_path}""")
        self.data_path = data_path

    def write_vfs(self, vfs):
        """
        Write a vfs to disk

        Args:
            vfs (dict): virtual file system data

        Returns:
            (str): The vfs's absolute root path in the real filesystem
        """
        vfs_path = os.path.join(self.data_path, vfs["name"])
        logger.info("""
Writing VFS:
    vfs: %s
    vfs_path: %s""", vfs, vfs_path)

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
