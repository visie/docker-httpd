#!/usr/bin/env sh

set -e

# Obtém o nome do usuário
test ${USERNAME} || USERNAME=${USER}
test ${USERNAME} || USERNAME=www-data

if [ $(echo ${UID} | grep -P -v '^\d+(:\d+)?$') ]; then
    # UID na verdade é USERNAME
    USERNAME=${UID}
    UID=
    GID=
fi

if [ $(echo ${UID} | grep -P '^\d+:\d+$') ]; then
    # UID contém o GID
    GID=$(echo ${UID} | cut -f2 -d':')
    UID=$(echo ${UID} | cut -f1 -d':')
fi

test ${UID} || UID=$(getent passwd "${USERNAME}" | cut -f3 -d':')
test "${UID}" != "0" || UID=""
test ${UID} || UID=$(id -u www-data)
test ${GID} || GID=$(getent passwd "${USERNAME}" | cut -f4 -d':')
test "${GID}" != "0" || GID=""
test ${GID} || GID=$(uid -g www-data)

if [ -z "$(grep -P "${USERNAME}:[^:]*:${UID}:${GID}" /etc/passwd)" ]; then
    # O usuário desejado não existe!
    groupadd -f -g ${GID} -o ${USERNAME}
    useradd -g ${GID} -M -N -o -u ${UID} ${USERNAME}
fi

groupmod -g ${GID} -o ${USERNAME}
usermod -g ${GID} -o -u ${UID} -d /var/www/html ${USERNAME} 2>/dev/null

# Setup inicial das bases e usuários
HOME=$(getent passwd ${USERNAME} | awk -F':' '{print $(NF - 1)}')
test ${HOME} || HOME=/var/www/html
if [ -e ${HOME} ]; then
    test -d ${HOME} || rm -rf ${HOME}
    test -d ${HOME} || mkdir -p ${HOME}
fi

chown -R ${UID}:${GID} ${HOME}

# Comando a ser executado
cmd="apache2 -DFOREGROUND"
if [ $(echo ${1} | grep -P '^[^-]') ]; then
    cmd=${1}
    shift
fi

export APACHE_RUN_USER=$(getent passwd ${UID} | cut -f1 -d':')
export APACHE_RUN_GROUP=$(getent passwd ${GID} | cut -f1 -d':')
exec ${cmd} ${@}
