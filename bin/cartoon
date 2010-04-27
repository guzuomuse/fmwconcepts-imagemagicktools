#!/bin/bash
#
# Developed by Fred Weinhaus 4/4/2010 .......... revised 4/4/2010
# 
# USAGE: cartoon [-m method] [-n numcolors] [-i imagefilter] [-e edgefilter] [-p pctedges] [-s smooth] infile outfile
# USAGE: cartoon [-h or -help]
# 
# OPTIONS:
# 
# -m      method            method of color reduction; choices are 1 or 2;
#                           default=1
# -n      numcolors         number of desired colors; integer>0; default=10
# -i      imagefilter       size of median filter to preprocess image; 
#                           integer>=0; default=2
# -e      edgefilter        size of median filter to preprocess grayscale image 
#                           before extracting gradient edges; integer>=0; default=2
# -p      pctedges          percentage of edges to use from gradient images; 
#                           0<=integer<=100; default=75
# -s      smooth            size of blur filter to smooth the image before 
#                           applying the edges; float>=0
# 
###
# 
# NAME: CARTOON 
# 
# PURPOSE: To create a cartoon-like appearance to an image.
# 
# DESCRIPTION: CARTOON creates a cartoon-like appearance to an image. The 
# image is color reduced to try to achieve the desired number of colors. There 
# are two methods to do this. The first is not terribly sensitive to the 
# desired number of colors. Values in the range of about 6-14 generally produce 
# the same result. But the image can be a bit noisy/grainy, so post smoothing 
# is generally needed. The second produces different results for different 
# desired number of colors and generally is not as noise sensitive. Edges can 
# then be superimposed onto the image. The edges are produced by a gradient 
# edge detector.
# 
# 
# ARGUMENTS: 
# 
# -m method ... METHOD is the color reduction method. The choices are 1 or 2. 
# Method 1 uses the IM -colors function channel-by-channel. Method 2 computes 
# a -fx formula and is applied via -clut. The default=1
# 
# -n numcolors ... NUMCOLORS is the desired number of reduced colors. Values 
# are integers>0. The default=10.
# 
# -i imagefilter ... IMAGEFILTER is the size of a median filter that will be 
# applied to the image before reducing colors. Values are integers>=0. The 
# default=2.
# 
# -e edgefilter ... EDGEFILTER is the size of a median filter that will be 
# applied to a grayscale version of the image before extracting edges. Values 
# are integers>=0. The default=2.
# 
# -p pctedges ... PCTEDGES is the percentage of the edges from the gradient 
# edge extraction from the grayscale image to overlay on the image. Values 
# are 0<=integer<=100. The default=75.
# 
# -s smooth ... SMOOTH is the amount of (-blur) smoothing to apply to the color 
# reduced image before the edges are overlayed. Values are floats>=0. 
# The default=1.
# 
# CAVEAT: No guarantee that this script will work on all platforms, 
# nor that trapping of inconsistent parameters is complete and 
# foolproof. Use At Your Own Risk. 
# 
######
# 

# set default values
method=1			# color reduction method: 1 or 2
numcolors=10		# number of colors
imagefilter=2		# median filter image
edgefilter=2		# median filter grayscale image for edges
pctedges=75			# percent edge threshold
smooth=1			# post smooth image before applying edges

# set directory for temporary files
dir="."    # suggestions are dir="." or dir="/tmp"

# set up functions to report Usage and Usage with Description
PROGNAME=`type $0 | awk '{print $3}'`  # search for executable on path
PROGDIR=`dirname $PROGNAME`            # extract directory of program
PROGNAME=`basename $PROGNAME`          # base name of program
usage1() 
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -n '/^###/q;  /^#/!q;  s/^#//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}
usage2() 
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -n '/^######/q;  /^#/!q;  s/^#*//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}


# function to report error messages
errMsg()
	{
	echo ""
	echo $1
	echo ""
	usage1
	exit 1
	}


# function to test for minus at start of value of second part of option 1 or 2
checkMinus()
	{
	test=`echo "$1" | grep -c '^-.*$'`   # returns 1 if match; 0 otherwise
    [ $test -eq 1 ] && errMsg "$errorMsg"
	}

