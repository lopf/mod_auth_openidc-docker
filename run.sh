#!/bin/bash

docker stop apache-azure
docker rm apache-azure
docker run -it --name apache-azure -p 8080:80 \
        -v ${PWD}/conf/openidc.conf:/usr/local/apache2/conf/extra/openidc.conf \
        -v ${PWD}/public-html:/usr/local/apache2/htdocs \
        azurepache
