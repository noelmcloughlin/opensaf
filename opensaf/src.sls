# opensaf.src
#
# Manages installation of opensaf from source.

{% from 'opensaf/map.jinja' import opensaf, sls_block with context %}

opensaf_build_dep:
  {% if salt['grains.get']('os_family') == 'Debian' %}
  cmd.run:
    - name: apt-get -y install libxml2-dev
  {% elif salt['grains.get']('os_family') == 'RedHat' %}
  cmd.run:
    - name: yum -y install libxml2-dev gcc gcc-c++ rpm-build ant createrepo
  {% elif salt['grains.get']('os_family') == 'Suse' %}
  cmd.run:
    - name: zypper install -y libxml2-dev gcc gcc-c++ rpm-build ant
  {% else %}
     ## install build deps for other distros
  {% endif %}

opensaf_download:
  archive.extracted:
    - name: {{ opensaf.source.src_root }}
    - source: {{ opensaf.source.url }}
    - source_hash: {{ opensaf.source.urlhash }}
    - archive_format: {{ opensaf.source.archive_type }}
    - if_missing: /usr/sbin/opensaf-{{ opensaf.source.version }}
    - require:
      - cmd: opensaf_build_dep
    - onchanges:
      - cmd: opensaf_build_dep

opensaf_configure:
  cmd.run:
    - name: ./configure {{ opensaf.source.configure_flags }} {{ opensaf.source.opts | join(' ') }}
    - cwd: {{ opensaf.source.src_root }}
    - require:
      - archive: opensaf_download
    - onchanges:
      - archive: opensaf_download

opensaf_build:
  cmd.run:
    - name: make {{opensaf.source.make_flags }}
    - cwd: {{ opensaf.source.src_root }}
    - require_in:
      - opensaf_install
      - opensaf_repo_install
    - require:
      - cmd: opensaf_configure
    - onchanges:
      - cmd: opensaf_configure

opensaf_install:
  cmd.run:
    - name: make install
    - cwd: {{ opensaf.source.src_root }}
    - require:
      - cmd: opensaf_build
    - onchanges:
      - cmd: opensaf_build

opensaf_link:
  file.copy:
    - name: /usr/sbin/opensaf-{{ opensaf.source.version }}
    - source: /usr/sbin/opensaf
    - require:
      - cmd: opensaf_install
    - onchanges:
      - cmd: opensaf_install

{% if opensaf.source.make_flags == 'rpm' %}
opensaf_create_yum_repo:
  file.managed:
    - name: {{ opensaf.package.rpmdir }}
    - source: {{ opensaf.source.src_root }}/rpm/RPMS/x86_64
    - makedirs: True
    - force: True
    - require_in:
      - pkgrepo: opensaf_yum_repo
      - pkgrepo: opensaf_zypp_repo
    - require:
      - cmd: opensaf_build
    - onchanges:
      - cmd: opensaf_build
  cmd.run:
    - name: createrepo {{ opensaf.package.rpmdir }}
    - require:
      - file: opensaf_create_yum_repo
{% endif %}
