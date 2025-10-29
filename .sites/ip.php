<?php
/**
 * Advanced IP Tracker with Geolocation & Device Fingerprinting
 * Captures: Real IP, Location, Device Info, ISP, etc.
 */

// Error handling - prevent 500 errors
error_reporting(0);
ini_set('display_errors', 0);

// ============================================
// REAL IP DETECTION (Bypass Proxies/VPNs)
// ============================================
function getRealIP() {
    $ip_keys = array(
        'HTTP_CLIENT_IP',
        'HTTP_X_FORWARDED_FOR',
        'HTTP_X_FORWARDED',
        'HTTP_X_CLUSTER_CLIENT_IP',
        'HTTP_FORWARDED_FOR',
        'HTTP_FORWARDED',
        'HTTP_CF_CONNECTING_IP', // Cloudflare
        'HTTP_X_REAL_IP',
        'REMOTE_ADDR'
    );
    
    foreach ($ip_keys as $key) {
        if (array_key_exists($key, $_SERVER) === true) {
            foreach (explode(',', $_SERVER[$key]) as $ip) {
                $ip = trim($ip);
                if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE) !== false) {
                    return $ip;
                }
            }
        }
    }
    return $_SERVER['REMOTE_ADDR'];
}

$ipaddr = getRealIP();

// ============================================
// GET GEOLOCATION DATA (FREE API)
// ============================================
function getGeolocation($ip) {
    $geo_data = array();
    
    // Using ip-api.com (free, no key required)
    $api_url = "http://ip-api.com/json/{$ip}?fields=status,message,country,countryCode,region,regionName,city,zip,lat,lon,timezone,isp,org,as,query";
    
    // Check if curl is available
    if (function_exists('curl_init')) {
        try {
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $api_url);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
            curl_setopt($ch, CURLOPT_TIMEOUT, 3); // Reduced timeout
            curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 2);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
            curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
            $response = @curl_exec($ch);
            curl_close($ch);
            
            if ($response) {
                $data = @json_decode($response, true);
                if ($data && isset($data['status']) && $data['status'] == 'success') {
                    $geo_data = $data;
                }
            }
        } catch (Exception $e) {
            // Silently fail
        }
    } else {
        // Fallback to file_get_contents if curl not available
        try {
            $context = stream_context_create(array(
                'http' => array(
                    'timeout' => 3,
                    'ignore_errors' => true
                )
            ));
            $response = @file_get_contents($api_url, false, $context);
            if ($response) {
                $data = @json_decode($response, true);
                if ($data && isset($data['status']) && $data['status'] == 'success') {
                    $geo_data = $data;
                }
            }
        } catch (Exception $e) {
            // Silently fail
        }
    }
    
    return $geo_data;
}

$geo = getGeolocation($ipaddr);

// ============================================
// COLLECT DEVICE & BROWSER INFO
// ============================================
$user_agent = $_SERVER['HTTP_USER_AGENT'];
$accept_lang = isset($_SERVER['HTTP_ACCEPT_LANGUAGE']) ? $_SERVER['HTTP_ACCEPT_LANGUAGE'] : 'Unknown';
$accept_encoding = isset($_SERVER['HTTP_ACCEPT_ENCODING']) ? $_SERVER['HTTP_ACCEPT_ENCODING'] : 'Unknown';
$referer = isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : 'Direct';
$request_uri = isset($_SERVER['REQUEST_URI']) ? $_SERVER['REQUEST_URI'] : 'Unknown';
$server_protocol = isset($_SERVER['SERVER_PROTOCOL']) ? $_SERVER['SERVER_PROTOCOL'] : 'Unknown';

// Additional headers
$headers = array();
foreach ($_SERVER as $key => $value) {
    if (substr($key, 0, 5) == 'HTTP_') {
        $headers[str_replace('HTTP_', '', $key)] = $value;
    }
}

// ============================================
// BUILD DETAILED LOG OUTPUT
// ============================================
$timestamp = date('[Y-m-d H:i:s]');
$separator = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";

$log_data = "\n{$separator}\n";
$log_data .= "{$timestamp} ▼ NEW TARGET DETECTED ▼\n";
$log_data .= "{$separator}\n\n";

// IP Information
$log_data .= "╔═══ IP INFORMATION ═══╗\n";
$log_data .= "  Real IP Address: {$ipaddr}\n";

if (!empty($geo)) {
    $log_data .= "\n╔═══ GEOLOCATION DATA ═══╗\n";
    $log_data .= "  Country: " . ($geo['country'] ?? 'Unknown') . " (" . ($geo['countryCode'] ?? '') . ")\n";
    $log_data .= "  Region: " . ($geo['regionName'] ?? 'Unknown') . " (" . ($geo['region'] ?? '') . ")\n";
    $log_data .= "  City: " . ($geo['city'] ?? 'Unknown') . "\n";
    $log_data .= "  ZIP Code: " . ($geo['zip'] ?? 'Unknown') . "\n";
    $log_data .= "  Coordinates: " . ($geo['lat'] ?? '0') . ", " . ($geo['lon'] ?? '0') . "\n";
    $log_data .= "  Timezone: " . ($geo['timezone'] ?? 'Unknown') . "\n";
    $log_data .= "  ISP: " . ($geo['isp'] ?? 'Unknown') . "\n";
    $log_data .= "  Organization: " . ($geo['org'] ?? 'Unknown') . "\n";
    $log_data .= "  AS Number: " . ($geo['as'] ?? 'Unknown') . "\n";
    
    // Google Maps Link
    if (isset($geo['lat']) && isset($geo['lon'])) {
        $log_data .= "  Maps: https://www.google.com/maps?q={$geo['lat']},{$geo['lon']}\n";
    }
}

// Device & Browser Information
$log_data .= "\n╔═══ DEVICE & BROWSER ═══╗\n";
$log_data .= "  User-Agent: {$user_agent}\n";
$log_data .= "  Language: {$accept_lang}\n";
$log_data .= "  Encoding: {$accept_encoding}\n";
$log_data .= "  Referer: {$referer}\n";
$log_data .= "  Protocol: {$server_protocol}\n";

// Request Details
$log_data .= "\n╔═══ REQUEST DETAILS ═══╗\n";
$log_data .= "  Request URI: {$request_uri}\n";
$log_data .= "  Request Method: " . $_SERVER['REQUEST_METHOD'] . "\n";
$log_data .= "  Request Time: " . date('Y-m-d H:i:s', $_SERVER['REQUEST_TIME']) . "\n";

$log_data .= "\n{$separator}\n\n";

// ============================================
// SAVE TO FILE
// ============================================
try {
    $fp = @fopen('ip.txt', 'a');
    if ($fp) {
        @fwrite($fp, $log_data);
        @fclose($fp);
    } else {
        // Try alternative method
        @file_put_contents('ip.txt', $log_data, FILE_APPEND);
    }
} catch (Exception $e) {
    // Silently fail - don't break the page
}

// Don't output anything - this file is included in pages
// The page needs to continue rendering HTML/JavaScript
?>