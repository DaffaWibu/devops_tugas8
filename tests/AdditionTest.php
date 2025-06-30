<?php
use PHPUnit\Framework\TestCase;

// Pastikan fungsi add() di-load (melalui autoloading dari composer.json)
require_once __DIR__ . '/../index.php'; // Atau pastikan autoloading Composer berfungsi

class AdditionTest extends TestCase
{
    public function testAddFunction()
    {
        $this->assertEquals(5, add(2, 3));
        $this->assertEquals(0, add(-1, 1));
        $this->assertEquals(10, add(7, 3));
    }
}
?>