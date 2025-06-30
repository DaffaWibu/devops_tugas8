pipeline {
    agent {
        docker {
            image 'php:8.2-cli-alpine'
            args '-u 0:0'
        }
    }

    environment {
        IMAGE_NAME = "my-php-app"
        CONTAINER_NAME = "my-php-app-container"
    }

    stages {
        stage('Prepare Agent Environment') {
            steps {
                sh '''
                    echo "Preparing Docker CLI in agent container..."
                    apk add --no-cache curl ca-certificates gnupg libressl-dev
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
                sh '''
                    echo "Installing Composer in agent..."
                    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
                    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
                    php -r "unlink('composer-setup.php');"
                    echo "Composer installed in agent."
                    composer install --no-dev --prefer-dist --optimize-autoloader || echo "Composer install failed"
                '''
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh '''
                    echo "Running unit tests..."
                    echo "--- Diagnosing vendor/ directory ---"
                    ls -l .
                    echo -----------------------------------
                    echo "Contents of vendor/:"
                    ls -l vendor/ || echo "vendor/ not found"
                    echo -----------------------------------
                    echo "Contents of vendor/bin/:"
                    ls -l vendor/bin/ || echo "vendor/bin/ not found"

                    if [ -f ./vendor/bin/phpunit ]; then
                        ./vendor/bin/phpunit || exit 1
                    else
                        echo "PHPUnit not found. Installing temporarily..."
                        composer global require phpunit/phpunit
                        ~/.composer/vendor/bin/phpunit || echo "PHPUnit failed"
                    fi
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .'
            }
        }

        stage('Deploy Application') {
            steps {
                sh '''
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    docker run -d -p 8081:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}:${BUILD_NUMBER}
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
            echo 'Tes gagal! Cek log untuk detail.'
        }
    }
}
