#!/bin/bash

# Creates pipelines for users user001-user040 from template  config-template.xml
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
  sed "s/usernnn/${USERNAME}/g" config-template.xml > config.xml
  curl -s -X POST ${JENKINS_URL}/createItem?name=${USERNAME}${PIPELINE_SUFFIX} -u ${JENKINS_CREDS} --data-binary  @config.xml -H "${CRUMB}" -H "Content-Type:text/xml"
  if [ $? -ne 0 ]; then
    echo "Error creating pipeline ${USERNAME}${PIPELINE_SUFFIX}"
    break
  else
    echo "Pipeline ${USERNAME}${PIPELINE_SUFFIX} created"
  fi

done
