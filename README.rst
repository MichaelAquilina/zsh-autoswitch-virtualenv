Autoswitch Python Virtualenv
============================

|CircleCI| |Release| |GPLv3|

*zsh-autoswitch-virtualenv* is a simple and quick ZSH plugin that switches python
virtualenvs automatically as you move between directories.

* `How it Works`_
* `More Details`_
* Installing_
* `Pipenv Integration`_
* Commands_
* `Customising Messages`_
* Options_
* `Security Warnings`_
* `Running Tests`_


How it Works
------------

Simply call the ``mkvenv`` command in the directory you wish to setup a
virtual environment. A virtual environment specific to that folder will
now activate every time you enter it.

``zsh-autoswitch-virtualenv`` will try detect python projects and remind
you to create a virtual environment if e.g. setup.py or requirements.txt is
found in the current directory.

See the Commands_ section below for more detail.

More Details
------------

Moving out of the directory will automatically deactivate the virtual
environment. However you can also switch to a default python virtual
environment instead by setting the ``AUTOSWITCH_DEFAULTENV`` environment
variable.

Internally this plugin simply works by creating a file named ``.venv``
which contains the name of the virtual environment created (which is the
same name as the current directory but can be edited if needed). There
is then a precommand hook that looks for a ``.venv`` file and switches
to the name specified if one is found.

**NOTE**: you may want to add ``.venv`` to your ``.gitignore`` in git
projects (or equivalent file for the Version Control you are using).

Installing
----------

``autoswitch-virtualenv`` requires `virtualenv <https://pypi.org/project/virtualenv/>`__ to be installed.

Once ``virtualenv`` is installed, add one of the following lines to your ``.zshrc`` file depending on the
package manager you are using:

ZPlug_

::

    zplug "MichaelAquilina/zsh-autoswitch-virtualenv"

Antigen_

::

    antigen bundle "MichaelAquilina/zsh-autoswitch-virtualenv"

Zgen_

::

    zgen load "MichaelAquilina/zsh-autoswitch-virtualenv"

oh-my-zsh_

Copy this repository to ``$ZSH_CUSTOM/custom/plugins``, where ``$ZSH_CUSTOM``
is the directory with custom plugins of oh-my-zsh `(read more) <https://github.com/robbyrussell/oh-my-zsh/wiki/Customization/>`_:

::

    git clone "https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git" "$ZSH_CUSTOM/plugins/autoswitch_virtualenv"

Then add this line to your ``.zshrc``

::

    plugins=(autoswitch_virtualenv $plugins)

**Manual Installation**

Source the plugin shell script in your `~/.zshrc` profile. For example

::
   git clone "https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git" "$ZSH_CUSTOM/plugins/autoswitch_virtualenv"
   source $ZSH_CUSTOM/plugins/autoswitch_virtualenv/autoswitch_virtualenv.plugin.zsh


Pipenv Integration
------------------

This plugin will also detect and auto activate virtualenvs made with ``pipenv``.

Commands
--------

mkvenv
''''''

Setup a new project with virtualenv autoswitching using the ``mkvenv``
helper command.

::

    $ cd my-python-project
    $ mkvenv
    Creating my-python-project virtualenv
    Found a requirements.txt. Install? [y/N]:
    Collecting requests (from -r requirements.txt (line 1))
      Using cached requests-2.11.1-py2.py3-none-any.whl
    Installing collected packages: requests
    Successfully installed requests-2.11.1

Optionally, you can specify the python binary to use for this virtual environment

::

    $ mkvenv --python=/usr/bin/python3


It is also possible to inherit the system site packages (which can reduce duplication on the file system
and download/setup time).

::

    $ mkvenv --system-site-packages

In fact, ``mkvenv`` supports any parameters that can be passed to ``python -m virtualenv``.
A comprehensive list of options may be found in the
`virtualenv guide <https://virtualenv.pypa.io/en/latest/reference/#options>`__

``mkvenv`` will create a virtual environment with the same name as the
current directory, suggest installing ``requirements.txt`` if available
and create the relevant ``.venv`` file for you.

Next time you switch to that folder, you'll see the following message

::

    $ cd my-python-project
    Switching virtualenv: my-python-project  [Python 3.4.3+]
    $

If you have set the ``AUTOSWITCH_DEFAULTENV`` environment variable,
exiting that directory will switch back to the value set.

::

    $ cd ..
    Switching virtualenv: mydefaultenv  [Python 3.4.3+]
    $

Otherwise, ``deactivate`` will simply be called on the virtualenv to
switch back to the global python environment.

Autoswitching is smart enough to detect that you have traversed to a
project subdirectory. So your virtualenv will not be deactivated if you
enter a subdirectory.

::

    $ cd my-python-project
    Switching virtualenv: my-python-project  [Python 3.4.3+]
    $ cd src
    $ # Notice how this has not deactivated the project virtualenv
    $ cd ../..
    Switching virtualenv: mydefaultenv  [Python 3.4.3+]
    $ # exited the project parent folder, so the virtualenv is now deactivated

rmvenv
''''''

You can remove the virtual environment for a directory you are currently
in using the ``rmvenv`` helper function:

::

    $ cd my-python-project
    $ rmvenv
    Switching virtualenv: mydefaultenv  [Python 2.7.12]
    Removing myproject...

This will delete the virtual environment in ``.venv`` and remove the
``.venv`` file itself. The ``rmvenv`` command will fail if there is no
``.venv`` file in the current directory:

::

    $ cd my-non-python-project
    $ rmvenv
    No .venv file in the current directory!

