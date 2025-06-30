pipeline {
    agent {
        docker {
            image 'php:8.2-cli-alpine'
            args '-u 0:0' // Running as root in agent for setup purposes
        }
    }

    environment {
        IMAGE_NAME = "my-php-app"
        CONTAINER_NAME = "my-php-app-container"
        APP_PORT = "8081" 
    }

    stages {
        stage('Prepare Agent Environment') {
            steps {
                sh '''
                    echo "Preparing Docker CLI in agent container..."
                    # Minimal apk add untuk prasyarat docker-cli di Alpine
                    # (curl, ca-certificates, gnupg, libressl-dev adalah untuk menginstal Docker CLI)
                    apk add --no-cache \
                        curl \
                        ca-certificates \
                        gnupg \
                        libressl-dev 
                    
                    # Instal Docker CLI binary (versi stabil terbaru dari download.docker.com)
                    curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-26.1.3.tgz | tar -xz -C /usr/bin --strip-components=1

                    echo "Docker CLI installed in agent container."
                '''
            }
        }

        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/DaffaWibu/devops_tugas8.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                // Composer sudah ada di image php:8.2-cli-alpine, jadi tidak perlu instal ulang.
                // Langsung jalankan composer install.
                sh 'composer install --no-dev --prefer-dist --optimize-autoloader'
            }
            post {
                failure {
                    echo 'Failed to install PHP dependencies.'
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                // Menjalankan unit test menggunakan skrip 'test' dari composer.json
                // Ini lebih andal dan akan menemukan PHPUnit yang diinstal oleh Composer.
                sh 'composer run test'
            }
            post {
                success {
                    echo 'All tests passed successfully!'
                }
                failure {
                    echo 'Tes gagal! Cek log untuk detail.'
                    // exit 1 // Uncomment ini jika Anda ingin build gagal jika test gagal
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
            }
        }

        stage('Deploy Application') {
            steps {
                sh '''
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    docker run -d -p ${APP_PORT}:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}:${BUILD_NUMBER}
                    echo "Application deployed. Access at http://<your-jenkins-host-ip>:${APP_PORT}"
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}