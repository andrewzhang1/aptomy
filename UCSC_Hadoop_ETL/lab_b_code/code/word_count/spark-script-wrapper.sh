#!/usr/bin/env bash

#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

function find_script() {

  FILE="$(basename $1)"
  SCRIPT=

  if [ -z "${SPARK_MAJOR_VERSION}" ]; then
    spark_versions="$(ls -1 "/usr/hdp/current" | grep "^spark.*-client$")"

    num_spark=0
    for i in $spark_versions; do
      tmp="/usr/hdp/current/${i}/bin/${FILE}"
      if [ -f "${tmp}" ]; then
        num_spark=$(( $num_spark + 1 ))
        SCRIPT="${tmp}"
      fi
    done

    if [ "${num_spark}" -gt "1" ]; then
      echo "Multiple versions of Spark are installed but SPARK_MAJOR_VERSION is not set" 1>&2
      echo "Spark1 will be picked by default" 1>&2
      SCRIPT="/usr/hdp/current/spark-client/bin/${FILE}"
    fi

  elif [ "${SPARK_MAJOR_VERSION}" -eq "1" ]; then
    echo -e "SPARK_MAJOR_VERSION is set to 1, using Spark" 1>&2
    SCRIPT="/usr/hdp/current/spark-client/bin/${FILE}"

  else
    echo -e "SPARK_MAJOR_VERSION is set to ${SPARK_MAJOR_VERSION}, using Spark${SPARK_MAJOR_VERSION}" 1>&2
    SCRIPT="/usr/hdp/current/spark${SPARK_MAJOR_VERSION}-client/bin/${FILE}"
  fi

  if [ ! -f "${SCRIPT}" ]; then
    echo -e "${FILE} is not found, please check if spark${SPARK_MAJOR_VERSION} is installed" 1>&2
    exit 1
  fi

  echo "${SCRIPT}"
}
