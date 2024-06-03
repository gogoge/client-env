FROM ubuntu
COPY ./scripts/* /scripts/
COPY .aws/ /root/.aws/
COPY .vimrc /root/
RUN apt update && apt install curl unzip less vim git -y &&\
    sh /scripts/install-awscli.sh && \
    sh /scripts/install-eksctl.sh && \
    sh /scripts/install-kubectl.sh && \
    sh /scripts/install-helm.sh 


