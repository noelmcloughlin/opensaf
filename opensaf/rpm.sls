# opensaf.pkg
#
# Manages installation of opensaf from rpms built from source.

{% from 'opensaf/map.jinja' import opensaf, sls_block with context %}

opensaf_pkg_install:
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
    - baseurl: file://{{ opensaf.source.repodir }}
    - enabled: True
    - require:
      - cmd: opensaf_create_repo
    - require_in:
      - pkg: opensaf_pkg_install
    - watch_in:
      - pkg: opensaf_pkg_install
  {% endif %}

  {% if salt['grains.get']('os_family') == 'Suse' %}
opensaf_zypp_repo:
  pkgrepo.managed
    - name: opensaf_rpms
    - humanname: server_rpms
    - baseurl: file://{{ opensaf.source.repodir }}
    - enabled: True
    - require_in:
      - pkg: opensaf_pkg_install
    - watch_in:
      - pkg: opensaf_pkg_install
  {% endif %}

opensaf_remove_src:
  file.missing:
    - name: {{ opensaf.source.prefix }}/src/opensaf-{{ opensaf.source.version }}*
    - require:
      - pkg: opensaf_pkg_install
    - onchanges:
      - pkg: opensaf_pkg_install
  pkgrepo.absent:
    - name: opensaf_rpms
    - humanname: server_rpms
    - require:
      - file: opensaf_remove_src
    - onchanges:
      - file: opensaf_remove_src

{% endif %}

