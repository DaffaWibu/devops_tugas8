pipeline {
    agent {
        // Menggunakan Docker image PHP sebagai agen untuk menjalankan langkah-langkah pipeline
        // Ini memastikan lingkungan yang konsisten dengan PHP, Composer, dan ekstensi yang dibutuhkan
        docker {
            image 'php:8.2-fpm-alpine' // Atau versi PHP yang Anda inginkan
            args '-u 0:0' // Untuk menghindari masalah permission jika ada, opsional
        }
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Mengambil kode dari repositori GitHub
                // Anda mungkin perlu menginstal plugin Git di Jenkins jika belum ada
                git 'https://github.com/DaffaWibu/devops_tugas8.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                // Menginstal Composer dependencies di dalam container Docker
                // Memastikan Composer terinstal di dalam image 'php:8.2-fpm-alpine'
                sh 'apk add --no-cache git' // Pastikan git ada di dalam container untuk composer install
                sh 'docker-php-ext-install pdo pdo_mysql && docker-php-ext-enable pdo_mysql' // Contoh instalasi ekstensi jika dibutuhkan
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
                // Menjalankan unit test menggunakan Composer script "test"
                // Asumsi PHPUnit sudah terinstal sebagai dev dependency
                sh 'composer run test'
            }
            post {
                success {
                    echo 'All tests passed successfully!'
                }
                failure {
                    echo 'Some tests failed. Check logs for details.'
                }
            }
        }

        stage('Build Docker Image for Deployment') {
            steps {
                // Membangun Docker image lokal dari aplikasi PHP
                // Ini akan menciptakan image yang siap untuk di-deploy
                script {
                    def appImage = docker.build("my-php-app:${env.BUILD_NUMBER}", ".")
                    appImage.push() // Opsional: Push ke Docker Hub jika Anda punya akun dan terkonfigurasi
                    echo "Docker image 'my-php-app:${env.BUILD_NUMBER}' built and pushed (if configured)."
                }
            }
        }

        stage('Deploy Application (Local Docker Container)') {
            steps {
                // Menjalankan aplikasi dari Docker image yang baru dibuat
                script {
                    // Hentikan dan hapus container lama jika ada
                    sh 'docker stop my-php-app-container || true'
                    sh 'docker rm my-php-app-container || true'

                    // Jalankan container baru dari image yang baru di-build
                    sh 'docker run -d -p 80:80 --name my-php-app-container my-php-app:' + env.BUILD_NUMBER
                    echo "Application deployed to http://<your-jenkins-host-ip>:80 (or port you mapped)."
                }
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