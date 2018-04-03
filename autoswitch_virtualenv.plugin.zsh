function _maybeworkon() {
  if [[ -z "$VIRTUAL_ENV" || "$1" != "$(basename $VIRTUAL_ENV)" ]]; then
     if [ -z "$AUTOSWITCH_SILENT" ]; then
        printf "Switching virtualenv: %s  " $1
     fi

     workon "$1"

     if [ -z "$AUTOSWITCH_SILENT" ]; then
       # For some reason python --version writes to stderr
       printf "[%s]\n" "$(python --version 2>&1)"
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
    if [ "$PWD" != "$MYOLDPWD" ]; then
        MYOLDPWD="$PWD"

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
          elif [[ "$file_permissions" != "600" ]]; then
            printf "AUTOSWITCH WARNING: Virtualenv will not be activated\n\n"
            printf "Reason: Found a .venv file with weak permission settings ($file_permissions).\n"
            printf "Run the following command to fix this: \"chmod 600 $venv_path\"\n"
          else
            SWITCH_TO="$(<"$venv_path")"
          fi
        fi

        if [[ -n "$SWITCH_TO" ]]; then
          _maybeworkon "$SWITCH_TO"
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


# remove virutal environment for current directory
function rmvenv()
{
  if [[ -f ".venv" ]]; then
    venv_name="$(<.venv)"
    current_venv="$(basename $VIRTUAL_ENV)"
    if [[ "$current_venv" = "$venv_name" ]]; then
      _default_venv
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

autoload -Uz add-zsh-hook
add-zsh-hook -D chpwd check_venv
add-zsh-hook chpwd check_venv

# auto-detect virtualenv on zsh startup
[[ -o interactive ]] && check_venv
