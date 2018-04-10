#!/bin/bash

OPENVIBE_ROOT_PATH="$HOME/Git/openvibe/dist/extras-Release"
MY_SCRIPT_PATH="$HOME/Git/magister_BCI/OpenVibe/ssvep_maka"
#INPUT_TRAINING_FILE_LOC="$MY_SCRIPT_PATH/signals/ssvep-record-[2018.02.13-15.22.10]-martin-8-5elect.ov"
#INPUT_TESTING_FILE_LOC="$MY_SCRIPT_PATH/signals/ssvep-record-[2018.02.13-15.31.38]-martin-test-no-zero-8-5-elect.ov"

#declare -a trainingArr=("$MY_SCRIPT_PATH/signals/ssvep-record-[2018.02.26-14.25.26]-robert-ch3BAD.ov")

#declare -a testingArr=("$MY_SCRIPT_PATH/signals/ssvep-record-[2018.02.26-14.37.24]-robert-ch3BAD-test.ov")
declare -a trainingArr=("$MY_SCRIPT_PATH/signals/ssvep-record-[2018.02.13-15.22.10]-martin-8-5elect.ov" 
                "$MY_SCRIPT_PATH/signals/ssvep-record-[2018.02.15-14.20.15]-teet.ov"
#                "$MY_SCRIPT_PATH/signals/ssvep-record-[2018.01.10-15.32.49]-tonis.ov"
#                "$MY_SCRIPT_PATH/signals/ssvep-record-[2018.02.16-12.29.19]-anti.ov"
#                "$MY_SCRIPT_PATH/signals/ssvep-record-[2018.03.08-15.10.29]-klavs.ov" 
#                "$MY_SCRIPT_PATH/signals/ssvep-record-[2018.03.09-15.52.56]-frida.ov"                  
                )
#
declare -a testingArr=("$MY_SCRIPT_PATH/signals/ssvep-record-[2018.02.13-15.31.38]-martin-test-no-zero-8-5-elect.ov" 
                "$MY_SCRIPT_PATH/signals/ssvep-record-[2018.02.15-14.32.32]-teet-test-no-zero.ov"
#                "$MY_SCRIPT_PATH/signals/ssvep-record-[2018.01.17-16.49.48]-tonis-test.ov"
#                "$MY_SCRIPT_PATH/signals/ssvep-record-[2018.02.16-12.41.41]-anti-test.ov"
#                "$MY_SCRIPT_PATH/signals/ssvep-record-[2018.03.08-15.24.56]-klavs-test.ov"
#                "$MY_SCRIPT_PATH/signals/ssvep-record-[2018.03.09-16.05.30]-frida-test.ov"
#
                )
parameterIdent="epDur"

declare -a parametersEpDur=(0.5 0.4 0.3 0.2 0.1)
#declare -a parametersEpInt=(0.012 0.024 0.048 0.096 0.192)
declare -a parametersEpInt=(0.01 0.025 0.05 0.075 0.1 0.2)
declare -a parametersFreqTol=(0.5 0.4 0.3 0.25 0.2 0.1)
declare -a parametersCh=("1:5" "1:4" "1:3" "1:2" "1:1")

if [ "$parameterIdent" = "epDur" ]; then
    declare -a parameters=( ${parametersEpDur[@]} )
fi
if [ "$parameterIdent" = "epInt" ]; then
    declare -a parameters=( ${parametersEpInt[@]} )
fi
if [ "$parameterIdent" = "freqTol" ]; then
    declare -a parameters=( ${parametersFreqTol[@]} )
fi
if [ "$parameterIdent" = "channel" ]; then
    declare -a parameters=( ${parametersCh[@]} )
fi

PROC_EPOCH_DUR=0.5
PROC_EPOCH_INTER=0.1
FREQ_TOLERANCE=0.25
CHANNELS="1:5"

for k in ${parameters[@]}
do
	if [ "$parameterIdent" = "epDur" ]; then
        PROC_EPOCH_DUR=$k
    fi
    if [ "$parameterIdent" = "epInt" ]; then
        PROC_EPOCH_INTER=$k
    fi
    if [ "$parameterIdent" = "freqTol" ]; then
        FREQ_TOLERANCE=$k
    fi
    if [ "$parameterIdent" = "channel" ]; then
        CHANNELS=$k 
    fi
    
    #echo "Epoch Dur is" $PROC_EPOCH_DUR

	

	arraylength=${#trainingArr[@]}

	for ((i=0; i<${arraylength}; i++));
	do
		SIM_FREQ1="20"
		SIM_FREQ2="15"
		SIM_FREQ3="12"
		SIM_FREQ4="10"
		if [ "$i" -ge "4" ]; then
        	SIM_FREQ1="30"
			SIM_FREQ2="20"
			SIM_FREQ3="12"
			SIM_FREQ4="7.5"

    	fi 

		sudo "$OPENVIBE_ROOT_PATH/openvibe-designer.sh" --play-fast "$MY_SCRIPT_PATH/ssvep-configuration-auto.xml" --invisible \
			--define epDur $PROC_EPOCH_DUR \
			--define epInt $PROC_EPOCH_INTER \
			--define freqTol $FREQ_TOLERANCE \
			--define ch $CHANNELS \
			--define simFreq1 $SIM_FREQ1 \
			--define simFreq2 $SIM_FREQ2 \
			--define simFreq3 $SIM_FREQ3 \
			--define simFreq4 $SIM_FREQ4 
		wait
		sudo "$OPENVIBE_ROOT_PATH/openvibe-designer.sh" --play-fast "$MY_SCRIPT_PATH/CSP-training-auto.xml" --define inFile ${trainingArr[$i]} --invisible 
		wait
		sudo "$OPENVIBE_ROOT_PATH/openvibe-designer.sh" --play-fast "$MY_SCRIPT_PATH/classifier-training-auto.xml" --define inFile ${trainingArr[$i]} --invisible
		wait
		sudo "$OPENVIBE_ROOT_PATH/openvibe-designer.sh" --play-fast "$MY_SCRIPT_PATH/perf-measure-auto.mxs" --define inFile ${testingArr[$i]} --invisible \
			--define epDur $PROC_EPOCH_DUR \
		    --define epInt $PROC_EPOCH_INTER \
		    --define freqTol $FREQ_TOLERANCE \
			--define ch $CHANNELS \
			--define nrOfSubjects ${arraylength} \
			--define simFreq1 $SIM_FREQ1 \
			--define simFreq2 $SIM_FREQ2 \
			--define simFreq3 $SIM_FREQ3 \
			--define simFreq4 $SIM_FREQ4 \
			--define curreSubjNr $i
		wait
	done
done