pipeline {
    agent {
        docker {
            image 'php:8.2-cli-alpine'
            args '-u 0:0' // Menjalankan sebagai user root di dalam container untuk izin instalasi
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
                    apk add --no-cache \
                        curl \
                        ca-certificates \
                        gnupg \
                        libressl-dev 
                    
                    # Instal Docker CLI binary (versi stabil terbaru)
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
                // Menginstal Composer secara eksplisit dan menempatkannya di /usr/local/bin
                sh '''
                    echo "Installing Composer in agent..."
                    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
                    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
                    php -r "unlink('composer-setup.php');"
                    echo "Composer installed in agent."
                    
                    # Instal PHP dependencies setelah Composer terinstal
                    composer install --no-dev --prefer-dist --optimize-autoloader
                '''
            }
            post {
                failure {
                    echo 'Failed to install PHP dependencies.'
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh 'composer run test'
            }
            post {
                success {
                    echo 'All tests passed successfully!'
                }
                failure {
                    echo 'Tes gagal! Cek log untuk detail.'
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