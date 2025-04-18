import importlib.util
import sys


def does_module_exists(name):
    try:
        importlib.util.find_spec(name)
        return True
    except ImportError:
        return False


def lazy_import(name):
    spec = importlib.util.find_spec(name)
    loader = importlib.util.LazyLoader(spec.loader)
    spec.loader = loader
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    loader.exec_module(module)
    return module
