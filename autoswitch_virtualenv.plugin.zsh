export AUTOSWITCH_VERSION='1.12.0'

RED="\e[31m"
GREEN="\e[32m"
PURPLE="\e[35m"
BOLD="\e[1m"
NORMAL="\e[0m"

function _virtual_env_dir() {
    local venv_name="$1"
    local VIRTUAL_ENV_DIR="${AUTOSWITCH_VIRTUAL_ENV_DIR:-$HOME/.virtualenvs}"
    mkdir -p "$VIRTUAL_ENV_DIR"
    printf "%s/%s" "$VIRTUAL_ENV_DIR" "$venv_name"
}


function _python_version() {
    local PYTHON_BIN="$1"
    if [[ -f "$PYTHON_BIN" ]] then
        # For some reason python --version writes to stderr
        printf "%s" "$($PYTHON_BIN --version 2>&1)"
    else
        printf "unknown"
    fi
}


function _autoswitch_message() {
    if [ -z "$AUTOSWITCH_SILENT" ]; then
        printf "$@"
    fi
}


function _maybeworkon() {
    local venv_dir="$1"
    local venv_type="$2"
    local venv_name="$(basename $venv_dir)"

    local DEFAULT_MESSAGE_FORMAT="Switching %venv_type: ${BOLD}${PURPLE}%venv_name${NORMAL} ${GREEN}[🐍%py_version]${NORMAL}"
    if [[ "$LANG" != *".UTF-8" ]]; then
        # Remove multibyte characters if the terminal does not support utf-8
        DEFAULT_MESSAGE_FORMAT="${DEFAULT_MESSAGE_FORMAT/🐍/}"
    fi

    if [[ -z "$VIRTUAL_ENV" || "$venv_name" != "$(basename $VIRTUAL_ENV)" ]]; then

        if [[ ! -d "$venv_dir" ]]; then
            printf "Unable to find ${PURPLE}$venv_name${NORMAL} virtualenv\n"
            printf "If the issue persists run ${PURPLE}rmvenv && mkvenv${NORMAL} in this directory\n"
            return
        fi

        local py_version="$(_python_version "$venv_dir/bin/python")"
        local message="${AUTOSWITCH_MESSAGE_FORMAT:-"$DEFAULT_MESSAGE_FORMAT"}"
        message="${message//\%venv_type/$venv_type}"
        message="${message//\%venv_name/$venv_name}"
        message="${message//\%py_version/$py_version}"
        _autoswitch_message "${message}\n"

        # Much faster to source the activate file directly rather than use the `workon` command
        source "$venv_dir/bin/activate"
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
        # Abort search at file system root or HOME directory (latter is a perfomance optimisation).
        if [[ "$check_dir" = "/" || "$check_dir" = "$HOME" ]]; then
            return
        fi
        _check_venv_path "$(dirname "$check_dir")"
    fi
}


# Automatically switch virtualenv when .venv file detected
function check_venv()
{
    local file_owner
    local file_permissions

    # Get the .venv file, scanning parent directories
    local venv_path=$(_check_venv_path "$PWD")
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
            local switch_to="$(<"$venv_path")"
            _maybeworkon "$(_virtual_env_dir "$switch_to")" "virtualenv"
            return
        fi
    fi

    # check if Pipfile exists rather than invoking pipenv as it is slow
    if [[ -a "Pipfile" ]] && type "pipenv" > /dev/null; then
        if venv_path="$(PIPENV_IGNORE_VIRTUALENVS=1 pipenv --venv 2>/dev/null)"; then
            _maybeworkon "$venv_path" "pipenv"
            return
        fi
    fi

    # If we still haven't got anywhere, fallback to defaults
    if [[ -f "$PWD/Pipfile" ]]; then
        printf "Python project detected. "
        printf "Run ${PURPLE}pipenv install${NORMAL} to setup autoswitching\n"
    elif [[ -f "$PWD/requirements.txt" || -f "$PWD/setup.py" ]]; then
        printf "Python project detected. "
        printf "Run ${PURPLE}mkvenv${NORMAL} to setup autoswitching\n"
    fi
    _default_venv
}

