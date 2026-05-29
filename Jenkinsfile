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
                sleep 5
                docker ps
                """
            }
        }

        stage('Smoke test') {
            steps {
                sh """
                echo "Waiting for Flask..."

                URL="http://localhost:${HOST_PORT}/health"

                for i in \$(seq 1 30)
                do
                    HTTP_CODE=\$(curl -s -o /tmp/resp.txt -w "%{http_code}" --connect-timeout 2 --max-time 3 \$URL || true)
                    BODY=\$(cat /tmp/resp.txt 2>/dev/null || true)

                    echo "Attempt \$i -> code=\$HTTP_CODE body=\$BODY"

                    if [ "\$HTTP_CODE" = "200" ]; then
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
