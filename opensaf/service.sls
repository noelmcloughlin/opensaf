# opensaf.service
#
# Manages the opensaf service.

{% from 'opensaf/map.jinja' import opensaf, sls_block with context %}
{% set service_function = {True:'running', False:'dead'}.get(opensaf.service.enable) %}

include:
  {% if opensaf.install_from_source %}
  - opensaf.src
  {% else %}
  - opensaf.pkg
  {% endif %}

{% if opensaf.install_from_source %}
opensaf_systemd_service_file:
  file.managed:
    - name: /lib/systemd/system/opensaf.service
    - source: salt://opensaf/files/opensaf.service
{% endif %} 
  
opensaf_service:
  service.{{ service_function }}:
    {{ sls_block(opensaf.service.opts) }}
    - name: {{ opensaf.service.name }}
    - enable: {{ opensaf.service.enable }}
    - require:
      {% if opensaf.install_from_source %}
      - sls: opensaf.src
      {% else %}
      - sls: opensaf.pkg
      {% endif %}
    - listen:
      {% if opensaf.install_from_source %}
      - cmd: opensaf_install
      {% else %}
      - pkg: opensaf_install
      {% endif %}