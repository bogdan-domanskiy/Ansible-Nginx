#!/bin/bash
#==============================================START ENKINS CREATE NEW USER=======================================================
#The USER_PASS  needs to export before running.

#cd ~
wget http://$HOST_IP:8080/jnlpJars/jenkins-cli.jar

#export ADMIN_PASS=`cat /var/lib/jenkins/secrets/initialAdminPassword`
export HOST_IP="127.0.0.1"
export USER_NAME="doman"


cat <<EOF >test.sh
#!/bin/sh
echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("$USER_NAME", "$USER_PASS")' | java -jar ./jenkins-cli.jar -s "http://$HOST_IP:8080/" -auth admin:$ADMIN_PASS groovy = –
EOF

chmod +x test.sh | sh test.sh

rm -fr test.sh


#==============================================FINISH JENKINS CREATE NEW USER=======================================================
#==============================================START INSTALL NEEDED PLUGINS=======================================================

cat <<'EOF' >plugins.txt
ant
bouncycastle-api
build-timeout
command-launcher
email-ext
github-branch-source
gradle
ldap
matrix-auth
jdk-tool
antisamy-markup-formatter
pam-auth
workflow-aggregator
pipeline-github-lib
ssh-slaves
timestamper
ws-cleanup
azure-keyvault
ansible:1.1
EOF


for i in `cat plugins.txt`; do java -jar jenkins-cli.jar -s http://$HOST_IP:8080/ -auth $USER_NAME:$USER_PASS install-plugin $i ;done

java -jar jenkins-cli.jar -auth $USER_NAME:$USER_PASS -s http://$HOST_IP:8080/ restart  | sleep 2m

rm -fr plugins.txt

#==============================================FINISH INSTALL NEEDED PLUGINS=======================================================
#==============================================START CREATE JENKINS SECRETS=======================================================
#Source of secret xml file.
# java -jar jenkins-cli.jar -s http://$HOST_IP:8080/  -auth admin:$ADMIN_PASS -webSocket list-credentials-as-xml system::system::jenkins

#The SECREDID and other AzureCredentials needs to export before running.
cat <<EOF >credentials.xml
<list>
  <com.cloudbees.plugins.credentials.domains.DomainCredentials plugin="credentials@2.3.13">
    <domain>
      <specifications/>
    </domain>
    <credentials>
      <com.microsoft.azure.util.AzureCredentials plugin="azure-credentials@4.0.3">
        <scope>GLOBAL</scope>
        <id>AzureKeyVault</id>
        <description></description>
        <data>
          <subscriptionId>$SUBSCRIPTION_ID</subscriptionId>
          <clientId>$CLIENT_ID</clientId>
          <clientSecret>$CLIENT_SECRET</clientSecret>
          <certificateId></certificateId>
          <tenant>$TENNANT_ID</tenant>
          <azureEnvironmentName>Azure</azureEnvironmentName>
        </data>
      </com.microsoft.azure.util.AzureCredentials>
      <com.microsoft.jenkins.keyvault.SecretStringCredentials plugin="azure-credentials@4.0.3">
        <scope>GLOBAL</scope>
        <id>VMpass</id>
        <description></description>
        <credentialId>AzureKeyVault</credentialId>
        <secretIdentifier>https://doman-kv.vault.azure.net/secrets/Doman-secret/$VM_PASS_VAR_HASH</secretIdentifier>
      </com.microsoft.jenkins.keyvault.SecretStringCredentials>
      <com.microsoft.jenkins.keyvault.SecretStringCredentials plugin="azure-credentials@4.0.3">
        <scope>GLOBAL</scope>
        <id>DigitalOcean-token</id>
        <description></description>
        <credentialId>AzureKeyVault</credentialId>
        <secretIdentifier>https://doman-kv.vault.azure.net/secrets/DigitalOcean-token/$DIGITAL_TOKEN_VAR_HASH</secretIdentifier>
      </com.microsoft.jenkins.keyvault.SecretStringCredentials>
    </credentials>
  </com.cloudbees.plugins.credentials.domains.DomainCredentials>
</list>
EOF


java -jar jenkins-cli.jar -s http://$HOST_IP:8080/ -auth $USER_NAME:$USER_PASS -webSocket import-credentials-as-xml system::system::jenkins < credentials.xml

rm -fr credentials.xml

#==============================================END CREATE JENKINS SECRETS=======================================================
#=================================================START JENKINS CREATE JOB=========================================================
#Source of job.
# java -jar jenkins-cli.jar -s http://$HOST_IP:8080/ -auth $USER_NAME:$USER_PASS -webSocket get-job AnsibleRun

cat <<'EOF' >job.xml
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.40">
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.84">
    <script>pipeline {
      agent { node { label 'master' } }
      stages {
        stage('Cloning Git') {
          steps {
            git 'https://github.com/bogdan-domanskiy/Ansible-Nginx.git'
            sh "ls -la"
          }
        }
        /*stage('Get the hosts IP') {
          steps{
            script {
                withCredentials([string(credentialsId: 'dgtoken', variable: 'DIGI_TOKEN')]) {
                sh ("""
                echo $DIGI_TOKEN
                export DIGI_VM_IP=`sh get_vm_ip.sh`
                echo $DIGI_VM_IP
                """)
                }

            }
          }
        }*/
        stage('Check ansible syntax') {
          steps{
            script {
            sh "ansible-playbook -i ./hosts/test ansible_playbook.yml --syntax-check -vv"
            }
          }
        }
        stage('Deploy Image') {
          steps{
            script {
              withCredentials([usernamePassword(credentialsId: 'manual_pass', usernameVariable: 'USERNAME', passwordVariable: 'ANSIBLE_HOST_PASSWORD')]) {
                sh("""
                    ansible-playbook -i ./hosts/test ansible_playbook.yml -e ansible_password=$ANSIBLE_HOST_PASSWORD -vv
                  """)
              }
            }
          }
        }
        stage('Remove cloned dir.') {
          steps{
            sh "rm -fr ../Ansible-Nginx"
          }
        }
      }
    }
</script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

java -jar jenkins-cli.jar -s http://$HOST_IP:8080/ -auth $USER_NAME:$USER_PASS -webSocket create-job AnsibleRun < job.xml

rm -fr job.xml
