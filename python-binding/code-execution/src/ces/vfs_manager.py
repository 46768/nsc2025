"""Virtual filesystem management module

Provides classes for managing virtual filesystem
on the disk. Used for writing a vfs to the disk,
getting a file on the disk relative to a vfs, and
cleaning up after usage

Notes:
    Currently the VFSMgr only provides a method to write
    vfs to disk, it will be replaced by VFSManager and
    VFS classes, the former for managing VFS classes,
    and the latter for managing vfs on the disk. They
    will provide a better API for managing vfs on the disk
"""

import os
import shutil
import logging

logger = logging.getLogger(__name__)


def vfs_path_join(vfs_path, vfs_rel_path):
    """Joins absolute vfs root path to a vfs relative one

    Args:
        vfs_path (str): Absolute path to the vfs root
        vfs_rel_path (str): VFS relative path

    Returns:
        str: The absolute path of the file within a vfs
    """
    return os.path.join(vfs_path, vfs_rel_path.removeprefix('/'))


class VFSMgr:
    """A Virtual filesystem manager for writing vfs to disk

    A Class for writing vfs to disk in a data directory path
    for easy cleanup if needed

    Args:
        data_path (str): Absolute path to the vfs data directory
                to write vfs to
    """

    def __init__(self, data_path):
        self.data_path = data_path

    def write_vfs(self, vfs):
        """Write a vfs to disk

        Write a virtual filesystem to the disk with root
        directory name being the vfs name in the provided
        vfs data path

        Args:
            vfs (dict): Dictionary containing data about a
                    virtual filsystem
        """

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
