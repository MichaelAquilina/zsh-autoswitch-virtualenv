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


Installation from Antigen
-------------------------

Installing from Antigen is super easy! Just add the following line to your `.zshrc`:

```
antigen bundle MichaelAquilina/zsh-autoswitch-virtualenv
```
if you want to set a default virtual environment then you can also export `DEFAULT_VIRTUALENV` in
your `.zshrc` file.

```
export DEFAULT_VIRTUALENV="mydefaultenv"
antigen bundle MichaelAquilina/zsh-autoswitch-virtualenv
```

Example:
--------

Setup a new project with virtualenv autoswitching
```
$ cd my-python-project
$ mkvirtualenv my-python-project
$ echo "my-python-project" > .venv
```
Next time you switch to that folder, you'll see the following message
```
$ cd my-python-project
Switching virtualenv: my-python-project  [Python 3.4.3+]
$
```
If you have set the `DEFAULT_VIRTUALENV` environment variable, exiting that directory will switch
back to the value set.
```
$ cd ..
Switching virtualenv: mydefaultenv  [Python 3.4.3+]
$
```
Otherwise, `deactivate` will simply be called on the virtualenv to switch back to the global
python environment.
