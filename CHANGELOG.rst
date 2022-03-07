Changelog
=========

3.5.0
-----
* Add support for virtualenv directories created by `python -m venv` (#168 thanks @afeblot)

3.4.0
-----
* Remove `pwgen` dependency. Thanks (#166 @hauntsaninja)

3.3.2
-----
* Dont attempt to activate a Pipenv or Poetry project if they are not installed (#161 thanks @stevenxxiu)

3.3.1
-----
* Fixed a bug where shell enviroments would become slow after autoswitching (#159 Thanks @yut13)

3.3.0
-----
* virtualenv names are now generated with a random prefixed string. This will prevent multiple directories which share the same name from causing conflicts.
* pwgen is now a requirement for running zsh-autoswitch-virtualenv
* display if AUTOSWITCH_DEFAULT_PYTHON is used during mkvenv command

3.2.0
-----
* Fix case where autoswitch would not activate correctly when starting in a directory which has a .venv set

3.1.1
-----
* Fix poetry switching when multiple venvs are available (#144) (Thanks @hauntsaninja)

3.1.0
-----
* Correctly determine location of poetry virtualenvs based on configuration

3.0.2
-----
* Correctly determine virtualenv paths for poetry on Mac OSX

3.0.1
-----
* Fix issue where poetry projects would not activate if another virtualenv is already activated (#134)

3.0.0
-----
* Improve integration support for poetry and pipenv. The ``mkvenv`` and ``rmvenv`` commands work as expected.
* Improve detection of poetry projects by looking for "poetry.lock" rather than "pyproject.toml"

2.0.1
-----
* Fix issue where poetry would incorrectly try activate in projects with pyproject.toml but no poetry setup (Issue #130) (Thanks @hauntsaninja)

2.0.0
-----
* Support autoswitching of poetry projects

1.16.2
------
* Output messages to stderr instead of stdout

1.16.1
------
* Small improvement to zsh 5.0 compatibility

1.16.0
------
* Fix insecure activation of virtualenvs (#122)

1.15.2
------
* Use absolute path for ``/usr/bin/stat`` to prevent conflicts with other ``stat`` binaries. Fixes #110

1.15.1
------
* Fix detection of pipenv projects from subdirectories

1.15.0
------
* Add AUTOSWITCH_FILE configuration option

1.14.0
------
* Prevent pipenv from showing its courtesy because we activated its virtualenv

1.13.0
------
* Clean up pipenv names when displaying them

1.12.0
------
* Remove virtualenv requirement. This is now only needed for running mkvenv

1.11.1
------
* Fix bug with pipenv detection where extra messages would be incorrectly displayed
* Add zsh 5.7 to the CI testing process

1.11.0
------
* Correct project detection behaviour when working with pipenv

1.10.1
------
* Fix minor bug where variables would leak into user's environment

1.10.0
------
* Scan for requirements files recursively when setting up a virtualenv (#88 - fix by @nrc)
* Fix bug when `rm` was aliased to a different behaviour (#87 - fix by @rnc)
* Invoke pip install in editable (i.e. development) mode. (#91 - fix by @rnc)

1.9.0
-----
* Show message when deactivating virtual environments

1.8.2
-----
* local variables will no longer sneak into shell environment variables (Thanks @rnc)

1.8.1
-----
* Fixes a regression in Pipenv integration

1.8.0
-----
* Prompt to install requirements.txt even if setup dependencies installed

1.7.0
-----
* Add option to set default python binary to use when creating virtualenvs
* Add option to set default requirements file to install when creating virtualenvs

1.6.0
-----
* Display snake emoji by default when switching virtualenvs
* Minor tweaks and changes

1.5.0
-----
* Detect python projects with `setup.py`


1.4.1
-----
* Show helpful error message when target virtualenv is not found


1.3.1
-----
* Remove redundancy in directory checking logic
* Display help message when python project is detected

1.2.1
-----
* Improvements to coloring of output
* Add enable/disable command
* allow --verbose option with mkvenv
* allow user to specify location of virtual env directories


1.1.1
-----
* Hotfix: Fix conflict with you-should-use plugin default message

1.1.0
-----
* Switch messages can now be customised with the AUTOSWITCH_MESSAGE_FORMAT environment variable
* help text is now displayed when virtualenv is not installed

1.0.0
-----
* Remove dependency on virtualenvwrapper. autoswitch-virtualenv now works directly with virtualenv

0.7.0
-----
* Vastly improve the performance of switching environments

0.6.0
-----
* Improve plugin performance when checking for virtualenvs

0.5.1
-----
* Improve color output. Virtualenv name now displayed in purple


0.5.0
-----
* Color python version output when switching virtualenvs

0.4.0
-----
* Add support for detecting and auto activating with pipenv

0.3.6
-----
* Fix bug where version was not in sync with git

0.3.5
-----
* allow readable permissions for everyone and group
* Fixes to README

0.3.4
-----
* export autoswitch version

0.3.3
-----
* Improve help message formatting when plugin is not setup correctly

0.3.2
-----
* Fix bug #19 where MYOLDPWD would get set in window titles (zprezto).

0.3.1
-----
* Make help message clearer if virutalenvwrapper is not setup correctly

0.3.0
-----
* Disable plugin and print help message if virtualenvwrapper not setup correctly
* Fix bug in rmvenv when no virtualenv was activated
* Fix flaky tests

0.2.1
-----
* Add tests for mkvenv and check_venv


0.2.0
-----
* Introduce Changelog
* Fix tests and CI process
* use printf instead of echo for better system portability
* Add ability to disable loading hooks and running initial check_venv using DISABLE_AUTOSWITCH_VENV
* Introduce restructuredtext linter to CI
* Test ZSH 5.4.2 in CI
