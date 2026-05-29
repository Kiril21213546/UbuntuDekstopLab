pipeline {
    agent any

    environment {
        IMAGE_NAME = "flask-ci-cd"
        CONTAINER_NAME = "flask-app"
        HOST_PORT = "8081"
        CONTAINER_PORT = "5000"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker image') {
            steps {
                sh """
                docker build -t ${IMAGE_NAME}:latest .
                """
            }
        }

        stage('Run tests') {
            steps {
                sh """
                docker run --rm ${IMAGE_NAME}:latest pytest -q
                """
            }
        }

        stage('Deploy container') {
            steps {
                sh """
                docker rm -f ${CONTAINER_NAME} || true

                docker run -d \
                  --name ${CONTAINER_NAME} \
                  -p ${HOST_PORT}:${CONTAINER_PORT} \
                  ${IMAGE_NAME}:latest

                sleep 5

                docker ps
                docker logs ${CONTAINER_NAME}
                """
            }
        }

        stage('Smoke test') {
            steps {
                sh """
                echo "Checking application health..."

                for attempt in 1 2 3 4 5 6 7 8 9 10
                do
                    if curl -s http://localhost:${HOST_PORT}/health | grep healthy
                    then
                        echo "Application is healthy!"
                        exit 0
                    fi

                    echo "Retry \$attempt..."
                    sleep 3
                done

                echo "Smoke test failed"

                docker logs ${CONTAINER_NAME}

                exit 1
                """
            }
        }
    }

    post {
        always {
            sh 'docker images | head -n 5'
        }
    }
}
