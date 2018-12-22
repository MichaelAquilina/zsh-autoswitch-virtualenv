Changelog
=========

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
