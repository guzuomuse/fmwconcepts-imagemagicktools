#!/bin/bash
#
# Developed by Fred Weinhaus 8/22/2009 .......... revised 8/22/2009
#
# USAGE: cameradeblur [-t type] [-a amount] [-r rotation] [-n noise] [-m method] infile outfile
# USAGE: cameradeblur [-h or -help]
#
# OPTIONS:
#
# -t     type          type of blur; choices are: motion (or m) or 
#                      defocus (or d); default=defocus
# -a     amount        amount of blur; either length of motion blur or 
#                      diameter of defocus; float>0; default=10
# -r     rotation      rotation angle clockwise from horizontal for the 
#                      motion blur; floats; -180<=rotation<=180; default=0
# -n     noise         estimate of the noise to signal power ratio; float>=0; 
#                      default=0
# -m     method        computation method for computing defocus filter; 
#                      choices are slow (or s) or fast (or f); the slow 
#                      method will be more precise; the default=fast
# 
###
#
# NAME: CAMERADEBLUR 
# 
# PURPOSE: To deblur an image in the frequency domain using an ideal deblurring 
# filter for either motion blur or lens defocus.
# 
# DESCRIPTION: CAMERADEBLUR deblurs an image in the frequency domain using an
# ideal frequency domain deblurring filter for either motion blur or lens
# defocus. The motion blur filter in the frequency domain is just an
# optionally rotated 1D sinc function. The lens defocus filter in the
# frequency domain is just a jinc function. The user specifies the parameters
# needed to create those functions directly as images.An explicit filter image is not input to the script. Then it will
# be divided into the Fourier transform of the image created with +fft and
# the results will then be returned to the spatial domain via the inverse
# Fourier transform using +ift. Any alpha channel on the filter will be
# removed automatically before processing. If the image has an alpha channel
# it will not be processed, but simply copied from the input to the output.
# 
# OPTIONS: 
# 
# -t type ... TYPE of blur. The choices are: motion (or m) and defocus (or d).  
# The default=defocus.
# 
# -a amount ... AMOUNT of blur. This is either the length of the motion blur or 
# the diameter of the lens defocus. Values are float>0. The default=10.
# 
# -r rotation ... ROTATION angle in degrees specified clockwise from horizontal 
# for the motion blur. Values are floats with -180<=rotation<=180. The default=0.
# 
# -n noise ... NOISE is the estimate of the small constant added to the
# denominator in the division process and represents the noise to signal power
# ratio. Values are floats>=0. Usually, one simply uses trial an error with an
# arbitrary small value for the noise, typically, in the range of about 0.001 
# to 0.0001. However, it can be estimated from the variance of a nearly  
# constant section of the image (to get the noise variance) divided by an 
# estimate of the variance of the whole image (to get the signal variance). 
# Values are floats>=0. The default=0
# 
# -m method ... METHOD for computing the defocus filter. The choices are: 
# slow (or s) or fast (or f). The slow method will be more precise. The 
# default=fast.
# 
# REQUIREMENTS: IM version 6.5.4-7 or higher, but compiled with HDRI enabled 
# in any quantum level of Q8, Q16 or Q32. Also requires the FFTW delegate 
# library.
# 
# CAVEAT: No guarantee that this script will work on all platforms, 
# nor that trapping of inconsistent parameters is complete and 
# foolproof. Use At Your Own Risk. 
# 
######
#

