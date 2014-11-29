# VERSION 0.2
# DOCKER-VERSION  1.3.1
# AUTHOR:         Sam Alba <sam@docker.com>, Jono Wells <_@oj.io>
# DESCRIPTION:    Image with docker-registry project and dependecies
# TO_BUILD:       docker build --rm -t registry .
# TO_RUN:         docker run -p 5000:5000 registry

FROM wellsie/centos7-python
MAINTAINER Jono Wells <_oj.io>

RUN yum -y install patch \
  && yum -y clean all

COPY . /docker-registry
COPY ./config/boto.cfg /etc/boto.cfg

# Install core and registry
RUN pip install /docker-registry/depends/docker-registry-core file:///docker-registry#egg=docker-registry[bugsnag,newrelic,cors]

RUN patch \
 $(python -c 'import boto; import os; print os.path.dirname(boto.__file__)')/connection.py \
 < /docker-registry/contrib/boto_header_patch.diff

ENV DOCKER_REGISTRY_CONFIG /docker-registry/config/config_sample.yml
ENV SETTINGS_FLAVOR dev

EXPOSE 443 5000

CMD [ "docker-registry" ]
