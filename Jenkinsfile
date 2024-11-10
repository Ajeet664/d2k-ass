pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['UAT', 'Production'], description: 'Choose the deployment environment')
    }

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub')  
        DOCKER_IMAGE_NAME = 'ajityadav664/d2k-hello-world'  
        UAT_PORT = '8081'
        PROD_PORT = '8082'
        SERVER_IP = '98.84.242.50' 
        SSH_CREDENTIALS_ID = 'ec2' 
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Ajeet664/d2k-ass.git' 
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = params.ENVIRONMENT.toLowerCase()
                    docker.build("${DOCKER_IMAGE_NAME}:${imageTag}")
                }
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
                        echo 'Successfully logged in to Docker Hub'
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    def imageTag = params.ENVIRONMENT.toLowerCase()
                    docker.withRegistry('https://registry.hub.docker.com', DOCKER_HUB_CREDENTIALS) {
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

                    withCredentials([file(credentialsId: 'ec2-ssh-key', variable: 'SSH_PRIVATE_KEY_FILE')]) {
                        sh """
                        chmod 600 ${SSH_PRIVATE_KEY_FILE}
                        ssh -i ${SSH_PRIVATE_KEY_FILE} -o StrictHostKeyChecking=no ec2-user@${SERVER_IP} << EOF
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
