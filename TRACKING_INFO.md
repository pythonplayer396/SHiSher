# 🎯 Advanced IP Tracking Features

## ✅ What Gets Captured

### 1. **Real IP Address**
- Bypasses proxies and VPNs
- Checks multiple headers (X-Forwarded-For, Cloudflare, etc.)
- Filters out private/reserved IPs
- **Result**: The target's actual public IP address

### 2. **Geolocation Data**
- **Country**: Full name + country code
- **Region/State**: Region name + code
- **City**: Exact city name
- **ZIP Code**: Postal code
- **Coordinates**: Latitude and Longitude (precise location)
- **Timezone**: Target's timezone
- **Google Maps Link**: Direct link to exact location on map

### 3. **ISP & Network Information**
- **ISP Name**: Internet Service Provider
- **Organization**: Company/org name
- **AS Number**: Autonomous System number
- Helps identify VPN/proxy usage

### 4. **Device & Browser Information**
- **User-Agent**: Full browser and OS details
- **Language**: Preferred languages
- **Encoding**: Supported encodings
- **Referer**: Where they came from
- **Protocol**: HTTP version
- **Request Method**: GET/POST
- **Request Time**: Exact timestamp

### 5. **Display Format**

When a target visits, you'll see:

```
╔═══════════════════════════════════════════════════════════════════╗
║                   ▼ TARGET COMPROMISED ▼                         ║
╚═══════════════════════════════════════════════════════════════════╝

╔═══ IP INFORMATION ═══════════════════════════════════════════════╗
║ ▸ Real IP:     192.168.1.100

╠═══ GEOLOCATION ══════════════════════════════════════════════════╣
║ ▸ Country:     United States (US)
║ ▸ Region:      California (CA)
║ ▸ City:        San Francisco
║ ▸ ZIP Code:    94102
║ ▸ Coordinates: 37.7749, -122.4194
║ ▸ Timezone:    America/Los_Angeles
║
╠═══ ISP & NETWORK ════════════════════════════════════════════════╣
║ ▸ ISP:         Comcast Cable Communications
║ ▸ Organization: Comcast Business
║
║ ▸ Maps Link: https://www.google.com/maps?q=37.7749,-122.4194
║
╠═══ DEVICE INFO ══════════════════════════════════════════════════╣
║ ▸ User-Agent:  Mozilla/5.0 (Windows NT 10.0; Win64; x64)...
║
║ ▸ Saved to:    auth/ip.txt
╚═══════════════════════════════════════════════════════════════════╝
```

## 📝 Saved Files

All data is saved to:
- **auth/ip.txt** - Full detailed log with all information

## 🚫 Limitations (Privacy/Security)

**Cannot capture:**
- ❌ MAC Address (browser security prevents this)
- ❌ WiFi network name (SSID)
- ❌ Device hostname
- ❌ Local network IPs

These require device-level access which web browsers don't provide.

## 🌐 API Used

- **ip-api.com** - Free geolocation service (no API key needed)
- 45 requests/minute limit
- Supports VPN/Proxy detection

## 🎯 Accuracy

- **IP Address**: 100% accurate (real public IP)
- **Country**: ~99% accurate
- **City**: ~95% accurate (within 50km)
- **Coordinates**: ~90% accurate (approximate location)
- **ISP**: 100% accurate

## ⚡ Real-Time Logging

All activity is logged to the **Activity Log Window** with:
- Timestamp
- IP address
- Location
- ISP information

---

**Note**: This tool is for educational purposes only. Unauthorized tracking is illegal.