# set default values
type=defocus			#defocus or motion
amount=10				#length of motion blur or diameter of defocus
rotation=0				#rotation for motion blur
method="fast"			#computation method for defocus filter; slow or fast
noise=0					#noise to signal variance estimate

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
elif [ $# -gt 12 ]
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
				-t)    # get type
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID TYPE SPECIFICATION ---"
					   checkMinus "$1"
					   type=`echo "$1" | tr "[:upper:]" "[:lower:]"`
					   case "$type" in 
					   		motion|m) type="motion" ;;
					   		defocus|d) type="defocus" ;;
					   		*) errMsg "--- TYPE=$type IS AN INVALID VALUE ---" 
					   	esac
					   ;;
				-a)    # get amount
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID AMOUNT SPECIFICATION ---"
					   checkMinus "$1"
					   amount=`expr "$1" : '\([.0-9]*\)'`
					   [ "$amount" = "" ] && errMsg "--- AMOUNT=$amount MUST BE A NON-NEGATIVE FLOAT ---"
					   amounttest=`echo "$amount <= 0" | bc`
					   [ $amounttest -eq 1 ] && errMsg "--- AMOUNT=$amount MUST BE A POSITIVE FLOAT ---"
					   ;;
				-r)    # get rotation
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   #errorMsg="--- INVALID ROTATION SPECIFICATION ---"
					   #checkMinus "$1"
					   rotation=`expr "$1" : '\([-.0-9]*\)'`
					   [ "$rotation" = "" ] && errMsg "--- ROTATION=$rotation MUST BE A NON-NEGATIVE FLOAT ---"
					   rotationtestA=`echo "$rotation < -180" | bc`
					   rotationtestB=`echo "$rotation > 180" | bc`
					   [ $rotationtestA -eq 1 -o $rotationtestB -eq 1 ] && errMsg "--- ROTATION=$rotation MUST BE A FLOAT BETWEEN -180 AND 180 ---"
					   ;;
				-n)    # get noise
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID NOISE SPECIFICATION ---"
					   checkMinus "$1"
					   noise=`expr "$1" : '\([.0-9]*\)'`
					   [ "$noise" = "" ] && errMsg "--- NOISE=$noise MUST BE A NON-NEGATIVE FLOAT ---"
					   ;;
				-m)    # get method
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID METHOD SPECIFICATION ---"
					   checkMinus "$1"
					   method=`echo "$1" | tr "[:upper:]" "[:lower:]"`
					   case "$method" in 
					   		slow|s) method="slow" ;;
					   		fast|f) method="fast" ;;
					   		*) errMsg "--- METHOD=$method IS AN INVALID VALUE ---" 
					   	esac
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

# setup temporary images
tmpA1="$dir/fftblurideal_1_$$.mpc"
tmpB1="$dir/fftblurideal_1_$$.cache"
tmpF="$dir/fftblurideal_F_$$.pfm"
tmpL="$dir/fftidealblur_L_$$.pfm"
tmpA="$dir/fftidealdeblur_A_$$.pfm"
trap "rm -f $tmpA1 $tmpB1 $tmpF $tmpL $tmpA; exit 0" 0
trap "rm -f $tmpA1 $tmpB1 $tmpF $tmpL $tmpA; exit 1" 1 2 3 15

# read the input image and filter image into the temp files and test validity.
convert -quiet -regard-warnings "$infile" +repage "$tmpA1" ||
	errMsg "--- FILE $infile DOES NOT EXIST OR IS NOT AN ORDINARY FILE, NOT READABLE OR HAS ZERO SIZE  ---"


# test for valid version of IM
im_version=`convert -list configure | \
	sed '/^LIB_VERSION_NUMBER /!d;  s//,/;  s/,/,0/g;  s/,0*\([0-9][0-9]\)/\1/g'`
[ "$im_version" -lt "06040403" ] && errMsg "--- REQUIRES IM VERSION 6.5.4-3 OR HIGHER ---"

# test for hdri enabled
hdri_on=`convert -list configure | grep "enable-hdri"`
[ "$hdri_on" = "" ] && errMsg "--- REQUIRES HDRI ENABLED IN IM COMPILE ---"

# get image dimensions for later cropping as input is padded to square, even dimensions
width=`identify -ping -format "%w" $tmpA1`
height=`identify -ping -format "%h" $tmpA1`

# compute padded to even dimensions
w1=`convert xc: -format "%[fx:($width%2)==0?$width:($width+1)]" info:`
h1=`convert xc: -format "%[fx:($height%2)==0?$height:($height+1)]" info:`

# get center point adjusted for padding to even dimensions
cx=`convert xc: -format "%[fx:floor(($width+1)/2)]" info:`
cy=`convert xc: -format "%[fx:floor(($height+1)/2)]" info:`

# compute full and half-diagonals
w1d=`convert xc: -format "%[fx:sqrt(2)*$w1]" info:`
h1d=`convert xc: -format "%[fx:sqrt(2)*$h1]" info:`
cxd=`convert xc: -format "%[fx:sqrt(2)*$cx]" info:`
cyd=`convert xc: -format "%[fx:sqrt(2)*$cy]" info:`
# currently limited to square images
[ "$w1d" != "$h1d" ] && errMsg "--- IMAGE MUST BE SQUARE ---"

