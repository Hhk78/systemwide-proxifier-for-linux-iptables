#!/bin/bash

# Kullanıcıya soru sor
read -p "iptables'i sıfırlamak istediğinizden emin misiniz? Bu geçerli tüm yapılandırmayı yok eder! iptables-save komutu ile yedeğinizi aldığınızdan emin olunuz. (e/h): " response

# Kullanıcının cevabını kontrol et
if [ "$response" == "e" ]; then
    echo "iptables sıfırlanıyor..."
    sudo iptables -F && sudo iptables -X && sudo iptables -t nat -F && sudo iptables -t nat -X && sudo iptables -t mangle -F && sudo iptables -t mangle -X && sudo iptables -P INPUT ACCEPT && sudo iptables -P FORWARD ACCEPT && sudo iptables -P OUTPUT ACCEPT
    echo "iptables başarıyla sıfırlandı."
elif [ "$response" == "h" ]; then
    echo "İşlem iptal edildi."
else
    echo "Geçersiz cevap. İşlem iptal edildi."
fi
