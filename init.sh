#!/bin/bash
exec varnishd \
    -j unix,user=vcache \
    -F \
    -f ${VARNISH_CONFIG} \
    -s ${VARNISH_STORAGE} \
    -a ${VARNISH_LISTEN} \
    -T ${VARNISH_MANAGEMENT_LISTEN} \
    -p tcp_fastopen=On \
    -p feature=+esi_disable_xml_check \
    -p feature=+esi_ignore_https \
    -p feature=+esi_ignore_other_elements \
    -s ${VARNISH_TRANSIENT} \
    ${VARNISH_DAEMON_OPTS}