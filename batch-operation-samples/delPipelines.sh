#!/bin/bash
# Deletes  pipelines for users user001-user040
# Set to URL of Jenkins server e.g. http://n.n.n.n:8080
JENKINS_URL=

# Set to username:apikey where username is an admin user eg 'suser001:yourapikey'
JENKINS_CREDS=

# Suffix of pipeline name
PIPELINE_SUFFIX='_pipeline'

# This is required to authenticate - no changes needed
CRUMB=`curl -s "${JENKINS_URL}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)" -u ${JENKINS_CREDS}`

for i in $(seq 40)
do
  printf -v USERNAME "user%03d" $i
  curl -s -X POST ${JENKINS_URL}/job/${USERNAME}${PIPELINE_SUFFIX}/doDelete  -u ${JENKINS_CREDS} -H "${CRUMB}" -H "Content-Type:text/xml"
  if [ $? -ne 0 ]; then
    echo "Error deleting pipeline ${USERNAME}${PIPELINE_SUFFIX}"
    break
  else
    echo "Pipeline ${USERNAME}${PIPELINE_SUFFIX} deleted"
  fi

done
