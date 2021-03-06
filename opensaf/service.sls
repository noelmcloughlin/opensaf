# opensaf.service
#
# Manages the opensaf service.

{% from 'opensaf/map.jinja' import opensaf, sls_block with context %}
{% set service_function = {True:'running', False:'dead'}.get(opensaf.service.enable) %}

include:
  - opensaf.src
  {% if opensaf.lookup.use_make_install == False %}
  - opensaf.pkg
  {% endif %}

{% if opensaf.lookup.use_make_install %}
opensaf_systemd_service_file:
  file.managed:
    - name: /lib/systemd/system/{{ opensaf.service.name }}.service
    - source: salt://opensaf/files/{{ opensaf.service.name }}.service
{% endif %} 
  
opensaf_env_file:
  file.managed:
    - name: /etc/profile.d/opensaf.sh
    - source: salt://opensaf/files/opensaf.sh
    - template: jinja
    - force: True
    - context:
        opensaf_prefix: {{ opensaf.source.prefix }}

opensaf_service:
  service.{{ service_function }}:
    {{ sls_block(opensaf.service.opts) }}
    - name: {{ opensaf.service.name }}
    - enable: {{ opensaf.service.enable }}
    - require:
      - sls: opensaf.src
      {% if opensaf.lookup.use_make_install == False %}
      - sls: opensaf.rpm
      {% endif %}
    - listen:
      {% if opensaf.lookup.use_make_install %}
      - cmd: opensaf_install
      {% else %}
      - pkg: opensaf_pkg_install
      {% endif %}

