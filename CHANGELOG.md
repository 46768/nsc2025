# Github actions
- Added workflow to check for merging branch's existence of a CHANGELOG.md

# Python Binding
- Implemented python environment unpacking from python-packed.tar.gz archive
- Implemented binary self-healing of the conda environment
    - Only detect missing binary, does not include tampering, or checks of other files
- Implemented function to run python script using conda environment provided python3 binary
