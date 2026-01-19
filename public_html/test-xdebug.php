<?php
echo "Xdebug test\n";

// Mostrar versión y estado de Xdebug
if (function_exists('xdebug_info')) {
    // Xdebug 3+
    xdebug_info();
} elseif (function_exists('xdebug_get_version')) {
    // Xdebug 2.x
    echo "Xdebug version: " . xdebug_get_version() . "\n";
    echo "Xdebug loaded in PHP " . PHP_VERSION . "\n";
} else {
    echo "Xdebug is not loaded for PHP " . PHP_VERSION . "\n";
}
