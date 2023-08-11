#!/bin/bash

#BROWSER="${LOCALAPPDATA}/Mozilla Firefox/firefox.exe"
BROWSER="/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"

LOCATION="build/reports_clang"
LOCATION="$(dirname "${0}")"/"${LOCATION}"
#echo "${LOCATION}"

(mkdir -p "${LOCATION}"; cd "${LOCATION}"  &&  rm -rf *)

if [[ ${#} -eq 0 ]]; then
  exit
fi

## enable text- or HTML-output
#ARGS+=("--analyzer-output text")
ARGS+=("--analyzer-output html -o ${LOCATION}")

ARGS+=("-Xanalyzer -analyzer-checker=core")
ARGS+=("-Xanalyzer -analyzer-checker=deadcode")
ARGS+=("-Xanalyzer -analyzer-checker=security")
ARGS+=("-Xanalyzer -analyzer-checker=unix")
ARGS+=("-Xanalyzer -analyzer-checker=alpha.core")
ARGS+=("-Xanalyzer -analyzer-checker=alpha.security")

ARGS+=("-std=c99")

ARGS+=("-D__GNUC__")

ARGS+=("-I./cmocka")
ARGS+=("-I./cmocka/autoGenHeaders")
ARGS+=("-I./cmocka/Scom")
ARGS+=("-I./codegen")
ARGS+=("-I./sub/subcommon/sub/sciopta/include")
ARGS+=("-I./sub/subcommon/sub/sciopta/include/sciopta/ppc")
ARGS+=("-I./sub/subcommon/sub/sciopta/bsp/ppc/include")
ARGS+=("-I./sub/subcommon/sub/sciopta/bsp/ppc/mpc5xxx/include")
ARGS+=("-I./src/common")
ARGS+=("-I./src/common/Drv/inc")
ARGS+=("-I./src/common/Safety")
ARGS+=("-I./src/common/Safety/SafetyLib/inc")
ARGS+=("-I./src/pcb")
ARGS+=("-I./ScomFunctionBuild")
ARGS+=("-I./ScomFunctionBuild/ScomFunction_ert_rtw")
ARGS+=("-I./ScomFunctionBuild/slprj/ert/_sharedutils")
ARGS+=("-I./ScomFunctionBuild/slprj/ert/HandlePesRequest")
ARGS+=("-I./ScomFunctionBuild/slprj/ert/HandlePesRequestData")
ARGS+=("-I./ScomFunctionBuild/slprj/ert/HandlePesRequestSecurity")
ARGS+=("-I/c/MinGW/mingw/include")
ARGS+=("-I/c/WindRiver/diab/5.9.4.7/include")

for i in $@; do

  echo "## ${i}"
  echo "## ${i}" >>"${LOCATION}"/reports_clang.txt

#  echo ${ARGS[@]}
  clang --analyze ${ARGS[@]} "${i}" 2>>"${LOCATION}"/reports_clang.txt

#  clang-tidy "${i}" -- ${ARGS[@]}
done

REPORTS=$(find "${LOCATION}" -name \*.html)
NUM=$(echo "${REPORTS}" | grep html | wc -l)
echo "processing ${NUM} reports, please wait ..."

## rename the reports
for i in ${REPORTS}; do
#  echo ${i}
  CNAME=$(grep '<title>' "${i}" | cut -d '>' -f 2- | cut -d '<' -f 1 | cut -d '.' -f 1)
  CNAME=${CNAME//'/'/'_'}
  CNAME=${CNAME//'\'/'_'}
  CNAME=${CNAME//':'/'_'}
  if [[ ${CNAME} == "" ]]; then
    CNAME="unknown"
  fi
  CNAME+="_"
  FILE=${i/'report-'/${CNAME}}
#  echo "${i}" "->" "${FILE}"
  mv "${i}" "${FILE}"
done

## view HTML-reports with browser
if [[ ${NUM} -gt 0 ]]; then
  if [[ ${NUM} -gt 20 ]]; then
    echo "too many reports to browse, check ${LOCATION}"
    echo "press a key to continue ..."
    read
  else
    nohup "${BROWSER}" "${LOCATION}"/*.html &
  fi
fi

## give the browser some time to spawn processes, needed for Eclipse integration
sleep 1s

