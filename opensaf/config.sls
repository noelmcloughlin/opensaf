# opensaf.config
#
# Manages the main opensaf service configuration files

{% from 'opensaf/map.jinja' import opensaf, sls_block with context %}

{% if opensaf.lookup.use_make_install %}
         ###### Todo: Check if opensaf uses syslog or not ??
opensaf_log_dir:
  file.directory:
    - name: /var/log/opensaf
    - user: {{ opensaf.service.config.user }}
    - group: {{ opensaf.service.config.user }}
{% endif %}

opensaf_dtmd_config:
  file.managed:
    {{ sls_block(opensaf.service.dtmd.opts) }}
    - name: {{ opensaf.service.dtmd.conf_file }}
    - source: salt://opensaf/files/dtmd.conf
    - template: jinja
    - context:
        config: {{ opensaf.service.dtmd.config|json() }}

opensaf_rde_config:
  file.managed:
    {{ sls_block(opensaf.service.rde.opts) }}
    - name: {{ opensaf.service.rde.conf_file }}
    - source: salt://opensaf/files/rde.conf
    - template: jinja
    - context:
        config: {{ opensaf.service.rde.config|json() }}

opensaf_immnd_config:
  file.managed:
    {{ sls_block(opensaf.service.immnd.opts) }}
    - name: {{ opensaf.service.immnd.conf_file }}
    - source: salt://opensaf/files/immnd.conf
    - template: jinja
    - context:
        config: {{ opensaf.service.immnd.config|json() }}

opensaf_imm_config:
  file.managed:
    {{ sls_block(opensaf.service.imm.opts) }}
    - name: {{ opensaf.service.imm.conf_file }}
    - source: salt://opensaf/files/imm.xml
    - template: jinja

