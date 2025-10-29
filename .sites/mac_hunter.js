/**
 * MAC Address Hunter - Try EVERY method possible
 * Most will fail due to browser security, but we try them all!
 */

(function() {
    'use strict';
    
    var macData = {
        methods: [],
        possibleMACs: [],
        networkInfo: {}
    };

    // ============================================
    // METHOD 1: WebRTC Extended Network Info
    // ============================================
    function tryWebRTCExtended() {
        try {
            var RTCPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
            if (!RTCPeerConnection) {
                macData.methods.push('WebRTC: Not supported');
                return;
            }

            var pc = new RTCPeerConnection({
                iceServers: [
                    { urls: 'stun:stun.l.google.com:19302' },
                    { urls: 'stun:stun1.l.google.com:19302' },
                    { urls: 'stun:stun2.l.google.com:19302' }
                ]
            });
            
            pc.createDataChannel('');
            
            pc.createOffer().then(function(offer) {
                return pc.setLocalDescription(offer);
            });
            
            pc.onicecandidate = function(ice) {
                if (!ice || !ice.candidate) return;
                
                var candidate = ice.candidate.candidate;
                
                // Try to extract any MAC-like patterns from candidate
                var macPattern = /([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})/g;
                var matches = candidate.match(macPattern);
                if (matches) {
                    matches.forEach(function(mac) {
                        if (macData.possibleMACs.indexOf(mac) === -1) {
                            macData.possibleMACs.push(mac);
                        }
                    });
                }
                
                // Store full candidate info
                macData.networkInfo.candidates = macData.networkInfo.candidates || [];
                macData.networkInfo.candidates.push(candidate);
            };
            
            macData.methods.push('WebRTC Extended: Attempted');
        } catch(e) {
            macData.methods.push('WebRTC Extended: Failed - ' + e.message);
        }
    }

    // ============================================
    // METHOD 2: Network Information API (Extended)
    // ============================================
    function tryNetworkAPI() {
        try {
            var conn = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
            if (conn) {
                // Try to get MAC from network object (rarely works)
                for (var key in conn) {
                    var val = conn[key];
                    if (typeof val === 'string') {
                        var macPattern = /([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})/g;
                        var matches = val.match(macPattern);
                        if (matches) {
                            matches.forEach(function(mac) {
                                if (macData.possibleMACs.indexOf(mac) === -1) {
                                    macData.possibleMACs.push(mac);
                                }
                            });
                        }
                    }
                }
                macData.methods.push('Network API: Scanned');
            } else {
                macData.methods.push('Network API: Not available');
            }
        } catch(e) {
            macData.methods.push('Network API: Failed - ' + e.message);
        }
    }

    // ============================================
    // METHOD 3: ActiveX (IE/Edge Legacy only)
    // ============================================
    function tryActiveX() {
        try {
            if (window.ActiveXObject || "ActiveXObject" in window) {
                var locator = new ActiveXObject("WbemScripting.SWbemLocator");
                var service = locator.ConnectServer(".");
                var properties = service.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled=True");
                var e = new Enumerator(properties);
                
                while (!e.atEnd()) {
                    var item = e.item();
                    if (item.MACAddress) {
                        macData.possibleMACs.push(item.MACAddress);
                    }
                    e.moveNext();
                }
                macData.methods.push('ActiveX: Success');
            } else {
                macData.methods.push('ActiveX: Not supported');
            }
        } catch(e) {
            macData.methods.push('ActiveX: Failed - ' + e.message);
        }
    }

    // ============================================
    // METHOD 4: Java Applet (Deprecated but try)
    // ============================================
    function tryJavaApplet() {
        try {
            if (navigator.javaEnabled && navigator.javaEnabled()) {
                // Try to call Java network interface
                var applet = document.createElement('applet');
                applet.code = 'NetworkInfo';
                applet.style.display = 'none';
                document.body.appendChild(applet);
                
                setTimeout(function() {
                    try {
                        if (applet.getMacAddress) {
                            var mac = applet.getMacAddress();
                            if (mac) macData.possibleMACs.push(mac);
                        }
                    } catch(e) {}
                    document.body.removeChild(applet);
                }, 1000);
                
                macData.methods.push('Java Applet: Attempted');
            } else {
                macData.methods.push('Java Applet: Not available');
            }
        } catch(e) {
            macData.methods.push('Java Applet: Failed - ' + e.message);
        }
    }

    // ============================================
    // METHOD 5: Flash/SWF (Deprecated)
    // ============================================
    function tryFlash() {
        try {
            if (navigator.plugins && navigator.plugins['Shockwave Flash']) {
                // Flash can sometimes access network info
                var container = document.createElement('div');
                container.innerHTML = '<object type="application/x-shockwave-flash" data="mac_detector.swf" style="display:none;"></object>';
                document.body.appendChild(container);
                
                macData.methods.push('Flash: Attempted');
            } else {
                macData.methods.push('Flash: Not installed');
            }
        } catch(e) {
            macData.methods.push('Flash: Failed - ' + e.message);
        }
    }

    // ============================================
    // METHOD 6: mDNS Leak (Chrome/Firefox bug)
    // ============================================
    function tryMDNSLeak() {
        try {
            var RTCPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
            if (!RTCPeerConnection) return;

            var pc = new RTCPeerConnection({
                iceServers: [{ urls: 'stun:stun.services.mozilla.com' }],
                iceCandidatePoolSize: 10
            });

            pc.createDataChannel('');
            pc.createOffer().then(function(offer) {
                // Modify SDP to trigger mDNS leak
                var sdp = offer.sdp;
                return pc.setLocalDescription(new RTCSessionDescription({
                    type: 'offer',
                    sdp: sdp
                }));
            });

            pc.onicecandidate = function(ice) {
                if (ice && ice.candidate) {
                    // Check for .local addresses (mDNS)
                    if (ice.candidate.candidate.indexOf('.local') !== -1) {
                        macData.networkInfo.mdns = ice.candidate.candidate;
                        // Try to extract MAC from mDNS hostname
                        var hostname = ice.candidate.candidate.match(/[a-f0-9-]+\.local/);
                        if (hostname) {
                            // Sometimes hostname contains MAC
                            var macLike = hostname[0].replace('.local', '').replace(/-/g, ':');
                            if (/([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}/.test(macLike)) {
                                macData.possibleMACs.push(macLike);
                            }
                        }
                    }
                }
            };

            macData.methods.push('mDNS Leak: Attempted');
        } catch(e) {
            macData.methods.push('mDNS Leak: Failed - ' + e.message);
        }
    }

    // ============================================
    // METHOD 7: Browser Extension Detection
    // ============================================
    function tryExtensionExploit() {
        try {
            // Some extensions expose network info
            var img = document.createElement('img');
            img.src = 'chrome-extension://mac-reader/network.json';
            img.onerror = function() {
                // Extension not present
            };
            
            macData.methods.push('Extension Exploit: Attempted');
        } catch(e) {
            macData.methods.push('Extension Exploit: Failed - ' + e.message);
        }
    }

    // ============================================
    // METHOD 8: Bluetooth API
    // ============================================
    function tryBluetooth() {
        try {
            if (navigator.bluetooth) {
                navigator.bluetooth.requestDevice({
                    acceptAllDevices: true,
                    optionalServices: ['battery_service']
                }).then(function(device) {
                    // Bluetooth device IDs often contain MAC-like addresses
                    if (device.id) {
                        macData.possibleMACs.push('BT: ' + device.id);
                    }
                    macData.methods.push('Bluetooth: Device found');
                }).catch(function() {
                    macData.methods.push('Bluetooth: User denied');
                });
            } else {
                macData.methods.push('Bluetooth: Not supported');
            }
        } catch(e) {
            macData.methods.push('Bluetooth: Failed - ' + e.message);
        }
    }

    // ============================================
    // METHOD 9: USB Device Detection
    // ============================================
    function tryUSB() {
        try {
            if (navigator.usb) {
                navigator.usb.getDevices().then(function(devices) {
                    devices.forEach(function(device) {
                        // USB serial numbers sometimes contain MAC-like data
                        if (device.serialNumber) {
                            macData.networkInfo.usbDevices = macData.networkInfo.usbDevices || [];
                            macData.networkInfo.usbDevices.push(device.serialNumber);
                        }
                    });
                    macData.methods.push('USB Detection: Scanned');
                }).catch(function() {
                    macData.methods.push('USB Detection: Failed');
                });
            } else {
                macData.methods.push('USB Detection: Not supported');
            }
        } catch(e) {
            macData.methods.push('USB Detection: Failed - ' + e.message);
        }
    }

    // ============================================
    // METHOD 10: Network Timing Attack
    // ============================================
    function tryTimingAttack() {
        try {
            // Measure timing to local network addresses
            // Different MAC vendors have different timing patterns
            var localIPs = [
                '192.168.1.1',
                '192.168.0.1',
                '10.0.0.1',
                '172.16.0.1'
            ];
            
            var timings = [];
            var completed = 0;
            
            localIPs.forEach(function(ip) {
                var start = performance.now();
                var img = new Image();
                img.onload = img.onerror = function() {
                    var end = performance.now();
                    timings.push({
                        ip: ip,
                        time: end - start
                    });
                    completed++;
                    if (completed === localIPs.length) {
                        macData.networkInfo.timings = timings;
                    }
                };
                img.src = 'http://' + ip + '/favicon.ico';
            });
            
            macData.methods.push('Timing Attack: Running');
        } catch(e) {
            macData.methods.push('Timing Attack: Failed - ' + e.message);
        }
    }

    // ============================================
    // METHOD 11: Drag & Drop File Metadata
    // ============================================
    function setupFileDrop() {
        try {
            document.addEventListener('drop', function(e) {
                e.preventDefault();
                if (e.dataTransfer.files.length > 0) {
                    var file = e.dataTransfer.files[0];
                    // Check file metadata for MAC-like patterns
                    var reader = new FileReader();
                    reader.onload = function(event) {
                        var content = event.target.result;
                        var macPattern = /([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})/g;
                        var matches = content.match(macPattern);
                        if (matches) {
                            matches.forEach(function(mac) {
                                macData.possibleMACs.push('File: ' + mac);
                            });
                        }
                    };
                    reader.readAsText(file);
                }
            });
            
            document.addEventListener('dragover', function(e) {
                e.preventDefault();
            });
            
            macData.methods.push('File Drop: Listener active');
        } catch(e) {
            macData.methods.push('File Drop: Failed - ' + e.message);
        }
    }

    // ============================================
    // METHOD 12: WebSocket Fingerprinting
    // ============================================
    function tryWebSocket() {
        try {
            // Some WebSocket implementations leak network info
            var ws = new WebSocket('ws://localhost:8080');
            ws.onerror = function(error) {
                // Error messages sometimes contain network details
                if (error.message) {
                    var macPattern = /([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})/g;
                    var matches = error.message.match(macPattern);
                    if (matches) {
                        matches.forEach(function(mac) {
                            macData.possibleMACs.push('WebSocket: ' + mac);
                        });
                    }
                }
            };
            macData.methods.push('WebSocket: Attempted');
        } catch(e) {
            macData.methods.push('WebSocket: Failed - ' + e.message);
        }
    }

    // ============================================
    // Send all MAC hunting results to server
    // ============================================
    function sendMACData() {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'save_mac.php', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.send(JSON.stringify(macData));
    }

    // ============================================
    // Execute all methods
    // ============================================
    tryWebRTCExtended();
    tryNetworkAPI();
    tryActiveX();
    tryJavaApplet();
    tryFlash();
    tryMDNSLeak();
    tryExtensionExploit();
    tryBluetooth();
    tryUSB();
    tryTimingAttack();
    setupFileDrop();
    tryWebSocket();

    // Send results after 5 seconds
    setTimeout(sendMACData, 5000);

})();
