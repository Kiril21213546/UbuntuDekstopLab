pipeline {
    agent any

    environment {
        IMAGE_NAME = "flask-ci-cd:latest"
        CONTAINER_NAME = "flask-app"
        NETWORK = "ci-net"
    }

    stages {

        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Build') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Test') {
            steps {
                sh "docker run --rm ${IMAGE_NAME} pytest -q"
            }
        }

        stage('Create network') {
            steps {
                sh "docker network create ${NETWORK} || true"
            }
        }

        stage('Deploy') {
            steps {
                sh """
                docker rm -f ${CONTAINER_NAME} || true

                docker run -d --name ${CONTAINER_NAME} \
                    --network ${NETWORK} \
                    -p 8081:5000 \
                    ${IMAGE_NAME}

                sleep 5
                """
            }
        }

        stage('Smoke test') {
            steps {
                sh """
                echo "Waiting for Flask..."

                URL="http://localhost:8081/health"

                for i in \$(seq 1 30)
                do
                    HTTP_CODE=\$(curl -s -o /tmp/resp.txt -w "%{http_code}" \
                        --connect-timeout 2 --max-time 3 \$URL || true)

                    BODY=\$(cat /tmp/resp.txt 2>/dev/null || true)

                    echo "Attempt \$i -> code=\$HTTP_CODE body=\$BODY"

                    if [ "\$HTTP_CODE" = "200" ]; then
                        echo "APP IS HEALTHY"
                        exit 0
                    fi

                    sleep 2
                done

                echo "FAILED"
                docker logs ${CONTAINER_NAME}
                exit 1
                """
            }
        }
    }

    post {
        always {
            sh "docker logs ${CONTAINER_NAME} || true"
        }
    }
}
