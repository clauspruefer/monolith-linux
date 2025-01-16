#>> ---------------------------------------------------------------------------
#>> Monolith Linux .bashrc
#>> ---------------------------------------------------------------------------

#>> define aliases
alias ps='ps -ef'

#>> source /etc/bashrc if existing
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

