FROM alpine:latest

ADD setup-configuration /root/setup-configuration/ 
COPY my_wrapper_script.sh /root/my_wrapper_script.sh

RUN apk -U upgrade \
    && apk add --no-cache bash unzip curl haproxy wireguard-tools iptables ip6tables \
    && apk add --virtual build-deps --no-cache go git make \
    && git clone https://git.zx2c4.com/wireguard-go /tmp/wireguard-go \
    && cd /tmp/wireguard-go \
    && make \
    && install -m 755 wireguard-go /usr/local/bin/wireguard-go \
    && cd \
    && chmod +x /root/setup-configuration/*.sh /root/*.sh \
    && mkdir /tmp/v2ray \
    && curl -sL 'https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip' -o /tmp/v2ray/v2ray.zip \
    && unzip -q /tmp/v2ray/v2ray.zip -d /tmp/v2ray \
    && install -m 755 /tmp/v2ray/v2ray /usr/local/bin/v2ray \
    && install -m 755 /tmp/v2ray/v2ctl /usr/local/bin/v2ctl \
    && mkdir /tmp/mtg \
    && mtg_version=$(curl -s 'https://github.com/9seconds/mtg/releases/latest' |grep -o 'tag\/v[0-9].*[0-9]' |grep -o '[0-9].*[0-9]') \
    && curl -sL "https://github.com/9seconds/mtg/releases/download/v${mtg_version}/mtg-${mtg_version}-linux-amd64.tar.gz" -o /tmp/mtg/mtg.tar.gz \
    && tar -C /tmp/mtg -xf /tmp/mtg/mtg.tar.gz \
    && install -m 755 /tmp/mtg/mtg-${mtg_version}-linux-amd64/mtg /usr/local/bin/mtg \
    && mkdir /tmp/ss \
    && ss_version=$(curl -s 'https://github.com/shadowsocks/shadowsocks-rust/releases/latest' |grep -o 'tag\/v[0-9].*[0-9]' |grep -o '[0-9].*[0-9]') \
    && curl -sL "https://github.com/shadowsocks/shadowsocks-rust/releases/download/v${ss_version}/shadowsocks-v${ss_version}.x86_64-unknown-linux-musl.tar.xz" -o /tmp/ss/ss.tar.xz \
    && tar -C /tmp/ss -xf /tmp/ss/ss.tar.xz \
    && install -m 755 /tmp/ss/ssserver /usr/local/bin/ssserver \
    && rm -rf /tmp/wireguard-go /tmp/v2ray /tmp/mtg /tmp/ss /root/go \
    && apk del build-deps


CMD /root/my_wrapper_script.sh
