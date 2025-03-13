# IDE
- Added shell module for running python code

# Code Execution Server
- (Breaking change) Migrated from websocket to HTTP
- (Breaking change) Updated data packets to fit HTTP more
- Implemented a reverse proxy to route client packets
- Implemented python code execution
- Implemented AST security checking

# Code Execution Client
- Implemented HTTP client to communicate with the server

# IDE
## Shell
- Added a shell
- Added shell modules
- Added shell module signals
- Added builtin shell module
- Added editor shell module

## Editor
- Implemented VFS file loading
- Implemented buffer saving

# Core
- Implemented a virtual file system
