FROM ubuntu:16.04
MAINTAINER sameer@damagehead.com

ENV GITLAB_CI_MULTI_RUNNER_VERSION=1.11.0 \
    GITLAB_CI_MULTI_RUNNER_USER=gitlab_ci_multi_runner \
    GITLAB_CI_MULTI_RUNNER_HOME_DIR="/home/gitlab_ci_multi_runner"
ENV GITLAB_CI_MULTI_RUNNER_DATA_DIR="${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/data"

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E1DD270288B4E6030699E45FA1715D88E1DF1F24 \
 && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      git-core openssh-client curl libapparmor1 wget zip sudo \
      php \
      php7.0-cli \
      php7.0-json \
      php7.0-common \
      php7.0-xml \
      php7.0-gd \
      php7.0-curl \
      php7.0-mbstring \
      php7.0-mcrypt \
      php7.0-zip \
      php7.0-mysql \
      npm \
      ttfautohint \
      fontforge \
      jpegoptim \
      optipng \
      ruby \
      ruby-dev \

 && npm install -g \
      grunt-cli \
      bower \
      foundation \

 && gem install compass \

 && wget -q -O /usr/local/bin/gitlab-ci-multi-runner \
      https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/v${GITLAB_CI_MULTI_RUNNER_VERSION}/binaries/gitlab-ci-multi-runner-linux-amd64 \
 && chmod 0755 /usr/local/bin/gitlab-ci-multi-runner \
 && adduser --disabled-login --gecos 'GitLab CI Runner' ${GITLAB_CI_MULTI_RUNNER_USER} \
 && sudo -HEu ${GITLAB_CI_MULTI_RUNNER_USER} ln -sf ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh ${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/.ssh \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

RUN mkdir -p /usr/local/composer && cd /usr/local/composer \
&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer creates=/usr/local/bin/composer \
&& php -r "unlink('composer-setup.php');"

COPY composer/composer.json /usr/local/composer/composer.json

RUN cd /usr/local/composer \
&& composer install \
&& for f in $(ls -d /usr/local/composer/vendor/bin/*); do ln -s $f /usr/local/bin; done

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | NVM_DIR=/usr/local/nvm bash \
 && echo 'export NVM_DIR="/usr/local/nvm"' >> /home/gitlab_ci_multi_runner/.bashrc \
 && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> /home/gitlab_ci_multi_runner/.bashrc

RUN ln -s /usr/bin/nodejs /usr/bin/node

COPY php/php.ini /etc/php/7.0/cli/php.ini

VOLUME ["${GITLAB_CI_MULTI_RUNNER_DATA_DIR}"]
WORKDIR "${GITLAB_CI_MULTI_RUNNER_HOME_DIR}"
ENTRYPOINT ["/sbin/entrypoint.sh"]
