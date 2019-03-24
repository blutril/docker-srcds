#!/bin/bash

_sig () {
	export SIG=$1
	SIG_SHORT=$(echo ${SIG} | sed -e 's/^SIG//g')
	echo "Caught ${SIG} signal!"
	if [[ -x "./${SIG}_before.sh" ]]; then
		./ts3server_before_${SIG}.sh
	fi
	kill -s ${SIG} ${PID}
	if [[ -x "./${SIG}_after.sh" ]]; then
		./ts3server_after_${SIG}.sh
	fi
	wait "${PID}"
}

PORT=${PORT:-27015}
TVPORT=${TVPORT:-27020}
CLIENTPORT=${CLIENTPORT:-27005}
SPORT=${SPORT:-26900}
SRCDSPARAMS=${SRCDSPARAMS:-}
AUTHKEY=${AUTHKEY:-}
GLST=${GLST:-}
GLSTAPP=${GLSTAPP:-}
GLSTMEMO=${GLSTMEMO:-$(hostname)}
APPS=${APPS:-244310}

IFS=',' read -ra APPS <<< "$APPS"
for a in "${APPS[@]}" ; do
	steamcmd \
		+login anonymous \
		+force_install_dir "${BASEDIR}" \
		+app_update "${a}" -validate -language en \
		+quit
done

if [[ -z "${GLST}" && -n "${GLSTAPP}" && -n "${AUTHKEY}" ]]; then
	echo "Try to created GLST"
	IFS=- read STEAMID GLST <<<"$(curl \
		-s \
		-d "key=${AUTHKEY}&appid=${GLSTAPP}&memo=${GLSTMEMO}" \
		'https://api.steampowered.com/IGameServersService/CreateAccount/v1/' \
		| jq \
			-e \
			-r '.response | "\(.steamid)-\(.login_token)"' \
	)"
	if [[ "${STEAMID}" =~ ^[0-9]+$ && "${GLST}" =~ ^[0-9A-F]+$ ]]; then
		echo "Created GLST: ${GLST} (${GLSTMEMO}) for APPID ${GLSTAPP}"
	else
		echo "GLST can't be created! Check your AUTHKEY, GLSTAPP and account requirements"
		STEAMID=
		GLST=
	fi
fi

# register traps
IFS=' ' read -r -a singals <<< $(kill -l | sed -e 's/[0-9]\+)//g' | tr -d '\t\r\n')
for SIG in "${singals[@]}"; do
	SIG_SHORT=$(echo ${SIG} | sed -e 's/^SIG//g')
	echo "Register ${SIG} event"
	eval "trap '_sig ${SIG}' ${SIG_SHORT}"
done

# execution
./srcds_run \
	-strictportbind \
	-port "${PORT}" \
	-tv_port "${TVPORT}" \
	-clientport "${CLIENTPORT}" \
	-sport "${SPORT}" \
	+sv_setsteamaccount "${GLST}" \
	"$(eval "echo ${SRCDSPARAMS}")" \
	"${@}" &

export PID=$!

wait "${PID}"

if [ -n "${STEAMID}" ]; then
	curl \
		-s \
		-d "key=${AUTHKEY}&steamid=${STEAMID}" \
		'https://api.steampowered.com/IGameServersService/DeleteAccount/v1/'
fi
