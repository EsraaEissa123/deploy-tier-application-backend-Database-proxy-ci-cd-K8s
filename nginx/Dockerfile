FROM nginx:alpine

# إنشاء مجلد الشهادات
RUN mkdir /etc/nginx/certs/

# نسخ ملف إعداد Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# نسخ الشهادة والمفتاح الذين تم توليدهما بواسطة generate-ssl.sh
# ستحتاج إلى تشغيل generate-ssl.sh قبل بناء هذه الصورة
COPY nginx-selfsigned.crt /etc/nginx/certs/
COPY nginx-selfsigned.key /etc/nginx/certs/