FROM ubuntu:16.04

RUN apt-get -yqq update && \
    apt-get -yqq install python python-nose python-zmq ipython python-numpy \
                         python-scipy python-netcdf4 python-matplotlib \
                         python-mpltoolkits.basemap python-pip apache2 \
                         libapache2-mod-wsgi python-setuptools python-lxml \
                         git-core && \
    pip install threddsclient && \
    pip install https://github.com/bstdenis/pywps/archive/fix_async.zip && \
    pip install https://github.com/Ouranosinc/pyPavics/archive/minmax.zip && \
    pip install https://github.com/Ouranosinc/PAVICS-DataCatalog/archive/package.zip

RUN mkdir /var/www/html/wps && \
    mkdir /var/www/html/wps_results && \
    useradd apapywps && \
    mkdir /home/apapywps && \
    chown apapywps /home/apapywps && \
    chgrp apapywps /home/apapywps && \
    chown apapywps /var/www/html/wps_results && \
    chgrp apapywps /var/www/html/wps_results



COPY pywps.wsgi /var/www/html/wps/
COPY apache2.conf /etc/apache2/
COPY pywps.cfg /etc/
COPY catalog.cfg /home/

CMD export SOLR_HOST=$(grep --only-matching --perl-regex "(?<=SOLR_HOST\=).*" /home/catalog.cfg) && \
    export THREDDS_HOST=$(grep --only-matching --perl-regex "(?<=THREDDS_HOST\=).*" /home/catalog.cfg) && \
    export WPS_HOST=$(grep --only-matching --perl-regex "(?<=WPS_HOST\=).*" /home/catalog.cfg) && \
    export WMS_ALTERNATE_SERVER=$(grep --only-matching --perl-regex "(?<=WMS_ALTERNATE_SERVER\=).*" /home/catalog.cfg) && \
    printf "\nexport SOLR_HOST=\"$SOLR_HOST\"\n" >> /etc/apache2/envvars && \
    printf "\nexport THREDDS_HOST=\"$THREDDS_HOST\"\n" >> /etc/apache2/envvars && \
    printf "\nexport WMS_ALTERNATE_SERVER=\"$WMS_ALTERNATE_SERVER\"\n" >> /etc/apache2/envvars && \
    sed -i '/outputurl=/c\outputurl=http://'"$WPS_HOST"'/wps_results/' /etc/pywps.cfg && \
    /etc/init.d/apache2 start && tail -f /dev/null

EXPOSE 80
