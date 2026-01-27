# Configuring vera_jupyter.sh Script

This guide explains how to customize the `vera_jupyter.sh` script to match your project requirements, resource allocations, and preferences.

## What Does the Script Do?

The `vera_jupyter.sh` script automates the process of:
1. Requesting a compute node on Vera
2. Starting Jupyter Notebook in a Singularity container on the compute node
3. Setting up an SSH tunnel from the login node to the compute node
4. Managing screen sessions for both processes
5. Providing logging with timestamps for debugging

## Configuration Variables

All customizable settings are located in the **Configuration** section at the top of the script (lines 3-18). Here's what each variable does:

### Basic Settings

#### `VERA_USER`
```bash
VERA_USER=$(whoami)
```
- **What it does:** Automatically detects your username
- **Default:** Uses `whoami` command (no need to change)
- **When to modify:** Usually not needed, but you can hardcode a username if required

#### `COMPUTE_SCREEN` and `LOGIN_SCREEN`
```bash
COMPUTE_SCREEN="compute_node_2"
LOGIN_SCREEN="login_node_2"
```
- **What it does:** Names for the screen sessions that run your Jupyter notebook and SSH tunnel
- **Default:** `compute_node_2` and `login_node_2`
- **When to modify:** If you want to run multiple instances or prefer different names
- **Example:** Change to `"my_jupyter_session"` and `"my_tunnel_session"`

#### `SCRIPT_DIR` and `SIF_PATH`
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIF_PATH="$SCRIPT_DIR/basic_python_module.sif"
```
- **What it does:** Automatically detects the script's directory and sets the container path relative to it
- **Default:** `basic_python_module.sif` in the same directory as the script
- **When to modify:** 
  - If your container has a different name, change `basic_python_module.sif` to your container name
  - If your container is in a different location, modify `SIF_PATH` to point to the correct path
- **Examples:**
  ```bash
  SIF_PATH="$SCRIPT_DIR/my_container.sif"                    # Same directory as script
  SIF_PATH="/cephyr/NOBACKUP/groups/mygroup/container.sif"     # Full path
  SIF_PATH="~/containers/bioinformatics.sif"                 # Relative to home
  ```
- **Note:** The script automatically finds its own directory, so if you keep the container in the same folder as the script, you only need to change the filename.

#### `PORT`
```bash
PORT=8080
```
- **What it does:** The port number Jupyter Notebook will use
- **Default:** `8080`
- **When to modify:** If port 8080 is already in use, change to another port (e.g., `8081`, `8889`, `9000`)
- **Important:** Make sure to use the same port in your local SSH tunnel command!

### Project and Resource Allocation

#### `ACCOUNT`
```bash
ACCOUNT="BBT046"
```
- **What it does:** Your project account identifier (billing account)
- **Default:** `BBT046`
- **When to modify:** **MUST CHANGE** - Use your own project account
- **How to find your account:**
  - Run `projinfo` command on Vera to see your projects
  - Check with your supervisor or project PI
  - Look for format like `C3SE2024-XX-XX` or similar
- **Example:**
  ```bash
  ACCOUNT="C3SE2024-11-05"
  ```

#### `PARTITION`
```bash
PARTITION="vera"
```
- **What it does:** Specifies which cluster partition to use
- **Default:** `vera`
- **When to modify:** Usually keep as `vera` unless you have access to a different partition

#### `NODE_CONSTRAINT`
```bash
NODE_CONSTRAINT="MEM512"
```
- **What it does:** Requests a node with specific memory capacity
- **Default:** `MEM512` (512 GB memory)
- **Available options:**
  - `MEM512` - 512 GB memory (Icelake nodes)
  - `MEM768` - 768 GB memory (Zen4 nodes, default if not specified)
  - `MEM1024` - 1024 GB memory
  - `MEM1536` - 1536 GB memory
  - `MEM2048` - 2048 GB memory
  - `ZEN4` - Zen4 CPU nodes (768+ GB memory)
  - `ICELAKE` - Icelake CPU nodes (512+ GB memory)
- **When to modify:** 
  - If you need more memory for large datasets
  - If you want a specific CPU architecture
- **Example:**
  ```bash
  NODE_CONSTRAINT="MEM1024"    # Request 1TB memory node
  NODE_CONSTRAINT="ZEN4"        # Request Zen4 node (default)
  ```

### Resource Allocation in srun Command

The `srun` command (line 31) contains several resource allocation parameters:

#### Time Allocation (`-t`)
```bash
-t 02:00:00
```
- **What it does:** Maximum wall time for your job (hours:minutes:seconds)
- **Default:** `02:00:00` (2 hours)
- **Format:** `HH:MM:SS` or `DD-HH:MM:SS` for days
- **When to modify:** 
  - Request more time for longer sessions
  - Request less time if you have limited allocation
- **Examples:**
  ```bash
  -t 01:00:00      # 1 hour
  -t 04:00:00      # 4 hours
  -t 1-00:00:00    # 1 day (24 hours)
  -t 3-00:00:00    # 3 days (72 hours, maximum)
  ```
- **Note:** Maximum is 7 days, but longer jobs may require manual approval

#### CPUs per Task (`--cpus-per-task`)
```bash
--cpus-per-task=4
```
- **What it does:** Number of CPU cores to allocate
- **Default:** `4`
- **When to modify:**
  - Increase for parallel processing or heavy computations
  - Decrease if you have limited allocation
- **Examples:**
  ```bash
  --cpus-per-task=8      # 8 cores
  --cpus-per-task=16     # 16 cores
  --cpus-per-task=32     # 32 cores
  --cpus-per-task=64     # Full node (64 cores)
  ```
- **Note:** Vera nodes typically have 64 cores total

#### Memory (`--mem`)
```bash
--mem=0
```
- **What it does:** Memory allocation (0 means use default based on cores)
- **Default:** `0` (proportional to CPU allocation)
- **When to modify:** Usually keep as `0` unless you need specific memory allocation
- **Example:**
  ```bash
  --mem=32G              # Request 32 GB memory
  ```

#### Nodes (`--nodes`)
```bash
--nodes=1
```
- **What it does:** Number of nodes to request
- **Default:** `1`
- **When to modify:** Usually keep as `1` for single-node jobs

#### Exclusive (`--exclusive`)
```bash
--exclusive
```
- **What it does:** Requests exclusive access to the node
- **Default:** Enabled
- **When to modify:** Remove if you want to share the node (not recommended for Jupyter)

### Jupyter Notebook Configuration

The script uses `singularity exec` to run Jupyter Notebook with specific flags (line 34):

```bash
singularity exec $SIF_PATH jupyter-notebook --no-browser --port=$PORT --NotebookApp.token='' --NotebookApp.password=''
```

#### Jupyter Flags Explained

- `--no-browser`: Prevents Jupyter from trying to open a browser automatically (since you're accessing via SSH tunnel)
- `--port=$PORT`: Sets the port number (default: 8080)
- `--NotebookApp.token=''`: Disables token authentication for easier access
- `--NotebookApp.password=''`: Disables password authentication

**Security Note:** These settings make Jupyter accessible without authentication, but your SSH tunnel provides the security. Always ensure your SSH connection is secure and don't expose the port publicly.

## Common Customization Examples

### Example 1: Change Project Account and Time Allocation
```bash
ACCOUNT="C3SE2024-11-05"        # Your project account
# In srun command, change:
-t 04:00:00                      # 4 hours instead of 2
```

### Example 2: Request More Memory and CPUs
```bash
NODE_CONSTRAINT="MEM1024"        # 1TB memory node
# In srun command, change:
--cpus-per-task=16               # 16 cores instead of 4
```

### Example 3: Use Different Container
```bash
# Option 1: Container in same directory as script (just change filename)
SIF_PATH="$SCRIPT_DIR/my_container.sif"

