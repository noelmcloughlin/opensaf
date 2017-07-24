# opensaf
#
# Meta-state to fully install opensaf.

{% from 'opensaf/map.jinja' import opensaf, sls_block with context %}

include:
  - opensaf.config
  - opensaf.service

extend:
  opensaf_service:
    service:
      - listen:
        - file: opensaf_dtmd_config
        - file: opensaf_rde_config
        - file: opensaf_immnd_config
        - file: opensaf_imm_config
      - require:
        - file: opensaf_dtmd_config
        - file: opensaf_rde_config
        - file: opensaf_immnd_config
        - file: opensaf_imm_config
  opensaf_dtmd_config:
    file:
      - require:
        - cmd: opensaf_build
        {% if opensaf.lookup.use_make_install %}
        - cmd: opensaf_install
        {% else %}
        - pkg: opensaf_pkg_install
        {% endif %}
  opensaf_rde_config:
    file:
      - require:
        - cmd: opensaf_build
        {% if opensaf.lookup.use_make_install %}
        - cmd: opensaf_install
        {% else %}
        - pkg: opensaf_pkg_install
        {% endif %}
  opensaf_immnd_config:
    file:
      - require:
        - cmd: opensaf_build
        {% if opensaf.lookup.use_make_install %}
        - cmd: opensaf_install
        {% else %}
        - pkg: opensaf_pkg_install
        {% endif %}
  opensaf_imm_config:
    file:
      - require:
        - cmd: opensaf_build
        {% if opensaf.lookup.use_make_install %}
        - cmd: opensaf_install
        {% else %}
        - pkg: opensaf_pkg_install
        {% endif %}
