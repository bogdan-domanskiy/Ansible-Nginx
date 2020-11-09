# Ansible-Nginx
The Jenkins run a ansible playbook with role of nginx installation.


This repository consist of the next two main steps:

  - The first step is the Jenkins pipeline. 
  - The second step is the Ansible playbook.

Before running you should import the next needed environment variables. Also, for the correct pipeline executing you should install sshpass package, ansible, and doctl on Jenkins master.

  Environment variables for the Jenkins master:
  export ADMIN_PASS=`cat /var/jenkins_home/secrets/initialAdminPassword` or export ADMIN_PASS=`cat /var/lib/jenkins/secrets/initialAdminPassword`

  export CLIENT_ID="00000-0000-0000-000-0000"

  export CLIENT_SECRET="00000-0000-0000-000-0000"

  export SUBSCRIPTION_ID="00000-0000-0000-000-0000"

  export TENNANT_ID="00000-0000-0000-000-0000"

  export VM_PASS_VAR_HASH="00000-0000-0000-000-0000"

  export DIGITAL_TOKEN_VAR_HASH="00000-0000-0000-000-0000"


Then you will prepare Jenkins master using Jenkins-automatization.sh script.
