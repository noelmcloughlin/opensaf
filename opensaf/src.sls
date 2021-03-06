# opensaf.src
#
# Manages installation of opensaf from source.

{% from 'opensaf/map.jinja' import opensaf, sls_block with context %}

opensaf_source_build_deps:
  pkg.installed:
    - pkgs:
      - libtool
      - gcc
      - ant
  {% if salt['grains.get']('os_family') == 'Debian' %}
      - libxml2-dev
      - g++
  {% endif %}
  {% if salt['grains.get']('os_family') == 'RedHat' %}
      - createrepo
  {% endif %}
  {% if salt['grains.get']('os_family') == 'RedHat' or salt['grains.get']('os') == 'SUSE' %}
      - libxml2-devel
      - rpm-build
      - gcc-c++
  {% endif %}
     ## install build deps for other distros

opensaf-archive-extracted:
  archive.extracted:
    - name: {{ opensaf.source.prefix }}/src
    - source: {{ opensaf.source.url }}
    - archive_format: {{ opensaf.source.archive_type }}
  {% if grains['saltversioninfo'] > [2016, 11, 6] and opensaf.source_hash %}
    - source_hash: {{ opensaf.source.urlhash }}
  {% endif %}
  {% if grains['saltversioninfo'] < [2016, 11, 0] and opensaf.lookup.use_make_install %}
    - tar_options: {{ opensaf.source.unpack_opts }}
    - if_missing: {{ opensaf.source.prefix }}/lib/opensaf/opensafd-{{ opensaf.version }}
  {% endif %}
  {% if grains['saltversioninfo'] > [2016, 11, 0] and opensaf.lookup.use_make_install %}
    - options: {{ opensaf.source.unpack_opts }}
  {% endif %}
    - require:
      - cmd: opensaf_source_build_deps
    - onchanges:
      - cmd: opensaf_source_build_deps

  {% if grains['saltversioninfo'] <= [2016, 11, 6] and opensaf.source_hash %}
    # See: https://github.com/saltstack/salt/pull/41914
opensaf-check-archive-hash:
  module.run:
    - name: file.check_hash
    - path: {{ archive_file }}
    - file_hash: {{ opensaf.source.urlhash }}
    - onchanges:
      - cmd: opensaf-archive-extracted
    - require_in:
      - cmd: opensaf_make_configure
  {%- endif %}

opensaf_make_configure:
  cmd.run:
    - cwd: {{ opensaf.source.prefix }}/src/opensaf-{{ opensaf.version }}
    - name: ./configure {{ opensaf.source.configure_flags }} {{ opensaf.source.opts | join(' ') }}
    - require:
      - archive: opensaf-archive-extracted

opensaf_build:
  cmd.run:
    - cwd: {{ opensaf.source.prefix }}/src/opensaf-{{ opensaf.version }}
    - name: make {{opensaf.source.make_flags }}
    - require_in:
      - cmd: opensaf_install
      - opensaf_repo_install
    - require:
      - cmd: opensaf_make_configure
    - onchanges:
      - cmd: opensaf_make_configure

{% if opensaf.lookup.use_make_install %}
opensaf_install:
  cmd.run:
    - cwd: {{ opensaf.source.prefix }}/src/opensaf-{{ opensaf.version }}
    - name: make install
    - require:
      - cmd: opensaf_build
    - onchanges:
      - cmd: opensaf_build

opensaf_link:
  file.copy:
    - name: {{ opensaf.source.prefix }}/lib/opensaf/opensafd-{{ opensaf.version }}
    - source: {{ opensaf.source.prefix }}/lib/opensaf/opensafd
    - require:
      - cmd: opensaf_install
    - onchanges:
      - cmd: opensaf_install
{% else %}

   {% if opensaf.lookup.use_make_rpm %}
opensaf_create_repo:
  cmd.run:
    - name: createrepo {{ opensaf.source.repodir }}
    - require:
      - cmd: opensaf_build
    - onchanges:
      - cmd: opensaf_build
   {% endif %}
{% endif %}

