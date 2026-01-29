<?php
header('Content-Type: application/json');

$p = $_POST['p'] ?? '';

if (empty($p)) {
    echo json_encode(['error' => 'No route received']);
    exit;
}

// A little basic safety
$p = str_replace(['..\\', '../'], '', $p);

// Check availability
$exist = file_exists($p) && is_dir($p);

echo json_encode([
    'exist' => $exist,
    'route' => $p
]);