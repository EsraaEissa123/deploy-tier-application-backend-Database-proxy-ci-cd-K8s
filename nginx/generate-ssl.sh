#!/bin/sh
# توليد مفتاح خاص وشهادة موقعة ذاتياً (self-signed certificate)

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout nginx/nginx-selfsigned.key \
    -out nginx/nginx-selfsigned.crt \
    -subj "/C=JO/ST=Amman/L=Amman/O=BlogAPI/OU=IT/CN=localhost"