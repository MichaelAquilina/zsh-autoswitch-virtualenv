Autoswitch Python Virtualenv
============================

Simple ZSH plugin that switches python virtualenvs automatically as you move between directories.

Simply create a `.venv` file with the name of the virtualenv you want to automatically switch to
when you move into the directory. Moving out of the directory will automatically switch back to the
default python virtual environment - set by `DEFAULT_VIRTUALENV` environment variable. If
`DEFAULT_VIRTUALENV` has not been set, then moving to a directory without a `.venv` file will simply
deactivate any currently active virtualenv.

NOTE that the virutalenv you specify in `.venv` must already exist.

Requirements
------------

`virtualenvwrapper` must be installed for this plugin to work correctly.

On Ubuntu simply install from the standard repositories:

`sudo apt-get install virtualenvwrapper`

Mac OSX can install `virtualenvwrapper` from brew:

`brew install virtualenvwrapper`
