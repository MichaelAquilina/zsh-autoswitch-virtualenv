Autoswitch Python Virtualenv
============================

Simple ZSH plugin that switches python virtualenvs automatically as you move between directories.

Simply create a `.venv` file with the name of the virtualenv you want to automatically switch to
when you move into the directory. Moving out of the directory will automatically switch back to the
default python virtual environment - set by the `AUTOSWITCH_DEFAULTENV` environment variable. If
`AUTOSWITCH_DEFAULTENV` has not been set, then moving to a directory without a `.venv` file will simply
deactivate any currently active virtualenv.

NOTE that the virutalenv you specify in `.venv` must already exist.

:tada: Pull Requests for fixes or improvements are welcome! :tada:

Requirements
------------

`virtualenvwrapper` must be installed for this plugin to work correctly.

On Ubuntu simply install from the standard repositories:

`sudo apt-get install virtualenvwrapper`

Mac OSX can install `virtualenvwrapper` from brew:

`brew install virtualenvwrapper`


Installation from Antigen
-------------------------

Installing from [Antigen](https://github.com/zsh-users/antigen) is super easy! Just add the following line to your `.zshrc`:

```
antigen bundle MichaelAquilina/zsh-autoswitch-virtualenv
```

Installation with Zgen
----------------------

Installing with [Zgen](https://github.com/tarjoilija/zgen) is super easy! Just add the following line to your `.zshrc`:

```zgen load unixorn/tumult.plugin.zsh```

where you're doing your other `zgen load` calls.


Setting a default virtualenv
----------------------------
```
if you want to set a default virtual environment then you can also export `AUTOSWITCH_DEFAULTENV` in
your `.zshrc` file.

```
export AUTOSWITCH_DEFAULTENV="mydefaultenv"
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
If you have set the `AUTOSWITCH_DEFAULTENV` environment variable, exiting that directory will switch
back to the value set.
```
$ cd ..
Switching virtualenv: mydefaultenv  [Python 3.4.3+]
$
```
Otherwise, `deactivate` will simply be called on the virtualenv to switch back to the global
python environment.

Options
-------

Right now the only option available is to prevent verbose messages from being displayed when moving
between directories. You can do this by setting `AUTOSWITCH_SILENT` to a non-empty value.
