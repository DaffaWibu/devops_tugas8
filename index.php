<?php
require 'vendor/autoload.php';

// Contoh sederhana: menggunakan Composer untuk autoloading
// Anda bisa menambahkan logika PHP lain di sini
echo "<h1>Hello from Simple PHP App!</h1>";
echo "<p>This app is running via a Jenkins Pipeline.</p>";

// Contoh fungsi sederhana untuk testing
function add($a, $b) {
    return $a + $b;
}

echo "<p>2 + 3 = " . add(2, 3) . "</p>";
?>