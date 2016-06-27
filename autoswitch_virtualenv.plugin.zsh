function precmd() {
  check_venv
}


function maybeworkon() {
  if [ "$1" != "$(basename $VIRTUAL_ENV)" ]; then
     printf "Switching virtualenv: %s  " $1
     workon "$1"
     # For some reason python --version writes to stderr
     printf "[%s]\n" "$(python --version 2>&1)"
  fi
}

# Automatically switch virtualenv when .venv file detected
function check_venv()
{
    if [ "$PWD" != "$MYOLDPWD" ]; then
        MYOLDPWD="$PWD"
        if [[ -f ".venv" ]]; then
           maybeworkon "$(cat .venv)"
        elif [[ -n "$DEFAULT_VIRTUALENV" ]]; then
           maybeworkon "$DEFAULT_VIRTUALENV"
        elif [[ -n "$VIRTUAL_ENV" ]]; then
           deactivate
        fi
    fi
}
