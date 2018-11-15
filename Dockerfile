FROM centos:latest

RUN yum install -y epel-release
RUN yum install -y jq
RUN yum install -y dos2unix

WORKDIR /app
COPY  ./scripts/* /app

RUN dos2unix /app/*