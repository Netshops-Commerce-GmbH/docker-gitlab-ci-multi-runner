FROM ubuntu:19.04
MAINTAINER benjamin,schnoor@etribes.de

ENV GITLAB_CI_MULTI_RUNNER_VERSION=11.6.0 \
    GITLAB_CI_MULTI_RUNNER_USER=gitlab_ci_multi_runner \
    GITLAB_CI_MULTI_RUNNER_HOME_DIR="/home/gitlab_ci_multi_runner" \
    GITLAB_CI_MULTI_RUNNER_DATA_DIR="${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/data" \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        git-core openssh-client curl libapparmor1 wget zip sudo \
        php7.2 \
        php7.2-cli \
        php7.2-json \
        php7.2-common \
        php7.2-xml \
        php7.2-gd \
        php7.2-curl \
        php7.2-mbstring \
        php7.2-zip \
        php7.2-mysql \
        npm \
        ttfautohint \
        fontforge \
        jpegoptim \
        optipng \
        rsync \
        nano \
        vim

RUN npm install -g \
        grunt-cli \
        foundation \
        psi

RUN wget -q -O /usr/local/bin/gitlab-ci-multi-runner \
        https://gitlab-runner-downloads.s3.amazonaws.com/v${GITLAB_CI_MULTI_RUNNER_VERSION}/binaries/gitlab-runner-linux-amd64 \
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
    && mkdir -p /usr/local/composer/vendor \
    && chown ${GITLAB_CI_MULTI_RUNNER_USER}:${GITLAB_CI_MULTI_RUNNER_USER} /usr/local/composer \
    && chmod -R 777 /usr/local/composer \
    && su ${GITLAB_CI_MULTI_RUNNER_USER} -c "composer install --dev" \
    && for f in $(ls -d /usr/local/composer/vendor/bin/*); do ln -s $f /usr/local/bin; done

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | NVM_DIR=/usr/local/nvm bash \
    && echo 'export NVM_DIR="/usr/local/nvm"' >> /home/gitlab_ci_multi_runner/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> /home/gitlab_ci_multi_runner/.bashrc \
    && mkdir -p /usr/local/nvm \
    && chmod -R 777 /usr/local/nvm \
    ## TODO: doesn't work. Need to optimize!
    && su ${GITLAB_CI_MULTI_RUNNER_USER} -c "/usr/local/nvm/nvm.sh install lts/* && /usr/local/nvm/nvm.sh install 0.10.41 && /usr/local/nvm/nvm.sh alias default lts/*"

COPY php/php.ini /etc/php/7.2/cli/php.ini

VOLUME ["${GITLAB_CI_MULTI_RUNNER_DATA_DIR}"]
WORKDIR "${GITLAB_CI_MULTI_RUNNER_HOME_DIR}"
ENTRYPOINT ["/sbin/entrypoint.sh"]

