FROM maven:3-openjdk-11

ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update \
&& apt-get install --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        git \
        iputils-ping \
        libcurl4 \
        libicu63 \
        libunwind8 \
        netcat \
        zip

RUN curl https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb --output packages-microsoft-prod.deb \
&& dpkg -i packages-microsoft-prod.deb

RUN apt-get update \
&& apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    dotnet-sdk-5.0\
&& curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
&& add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable" \
&& apt-get update \
&& apt-get install docker-ce-cli 

COPY --from=maven:3-openjdk-8 /usr/local/openjdk-8/ /usr/local/openjdk-8
COPY --from=maven:3-openjdk-15 /usr/java/openjdk-15/ /usr/local/openjdk-15
COPY --from=maven:3-openjdk-15 /etc/pki/ca-trust/extracted/java/cacerts/ /etc/pki/ca-trust/extracted/java/cacerts

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

ENV JAVA_HOME_8_X64=/usr/local/openjdk-8
ENV JAVA_HOME_11_X64=/usr/local/openjdk-11
ENV JAVA_HOME_15_X64=/usr/local/openjdk-15

CMD ["./start.sh"]
