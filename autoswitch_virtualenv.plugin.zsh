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

# Automatically switch virtualenv when .venv file detected
function check_venv()
{
    if [ "$PWD" != "$MYOLDPWD" ]; then
        MYOLDPWD="$PWD"
        if [[ -f ".venv" ]]; then
          maybeworkon "$(cat .venv)"
          AUTOSWITCH_PROJECT="$PWD"
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
    venv_name="$(cat .venv)"
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
    for requirements in *requirements.txt
    do
      printf "Found a %s file. Install? [y/N]: " "$requirements"
      if read -q; then
        pip install -r "$requirements"
      fi
    done
    echo "$venv_name" > ".venv"
  fi
}
