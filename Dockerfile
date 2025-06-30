# Gunakan image PHP 8.2 dengan Apache sebagai base image.
# Ini menyediakan lingkungan PHP dan server web Apache yang sudah terkonfigurasi.
FROM php:8.2-apache

# Atur direktori kerja default di dalam kontainer.
# Semua perintah setelah ini (COPY, RUN) akan dieksekusi relatif terhadap direktori ini.
WORKDIR /var/www/html

# Salin file composer (Composer CLI) dari image 'composer:latest' ke dalam kontainer.
# Ini adalah praktik multi-stage build yang efisien untuk mendapatkan Composer.
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Salin seluruh isi direktori aplikasi PHP Anda (di host) ke direktori kerja di dalam kontainer.
# Pastikan Dockerfile ini berada di root direktori proyek PHP Anda.
COPY . /var/www/html

# Instal semua dependensi PHP yang didefinisikan dalam composer.json.
# --no-dev: Hanya instal dependensi produksi.
# --optimize-autoloader: Mengoptimalkan autoloader Composer untuk kinerja yang lebih baik.
RUN composer install --no-dev --optimize-autoloader

# Buka port 80 di dalam kontainer.
# Ini memberi tahu Docker bahwa kontainer ini akan mendengarkan koneksi pada port 80.
EXPOSE 80

# Tentukan perintah yang akan dijalankan saat kontainer dimulai.
# "apache2-foreground" adalah cara standar untuk menjalankan Apache di foreground
# sehingga kontainer tetap berjalan.
CMD ["apache2-foreground"]