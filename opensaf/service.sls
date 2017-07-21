# opensaf.service
#
# Manages the opensaf service.

{% from 'opensaf/map.jinja' import opensaf, sls_block with context %}
{% set service_function = {True:'running', False:'dead'}.get(opensaf.service.enable) %}

include:
  {% if opensaf.build_from_source or opensaf.install_from_source %}
  - opensaf.src
  {% endif %}
  {% if opensaf.install_from_rpm %}
  - opensaf.rpm
  {% endif %}

{% if opensaf.install_from_source %}
opensaf_systemd_service_file:
  file.managed:
    - name: /lib/systemd/system/{{ opensaf.service.name }}.service
    - source: salt://opensaf/files/{{ opensaf.service.name }}.service
{% endif %} 
  
opensaf_service:
  service.{{ service_function }}:
    {{ sls_block(opensaf.service.opts) }}
    - name: {{ opensaf.service.name }}
    - enable: {{ opensaf.service.enable }}
    - require:
      {% if opensaf.build_from_source or opensaf.install_from_source %}
      - sls: opensaf.src
      {% endif %}
      {% if opensaf.install_from_rpm %}
      - sls: opensaf.rpm
      {% endif %}
    - listen:
      {% if opensaf.install_from_source %}
      - cmd: opensaf_install
      {% else %}
      - pkg: opensaf_install
      {% endif %}
