export AUTOSWITCH_VERSION='0.6.0'

RED="\e[31m"
GREEN="\e[32m"
PURPLE="\e[35m"
BOLD="\e[1m"
NORMAL="\e[0m"

if ! type workon > /dev/null; then
    export DISABLE_AUTOSWITCH_VENV="1"
    printf "${BOLD}${RED}"
    printf "zsh-autoswitch-virtualenv requires virtualenvwrapper to be installed!\n\n"
    printf "${NORMAL}"
    printf "If this is already installed but you are still seeing this message, \nadd the "
    printf "following to your ~/.zshrc:\n\n"
    printf "${BOLD}"
    printf "source =virtualenvwrapper.sh\n"
    printf "\n"
    printf "${NORMAL}"
    printf "https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv#Setup"
    printf "\n"
fi

function _print_python_version() {
   # For some reason python --version writes to stderr
   if type python > /dev/null; then
       printf "${GREEN}[%s]${NORMAL}\n" "$(python --version 2>&1)"
   elif type python3 > /dev/null; then
       printf "${GREEN}[%s]${NORMAL}\n" "$(python3 --version 2>&1)"
   else
       printf "Unable to find python installed on this machine"
    fi
}


function _maybeworkon() {
  if [[ -z "$VIRTUAL_ENV" || "$1" != "$(basename $VIRTUAL_ENV)" ]]; then
     if [ -z "$AUTOSWITCH_SILENT" ]; then
        printf "Switching virtualenv: ${BOLD}${PURPLE}%s${NORMAL} " $1
     fi

     # Much faster to source the activate file directly rather than use the `workon` command
     source "$HOME/.virtualenvs/$1/bin/activate"

     if [ -z "$AUTOSWITCH_SILENT" ]; then
        _print_python_version
     fi
  fi
}


function _maybepipenv() {
  if [[ -z "$VIRTUAL_ENV" || "$1" != "$VIRTUAL_ENV" ]]; then
     if [ -z "$AUTOSWITCH_SILENT" ]; then
        printf "Switching pipenv: ${BOLD}${PURPLE}%s${NORMAL} " "$(basename "$1")"
     fi

     source "$1/bin/activate"

     if [ -z "$AUTOSWITCH_SILENT" ]; then
        _print_python_version
     fi
  fi
}


# Gives the path to the nearest parent .venv file or nothing if it gets to root
function _check_venv_path()
{
    local check_dir=$1

    if [[ -f "${check_dir}/.venv" ]]; then
        printf "${check_dir}/.venv"
        return
    else
        if [ "$check_dir" = "/" ]; then
            return
        fi
        _check_venv_path "$(dirname "$check_dir")"
    fi
}


# Automatically switch virtualenv when .venv file detected
function check_venv()
{
    if [ "AS:$PWD" != "$MYOLDPWD" ]; then
        # Prefix PWD with "AS:" to signify this belongs to this plugin
        # this prevents the AUTONAMEDIRS in prezto from doing strange things
        # See https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv/issues/19
        MYOLDPWD="AS:$PWD"

        SWITCH_TO=""

        # Get the .venv file, scanning parent directories
        venv_path=$(_check_venv_path "$PWD")
        if [[ -n "$venv_path" ]]; then

          stat --version &> /dev/null
          if [[ $? -eq 0 ]]; then   # Linux, or GNU stat
            file_owner="$(stat -c %u "$venv_path")"
            file_permissions="$(stat -c %a "$venv_path")"
          else                      # macOS, or FreeBSD stat
            file_owner="$(stat -f %u "$venv_path")"
            file_permissions="$(stat -f %OLp "$venv_path")"
          fi

          if [[ "$file_owner" != "$(id -u)" ]]; then
            printf "AUTOSWITCH WARNING: Virtualenv will not be activated\n\n"
            printf "Reason: Found a .venv file but it is not owned by the current user\n"
            printf "Change ownership of $venv_path to '$USER' to fix this\n"
          elif ! [[ "$file_permissions" =~ ^[64][04][04]$ ]]; then
            printf "AUTOSWITCH WARNING: Virtualenv will not be activated\n\n"
            printf "Reason: Found a .venv file with weak permission settings ($file_permissions).\n"
            printf "Run the following command to fix this: \"chmod 600 $venv_path\"\n"
          else
            SWITCH_TO="$(<"$venv_path")"
          fi
        fi

        if [[ -n "$SWITCH_TO" ]]; then
          _maybeworkon "$SWITCH_TO"

        # check if Pipfile exists rather than invoking pipenv as it is slow
        elif [[ -a "Pipfile" ]] && type "pipenv" > /dev/null; then
          _maybepipenv "$(pipenv --venv)"
        else
          _default_venv
        fi
    fi
}

# Switch to the default virtual environment
function _default_venv()
{
  if [[ -n "$AUTOSWITCH_DEFAULTENV" ]]; then
     _maybeworkon "$AUTOSWITCH_DEFAULTENV"
  elif [[ -n "$VIRTUAL_ENV" ]]; then
     deactivate
  fi
}


# remove virtual environment for current directory
function rmvenv()
{
  if [[ -f ".venv" ]]; then

    venv_name="$(<.venv)"

    # detect if we need to switch virtualenv first
    if [[ -n "$VIRTUAL_ENV" ]]; then
        current_venv="$(basename $VIRTUAL_ENV)"
        if [[ "$current_venv" = "$venv_name" ]]; then
            _default_venv
        fi
    fi

    rmvirtualenv "$venv_name"
    rm ".venv"
  else
    printf "No .venv file in the current directory!\n"
  fi
}


# helper function to create a virtual environment for the current directory
function mkvenv()
{
  if [[ -f ".venv" ]]; then
    printf ".venv file already exists. If this is a mistake use the rmvenv command\n"
  else
    venv_name="$(basename $PWD)"
    mkvirtualenv "$venv_name" $@

    setopt nullglob
    for requirements in *requirements.txt
    do
      printf "Found a %s file. Install? [y/N]: " "$requirements"
      read ans

      if [[ "$ans" = "y" || "$ans" = "Y" ]]; then
        pip install -r "$requirements"
      fi
    done
    printf "$venv_name\n" > ".venv"
    chmod 600 .venv
    AUTOSWITCH_PROJECT="$PWD"
  fi
}

if [[ -z "$DISABLE_AUTOSWITCH_VENV" ]]; then
    autoload -Uz add-zsh-hook
    add-zsh-hook -D chpwd check_venv
    add-zsh-hook chpwd check_venv

    check_venv
fi
