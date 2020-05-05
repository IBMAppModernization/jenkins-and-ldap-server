#!/bin/bash
# Get xml config of pipeline with name user001_pipeline and converst to a template with name  config-template.xml
# Set to URL of Jenkins server e.g. http://n.n.n.n:8080
JENKINS_URL=

# Set to username:apikey where username is an admin user eg 'suser001:yourapikey'
JENKINS_CREDS=

# Gets pipeline with name user001_pipeline
USERNAME=user001

# Suffix of pipeline name
PIPELINE_SUFFIX='_pipeline'

# This is required to authenticate - nio changes needed
CRUMB=`curl -s "${JENKINS_URL}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)" -u ${JENKINS_CREDS}`

# Get xml of user001_pipeline
curl -s "${JENKINS_URL}"/job/user001_pipeline/config.xml -u "$JENKINS_CREDS" -H "$CRUMB" > temp.xml

# Change refs to user001 to usernnn for template
sed "s/${USERNAME}/usernnn/g" temp.xml  >  config-template.xml && rm temp.xml
