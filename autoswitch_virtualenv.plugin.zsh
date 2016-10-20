function precmd() {
  check_venv
}

function maybeworkon() {
  if [ "$1" != "$(basename $VIRTUAL_ENV)" ]; then
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
        else
          default_venv
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
    if [[ -f "requirements.txt" ]]; then
      printf "Found a requirements.txt. Install? (Y/n): "
      read install_prompt
      if [[ "$install_prompt" != "n" ]]; then
        pip install -r requirements.txt
      fi
    fi
    echo "$venv_name" > ".venv"
  fi
}
