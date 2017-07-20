# opensaf.pkg
#
# Manages installation of opensaf from pkg.

{% from 'opensaf/map.jinja' import opensaf, sls_block with context %}

opensaf_install:
  pkg.installed:
    {{ sls_block(opensaf.package.opts) }}
    - name: {{ opensaf.package.name }}

{% if opensaf.build_from_source %}
include:
  - opensaf.src

  {% if salt['grains.get']('os_family') == 'RedHat' %}
opensaf_yum_repo:
  pkgrepo.managed:
    - name: opensaf_rpms
    - humanname: opensaf repo
    - baseurl: 'file:///{{ opensaf.package.rpmdir }}'
    - enabled: True
    - require_in:
      - pkg: opensaf_install
    - watch_in:
      - pkg: opensaf_install
  {% endif %}

  {% if salt['grains.get']('os_family') == 'Suse' %}
opensaf_zypp_repo:
  pkgrepo.managed
    - name: opensaf_rpms
    - humanname: server_rpms
    - baseurl: 'file:///{{ opensaf.package.rpmdir }}'
    - enabled: True
    - require_in:
      - pkg: opensaf_install
    - watch_in:
      - pkg: opensaf_install
  {% endif %}

{% endif %}

