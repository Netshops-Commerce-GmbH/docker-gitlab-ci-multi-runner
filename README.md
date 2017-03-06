# Based on sameersbn/gitlab-ci-multi-runner:1.1.4-7

use 
- ubuntu 16.04 
- GITLAB_CI_MULTI_RUNNER_VERSION 1.11.0

added
- php7.0
- composer
- consolidation/robo:         ^1.0
- henrikbjorn/lurker:         ^1.2
- mikey179/vfsStream:         ^1.6
- badges/poser:               ~1.2
- overtrue/phplint:           ^0.2.0
- squizlabs/php_codesniffer:  ^2.8
- phing/phing:                ^2.16
- phploc/phploc:              ^3.0
- phpunit/php-code-coverage:  ^5.0
- sebastian/phpcpd:           ^3.0
- andres-montanez/magallanes: ^3.0
- deployer/deployer:          ^4.2
- deployer/recipes:           ^4.0