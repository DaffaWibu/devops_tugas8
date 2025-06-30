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
        # Menentukan port untuk aplikasi yang di-deploy (misal: 8081 di host ke 80 di container)
        APP_PORT = "8081" 
    }

    stages {
        stage('Prepare Agent Environment') {
            steps {
                sh '''
                    echo "Preparing Docker CLI in agent container..."
                    # Instal paket yang dibutuhkan untuk Docker CLI (sesuai distro Alpine)
                    apk add --no-cache \
                        curl \
                        git \
                        zip \
                        unzip \
                        ca-certificates \
                        gnupg \
                        libressl-dev # libressl-dev atau openssl-dev mungkin dibutuhkan untuk curl/gpg

                    # Unduh dan instal Docker CLI binary
                    # Menggunakan versi yang lebih baru dan stabil yang bisa diunduh
                    # Perhatikan: URL ini bisa berubah, jika gagal, cari URL terbaru dari Docker
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
                    # Composer sudah diinstal di tahap 'Prepare Agent Environment'
                    # Pastikan Composer bisa diakses
                    chmod +x /usr/local/bin/composer || true # Pastikan executable
                    
                    composer install --no-dev --prefer-dist --optimize-autoloader
                '''
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh '''
                    # Menjalankan unit test menggunakan skrip 'test' dari composer.json
                    # Ini lebih andal karena composer tahu di mana PHPUnit berada.
                    composer run test
                '''
            }
            post {
                success {
                    echo 'All tests passed successfully!'
                }
                failure {
                    echo 'Some tests failed. Check logs for details.'
                    // exit 1 // Uncomment ini jika Anda ingin build gagal jika test gagal
                }
            }
        }

        stage('Build Docker Image') {
            // Tahap ini akan berjalan di agen Docker yang sama (php:8.2-cli-alpine)
            // yang sudah memiliki Docker CLI dari tahap 'Prepare Agent Environment'.
            steps {
                sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
            }
        }

        stage('Deploy Application') {
            // Tahap ini juga akan berjalan di agen Docker yang sama.
            steps {
                sh '''
                    # Hentikan dan hapus container lama jika ada
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true

                    # Jalankan container baru dari image yang baru di-build
                    # Mapping port: ${APP_PORT} di host ke port 80 di container
                    docker run -d -p ${APP_PORT}:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}:${BUILD_NUMBER}
                    echo "Application deployed to http://<your-jenkins-host-ip>:${APP_PORT}"
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