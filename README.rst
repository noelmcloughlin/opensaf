=====
opensaf
=====

Install opensaf either from source or package built from source

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

.. contents::
    :local:

``opensaf``
------------

Meta-state for inclusion of all states.

**Note:** opensaf requires the merge parameter of salt.modules.pillar.get(),
first available in the Helium release.

``opensaf.install``
--------------------

Installs the opensaf package.

``opensaf.config``
-------------------

Manages the opensaf main server configuration file.

``opensaf.service``
--------------------

Manages the startup and running state of the opensaf service.

