"""
we package oil and force a namespace on it;
we want some sense that its packages aren't
leaking out
"""

# this shouldn't raise
import oil._devbuild

try:
    # this should
    import _devbuild

    raise Exception("_devbuild shouldn't be importable by itself")
except ImportError:
    pass