# Option 2: Container in different location
SIF_PATH="/cephyr/NOBACKUP/groups/mygroup/my_container.sif"
```

### Example 4: Change Port (if 8080 is busy)
```bash
PORT=8889
# Remember to update your local SSH tunnel:
# ssh -N -L 8889:localhost:8889 <user_name>@vera1.c3se.chalmers.se
```

### Example 5: Longer Session with More Resources
```bash
ACCOUNT="C3SE2024-11-05"
NODE_CONSTRAINT="MEM1024"
# In srun command:
-t 1-00:00:00                    # 1 day
--cpus-per-task=32              # 32 cores
```

## Step-by-Step: How to Modify the Script

1. **Open the script in a text editor:**
   ```bash
   nano vera_jupyter.sh
   # or
   vim vera_jupyter.sh
   ```

2. **Locate the Configuration section** (lines 3-18)

3. **Modify the variables** you need to change

4. **If changing time/CPU allocation**, also modify the `srun` command on line 31:
   ```bash
   srun -A $ACCOUNT -p $PARTITION -t HH:MM:SS -C $NODE_CONSTRAINT --nodes=1 --exclusive --mem=0 --cpus-per-task=N --pty bash -c '
   ```

5. **If changing container name**, modify line 9:
   ```bash
   SIF_PATH="$SCRIPT_DIR/your_container_name.sif"
   ```

6. **Save the file**

7. **Test your changes** by running the script

## Important Notes

- **Always check your project allocation** using `projinfo` before requesting resources
- **Account (`ACCOUNT`) is mandatory** - you must use your own project account
- **Port consistency:** If you change `PORT`, update your local SSH tunnel command accordingly
- **Resource limits:** Your project may have limits on simultaneous resource usage
- **Screen sessions:** The script creates new screen sessions each time - use `screen -r <screen_name>` to attach and monitor
- **Container location:** The script automatically finds containers in the same directory as the script - keep your `.sif` file in the `vera_script` folder
- **Jupyter security:** The script runs Jupyter with `--NotebookApp.token='' --NotebookApp.password=''` for easy access - ensure your SSH tunnel is secure
- **Logging:** The script includes timestamped logging to help debug issues - check screen sessions for detailed logs

## Troubleshooting

### "Account not found" error
- Verify your `ACCOUNT` variable matches your project account from `projinfo`
- Check with your supervisor if unsure

### "Port already in use" error
- Change the `PORT` variable to a different number
- Update your local SSH tunnel command

### "Insufficient resources" or long queue times
- Reduce `--cpus-per-task` or time allocation (`-t`)
- Try a different `NODE_CONSTRAINT` (e.g., remove MEM constraint)
- Check `sinfo` to see available resources

### Container not found
- Verify `SIF_PATH` points to the correct file
- Check that `basic_python_module.sif` exists in the same directory as `vera_jupyter.sh`
- If using a different container name, update `SIF_PATH` in the script
- Use full path if container is not in the script directory
- Check file permissions with `ls -l basic_python_module.sif`

### Jupyter Notebook not accessible
- Check that the compute node job is running: `squeue -u $USER`
- Attach to the compute screen to see logs: `screen -r compute_node_2`
- Verify the port matches in both the script and your SSH tunnel command
- Check that the SSH tunnel is active and connected

## Additional Resources

- Vera documentation: https://www.c3se.chalmers.se/documentation/first_time_users/intro-vera/presentation.html
- SLURM documentation: Use `man srun` on Vera for detailed options
- Check available modules: `module avail` on Vera
