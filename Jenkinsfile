// Definisi pipeline Jenkins
pipeline {
    // Menentukan agen Docker untuk menjalankan seluruh pipeline.
    // Menggunakan 'php:8.2-cli-alpine' yang lebih ringan dan cocok untuk CLI.
    agent {
        docker {
            image 'php:8.2-cli-alpine'
            args '-u 0:0' // Menjalankan sebagai user root di dalam container untuk izin instalasi
        }
    }

    // Mendefinisikan variabel lingkungan yang akan digunakan di seluruh pipeline.
    environment {
        IMAGE_NAME = "my-php-app"
        CONTAINER_NAME = "my-php-app-container"
        // Menentukan port untuk aplikasi yang di-deploy (misal: 8081 di host ke 80 di container)
        APP_PORT = "8081" 
    }

    // Definisi tahap-tahap (stages) pipeline
    stages {
        // Tahap 1: Menyiapkan lingkungan agen dengan menginstal Docker CLI.
        // Ini penting karena agen 'php:8.2-cli-alpine' tidak secara default punya Docker CLI.
        stage('Prepare Agent Environment') {
            steps {
                sh '''
                    echo "Preparing Docker CLI in agent container..."
                    # Memperbarui daftar paket dan menginstal paket dasar yang dibutuhkan
                    apk add --no-cache \
                        curl \
                        git \
                        zip \
                        unzip \
                        ca-certificates \
                        gnupg \
                        libressl-dev # libressl-dev atau openssl-dev mungkin dibutuhkan untuk curl/gpg
                    
                    # Mengunduh dan menginstal Docker CLI binary secara statis
                    # URL ini untuk Docker CLI versi 26.1.3 (stable) untuk Linux x86_64
                    # Jika ada error 403 atau not found, URL ini mungkin perlu diperbarui
                    curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-26.1.3.tgz | tar -xz -C /usr/bin --strip-components=1

                    echo "Docker CLI installed in agent container."
                '''
            }
        }

        // Tahap 2: Mengkloning repositori kode dari GitHub.
        stage('Clone Repository') {
            steps {
                // Mengambil kode dari branch 'main' di repositori GitHub Anda.
                git branch: 'main', url: 'https://github.com/DaffaWibu/devops_tugas8.git'
            }
        }

        // Tahap 3: Menginstal dependensi PHP menggunakan Composer.
        stage('Install Dependencies') {
            steps {
                sh '''
                    # Memastikan Composer bisa diakses (chmod +x untuk executable)
                    chmod +x /usr/local/bin/composer || true 
                    
                    # Menjalankan Composer untuk menginstal dependensi.
                    # --no-dev: Hanya dependensi produksi.
                    # --prefer-dist: Mengunduh dari distribusi.
                    # --optimize-autoloader: Mengoptimalkan autoloading.
                    composer install --no-dev --prefer-dist --optimize-autoloader
                '''
            }
        }

        // Tahap 4: Menjalankan unit test aplikasi.
        stage('Run Unit Tests') {
            steps {
                // Menjalankan unit test menggunakan skrip 'test' yang didefinisikan di composer.json.
                // Ini adalah cara paling andal untuk menjalankan PHPUnit melalui Composer.
                sh 'composer run test'
            }
            // Blok post untuk tindakan setelah tahap ini selesai.
            post {
                success {
                    echo 'All tests passed successfully!'
                }
                failure {
                    echo 'Tes gagal! Cek log untuk detail.'
                    // exit 1 // Anda bisa mengaktifkan ini jika ingin build langsung gagal jika tes gagal
                }
            }
        }

        // Tahap 5: Membangun Docker Image dari aplikasi PHP.
        // Tahap ini akan berjalan di agen Docker yang sama (php:8.2-cli-alpine)
        // yang sudah memiliki Docker CLI dari tahap 'Prepare Agent Environment'.
        stage('Build Docker Image') {
            steps {
                // Membangun Docker Image menggunakan Dockerfile di direktori saat ini.
                // Nama Image akan menjadi "my-php-app:BUILD_NUMBER".
                sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
            }
        }

        // Tahap 6: Mendeploy aplikasi sebagai kontainer Docker lokal.
        // Tahap ini juga akan berjalan di agen Docker yang sama.
        stage('Deploy Application') {
            steps {
                sh '''
                    echo "Deploying application..."
                    # Hentikan kontainer lama jika ada dan hapus
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true

                    # Jalankan kontainer baru dari Image yang baru di-build.
                    # Memetakan port APP_PORT (dari host) ke port 80 (di kontainer).
                    docker run -d -p ${APP_PORT}:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}:${BUILD_NUMBER}
                    echo "Application deployed. Access at http://<your-jenkins-host-ip>:${APP_PORT}"
                '''
            }
        }
    }

    // Blok post untuk tindakan setelah seluruh pipeline selesai.
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