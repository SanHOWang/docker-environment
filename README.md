# Docker-Based Development Environment

This repository provides a Docker-based development environment for C programming, Verilator simulation, and SystemC-based modeling. It includes:

- `docker.sh`: A control script to build, run, and manage the container.
- `eman`: An in-container CLI tool for common development workflows.

---

## Project Structure

The directory tree, relative to where `docker.sh` resides:

```
.
├── docker.sh                  # Container management script
├── Dockerfile                 # Multi-stage build with Verilator, SystemC, GCC, etc.
├── scripts/
│   └── eman.sh                # Entry-point CLI inside the container
├── workspace/
│   └── lab0/
│       ├── c_cpp/arrays/multidim_array/
│       │   ├── main.c
│       │   └── Makefile
│       └── verilog/counter/
│           ├── Counter.v
│           ├── Makefile
│           └── testbench.cc
```

---

## Using `docker.sh`

### Build Image

```bash
./docker.sh build
```

Rebuild without cache:

```bash
./docker.sh rebuild
```

### Run Container

```bash
./docker.sh run
```

By default, it will mount:

```
./workspace → /home/<user>/workspace
```

You can manually mount a custom directory:

```bash
./docker.sh run -m $(pwd)/workspace:/home/user/workspace
```

### Other Commands

```bash
./docker.sh stop             # Stop container
./docker.sh clean-container  # Stop and remove container
./docker.sh clean-all        # Remove container and image
```

### CLI Options

| Option               | Description                                                 | When to Use    | Default                              |
| -------------------- | ----------------------------------------------------------- | -------------- | ------------------------------------ |
| `--username`, `-u`   | Set the username in the container                           | `run`, `build` | Current host username (`$USER`)      |
| `--image-name`, `-i` | Set the name of the Docker image                            | `run`, `build` | `"aoc2026-env"`                      |
| `--cont-name`, `-c`  | Set the name of the Docker container                        | `run`          | `"aoc2026-container"`                |
| `--mount`, `-m`      | Mount host path to container path (`HOST:CONTAINER` format) | `run`          | `./workspace:/home/<user>/workspace` |

---

## `eman` Commands (Inside Container)

After entering the container, use the `eman` command to invoke predefined actions.

```bash
eman help
```

### C Examples

```bash
eman c-version   # Show GCC and Make version
eman c-example   # Run the C example at:
                 # /home/<user>/workspace/lab0/c_cpp/arrays/multidim_array
```

### Verilator Examples

```bash
eman verilator-version   # Show Verilator version
eman verilator-example   # Run the Verilator example at:
                         # /home/<user>/workspace/lab0/verilog/counter
```

---

## Environment Details

- **Base OS**: Ubuntu 24.04
- **Default user**: `user` (UID=1001, GID=1001)
- **Locale & Timezone**: UTF-8 with `Asia/Taipei` timezone
- **User privileges**: `sudo` enabled, non-root development environment

### Preinstalled Tools

| Category           | Tools                                                                |
| ------------------ | -------------------------------------------------------------------- |
| Shell & Utility    | `vim`, `git`, `curl`, `wget`, `ca-certificates`, `sudo`, `apt-utils` |
| Compiler Toolchain | `gcc`, `make`, `build-essential`                                     |
| Python             | `python3`, `pip`, `miniconda` (from upstream stage)                  |
| C++ Simulation     | `Verilator` (from upstream stage), `SystemC 2.3.4` (with ldconfig)   |
| Custom CLI Tool    | `eman` (custom script installed to `/usr/local/bin`)                 |
