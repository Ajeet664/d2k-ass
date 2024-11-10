
# Jenkins Pipeline Setup & Deployment Guide for .NET Core API

This guide details the steps for setting up a Jenkins pipeline to automate the build, push, and deployment of a Dockerized .NET Core API to AWS EC2. The pipeline supports both UAT and Production environments and uses Docker Hub as the image registry.

---

## Prerequisites

### Install Jenkins and Docker on the Server (AWS EC2 Ubuntu Server)
Run the following commands to install Jenkins and Docker:
```markdown
sudo apt update
sudo apt install -y jenkins docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

### Required Jenkins Plugins
- **Git Plugin**: For GitHub repository integration.
- **Pipeline Plugin**: To enable pipeline jobs in Jenkins.
- **Docker Pipeline Plugin**: For Docker-specific commands in the pipeline.
- **Credentials Binding Plugin**: For secure credential management.
- **SSH Agent Plugin**: To securely manage SSH keys for EC2 access.

### Docker Hub Account
A Docker Hub account is required for storing Docker images.

### AWS EC2 Instances
- **UAT**: Runs on port `8081`.
- **Production**: Runs on port `8082`.

### GitHub Repository
Clone the GitHub (https://github.com/doddatpivotal/dotnet-hello-world) 

---

## Steps to Set Up Repository and Add Files

### Step 1: Clone the Repository
On your Ubuntu server, navigate to `/var/www/` and clone the repository:
```bash
cd /var/www/
git clone https://github.com/doddatpivotal/dotnet-hello-world 
mv dotnet-hello-world d2k-ass
cd d2k-ass
```

- **Update .NET Core Version**: Ensure compatibility with environment by updating to a supported .NET Core version if necessary.

- **Add Dockerfile and Jenkinsfile**: Add the Dockerfile and Jenkinsfile to the project.
  - For file contents, refer GitHub repository: https://github.com/Ajeet664/d2k-ass

- **Push to GitHub Repository**:
  - Create a new repository on my GitHub account.
  ```bash
  git remote add origin https://github.com/Ajeet664/d2k-ass.git
  git push -u origin master
  ```

### Step 2: Configure Jenkins and GitHub Webhook

1. **Configure Jenkins Credentials**:
   - **Docker Hub**: Add a Docker Hub credential with ID `dockerhub` in Jenkins.
   - **EC2 SSH Key**: Add an SSH credential with ID `ec2-ssh-key` for EC2 access.

2. **Configure GitHub Webhook**:
   - In my GitHub repository, go to **Settings > Webhooks > Add Webhook**.
   - Set the **Payload URL** to your Jenkins server URL followed by `/github-webhook/` . `http://98.84.242.50:8080/github-webhook/`.
   - Set **Content type** to `application/json`.
   - Select **Just the push event**.

3. **Create Jenkins Pipeline Job**:
   - In Jenkins, create a new **Pipeline** job.
   - Connect it to my GitHub repository  `https://github.com/Ajeet664/d2k-ass.git`
   - Set the pipeline definition to use the Jenkinsfile from my repository.

---

### Step 3: Run the Pipeline

1. **Build with Parameters**:
   - In Jenkins, select **Build with Parameters**.
   - Choose **UAT** or **Production** for the `ENVIRONMENT` parameter.

2. **Pipeline Execution**:
   - Jenkins will:
     - Pull the code from GitHub.
     - Build the Docker image, then push it to Docker Hub.
     - Deploy the image to the designated EC2 instance based on the selected environment.

---

### Step 4: Verify Deployment
- **UAT URL**: [http://98.84.242.50:8081/api/hello](http://98.84.242.50:8081/api/hello)
- **Production URL**: [http://98.84.242.50:8082/api/hello](http://98.84.242.50:8082/api/hello)

Check these URLs to verify that the application is running as expected in both environments.

**GitHub Repository:** https://github.com/Ajeet664/d2k-ass – This repository contains the Dockerfile, Jenkinsfile, and documentation for setting up the pipeline and configuring UAT/Production deployments.
**Docker Hub Image:** https://hub.docker.com/repository/docker/ajityadav664/d2k-hello-world/general


--- 
