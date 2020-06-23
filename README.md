# External Jenkins and LDAP for IBM Client Dev Advocacy Workshops

This repo contains an ansible playbook for installing and configuring the following on a VM with CentOS 7 or RHEL 7:

1. An OpenLDAP server with a set of users, groups and passwords.

    * Latest available version in the yum repo is installed

    * Two groups are created: *admins* and *developers*
        * Members of the *admins* group will be Jenkins super users
            - One member of this group will be created - *suser001*
        * Members of the *developers* will be Jenkins regular users
            - 40 members of this group will be created with usernames in the range:  *user001 - user040*

2. A Jenkins server using the above LDAP for user authentication

    * Latest available version in the Jenkins yum repo is installed

    * The following are also installed to support Jenkins pipelines:
        * OpenJDK 8 - latest available version in the yum repo
        * Docker - latest available version in Docker yum repo
        * kubectl - v1.16.9
        * Maven - latest available version in yum repo
        * IBM Cloud CLI - latest available version

    * The latest versions of the following plugins and their dependencies are also installed:

        * ant
        * build-timeout
        * command-launcher
        * email-ext
        * github-branch-source
        * github-pullrequest
        * gradle
        * kubernetes
        * matrix-auth
        * pam-auth
        * antisamy-markup-formatter
        * workflow-aggregator
        * ssh-slaves
        * subversion
        * timestamper
        * ws-cleanup
        * ldap

## Prerequisites

1. A clone of this repo on your local machine.

1. A local installation of [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html). **Note:** The playbook was tested with *ansible 2.9.2* on *macOS Mojave*.

1. A Virtual Server Instance of CentOS 7 RHEL 7 running on IBM Cloud with passwordless SSH  from your local machine set for the *root* user.


## Running the playbook

1. Edit the file [inventory/hosts](inventory/hosts) and add the following:

    * A bind password for the LDAP server. This will be set when OpenLDAP is configured by the playbook

    ```
    # Set this to the LDAP bind password you want to use
    ldap_bind_password=yourverysecurebindpassword
    ```

    * The IP address of your CentOS 7 or RHEL 7 VSI

    ```
    # Add external IP address of provisioned CentOS 7  or RHEL 7 VSI
    [jenkinsvm]
    10.10.10.10
    ```

2. You may need to run chmod to make the scripts in the playbook executable for your localhost environment

```
chmod a+x playbooks/scripts/*.sh
```

3. Run the following command from the base directory of this cloned repo

```
ansible-playbook  -i inventory/hosts playbooks/site.yml

```

## Post install setup

1. Open the file **users.csv** in the **users** subfolder of the base directory of this cloned repo. The first line of the file will have the *suser001* user and the password. The remaining lines will be the users *user001 - user040* and their respective passwords. **Note:** if you run the playbook again and this file is present,  a fresh set of passwords will not be generated.

2. Configure your Jenkins server to use LDAP

    * In your browser go to the URL http://n.n.n.n:8080 where *n.n.n.n* is the IP address of your CentOS 7 or RHEL 7 VSI
    * Click on **Manage Jenkins** and then on **Configure Global Security**
    * Select **LDAP** as the **Security Realm**
    * Enter `127.0.0.1:389` as the **Server**
    * Click **Advanced Server Configuration**
    * Enter `ou=users,dc=clouddragons,dc=com` as the **User search base**
    * Enter `ou=groups,dc=clouddragons,dc=com` as the **Group search base**
    * Under **Group membership** select **Search for LDAP groups containing user**
    * Enter `cn=admin,dc=clouddragons,dc=com` as the **Manager DN**
    * Enter the LDAP bind password you configured in [inventory/hosts](inventory/hosts) as the **Manager Password**
    * Scroll down and click on **Test LDAP Settings**
    * Enter `suser001` as the **User** and the generated password for that user from **users.csv**. Click **Test**
    * Verify that the test is successful before continuing
    * Scroll down to **Authorization** and select the **Project-based Matrix Authorization Strategy**
    * Select **Read** in the **Overall** column for **Authenticated Users**
    * Click **Add user or group ...** . Enter `admins` as the name and click **OK**
    * Select the checkbox to the immediate right of the  **admins** groups to give all permissions to members of the group
    * Click **Save**


## Sample batch scripts

The following scripts are made available as samples to automate the creation and deletion of pipelines for each user in the range *user001 - user040*

* [batch-operation-samples/getjob.sh](batch-operation-samples/getJob.sh) - Get xml config of pipeline with name user001_pipeline and convert to a template

* [batch-operation-samples/genPipelines.sh](batch-operation-samples/getPipelines.sh) - Creates pipelines for users user001-user040 from a template

* [batch-operation-samples/delPipelines.sh](batch-operation-samples/delPipelines.sh) - Deletes pipelines for users user001-user040
