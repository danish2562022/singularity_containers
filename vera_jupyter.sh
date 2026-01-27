#!/bin/bash

# ======================
# Configuration
# ======================

# Get script directory (where script and SIF file are located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIF_PATH="$SCRIPT_DIR/basic_python_module.sif"

# Get username from current logged-in user
VERA_USER=$(whoami)
COMPUTE_SCREEN="compute_node_2"
LOGIN_SCREEN="login_node_2"
PORT=8080
ACCOUNT="BBT046"
PARTITION="vera"
NODE_CONSTRAINT="MEM512"

# ======================ss
# Script runs when already logged into Vera
# ======================

# Step 0: Change to home directory
cd ~

# Step 1: Start compute node Jupyter notebook in screen
screen -dmS $COMPUTE_SCREEN bash -c "
  cd ~
  echo '[$(date)] Starting srun job...'
  srun -A $ACCOUNT -p $PARTITION -t 02:00:00 -C $NODE_CONSTRAINT --nodes=1 --exclusive --mem=0 --cpus-per-task=4 --pty bash -c '
    cd ~
    echo \"[$(date)] Inside compute node, running singularity exec...\"
    singularity exec $SIF_PATH jupyter-notebook --no-browser --port=$PORT --NotebookApp.token='' --NotebookApp.password='' 2>&1
    echo \"[$(date)] Jupyter notebook exited with code: $?\"
    sleep 10
  ' 2>&1
  echo '[$(date)] srun exited with code: $?'
  sleep 30
"
echo "[✔] Started compute node Jupyter notebook in screen: $COMPUTE_SCREEN"
sleep 5

# Step 2: Start SSH tunnel in screen
screen -dmS $LOGIN_SCREEN bash -c "
  NODE_NAME=\$(squeue -u $VERA_USER -o '%N' | tail -n 1)
  echo \"[✔] Tunneling from \$NODE_NAME\"
  ssh -N -L $PORT:localhost:$PORT \$NODE_NAME
"
echo "[✔] SSH tunnel started in screen: $LOGIN_SCREEN"
echo "[✔] Done. Use 'screen -r $COMPUTE_SCREEN' and 'screen -r $LOGIN_SCREEN' to attach sessions."
 