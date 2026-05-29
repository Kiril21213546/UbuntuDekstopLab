pipeline {
    agent any

    environment {
        IMAGE_NAME = "flask-ci-cd:latest"
        CONTAINER_NAME = "flask-app"
        HOST_PORT = "8081"
        APP_PORT = "5000"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker image') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Run tests') {
            steps {
                sh "docker run --rm ${IMAGE_NAME} pytest -q"
            }
        }

        stage('Deploy container') {
            steps {
                sh """
                docker rm -f ${CONTAINER_NAME} || true
                docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${APP_PORT} ${IMAGE_NAME}
                sleep 3
                docker ps
                """
            }
        }

        stage('Smoke test') {
            steps {
                sh """
                echo "Waiting for Flask..."

                for i in \$(seq 1 25)
                do
                    RESPONSE=\$(curl -s http://localhost:${HOST_PORT}/health || true)

                    echo "Attempt \$i -> \$RESPONSE"

                    if echo "\$RESPONSE" | grep -q "healthy"
                    then
                        echo "APP IS HEALTHY"
                        exit 0
                    fi

                    sleep 2
                done

                echo "Smoke test FAILED"
                docker logs ${CONTAINER_NAME}
                exit 1
                """
            }
        }
    }

    post {
        always {
            sh """
            echo "Final logs:"
            docker logs ${CONTAINER_NAME} || true
            docker images | head -n 5
            """
        }
    }
}