#echo "width=$width; height=$height; w1=$w1; h1=$h1; cx=$cx; cy=$cy; w1d=$w1d; h1d=$h1d; cxd=$cxd; cyd=$cyd"

# scale the noise value by quantumrange
qnoise=`convert xc: -format "%[fx:quantumrange*$noise]" info:`

# test if image has alpha and set up copy to output
is_alpha=`convert $tmpA1 -format "%A" info:`
if [ "$is_alpha" = "True" ]; then
	convert $tmpA1 -alpha extract $tmpA 
	addalpha="$tmpA -compose copy_opacity -composite"
else
	addalpha=""
fi

: '
For "zero phase" filters see http://ccrma.stanford.edu/~jos/sasp/Rectangular_Window.html

Motion Blur
In frequency domain = sinc(dist*pi*(fx*cos(ang)-fy*sin(ang)); sinc(z)=sin(z)/z
fx=spatial frequency in x and fy=spatial frequency in y
fx=x/width, fy=y/height; 1/width, 1/height are frequency units
x,y are measured from center of image; thus -.5<=fx,fy<=.5
dist is length of motion blur in spatial domain
rotation ang is clockwise positive to be consistent with IM

Defocus
In frequency domain = jinc(diam*pi*fr); jinc(z)=2*J1(z)/(z)
J1 is Bessel function of first kind of order 1
see Abramowitz and Stegun, p369-370, formula 9.4.4 and 9.4.6
fr=spatial frequency in r
fr=sqrt(fx^2+fy^2); fx=x/width, fy=y/height; 1/width, 1/height are frequency units
x,y are measured from center of image; thus -.5<=fx,fy<=.5
diam is diameter of lens defocus in spatial domain
'

# compute spatial frequency units and other params and create filter
if [ "$type" = "motion" ]
	then 
	# compute spatial frequency units times pi*length=pi*amount, 
	# where spatial frequency units fx=1/w, fy=1/h
	# note f=1/dimension and w=pi*f=pi/dimension
	fxd=`convert xc: -format "%[fx:$amount*pi/$w1]" info:`
	fyd=`convert xc: -format "%[fx:$amount*pi/$h1]" info:`

	# compute angular orientation factors
	sinang=`convert xc: -format "%[fx:sin($rotation*pi/180)]" info:`
	cosang=`convert xc: -format "%[fx:cos($rotation*pi/180)]" info:`

	# create sinc filter
	if [ "$sinang" = "0" -o "$sinang" = "0.0" ]; then
		convert -size ${w1}x1 xc: \
			-fx "zz=$fxd*(i-$cx)*$cosang; zz?sin(zz)/(zz):1" \
			-scale ${w1}x${h1}\! $tmpF
	elif [ "$cosang" = "0" -o "$cosang" = "0.0" ]; then
		convert -size 1x${h1} xc: \
			-fx "zz=-$fyd*(j-$cy)*$sinang; zz?sin(zz)/(zz):1" \
			-scale ${w1}x${h1}\! $tmpF
	else
: '
		# old method
		convert -size ${w1}x${h1} xc: -monitor \
			-fx "zz=($fxd*(i-$cx)*$cosang+$fyd*(j-$cy)*$sinang); zz?sin(zz)/(zz):1" \
			$tmpF
'
		# fast method
		# note -compose divide has zero divide value of 0 and for sinc 
		# we need it to be 1. so we do -linear-stretch to force maxvalue=1
		# and -fill white -opaque black to make zero divide value=1
		# also since sinusoid already has built in 2*pi in frequency,  
		# we must divide xfact=yfact by that amount to compensate in freq
		h2=$(($h1+1))
		xfact=`convert xc: -format "%[fx:$cosang*$w1/2]" info:`
		yfact=`convert xc: -format "%[fx:$sinang*$h1/2]" info:`
		freq=`convert xc: -format "%[fx:$fxd/(2*pi)]" info:`
		convert \( -size ${w1}x${h2} gradient: \
		-gravity center -crop ${w1}x${h1}+0+1 +repage \
		-linear-stretch 1x0 -function polynomial "2,-1" \) \
		\( -clone 0 -rotate 90 -evaluate multiply $xfact \) \
		\( -clone 0 -rotate 180 -evaluate multiply $yfact \) \
		\( -clone 1 -clone 2 -compose plus -composite \) \
		\( -clone 3 -function sinusoid "$freq,0,1,0" -clone 3 +swap -compose divide -composite \) \
		-delete 0-3 -linear-stretch 0x1 -fill white -opaque black \
		$tmpF
	fi
	
elif [ "$type" = "defocus" ]
	then
	# compute spatial frequency units times pi*diameter=pi*amount, 
	# where spatial frequency units fx=1/w, fy=1/h
	# note f=1/dimension and w=pi*f=pi/dimension
	fxd=`convert xc: -format "%[fx:$amount*pi/$w1]" info:`
	fyd=`convert xc: -format "%[fx:$amount*pi/$h1]" info:`

	# create jinc filter
	a0=0.5; a1=-.56249985; a2=.21093573; a3=-.03954289; a4=.00443319; a5=-.00031781; a6=.00001109
	uu="(zz/3)"
	jinc1="($a0+$a1*pow($uu,2)+$a2*pow($uu,4)+$a3*pow($uu,6)+$a4*pow($uu,8)+$a5*pow($uu,10)+$a6*pow($uu,12))"

	b0=.79788456; b1=.00000156; b2=.01659667; b3=.00017105; b4=-.00249511; b5=.00113653; b6=-.00020033
	c0=-2.35619; c1=.12499612; c2=-.00005650; c3=-.00637879; c4=.00074348; c5=.00079824; c6=-.00029166
	iuu="(3/zz)"
	vv="($b0+$b1*$iuu+$b2*pow($iuu,2)+$b3*pow($iuu,3)+$b4*pow($iuu,4)+$b5*pow($iuu,5)+$b6*pow($iuu,6))"
	ww="(zz+$c0+$c1*$iuu+$c2*pow($iuu,2)+$c3*pow($iuu,3)+$c4*pow($iuu,4)+$c5*pow($iuu,5)+$c6*pow($iuu,6))"
	jinc2="$vv*cos($ww)/(zz*sqrt(zz))"

	if [ "$method" = "slow" ]; then
		# exact method
		# note: factor of 2 below due to A&S formula has max of 1/2 and we need it normalize to 1
		convert -size ${w1}x${h1} xc: -monitor \
			-fx "zz=hypot($fxd*(i-$cx),$fyd*(j-$cy)); (zz<=3)?2*$jinc1:2*$jinc2" \
			$tmpF
	
	elif [ "$method" = "fast" ]; then
		# approximate radial method -- works currently only for square images
		# note: factor of 2 below due to A&S formula has max of 1/2 and we need it normalize to 1
		convert -size 1x${cyd} gradient: -rotate 90 \
			-fx "zz=hypot($fxd*i,$fyd*j); (zz<=3)?2*$jinc1:2*$jinc2" \
			$tmpL		
		convert \( -size ${w1d}x${h1d} radial-gradient: -negate \
			-gravity center -crop ${w1}x${h1}+0+0 +repage \) \
			$tmpL -clut $tmpF
	fi
fi

debug="true"
if $debug; then
inname=`convert $infile -format "%t" info:`
rr=`echo $rotation | tr "-" "m"`
lval=100
convert $tmpF -linear-stretch 1x1 -evaluate log $lval ${inname}_ideal${type}${amount}_r${rr}_filt_log$lval.png
fi


# transform the image to real and imaginary components,
# divide both components by single filter (FxR)/(FxF + n) and (FxI)/(FxF + n),
# transform back
#
# first line takes fft of image and separates frames
# second line creates denominator
# third line creates FxR
# fourth line creates FxI
# fifth line creates (FxR/(FxF + n)
# sixth line creates (FxI/(FxF + n)
# seventh line deletes all intermediate steps and does ift of resulting components
convert \( $tmpA1 -alpha off +fft \) \
		\( $tmpF $tmpF -compose multiply -composite -evaluate add $qnoise \) \
		\( -clone 0 $tmpF -compose multiply -composite \) \
		\( -clone 1 $tmpF -compose multiply -composite \) \
		\( -clone 3 -clone 2 +swap -compose divide -composite \) \
		\( -clone 4 -clone 2 +swap -compose divide -composite \) \
		-delete 0-4 +ift -crop ${width}x${height}+0+0 +repage \
		$addalpha $outfile

exit 0



