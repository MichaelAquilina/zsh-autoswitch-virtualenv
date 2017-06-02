function precmd() {
  check_venv
}

function maybeworkon() {
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
function check_venv_path()
{
    local check_dir=$1

    if [[ -f "${check_dir}/.venv" ]]; then
        echo "${check_dir}/.venv"
        return
    else
        if [ "$check_dir" = "/" ]; then
            return
        fi
        check_venv_path $(dirname "$check_dir")
    fi
}


# Automatically switch virtualenv when .venv file detected
function check_venv()
{
    if [ "$PWD" != "$MYOLDPWD" ]; then
        MYOLDPWD="$PWD"

        SWITCH_TO=""

        venv_path=$(check_venv_path "$PWD")
        if [[ -n "$venv_path" ]]; then
          file_owner="$(stat -c %u "$venv_path")"
          file_permissions="$(stat -c %a "$venv_path")"

          if [[ "$file_owner" != "$(id -u)" ]]; then
            echo "AUTOSWITCH WARNING: Virtualenv will not be activated"
            echo ""
            echo "Reason: Found a .venv file but it is not owned by the current user"
            echo "Change ownership of $venv_path to '$USER' to fix this"
          elif [[ "$file_permissions" != "600" ]]; then
            echo "AUTOSWITCH WARNING: Virtualenv will not be activated"
            echo ""
            echo "Reason: Found a .venv file with weak permission settings ($file_permissions)."
            echo "Run the following command to fix this: \"chmod 600 .venv\""
          else
            SWITCH_TO="$(<"$venv_path")"
            AUTOSWITCH_PROJECT="$PWD"
          fi
        fi

        if [[ -n "$SWITCH_TO" ]]; then
          maybeworkon "$SWITCH_TO"
        elif [[ "$PWD" != "$AUTOSWITCH_PROJECT/"* ]]; then
          default_venv
          AUTOSWITCH_PROJECT=""
        fi
    fi
}

# Switch to the default virtual environment
function default_venv()
{
  if [[ -n "$AUTOSWITCH_DEFAULTENV" ]]; then
     maybeworkon "$AUTOSWITCH_DEFAULTENV"
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
      default_venv
    fi
    rmvirtualenv "$venv_name"
    rm ".venv"
  else
    echo "No .venv file in the current directory!"
  fi
}


# helper function to create a virtual environment for the current directory
function mkvenv()
{
  if [[ -f ".venv" ]]; then
    echo ".venv file already exists. If this is a mistake use the rmvenv command"
  else
    venv_name="$(basename $PWD)"
    mkvirtualenv "$venv_name" $@

    setopt nullglob
    for requirements in *requirements.txt
    do
      printf "Found a %s file. Install? [y/N]: " "$requirements"
      if read -q; then
        pip install -r "$requirements"
      fi
    done
    echo "$venv_name" > ".venv"
    chmod 600 .venv
  fi
}
