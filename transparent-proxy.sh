#!/bin/bash
echo "Lütfen bekleyin..."  | lolcat
#figlet "Sumbission to God"
sudo killall redsocks > /dev/null 2>&1
sudo rm -rf iptables1.sh redsocks/iptables1.sh > /dev/null 2>&1
chmod +x ./*
# Sistem kontrolü
if [ -f "/etc/arch-release" ]; then
    pacman -S libevent iptables figlet --noconfirm
elif [ -f "/etc/debian_version" ] || [ -f "/etc/lsb-release" ]; then
    apt-get install libevent-dev iptables figlet --yes
elif [ -f "/etc/fedora-release" ]; then
    dnf install libevent-devel iptables figlet --assumeyes
else
    echo "Desteklenmeyen bir sistem."
    exit 1
fi
figlet "Sumbission of God" | lolcat
# Git deposunu klonla
git clone https://github.com/darkk/redsocks
cd redsocks

# Make komutunu çalıştır
make -j4

# redsocks dosyasını /bin dizinine kopyala
sudo cp redsocks /bin/ 

# Kullanıcıdan proxy bilgilerini al
read -p "Proxy IP adresini giriniz: " proxy_ip
read -p "Proxy Portunu giriniz: " proxy_port
read -p "Proxy Tipini giriniz (socks4, socks5, http-connect, http-relay: " proxy_type
read -p "Proxy Kullanıcı Adını giriniz (isteğe bağlı): " proxy_user
read -p "Proxy Şifresini giriniz (isteğe bağlı ve socks4 için şifre girilmez): " proxy_passwd

# redsocks.conf dosyasını oluştur
cat <<EOF > redsocks.conf
base {
    log_debug = on;
    log_info = on;
    log = "file:./redsocks.log";

    daemon = on;

    redirector = iptables;
}

redsocks {
    local_ip = 0.0.0.0;
    local_port = 12345;

    ip = $proxy_ip;
    port = $proxy_port;

    type = $proxy_type;

    login = "$proxy_user";
    password = "$proxy_passwd";
}
EOF

# redsocks.conf dosyasını kullanarak redsocks'ı başlat
redsocks -c ./redsocks.conf

# Kullanıcıdan noproxy bilgisini al
read -p "NoProxy IP (proxy sunucusunun ip adresini tekrardan girin): " noproxy
export add_noproxy=e
if [ "$add_noproxy" == "E" ] || [ "$add_noproxy" == "e" ]; then
    read -p "Bir diğer NoProxy1 IP (yeni bir ip girmeyecekseniz proxy sunucusunun ip adresini girin! sakın boş bırakmayın!): " noproxy1
    read -p "Bir diğer NoProxy2 IP (yeni bir ip girmeyecekseniz proxy sunucusunun ip adresini girin! sakın boş bırakmayın!): " noproxy2
fi

# iptables1.sh dosyasını oluştur
cat <<EOF > iptables1.sh
iptables -t nat -N V2RAY
iptables -t mangle -N V2RAY
iptables -t mangle -N V2RAY_MARK

iptables -t nat -A V2RAY -d $noproxy -j RETURN

iptables -t nat -A V2RAY -d $noproxy1 -j RETURN
iptables -t nat -A V2RAY -d $noproxy2 -j RETURN

iptables -t nat -A V2RAY -d 0.0.0.0/8 -j RETURN
iptables -t nat -A V2RAY -d 10.0.0.0/8 -j RETURN
iptables -t nat -A V2RAY -d 127.0.0.0/8 -j RETURN
iptables -t nat -A V2RAY -d 169.254.0.0/16 -j RETURN
iptables -t nat -A V2RAY -d 172.16.0.0/12 -j RETURN
iptables -t nat -A V2RAY -d 192.168.0.0/16 -j RETURN
iptables -t nat -A V2RAY -d 224.0.0.0/4 -j RETURN
iptables -t nat -A V2RAY -d 240.0.0.0/4 -j RETURN
# Diğer kurallar buraya eklenebilir

iptables -t nat -A V2RAY -p tcp -j REDIRECT --to-ports 12345

iptables -t nat -A OUTPUT -p tcp -j V2RAY
iptables -t mangle -A PREROUTING -j V2RAY
iptables -t mangle -A OUTPUT -j V2RAY_MARK
iptables -t nat -A V2RAY -p udp -j REDIRECT --to-ports 12345

iptables -t nat -A OUTPUT -p udp -j V2RAY
iptables -t mangle -A PREROUTING -j V2RAY
iptables -t mangle -A OUTPUT -j V2RAY_MARK
EOF

# iptables1.sh dosyasını çalıştırabilir hale getir
chmod +x iptables1.sh
sudo cp ./redsocks/iptables1.sh .
sudo ./iptables1.sh > /dev/null 2>&1
# Kullanıcıya bilgi ver
sudo ./iptables1.sh
echo "Redsocks ve iptables kurulumu tamamlandı. NoProxy IP adreslerini iptables1.sh dosyasına ekleyerek kullanabilirsiniz."  | lolcat