# Switch to the default virtual environment
function _default_venv()
{
    if [[ -n "$AUTOSWITCH_DEFAULTENV" ]]; then
        _maybeworkon "$(_virtual_env_dir "$AUTOSWITCH_DEFAULTENV")" "virtualenv"
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        _autoswitch_message "Deactivating: ${BOLD}${PURPLE}%s${NORMAL}\n" "$(basename "$VIRTUAL_ENV")"
        deactivate
    fi
}


# remove virtual environment for current directory
function rmvenv()
{
    if [[ -f ".venv" ]]; then
        local venv_name="$(<.venv)"

        # detect if we need to switch virtualenv first
        if [[ -n "$VIRTUAL_ENV" ]]; then
            local current_venv="$(basename $VIRTUAL_ENV)"
            if [[ "$current_venv" = "$venv_name" ]]; then
                _default_venv
            fi
        fi

        printf "Removing ${PURPLE}%s${NORMAL}...\n" "$venv_name"
        # Using explicit paths to avoid any alias/function interference.
        # rm should always be found in this location according to
        # https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch03s04.html
        # https://www.freedesktop.org/wiki/Software/systemd/TheCaseForTheUsrMerge/
        /bin/rm -rf "$(_virtual_env_dir "$venv_name")"
        /bin/rm ".venv"
    else
        printf "No .venv file in the current directory!\n"
    fi
}


# helper function to create a virtual environment for the current directory
function mkvenv()
{
    if ! type "virtualenv" > /dev/null; then
        printf "${BOLD}${RED}"
        printf "zsh-autoswitch-virtualenv requires virtualenv to be installed!\n\n"
        printf "${NORMAL}"
        printf "If this is already installed but you are still seeing this message, \n"
        printf "then make sure the ${BOLD}virtualenv${NORMAL} command is in your PATH.\n"
        printf "\n"
        return
    fi

    if [[ -f ".venv" ]]; then
        printf ".venv file already exists. If this is a mistake use the rmvenv command\n"
    else
        local venv_name="$(basename $PWD)"

        printf "Creating ${PURPLE}%s${NONE} virtualenv\n" "$venv_name"

        # Copy parameters variable so that we can mutate it
        local params=("${@[@]}")

        if [[ -n "$AUTOSWITCH_DEFAULT_PYTHON" && ${params[(I)--python*]} -eq 0 ]]; then
            params+="--python=$AUTOSWITCH_DEFAULT_PYTHON"
        fi

        if [[ ${params[(I)--verbose]} -eq 0 ]]; then
            virtualenv $params "$(_virtual_env_dir "$venv_name")"
        else
            virtualenv $params "$(_virtual_env_dir "$venv_name")" > /dev/null
        fi

        printf "$venv_name\n" > ".venv"
        chmod 600 .venv

        _maybeworkon "$(_virtual_env_dir "$venv_name")" "virtualenv"

        install_requirements
    fi
}


function install_requirements() {
    if [[ -f "$AUTOSWITCH_DEFAULT_REQUIREMENTS" ]]; then
        printf "Install default requirements? (${PURPLE}$AUTOSWITCH_DEFAULT_REQUIREMENTS${NORMAL}) [y/N]: "
        read ans

        if [[ "$ans" = "y" || "$ans" == "Y" ]]; then
            pip install -r "$AUTOSWITCH_DEFAULT_REQUIREMENTS"
        fi
    fi

    if [[ -f "$PWD/setup.py" ]]; then
        printf "Found a ${PURPLE}setup.py${NORMAL} file. Install dependencies? [y/N]: "
        read ans

        if [[ "$ans" = "y" || "$ans" = "Y" ]]; then
            if [[ "$AUTOSWITCH_PIPINSTALL" = "FULL" ]]
            then
                pip install .
            else
                pip install -e .
            fi
        fi
    fi

    setopt nullglob
    local requirements
    for requirements in **/*requirements.txt
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


enable_autoswitch_virtualenv
check_venv