disable_autoswitch_virtualenv
'''''''''''''''''''''''''''''

Temporarily disables autoswitching of virtualenvs when moving between
directories.

enable_autoswitch_virtualenv
''''''''''''''''''''''''''''

Re-enable autoswitching of virtualenvs (if it was previously disabled).

Customising Messages
--------------------

By default, the following message is displayed in bold when an alias is found:

::

    Switching %venv_type: %venv_name [%py_version]

Where the following variables represent:

* ``%venv_type`` - the type of virtualenv being activated (virtualenv, pipenv)
* ``%venv_name`` - the name of the virtualenv being activated
* ``%py_version`` - the version of python used by the virtualenv being activated

This default message can be customised by setting the ``AUTOSWITCH_MESSAGE_FORMAT`` environment variable.

If for example, you wish to display your own custom message in red, you can add the
following to your ``~/.zshrc``:

::

    export AUTOSWITCH_MESSAGE_FORMAT="$(tput setaf 1)Switching to %venv_name 🐍 %py_version $(tput sgr0)"

``$(tput setaf 1)`` generates the escape code terminals use for red foreground text. ``$(tput sgr0)`` sets
the text back to a normal color.

You can read more about how you can use tput and terminal escape codes here:
http://wiki.bash-hackers.org/scripting/terminalcodes


Options
-------

The following options can be configured by setting the appropriate variables within your ``~/.zshrc`` file.

**Setting a default virtual environment**

You can set a default virtual environment to switch to when not in a python project by setting
the value of ``AUTOSWITCH_DEFAULTENV`` to the name of a virtualenv. For example:

::

    export AUTOSWITCH_DEFAULTENV="mydefaultenv"

**Setting a default python binary**

You may specify a default python binary to use when creating virtualenvs
by setting the value of ``AUTOSWITCH_DEFAULT_PYTHON``. For example:

::

    export AUTOSWITCH_DEFAULT_PYTHON="/usr/bin/python3"

You may still override this default as usual by passing the --python parameter to
the mkvenv command.

**Default requirements file**

You may specify a default requirements file to use when creating a virtualenv by
setting the value of ``AUTOSWTICH_DEFAULT_REQUIREMENTS``. For example:

::

    export AUTOSWITCH_DEFAULT_REQUIREMENTS="$HOME/.requirements.txt"

If the value is set and the target file exists you will be prompted to install with that file
each time you create a new virtualenv.


**Set verbosity when changing environments**

You can prevent verbose messages from being displayed when moving
between directories. You can do this by setting ``AUTOSWITCH_SILENT`` to
a non-empty value.

**Choosing where virtualenvs are stored**

By default, virtualenvs created are placed in ``$HOME/.virtualenvs`` - which is
the same location that the ``virtualenvwrapper`` package uses.

If you wish to change this to another location, simply set the value of the
environment variable ``AUTOSWITCH_VIRTUAL_ENV_DIR``.

**Customising pip install invocation**

By default `mkvenv` will install setup.py via pip in editable (i.e. development) mode. See
`here <http://codumentary.blogspot.com/2014/11/python-tip-of-year-pip-install-editable.html/>`__
and `here <https://pip.pypa.io/en/stable/reference/pip_install/#editable-installs/>`__ for
further information. To change this set ``AUTOSWITCH_PIPINSTALL`` to ``FULL``.

Security Warnings
-----------------

zsh-autoswitch-virtualenv will warn you and refuse to activate a virtual
envionrment automatically in the following situations:

-  You are not the owner of the ``.venv`` file found in a directory.
-  The ``.venv`` file has weak permissions. I.e. it is writable by other users on the system.

In both cases, the warnings should explain how to fix the problem.

These are security measures that prevents other, potentially malicious
users, from switching you to a virtual environment you did not want to
switch to.

Running Tests
-------------

Install `zunit <https://zunit.xyz/>`__. Run ``zunit`` in the root
directory of the repo.

::

    $ zunit
    Launching ZUnit
    ZUnit: 0.8.2
    ZSH:   zsh 5.3.1 (x86_64-suse-linux-gnu)

    ✔ _check_venv_path - returns nothing if not found
    ✔ _check_venv_path - finds .venv in parent directories
    ✔ _check_venv_path - returns nothing with root path
    ✔ check_venv - Security warning for weak permissions

NOTE: It is required that you use a minimum zunit version of 0.8.2


.. _Zplug: https://github.com/zplug/zplug

.. _Antigen: https://github.com/zsh-users/antigen

.. _ZGen: https://github.com/tarjoilija/zgen

.. _oh-my-zsh: https://github.com/robbyrussell/oh-my-zsh

.. |CircleCI| image:: https://circleci.com/gh/MichaelAquilina/zsh-autoswitch-virtualenv.svg?style=svg
   :target: https://circleci.com/gh/MichaelAquilina/zsh-autoswitch-virtualenv

.. |Release| image:: https://badge.fury.io/gh/MichaelAquilina%2Fzsh-autoswitch-virtualenv.svg
   :target: https://badge.fury.io/gh/MichaelAquilina%2Fzsh-autoswitch-virtualenv

.. |ASCIICAST| image:: https://asciinema.org/a/ciDroIzqcC14VEeXMkqdRbvXf.svg
   :target: https://asciinema.org/a/ciDroIzqcC14VEeXMkqdRbvXf

.. |GPLv3| image:: https://img.shields.io/badge/License-GPL%20v3-blue.svg
   :target: https://www.gnu.org/licenses/gpl-3.0
