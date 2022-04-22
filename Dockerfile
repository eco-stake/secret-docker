#
# Build: Secretd
#
FROM ubuntu:20.04

RUN apt-get update && apt upgrade -y && apt-get -y install wget make build-essential gcc git jq chrony autoconf libtool

WORKDIR /root

RUN wget "https://download.01.org/intel-sgx/sgx-linux/2.14/distro/ubuntu20.04-server/sgx_linux_x64_driver_2.11.0_2d2b795.bin"
RUN chmod +x ./sgx_linux_x64_driver_*.bin
RUN ./sgx_linux_x64_driver_*.bin
RUN echo "deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main" | tee /etc/apt/sources.list.d/intel-sgx.list \
  && wget -qO - https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && apt update

RUN apt install -y gdebi && wget -O /tmp/libprotobuf30_3.19.4-1_amd64.deb https://engfilestorage.blob.core.windows.net/filestorage/libprotobuf30_3.19.4-1_amd64.deb \
   && yes | gdebi /tmp/libprotobuf30_3.19.4-1_amd64.deb

RUN apt install -y libsgx-enclave-common libsgx-urts sgx-aesm-service libsgx-uae-service

ARG VERSION=v1.2.2
ARG CHECKSUM=1a51d3d9324979ef9a1f56023e458023488b4583bf4587abeed2d1f389aea947

RUN wget https://github.com/scrtlabs/SecretNetwork/releases/download/${VERSION}/secretnetwork_${VERSION}_mainnet_amd64.deb
RUN echo "${CHECKSUM} secretnetwork_${VERSION}_mainnet_amd64.deb" | sha256sum --check

RUN dpkg-deb -R secretnetwork_${VERSION}_mainnet_amd64.deb secretnetwork_${VERSION}_mainnet_amd64.deb.extracted
RUN mv secretnetwork_${VERSION}_mainnet_amd64.deb.extracted/usr/local/bin/secretd /usr/local/bin
RUN mv secretnetwork_${VERSION}_mainnet_amd64.deb.extracted/usr/lib/librust_cosmwasm_enclave.signed.so /usr/lib
RUN mv secretnetwork_${VERSION}_mainnet_amd64.deb.extracted/usr/lib/libgo_cosmwasm.so /usr/lib

COPY bootstrap.sh /usr/bin/
RUN chmod +x /usr/bin/bootstrap.sh
ENTRYPOINT [ "bootstrap.sh" ]

CMD [ "secretd", "start" ]