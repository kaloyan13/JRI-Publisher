#!/bin/bash -e

source /etc/environment

JRI_HOME="${CATALINA_HOME}/jasper_reports/"

#source the report environment
source "${JRI_HOME}/schedules/${1}_env.sh"

DONT_MAIL="${2}"

#set who is sending the mail
export EMAIL='root@localhost'
REPORT_FOLDER=$(dirname ${REP_ID})

#encode the / in report id
REP_ID=$(echo "${REP_ID}" | sed 's/\//%2F/g')

if [ "${OPT_PARAMS}" ]; then
  OPT_PARAMS="&${OPT_PARAMS}"
fi

URL="http://localhost:8080/JasperReportsIntegration/report?_repName=${REP_ID}&_repFormat=${REP_FORMAT}&_dataSource=${REP_DATASOURCE}&_outFilename=${REP_FILE}${OPT_PARAMS}"

TSTAMP=$(date '+%Y%m%d_%H%M%S')
REP_FILEPATH="${JRI_HOME}/reports/${REPORT_FOLDER}/${TSTAMP}_${REP_FILE}"

wget -O"${REP_FILEPATH}" "${URL}"
if [ $? -ne 0 ]; then
  rm -f "${REP_FILEPATH}"
fi

if [ -z "${DONT_MAIL}" ]; then
  echo "${EMAIL_BODY}" | mutt -s "${EMAIL_SUBJ}" -a "${REP_FILEPATH}" -- ${RECP_EMAIL}
fi

exit 0
