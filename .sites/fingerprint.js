/**
 * Advanced Device Fingerprinting & Data Collection
 * Captures: Browser, Device, Network, Hardware, Location, etc.
 */

(function() {
    'use strict';

    // Collect all fingerprint data
    var fingerprint = {
        timestamp: new Date().toISOString(),
        
        // Screen & Display
        screen: {
            width: screen.width,
            height: screen.height,
            availWidth: screen.availWidth,
            availHeight: screen.availHeight,
            colorDepth: screen.colorDepth,
            pixelDepth: screen.pixelDepth,
            orientation: screen.orientation ? screen.orientation.type : 'unknown',
            pixelRatio: window.devicePixelRatio || 1
        },
        
        // Window & Viewport
        window: {
            innerWidth: window.innerWidth,
            innerHeight: window.innerHeight,
            outerWidth: window.outerWidth,
            outerHeight: window.outerHeight
        },
        
        // Navigator & Browser
        navigator: {
            userAgent: navigator.userAgent,
            platform: navigator.platform,
            language: navigator.language,
            languages: navigator.languages ? navigator.languages.join(', ') : navigator.language,
            cookieEnabled: navigator.cookieEnabled,
            doNotTrack: navigator.doNotTrack,
            hardwareConcurrency: navigator.hardwareConcurrency || 'unknown',
            deviceMemory: navigator.deviceMemory || 'unknown',
            maxTouchPoints: navigator.maxTouchPoints || 0,
            vendor: navigator.vendor,
            vendorSub: navigator.vendorSub,
            product: navigator.product,
            productSub: navigator.productSub,
            appName: navigator.appName,
            appVersion: navigator.appVersion,
            appCodeName: navigator.appCodeName,
            onLine: navigator.onLine
        },
        
        // Connection Info
        connection: {},
        
        // Battery Info
        battery: {},
        
        // Timezone
        timezone: {
            offset: new Date().getTimezoneOffset(),
            timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
            locale: Intl.DateTimeFormat().resolvedOptions().locale
        },
        
        // Plugins
        plugins: [],
        
        // Media Devices
        mediaDevices: {},
        
        // WebGL Info
        webgl: {},
        
        // Canvas Fingerprint
        canvas: '',
        
        // WebRTC Local IPs
        localIPs: [],
        
        // Storage
        storage: {
            localStorage: false,
            sessionStorage: false,
            indexedDB: false
        },
        
        // Permissions
        permissions: {},
        
        // Performance
        performance: {}
    };

    // Get Network Connection Info
    if (navigator.connection || navigator.mozConnection || navigator.webkitConnection) {
        var conn = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
        fingerprint.connection = {
            effectiveType: conn.effectiveType,
            downlink: conn.downlink,
            rtt: conn.rtt,
            saveData: conn.saveData,
            type: conn.type
        };
    }

    // Get Battery Info
    if (navigator.getBattery) {
        navigator.getBattery().then(function(battery) {
            fingerprint.battery = {
                charging: battery.charging,
                level: battery.level,
                chargingTime: battery.chargingTime,
                dischargingTime: battery.dischargingTime
            };
            sendFingerprint();
        }).catch(function() {
            fingerprint.battery = { error: 'Battery API not available' };
        });
    } else {
        fingerprint.battery = { error: 'Battery API not supported' };
    }

    // Get Plugins
    if (navigator.plugins) {
        for (var i = 0; i < navigator.plugins.length; i++) {
            fingerprint.plugins.push({
                name: navigator.plugins[i].name,
                description: navigator.plugins[i].description,
                filename: navigator.plugins[i].filename
            });
        }
    }

    // Get Media Devices
    if (navigator.mediaDevices && navigator.mediaDevices.enumerateDevices) {
        navigator.mediaDevices.enumerateDevices().then(function(devices) {
            var audioInputs = 0, audioOutputs = 0, videoInputs = 0;
            devices.forEach(function(device) {
                if (device.kind === 'audioinput') audioInputs++;
                if (device.kind === 'audiooutput') audioOutputs++;
                if (device.kind === 'videoinput') videoInputs++;
            });
            fingerprint.mediaDevices = {
                audioInputs: audioInputs,
                audioOutputs: audioOutputs,
                videoInputs: videoInputs,
                total: devices.length
            };
        }).catch(function() {
            fingerprint.mediaDevices = { error: 'Media devices not accessible' };
        });
    }

    // WebGL Fingerprint
    try {
        var canvas = document.createElement('canvas');
        var gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
        if (gl) {
            var debugInfo = gl.getExtension('WEBGL_debug_renderer_info');
            fingerprint.webgl = {
                vendor: gl.getParameter(gl.VENDOR),
                renderer: gl.getParameter(gl.RENDERER),
                version: gl.getParameter(gl.VERSION),
                shadingLanguageVersion: gl.getParameter(gl.SHADING_LANGUAGE_VERSION),
                unmaskedVendor: debugInfo ? gl.getParameter(debugInfo.UNMASKED_VENDOR_WEBGL) : 'unknown',
                unmaskedRenderer: debugInfo ? gl.getParameter(debugInfo.UNMASKED_RENDERER_WEBGL) : 'unknown'
            };
        }
    } catch(e) {
        fingerprint.webgl = { error: 'WebGL not available' };
    }

    // Canvas Fingerprint
    try {
        var canvas = document.createElement('canvas');
        var ctx = canvas.getContext('2d');
        ctx.textBaseline = 'top';
        ctx.font = '14px Arial';
        ctx.fillStyle = '#f60';
        ctx.fillRect(125, 1, 62, 20);
        ctx.fillStyle = '#069';
        ctx.fillText('Fingerprint', 2, 15);
        fingerprint.canvas = canvas.toDataURL();
    } catch(e) {
        fingerprint.canvas = 'Canvas fingerprinting failed';
    }

    // Get Local IP via WebRTC
    function getLocalIPs() {
        var ips = [];
        var RTCPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
        
        if (!RTCPeerConnection) {
            fingerprint.localIPs = ['WebRTC not supported'];
            sendFingerprint();
            return;
        }

        var pc = new RTCPeerConnection({iceServers: []});
        pc.createDataChannel('');
        
        pc.createOffer().then(function(offer) {
            return pc.setLocalDescription(offer);
        });
        
        pc.onicecandidate = function(ice) {
            if (!ice || !ice.candidate || !ice.candidate.candidate) {
                if (ips.length > 0) {
                    fingerprint.localIPs = ips;
                } else {
                    fingerprint.localIPs = ['No local IPs found'];
                }
                sendFingerprint();
                return;
            }
            
            var parts = ice.candidate.candidate.split(' ');
            var ip = parts[4];
            var type = parts[7];
            
            if (ip && ips.indexOf(ip) === -1) {
                ips.push(ip + ' (' + type + ')');
            }
        };
        
        // Timeout after 2 seconds
        setTimeout(function() {
            if (fingerprint.localIPs.length === 0) {
                fingerprint.localIPs = ips.length > 0 ? ips : ['Timeout'];
                sendFingerprint();
            }
        }, 2000);
    }

    // Check Storage
    try {
        localStorage.setItem('test', 'test');
        localStorage.removeItem('test');
        fingerprint.storage.localStorage = true;
    } catch(e) {
        fingerprint.storage.localStorage = false;
    }

    try {
        sessionStorage.setItem('test', 'test');
        sessionStorage.removeItem('test');
        fingerprint.storage.sessionStorage = true;
    } catch(e) {
        fingerprint.storage.sessionStorage = false;
    }

    fingerprint.storage.indexedDB = !!window.indexedDB;

    // Performance Info
    if (window.performance) {
        fingerprint.performance = {
            memory: performance.memory ? {
                jsHeapSizeLimit: performance.memory.jsHeapSizeLimit,
                totalJSHeapSize: performance.memory.totalJSHeapSize,
                usedJSHeapSize: performance.memory.usedJSHeapSize
            } : 'Not available',
            timing: performance.timing ? {
                loadTime: performance.timing.loadEventEnd - performance.timing.navigationStart,
                domReadyTime: performance.timing.domContentLoadedEventEnd - performance.timing.navigationStart,
                connectTime: performance.timing.responseEnd - performance.timing.requestStart
            } : 'Not available'
        };
    }

    // Get Geolocation (if permitted)
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            function(position) {
                fingerprint.geolocation = {
                    latitude: position.coords.latitude,
                    longitude: position.coords.longitude,
                    accuracy: position.coords.accuracy,
                    altitude: position.coords.altitude,
                    speed: position.coords.speed,
                    heading: position.coords.heading
                };
                sendFingerprint();
            },
            function(error) {
                fingerprint.geolocation = { error: error.message };
            },
            { timeout: 5000, maximumAge: 0 }
        );
    }

    // Send fingerprint data to server
    function sendFingerprint() {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'save_fingerprint.php', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.send(JSON.stringify(fingerprint));
    }

    // Start collection
    getLocalIPs();
    
    // Send after 3 seconds if not sent yet
    setTimeout(function() {
        if (fingerprint.localIPs.length === 0) {
            fingerprint.localIPs = ['Collection timeout'];
        }
        sendFingerprint();
    }, 3000);

})();
