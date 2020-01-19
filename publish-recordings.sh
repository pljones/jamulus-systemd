#!/bin/bash -e
RECORDING_DIR=/opt/Jamulus/run/recording
RECORDING_HOST_DIR=drealm.info:html/jamulus/

cd "${RECORDING_DIR}"

find -maxdepth 1 -type d -name 'Jam-*' | sort | \
while read jamDir
do
	rppFile="${jamDir#./}.rpp"
	[[ -f "${jamDir}/${rppFile}" ]] || continue
	(
		cd "$jamDir"

		find -maxdepth 1 -type f -name '*.wav' | sort | while read wavFile
		do
			lra=0
			integrated=0
			removeWaveFromRpp=false

			duration=$(ffprobe -v 0 -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$wavFile")
			if [[ ${duration%.*} -lt 60 ]]
			then
				removeWaveFromRpp=true
				echo -n ''
			else
				opusFile="${wavFile%.wav}.opus"
				declare -a stats=($(
					nice -n 19 ffmpeg -y -hide_banner -nostats -nostdin -i "${wavFile}" -af ebur128 -b:a 160k "${opusFile}" 2>&1 | \
						grep '^ *\(I:\|LRA:\)' | { read x y x; read x z x; echo $y $z; }
				))
[[ ${#stats[@]} -eq 2 ]]
				integrated=${stats[0]}
				lra=${stats[1]}
				echo "$duration $lra $integrated" | awk '{ if ( $1 >= 60 && ( $2 > 6 || $3 > -48 ) ) exit 0; exit 1 }' || {
					rm "${opusFile}"
					removeWaveFromRpp=true
				}
			fi

			if $removeWaveFromRpp
			then
				echo "Removed ${wavFile} - duration $duration, lra $lra, integrated $integrated"
				# Magic sed command to remove an item from a track with a particular source wave file
				sed -e '/^    <ITEM */{N;N;N;N;N;N;N;N;N;N;N;N}' \
					-e "\%^ *<SOURCE WAVE\n *FILE *[^>]*${wavFile}\"\n *>\n%Md" \
					"${rppFile}" > "${rppFile}.tmp" && \
					mv "${rppFile}.tmp" "${rppFile}"
			else
				echo "Kept ${opusFile} - duration $duration, lra $lra, integrated $integrated"
			fi

			rm "$wavFile"
		done

		# Magic sed command to remove empty tracks
		sed -e '/^  <TRACK {/{N;N;N}' -e '/^ *<TRACK\([^>]\|\n\)*>$/d' \
			"${rppFile}" > "${rppFile}.tmp" && \
			mv "${rppFile}.tmp" "${rppFile}"

		if grep -q 'ITEM' "${rppFile}"
		then
			# Replace any remaining references to WAV files with OPUS compressed versions
			sed -e 's/\.wav/.opus/' -e 's/WAVE/OPUS/' \
				"${rppFile}" > "${rppFile}.tmp" && \
				mv "${rppFile}.tmp" "${rppFile}"
		else
			# As no items were left, remove the project
			echo "Removed ${rppFile}"
			rm "${rppFile}"
		fi

	)

	if [[ "$(cd "${jamDir}"; echo *)" == "*" ]]
	then
		rmdir "${jamDir}"
	else
		zip -r "${jamDir}.zip" "${jamDir}" -i '*.opus' '*.rpp' && {
			rm -r "${jamDir}"
			i=10
			while [[ $i -gt 0 ]] && ! scp -o ConnectionAttempts=6 "${jamDir}.zip" ${RECORDING_HOST_DIR}
			do
				(( i-- ))
				sleep $(( 11 - i ))
			done
			[[ $i -gt 0 ]]
		}
	fi

done
