I don't have any short-run intent to try and separately support POSIX mode, but I reviewed the notes on how it differs in the process of making sure I understand the command resolution order, so I wanted to go ahead and call out the points that might need to be taken into account if resholved did try to handle POSIX mode specifically:

5. Alias expansion always enabled
6. Reserved words appearing in a context where reserved words are recognized do not undergo alias expansion.
14. Function names may not be the same as one of the POSIX special builtins.
15. POSIX special builtins are found before shell functions during command lookup.
18. The 'time' reserved word may be used by itself as a command.  When used in this way, it displays timing statistics for the shell and its completed children.  The 'TIMEFORMAT' variable controls the format of the timing information.
20. The parser does not recognize 'time' as a reserved word if the next token begins with a '-'.

special builtins (https://www.gnu.org/software/bash/manual/html_node/Special-Builtins.html) are	resolved after aliases but before functions (normally, builtins are resolved after functions and before externals)
	break : . continue eval exec exit export readonly return set shift trap unset


import to Mu
import to union
