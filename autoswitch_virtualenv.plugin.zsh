export AUTOSWITCH_VERSION='1.2.1'

RED="\e[31m"
GREEN="\e[32m"
PURPLE="\e[35m"
BOLD="\e[1m"
NORMAL="\e[0m"


if ! type "virtualenv" > /dev/null; then
    export DISABLE_AUTOSWITCH_VENV="1"
    printf "${BOLD}${RED}"
    printf "zsh-autoswitch-virtualenv requires virtualenv to be installed!\n\n"
    printf "${NORMAL}"
    printf "If this is already installed but you are still seeing this message, \n"
    printf "then make sure the ${BOLD}virtualenv${NORMAL} command is in your PATH.\n"
    printf "\n"
fi


function _virtual_env_dir() {
    local VIRTUAL_ENV_DIR="${AUTOSWITCH_VIRTUAL_ENV_DIR:-$HOME/.virtualenvs}"
    mkdir -p "$VIRTUAL_ENV_DIR"
    printf "%s" "$VIRTUAL_ENV_DIR"
}


function _python_version() {
   PYTHON_BIN="$1"
   if [[ -f "$PYTHON_BIN" ]] then
       # For some reason python --version writes to stderr
       printf "%s" "$($PYTHON_BIN --version 2>&1)"
   else
       printf "unknown"
   fi
}


function _maybeworkon() {
  venv_name="$1"
  venv_type="$2"

  DEFAULT_MESSAGE_FORMAT="Switching %venv_type: ${BOLD}${PURPLE}%venv_name${NORMAL} ${GREEN}[%py_version]${NORMAL}"

  if [[ -z "$VIRTUAL_ENV" || "$venv_name" != "$(basename $VIRTUAL_ENV)" ]]; then
     if [ -z "$AUTOSWITCH_SILENT" ]; then
        py_version="$(_python_version "$(_virtual_env_dir)/$venv_name/bin/python")"

        message="${AUTOSWITCH_MESSAGE_FORMAT:-"$DEFAULT_MESSAGE_FORMAT"}"
        message="${message//\%venv_type/$venv_type}"
        message="${message//\%venv_name/$venv_name}"
        message="${message//\%py_version/$py_version}"
        printf "${message}\n"
     fi

     # Much faster to source the activate file directly rather than use the `workon` command
     source "$(_virtual_env_dir)/$venv_name/bin/activate"
  fi
}


# Gives the path to the nearest parent .venv file or nothing if it gets to root
function _check_venv_path()
{
    local check_dir="$1"

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
            printf "Change ownership of ${PURPLE}$venv_path${NORMAL} to ${PURPLE}'$USER'${NORMAL} to fix this\n"
          elif ! [[ "$file_permissions" =~ ^[64][04][04]$ ]]; then
            printf "AUTOSWITCH WARNING: Virtualenv will not be activated\n\n"
            printf "Reason: Found a .venv file with weak permission settings ($file_permissions).\n"
            printf "Run the following command to fix this: ${PURPLE}\"chmod 600 $venv_path\"${NORMAL}\n"
          else
            SWITCH_TO="$(<"$venv_path")"
          fi
        fi

        if [[ -n "$SWITCH_TO" ]]; then
          _maybeworkon "$SWITCH_TO" "virtualenv"

        # check if Pipfile exists rather than invoking pipenv as it is slow
        elif [[ -a "Pipfile" ]] && type "pipenv" > /dev/null; then
          venv_path="$(PIPENV_IGNORE_VIRTUALENVS=1 pipenv --venv)"
          _maybeworkon "$(basename "$venv_path")" "pipenv"
        else
          _default_venv
        fi
    fi
}

# Switch to the default virtual environment
function _default_venv()
{
  if [[ -n "$AUTOSWITCH_DEFAULTENV" ]]; then
     _maybeworkon "$AUTOSWITCH_DEFAULTENV" "virtualenv"
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

    printf "Removing ${PURPLE}%s${NORMAL}...\n" "$venv_name"
    rm -rf "$(_virtual_env_dir)/$venv_name"
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

    printf "Creating ${PURPLE}%s${NONE} virtualenv\n" "$venv_name"

    if [[ ${@[(ie)--verbose]} -eq ${#@} ]]; then
        virtualenv $@ "$(_virtual_env_dir)/$venv_name"
    else
        virtualenv $@ "$(_virtual_env_dir)/$venv_name" > /dev/null
    fi

    printf "$venv_name\n" > ".venv"
    chmod 600 .venv

    _maybeworkon "$venv_name"

    install_requirements
  fi
}


function install_requirements() {
    setopt nullglob
    for requirements in *requirements.txt
    do
      printf "Found a ${PURPLE}%s${NORMAL} file. Install? [y/N]: " "$requirements"
      read ans

      if [[ "$ans" = "y" || "$ans" = "Y" ]]; then
        pip install -r "$requirements"
      fi
    done
}


function enable_autoswitch_virtualenv() {
    autoload -Uz add-zsh-hook
    disable_autoswitch_virtualenv
    add-zsh-hook chpwd check_venv
}


function disable_autoswitch_virtualenv() {
    add-zsh-hook -D chpwd check_venv
}


if [[ -z "$DISABLE_AUTOSWITCH_VENV" ]]; then
    enable_autoswitch_virtualenv
    check_venv
fi
