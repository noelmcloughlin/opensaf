# opensaf.src
#
# Manages installation of opensaf from source.

{% from 'opensaf/map.jinja' import opensaf, sls_block with context %}

opensaf_build_dep:
  {% if salt['grains.get']('os_family') == 'Debian' %}
  cmd.run:
    - name: apt-get -y install libtool libxml2-dev
  {% elif salt['grains.get']('os_family') == 'RedHat' %}
  cmd.run:
    - name: yum -y install libtool libxml2-devel gcc gcc-c++ rpm-build ant createrepo
  {% elif salt['grains.get']('os_family') == 'Suse' or salt['grains.get']('os') == 'SUSE' %}
  cmd.run:
    - name: zypper install -y libtool libxml2-dev gcc gcc-c++ rpm-build ant
  {% else %}
     ## install build deps for other distros
  {% endif %}

opensaf_download:
  archive.extracted:
    - name: {{ opensaf.source.prefix }}/src
    - source: {{ opensaf.source.url }}
    - source_hash: {{ opensaf.source.urlhash }}
    - archive_format: {{ opensaf.source.archive_type }}
    {% if opensaf.lookup.install_from_source %}
    - if_missing: {{ opensaf.source.prefix }}/lib/opensaf/opensafd-{{ opensaf.source.version }}
    {% endif %}
    - require:
      - cmd: opensaf_build_dep
    - onchanges:
      - cmd: opensaf_build_dep

opensaf_make_configure:
  cmd.run:
    - cwd: {{ opensaf.source.prefix }}/src/opensaf-{{ opensaf.source.version }}
    - name: ./configure {{ opensaf.source.configure_flags }} {{ opensaf.source.opts | join(' ') }}
    - require:
      - archive: opensaf_download

opensaf_build:
  cmd.run:
    - cwd: {{ opensaf.source.prefix }}/src/opensaf-{{ opensaf.source.version }}
    - name: make {{opensaf.source.make_flags }}
    - require_in:
      - cmd: opensaf_install
      - opensaf_repo_install
    - require:
      - cmd: opensaf_make_configure
    - onchanges:
      - cmd: opensaf_make_configure

{% if opensaf.lookup.install_from_source %}
opensaf_install:
  cmd.run:
    - cwd: {{ opensaf.source.prefix }}/src/opensaf-{{ opensaf.source.version }}
    - name: make install
    - require:
      - cmd: opensaf_build
    - onchanges:
      - cmd: opensaf_build

opensaf_link:
  file.copy:
    - name: {{ opensaf.source.prefix }}/lib/opensaf/opensafd-{{ opensaf.source.version }}
    - source: {{ opensaf.source.prefix }}/lib/opensaf/opensafd
    - require:
      - cmd: opensaf_install
    - onchanges:
      - cmd: opensaf_install
{% else %}

   {% if opensaf.lookup.install_from_rpm %}
opensaf_create_repo:
  cmd.run:
    - name: createrepo {{ opensaf.source.repodir }}
    - require:
      - cmd: opensaf_build
    - onchanges:
      - cmd: opensaf_build
   {% endif %}
{% endif %}

