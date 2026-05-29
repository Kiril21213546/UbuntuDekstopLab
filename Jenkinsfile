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
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage("Run tests") {
            steps {
                sh "docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} pytest -q"
            }
        }

        stage("Deploy container") {
            steps {
                sh """
                docker rm -f ${APP_NAME} || true

                docker run -d --name ${APP_NAME} \
                -p ${HOST_PORT}:${CONTAINER_PORT} \
                ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage("Health check (FIXED)") {
            steps {
                sh """
                echo "Waiting for Flask container..."

                sleep 5

                for i in \$(seq 1 10); do
                    RESPONSE=\$(docker exec ${APP_NAME} python -c "
import requests
print(requests.get('http://localhost:${CONTAINER_PORT}/health').text)
" 2>/dev/null || true)

                    echo "Attempt \$i: \$RESPONSE"

                    echo "\$RESPONSE" | grep -q "healthy" && exit 0

                    sleep 2
                done

                echo "Health check FAILED"
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
