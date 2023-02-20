FROM ubuntu:focal

RUN apt-get update && apt-get install ruby-full binutils -y
RUN gem install fpm

WORKDIR /cnosdb
COPY . /cnosdb

RUN bash build/build.sh