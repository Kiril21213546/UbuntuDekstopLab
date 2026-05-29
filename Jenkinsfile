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

        stage("Smoke test") {
            steps {
                sh '''
                echo "Waiting for Flask to start..."

                for i in {1..20}; do
                    if curl -s http://localhost:8081/health; then
                        echo "App is up!"
                        exit 0
                    fi

                    echo "Waiting... attempt $i"
                    sleep 2
                done

                echo "App failed to start"
                exit 1
                '''
            }
        }
    }

    post {
        always {
            sh "docker images | head -n 5 || true"
        }
    }
}
