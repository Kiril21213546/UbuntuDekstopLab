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

        stage("Build") {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage("Test") {
            steps {
                sh "docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} pytest -q"
            }
        }

        stage("Deploy") {
            steps {
                sh """
                docker rm -f ${APP_NAME} || true

                docker run -d --name ${APP_NAME} \
                -p ${HOST_PORT}:${CONTAINER_PORT} \
                ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage("Health Check (FINAL FIX)") {
            steps {
                sh """
                echo "Waiting for Flask..."

                sleep 5

                for i in \$(seq 1 15); do
                    RESULT=\$(docker exec ${APP_NAME} curl -s http://localhost:${CONTAINER_PORT}/health || true)

                    echo "Attempt \$i: \$RESULT"

                    if echo "\$RESULT" | grep -q "healthy"; then
                        echo "SUCCESS"
                        exit 0
                    fi

                    sleep 2
                done

                echo "FAILED HEALTH CHECK"
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
