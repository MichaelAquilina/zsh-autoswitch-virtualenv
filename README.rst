Autoswitch Python Virtualenv
============================

|CircleCI| |Release| |GPLv3|

*zsh-autoswitch-virtualenv* is a simple ZSH plugin that switches python
virtualenvs automatically as you move between directories.

* `How it Works`_
* `More Details`_
* Installing_
* Setup_
* Commands_
* Options_
* `Security Warnings`_
* `Running Tests`_


How it Works
------------

Simply call the ``mkvenv`` command in the directory you wish to setup a
virtual environment. A virtual environment specific to that folder will
now activate every time you enter it.

See the *Commands* section below for more detail.

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

Add one of the following lines to your ``.zshrc`` file depending on the
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

Setup
-----

``virtualenvwrapper`` must be installed for this plugin to work
correctly. You should install it with pip:

::

    pip install virtualenvwrapper

You need to source this file in your ``.zshrc`` file as part of your
setup. This should work:

::

    source =virtualenvwrapper.sh

**IMPORTANT:** Make sure this is put *before* your package manager loading code (i.e. the
line of code discussed in the section that follows).

In combination, your ``.zshrc`` file should look something like this (if you
are using zplug)

::

    zplug "MichaelAquilina/zsh-autoswitch-virtualenv"
    source =virtualenvwrapper.sh

    zplug load

Commands
--------

mkvenv
''''''

Setup a new project with virtualenv autoswitching using the ``mkvenv``
helper command.

::

    $ cd my-python-project
    $ mkvenv
    Using real prefix '/usr'
    New python executable in /home/michael/.virtualenvs/my-python-project/bin/python2
    Also creating executable in /home/michael/.virtualenvs/my-python-project/bin/python
    Installing setuptools, pip, wheel...done.
    Found a requirements.txt. Install? [y/N]:
    Collecting requests (from -r requirements.txt (line 1))
      Using cached requests-2.11.1-py2.py3-none-any.whl
    Installing collected packages: requests
    Successfully installed requests-2.11.1

Optionally, you can specify the python binary to use for this virtual environment

::

    $ mkvenv --python=/usr/bin/python3

In fact, ``mkvenv`` supports any parameters that can be passed to ``mkvirtualenv``

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

Options
-------

**Setting a default virtual environment**

If you want to set a default virtual environment then you can also
export ``AUTOSWITCH_DEFAULTENV`` in your ``.zshrc`` file.

::

    export AUTOSWITCH_DEFAULTENV="mydefaultenv"
    antigen bundle MichaelAquilina/zsh-autoswitch-virtualenv

**Set verbosity when changing environments**

You can prevent verbose messages from being displayed when moving
between directories. You can do this by setting ``AUTOSWITCH_SILENT`` to
a non-empty value.

Security Warnings
-----------------

zsh-autoswitch-virtualenv will warn you and refuse to activate a virtual
envionrment automatically in the following situations:

-  You are not the owner of the ``.venv`` file found in a directory.
-  The ``.venv`` file has weak permissions. I.e. it is readable or
   writable by other users on the system.

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

.. |CircleCI| image:: https://circleci.com/gh/MichaelAquilina/zsh-autoswitch-virtualenv.svg?style=svg
   :target: https://circleci.com/gh/MichaelAquilina/zsh-autoswitch-virtualenv

.. |Release| image:: https://badge.fury.io/gh/MichaelAquilina%2Fzsh-autoswitch-virtualenv.svg
   :target: https://badge.fury.io/gh/MichaelAquilina%2Fzsh-autoswitch-virtualenv

.. |GPLv3| image:: https://img.shields.io/badge/License-GPL%20v3-blue.svg
   :target: https://www.gnu.org/licenses/gpl-3.0