# test for correct number of arguments and get values
if [ $# -eq 0 ]
	then
	# help information
   echo ""
   usage2
   exit 0
elif [ $# -gt 14 ]
	then
	errMsg "--- TOO MANY ARGUMENTS WERE PROVIDED ---"
else
	while [ $# -gt 0 ]
		do
			# get parameter values
			case "$1" in
		  -h|-help)    # help information
					   echo ""
					   usage2
					   exit 0
					   ;;
				-m)    # get method
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID METHOD SPECIFICATION ---"
					   checkMinus "$1"
					   method=`expr "$1" : '\([0-9]*\)'`
					   [ "$method" = "" ] && errMsg "--- METHOD=$method MUST BE A NON-NEGATIVE INTEGER ---"
					   [ $method -ne 1 -a $method -ne 2 ] && errMsg "--- METHOD=$method MUST BE EITHER 1 OR 2 ---"
					   ;;
				-n)    # get  numcolors
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID NUMCOLORS SPECIFICATION ---"
					   checkMinus "$1"
					   numcolors=`expr "$1" : '\([0-9]*\)'`
					   [ "$numcolors" = "" ] && errMsg "--- NUMCOLORS=$numcolors MUST BE A NON-NEGATIVE INTEGER VALUE (with no sign) ---"
					   test=`echo "$numcolors < 0" | bc`
					   [ $test -eq 1 ] && errMsg "--- NUMCOLORS=$numcolors MUST BE A POSITIVE INTEGER ---"
					   ;;
				-i)    # get  imagefilter
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID IMAGEFILTER SPECIFICATION ---"
					   checkMinus "$1"
					   imagefilter=`expr "$1" : '\([0-9]*\)'`
					   [ "$imagefilter" = "" ] && errMsg "--- IMAGEFILTER=$imagefilter MUST BE A NON-NEGATIVE INTEGER VALUE (with no sign) ---"
					   ;;
				-e)    # get  edgefilter
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID EDGEFILTER SPECIFICATION ---"
					   checkMinus "$1"
					   edgefilter=`expr "$1" : '\([0-9]*\)'`
					   [ "$edgefilter" = "" ] && errMsg "--- EDGEFILTER=$edgefilter MUST BE A NON-NEGATIVE INTEGER VALUE (with no sign) ---"
					   ;;
				-p)    # get pctedges
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID PCTEDGES SPECIFICATION ---"
					   checkMinus "$1"
					   pctedges=`expr "$1" : '\([0-9]*\)'`
					   [ "$pctedges" = "" ] && errMsg "--- PCTEDGES=$pctedges MUST BE A NON-NEGATIVE INTEGER VALUE (with no sign) ---"
					   test1=`echo "$pctedges < 0" | bc`
					   test2=`echo "$pctedges > 100" | bc`
					   [ $test1 -eq 1 -o $test2 -eq 1 ] && errMsg "--- PCTEDGES=$pctedges MUST BE AN INTEGER BETWEEN 0 AND 100 ---"
					   ;;
				-s)    # get  smooth
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID SMOOTH SPECIFICATION ---"
					   checkMinus "$1"
					   smooth=`expr "$1" : '\([.0-9]*\)'`
					   [ "$smooth" = "" ] && errMsg "--- SMOOTH=$smooth MUST BE A NON-NEGATIVE FLOAT (with no sign) ---"
					   ;;
				 -)    # STDIN and end of arguments
					   break
					   ;;
				-*)    # any other - argument
					   errMsg "--- UNKNOWN OPTION ---"
					   ;;
		     	 *)    # end of arguments
					   break
					   ;;
			esac
			shift   # next option
	done
	#
	# get infile and outfile
	infile=$1
	outfile=$2
fi

# test that infile provided
[ "$infile" = "" ] && errMsg "NO INPUT FILE SPECIFIED"

# test that outfile provided
[ "$outfile" = "" ] && errMsg "NO OUTPUT FILE SPECIFIED"

# setup temporary images and auto delete upon exit
tmpA1="$dir/cartoon_1_$$.mpc"
tmpB1="$dir/cartoon_1_$$.cache"
tmpA2="$dir/cartoon_2_$$.mpc"
tmpB2="$dir/cartoon_2_$$.cache"
tmpA3="$dir/cartoon_3_$$.mpc"
tmpB3="$dir/cartoon_3_$$.cache"
trap "rm -f $tmpA1 $tmpB1 $tmpA2 $tmpB2 $tmpA3 $tmpB3; exit 0" 0
trap "rm -f $tmpA1 $tmpB1 $tmpA2 $tmpB2 $tmpA3 $tmpB3; exit 1" 1 2 3 15

# read the input image and filter image into the temp files and test validity.
convert -quiet -regard-warnings "$infile" -colorspace RGB +repage "$tmpA1" ||
	errMsg "--- FILE $infile DOES NOT EXIST OR IS NOT AN ORDINARY FILE, NOT READABLE OR HAS ZERO SIZE  ---"


# define x and y derivative filters
# DX
# -1 0 1
# -1 0 1
# -1 0 1
dx="-1,0,1,-1,0,1,-1,0,1"
# DY
# 1 1 1
# 0 0 0
# -1 -1 -1
dy="1,1,1,0,0,0,-1,-1,-1"


# set up color image median
if [ $imagefilter -ne 0 ]; then
	medianize1="-median $imagefilter"
else
	medianize1=""
fi

# set up grayscale image median
if [ $edgefilter -ne 0 ]; then
	medianize2="-median $edgefilter"
else
	medianize2=""
fi

# set up smoothing
if [ "$smooth" != "0" ]; then
	smoothing="-blur 0x$smooth"
else
	smoothing=""
fi

# reduce colors
if [ $method -eq 1 ]; then
	convert $tmpA1 $medianize1 -separate -colors $numcolors +dither \
		-combine $smoothing $tmpA2
else
	convert \( $tmpA1 -median 2 \) \
		\( -size 1x256 gradient: -rotate 90 \
		-fx "floor(u*$numcolors+0.5)/$numcolors" \) \
		-clut $tmpA2
fi

# create and composite image with edges
if [ $pctedges -ne 0 ]; then
	# create thresholded gradient edge image
	convert \( $tmpA1 -colorspace gray $medianize2 \) \
		\( -clone 0 -bias 50% -convolve "$dx" -solarize 50% \) \
		\( -clone 0 -bias 50% -convolve "$dy" -solarize 50% \) \
		\( -clone 1 -clone 1 -compose multiply -composite -gamma 2 \) \
		\( -clone 2 -clone 2 -compose multiply -composite -gamma 2 \) \
		-delete 0-2 -compose plus -composite -threshold ${pctedges}% $tmpA3

	# composite with reduced color image
	convert $tmpA2 $tmpA3 -compose multiply -composite $outfile
else
	convert $tmpA2 $outfile
fi
exit 0

