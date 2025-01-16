#>> ---------------------------------------------------------------------------
#>> Monolith Linux .bash_profile
#>> ---------------------------------------------------------------------------

#>> source .bashrc if found
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

#>> set additional path(s)
PATH=$PATH:$HOME/bin:/usr/local/bin:/usr/local/sbin
export PATH

#>> set umask (restrictive)
umask 077

