pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['UAT', 'Production'], description: 'Choose the deployment environment')
    }

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker') // Replace with your Jenkins Docker Hub credentials ID
        DOCKER_IMAGE_NAME = 'd2k-hello-world'
        UAT_PORT = '8081'
        PROD_PORT = '8082'
        SERVER_IP = '98.84.242.50' // Replace with your EC2 instance IP
        SSH_CREDENTIALS_ID = 'ec2' // Replace with your Jenkins SSH credentials ID
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Ajeet664/d2k-ass.git' // Replace with your actual GitHub repository URL
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = params.ENVIRONMENT.toLowerCase()
                    // Build the Docker image with the environment-specific tag
                    docker.build("${DOCKER_IMAGE_NAME}:${imageTag}")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    def imageTag = params.ENVIRONMENT.toLowerCase()
                    // Push the image to Docker Hub with the environment tag (UAT or Production)
                    docker.withRegistry('', DOCKER_HUB_CREDENTIALS) {
                        docker.image("${DOCKER_IMAGE_NAME}:${imageTag}").push()
                    }
                }
            }
        }

        stage('Deploy to Server') {
            steps {
                script {
                    def port = (params.ENVIRONMENT == 'UAT') ? UAT_PORT : PROD_PORT
                    def imageTag = params.ENVIRONMENT.toLowerCase()
                    def containerName = "${DOCKER_IMAGE_NAME}-${imageTag}"

                    // SSH into the server and perform the deployment steps
                    sshagent([SSH_CREDENTIALS_ID]) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ec2-user@${SERVER_IP} << EOF
                        set -e  # Exit immediately if a command exits with a non-zero status
                        docker pull ${DOCKER_IMAGE_NAME}:${imageTag}

                        # Stop and remove the old container if it exists
                        docker stop ${containerName} || true
                        docker rm ${containerName} || true

                        # Remove the old Docker image to save space
                        docker rmi ${DOCKER_IMAGE_NAME}:${imageTag} || true

                        # Run the new container on the appropriate port (8081 for UAT, 8082 for Production)
                        docker run -d -p ${port}:80 --name ${containerName} ${DOCKER_IMAGE_NAME}:${imageTag}
                        EOF
                        """
                    }
                }
            }
        }
    }
}
