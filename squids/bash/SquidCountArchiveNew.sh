#!/bin/bash
ulimit -v 4000000

RUNTYPE=""
CONFIG_FILE_SWITCH=""
LOG=""
WIKISTATS=/a/wikistats_git
SQUIDS=$WIKISTATS/squids
PERL=$SQUIDS/perl
PERL=/home/ezachte/wikistats/perl # tests
LOGS=$SQUIDS/logs
cd $PERL

while getopts "se" optname
do
	case "$optname" in
		"s")
			echo "Running SquidCountArchive for sampled log archives";
			RUNTYPE="sampled"
			CONFIG_FILE_SWITCH=""
			LOG="$LOGS/SquidCountArchive.log"
			;;
		"e")
			echo "Running SquidCountArchive for editors log archives";
			RUNTYPE="editors"
			CONFIG_FILE_SWITCH="-r ../conf-editors/SquidCountArchiveConfig-editors.pm"
			LOG="$LOGS/SquidCountArchive-editors.log"
			;;
		"?")
			echo "Option not recognized $OPTARG"
			echo "Please specify either 's' for regular sampled files or 'e' for editor archives"
			;;
		":")
			echo "Argument missing for option $OPTARG"
			;;
		*)
			# Should not occur
			echo "Unknown error while option processing"
			echo "Maybe you didn't specify any parameters ?"
			;;
	esac
done

if [ "$RUNTYPE" != "sampled" -a "$RUNTYPE" != "editors" ]; then
	echo "[ERROR] Use -s or -e to specify what kind of run you're doing"
	exit 3;
fi

# let bash print every command so you know what is running
# (good for debugging)
set -x

echo "nice perl				     \
	SquidCountArchive.pl	     \
	-d 2013/02/01-2013/02/01     \
	$CONFIG_FILE_SWITCH          \
	-p | tee $LOG | cat"
