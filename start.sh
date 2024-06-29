#!/bin/sh
#
# This script:
#
# - Creates the data directory (uploaded files)
# - Generates a keystore (needed for docdoku-plm-server)
# - Pull images and starts all containers

# Exit on error
set -e

# Change this values in production
STOREPASS=changeit
KEYPASS=changeit
KEYALIAS=mykeyalias
STORETYPE=PKCS12
KEYALG=AES
KEYSIZE=256

#
# Script start
#

# Data directory check
if [ -d data ]; 
then 
    echo 'Data directory found'
else
    echo 'Creating data directory and volume...'
    mkdir data
    docker volume create --driver local \
        --opt type=none \
        --opt device=$(pwd)/data \
        --opt o=bind docdoku-plm-server-volume
fi

echo $(pwd)/data

# Keystore check
if [ -f keystore ]; 
then 
    echo 'Keystore found'
else
    echo 'Generating keystore...'
    # keytool
    docker run -it --rm \
     -v $(pwd):$(pwd) \
     -w $(pwd) \
     azul/zulu-openjdk:8u232 \
     keytool \
     -genseckey \
     -keystore keystore \
     -storetype ${STORETYPE} \
     -alias ${KEYALIAS} \
     -keyalg ${KEYALG} \
     -keysize ${KEYSIZE} \
     -storepass ${STOREPASS} \
     -keypass ${KEYPASS}
fi

echo $(pwd)/keystore

# Start the containers
docker-compose pull
docker-compose up -d --force-recreate --remove-orphans