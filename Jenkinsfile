pipeline {
    agent any

    environment {
        APP_NAME = "flask-app"
        IMAGE_NAME = "flask-ci-cd"
        IMAGE_TAG = "latest"
        HOST_PORT = "8081"
        CONTAINER_PORT = "5000"
    }

    stages {

        stage("Checkout") {
            steps {
                checkout scm
            }
        }

        stage("Build Docker image") {
            steps {
                sh """
                docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage("Run tests") {
            steps {
                sh """
                docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} pytest -q
                """
            }
        }

        stage("Deploy container") {
            steps {
                sh """
                if docker ps -a --format '{{.Names}}' | grep -w ${APP_NAME}; then
                    docker rm -f ${APP_NAME}
                fi

                docker run -d --name ${APP_NAME} \
                -p ${HOST_PORT}:${CONTAINER_PORT} \
                ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage("Health check (stable)") {
            steps {
                sh """
                echo "Waiting for container..."
                sleep 5

                for i in \$(seq 1 10); do
                    STATUS=\$(curl -s http://localhost:${HOST_PORT}/health || true)

                    echo "Attempt \$i: \$STATUS"

                    if echo "\$STATUS" | grep -q "healthy"; then
                        echo "Application is healthy!"
                        exit 0
                    fi

                    sleep 2
                done

                echo "Health check failed"
                exit 1
                """
            }
        }
    }

    post {
        always {
            sh "docker ps || true"
            sh "docker images | head -n 5 || true"
        }
    }
}

