#! /bin/sh
ulimit -v 4000000

WIKISTATS=/a/wikistats_git
SQUIDS=$WIKISTATS/squids
REPORTS=$SQUIDS/reports
#PERL=/home/ezachte/wikistats/squids/perl/ # tests
PERL=$SQUIDS/perl
CSV=$SQUIDS/csv
LOGS=$SQUIDS/logs
cd $PERL

LOG1=$LOGS/SquidCountryScan.log
LOG2=$LOGS/SquidReportArchive.log
CONFIG_FILE_SWITCH=""

#MONTH=2012-09 # adjust each month 
#QUARTER=2012Q3

RUNTYPE=""

PROCESSTYPE=""

ARG_MONTH=""
ARG_QUARTER=""

while getopts "hsecq:m:" optname
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
			CONFIG_FILE_SWITCH="-r ../conf-editors/SquidReportArchiveConfig-editors.pm"
			LOG="$LOGS/SquidCountArchive-editors.log"
			;;
		"m")
			echo "Running monthly report for $OPTARG"
			if [ $(echo "$OPTARG" | egrep "^[0-9]{4}-[0-9]{2}$" | wc -l) -ne 1 ]; then
				echo "[ERROR] Month parameter should be of the form  YYYY-MM";
				exit 2;
			fi
			ARG_MONTH=$OPTARG
			PROCESSTYPE="monthly"
			;;
		"q")
			echo "Running monthly report for $OPTARG"
			if [ $(echo "$OPTARG" | egrep "^[0-9]{4}Q[1-4]$" | wc -l) -ne 1 ]; then
				echo "[ERROR] Month parameter should be of the form  YYYYQ[1-4]";
				exit 3;
			fi
			ARG_QUARTER=$OPTARG
			PROCESSTYPE="quarter"
			;;
		"c")
			PROCESSTYPE="country-scan"
			;;
		"h")  
			echo "SquidReportArchive.sh script"
			echo ""
			echo "USAGE: SquidReportArchive.sh -[se] -[cqm] <args>"
			echo ""
			echo " -s           -  Use CSVs resulted from sampled squid   log files"
			echo " -e           -  Use CSVs resulted from sampled editors log files"
			echo " -c           -  Country scan "
			echo " -q <quarter> -  Quarter run with parameter between 1 and 4  "
			echo " -m <month>   -  Monthly run with parameter of the form YYYY-MM ( ex. 2012-09 )"
			echo ""
			exit 0;
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


# shows every command run (good for debugging)
#set -x

if [ "$PROCESSTYPE" != "country-scan" -a \( "$RUNTYPE" != "sampled" -a "$RUNTYPE" != "editors" \) ]; then
	echo "[ERROR] Use -s or -e to specify what kind of run you're doing";
	exit 4;
fi

case "$PROCESSTYPE" in
	monthly)
		echo "Processing $PROCESSTYPE"
		MONTH=$ARG_MONTH
		perl    SquidReportArchive.pl	  \
			-m $MONTH		  \
			-p | tee -a $LOG2 | cat
		cd $REPORTS/$MONTH
		tar -cvf - *.htm | gzip > reports-$MONTH.tar.gz
		;;
	quarter)
		echo "Processing $PROCESSTYPE"
		;;
	country-scan)
		echo "Processing $PROCESSTYPE"
		perl SquidCountryScan.pl
		;;
	*)
		echo "[ERROR] No processing type was selected (use one of -q -m -c)"
		exit 6;
		;;
esac

# once every so many months refresh meta info from English Wikipedia 
# perl SquidReportArchive.pl -w | tee -a $log | cat

# perl SquidReportArchive.pl -m 201007 > $log
# after further automating SquidScanCountries.sh

# perl SquidCountryScan.pl                  | tee -a $log1 | cat # collect csv data for all months, start in July 2009
# perl SquidReportArchive.pl -c             | tee -a $log2 | cat # -c for per country reports
# perl SquidReportArchive.pl -c -q $quarter | tee -a $log2 | cat # -c for per country reports

# after vetting reports are now manually rsynced to 
# - stat1001/a/srv/stats.wikimedia.org/htdocs/wikimedia/squids
# - stat1001/a/srv/stats.wikimedia.org/htdocs/archive/squid_reports/$month
# note: all gif and js files are also needed locally, that should change to shared location  
