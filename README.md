# Eurotunnel
This simple terraform script allows you to automatically deploy AWS EC2 instance and provision ready-to-use IPsec VPN along with Telegram MTProto proxy.
IPsec VPN is based on strongSwan. 
Default IPsec configuration within this script is suitable for two cases:
- site-to-site VPN
- remote access VPN
Official Docker image is used to run Telegram Messenger MTProto proxy.
![Alt text](images/scheme.png?raw=true "Deployed scheme")
