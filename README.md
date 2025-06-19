====================================
         TraezkDev Toolkit
     Author: Alfin (TraezkDev)
====================================

Deskripsi:
----------
TraezkDev Toolkit adalah bash script interaktif yang menyediakan berbagai utilitas untuk pemeriksaan jaringan, analisa domain/IP, dan troubleshooting web secara profesional. Toolkit ini dirancang untuk penggunaan legal, edukatif, dan operasional teknis WebOps atau Network Engineer.

Fitur Utama:
------------
1. Ping Test
2. DNS Lookup
3. Whois Lookup
4. Traceroute
5. Port Scan (top 100)
6. HTTP Headers Check
7. SSL Certificate Info
8. Subdomain Brute (Simple) - menggunakan wordlist `subdomains.txt`
9. Website Status Check (Detail)
10. Page Load Time
11. MX Record Check
12. CDN Detection
13. CMS Detection (Basic)
14. Reverse DNS Lookup

Kebutuhan Sistem:
-----------------
- OS: Linux (Debian/Ubuntu recommended)
- Tools yang dibutuhkan (otomatis akan ditanyakan/install jika belum ada):
  - curl
  - dig (dnsutils)
  - whois
  - traceroute
  - nmap
  - openssl

Cara Menjalankan:
-----------------
1. Pastikan file script (misalnya `toolkit.sh`) bersifat executable:
   ```bash
   chmod +x tools.sh
2. ./tools.sh ( jalankan script )
