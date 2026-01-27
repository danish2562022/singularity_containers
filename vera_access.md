# How to Login to Vera

## What is Vera?

Vera is a high-performance computing (HPC) cluster that provides powerful computational resources for running code and executing projects. It offers access to multiple compute nodes with significant processing power, memory, and storage capabilities, making it ideal for computationally intensive tasks, data analysis, and research projects.

For more detailed information about Vera, refer to the [Introduction to Vera documentation](https://www.c3se.chalmers.se/documentation/first_time_users/intro-vera/presentation.html).

## Purpose of SSH

SSH (Secure Shell) is a network protocol that allows you to securely connect to and interact with remote computers over an unsecured network. SSH provides encrypted communication between your local machine and the remote server, ensuring that your login credentials and data are protected during transmission. When connecting to Vera, SSH enables you to:

- Securely authenticate to the cluster
- Execute commands remotely
- Transfer files securely
- Run interactive sessions on the cluster

## Login Instructions

To log in to Vera, use SSH with the following command:

```bash
ssh <user_name>@vera1.c3se.chalmers.se
```

Replace `<user_name>` with your actual Vera username.

**Example:**
```bash
ssh anwer@vera1.c3se.chalmers.se
```

Once logged in, you will be connected to the Vera login node and can proceed with your work.

## What is Jupyter Notebook?

Jupyter Notebook is an open-source web application that allows you to create and share documents containing live code, equations, visualizations, and narrative text. The name "Jupyter" is derived from the three core programming languages it supports: **Ju**lia, **Py**thon, and **R**.

### Purpose of Jupyter Notebook

Jupyter Notebook serves multiple purposes in computational work:

- **Interactive Computing:** Execute code interactively and see results immediately, making it ideal for exploratory data analysis, prototyping, and experimentation.

- **Documentation:** Combine code, text explanations, visualizations, and mathematical equations in a single document, creating reproducible research notebooks.

- **Data Analysis:** Perfect for data science workflows, allowing you to load data, perform analysis, create visualizations, and document your findings all in one place.

- **Education and Collaboration:** Share notebooks with others to demonstrate workflows, teach concepts, or collaborate on projects. Notebooks can be easily shared and run by others.

- **Reproducible Research:** Keep code, results, and explanations together, making your research more transparent and reproducible.

- **Visualization:** Create rich visualizations and plots directly within the notebook, making it easy to explore and present data.

When running Jupyter Notebook on Vera, you leverage the cluster's powerful computational resources while maintaining the interactive and user-friendly interface of Jupyter Notebook in your web browser.

## Opening Jupyter Notebook on Vera

To run Jupyter Notebook on Vera, follow these steps:

1. **Login to Vera:** First, connect to Vera using SSH as described above.

2. **Download the script:** Once logged into Vera, download the `vera_script.zip` file:
   ```bash
   wget https://github.com/danish2562022/singularity_containers/raw/main/vera_script.zip
   ```

3. **Extract the zip file:**
   ```bash
   unzip vera_script.zip
   ```

4. **Remove the zip file:**
   ```bash
   rm vera_script.zip
   ```

5. **Navigate to the script directory:**
   ```bash
   cd vera_script
   ```

6. **Make the script executable:**
   ```bash
   chmod 755 vera_jupyter.sh
   ```

7. **Execute the script:**
   ```bash
   ./vera_jupyter.sh
   ```
   This script will:
   - Request a compute node and start Jupyter Notebook in a screen session
   - Set up an SSH tunnel from the login node to the compute node
   
   **Note:** By default, you will get a compute node allocation for 2 hours. The script will automatically release the resources after this time period.
   
   **For more information:** If you want detailed information about customizing `vera_jupyter.sh` (changing project account, time allocation, resource settings, etc.), you can read the detailed guide at [vera_access_script_description.md](https://github.com/danish2562022/singularity_containers/blob/main/vera_access_script_description.md).

8. **Create SSH tunnel from your local machine:** Open a **new terminal** on your local machine (Linux, MacBook, or Git Bash on Windows) and create an SSH tunnel to Vera:
   ```bash
   ssh -N -L 8080:localhost:8080 <user_name>@vera1.c3se.chalmers.se
   ```
   Replace `<user_name>` with your Vera username. This command will:
   - Create a local port forwarding tunnel (`-L`)
   - Forward local port 8080 to Vera's port 8080 (`-N` flag prevents executing remote commands)
   - Keep the tunnel running (leave this terminal open)
   
   **Note:** If Git Bash is not installed on Windows, you can follow the installation steps provided in the [Git Bash Windows SSH Guide](https://github.com/danish2562022/singularity_containers/blob/main/git_bash_windows_ssh.md).

9. **Access Jupyter Notebook:** Open Chrome or any web browser and navigate to:
   ```
   http://localhost:8080
   ```
   You should now be able to access your Jupyter Notebook running on Vera's compute node.

**Note:** Keep the SSH tunnel terminal open while using Jupyter Notebook. To stop the tunnel, press `Ctrl+C` in that terminal.

## After Completing Your Work

When you have finished your work and want to free up the compute node resources:

1. **Login to Vera** (if not already logged in):
   ```bash
   ssh <user_name>@vera1.c3se.chalmers.se
   ```

2. **Kill the screen sessions** to stop the Jupyter Notebook and SSH tunnel:
   ```bash
   pkill screen
   ```
   This will terminate all screen sessions, including the compute node Jupyter Notebook session and the SSH tunnel.

**Important:** Always remember to kill the screen sessions after completing your work to free up compute node resources for other users.
