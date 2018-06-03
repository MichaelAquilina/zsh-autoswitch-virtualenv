Changelog
=========

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
