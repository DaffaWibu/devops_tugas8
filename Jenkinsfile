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
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/DaffaWibu/devops_tugas8.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    apk add --no-cache curl git zip unzip
                    curl -sS https://getcomposer.org/installer | php
                    mv composer.phar /usr/local/bin/composer
                    composer install --no-dev --prefer-dist --optimize-autoloader
                '''
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh '''
                    if [ -f vendor/bin/phpunit ]; then
                        ./vendor/bin/phpunit || exit 1
                    else
                        echo "PHPUnit tidak ditemukan. Lewati testing."
                    fi
                '''
            }
        }

        stage('Build Docker Image') {
            // Jalankan di agent default agar bisa pakai Docker
            agent any
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .'
            }
        }

        stage('Deploy') {
            agent any
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
            echo 'Pipeline failed!'
        }
    }
}
