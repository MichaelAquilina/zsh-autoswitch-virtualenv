Autoswitch Python Virtualenv
============================

Simple ZSH plugin that switches python virtualenvs automatically as you move between directories.

Simply create a `.venv` file with the name of the virtualenv you want to automatically switch to
when you move into the directory. Moving out of the directory will automatically switch back to the
default python virtual environment (currently `defautl3` as this is still a personal WIP).

NOTE that the virutalenv you specify in `.venv` must already exist.
