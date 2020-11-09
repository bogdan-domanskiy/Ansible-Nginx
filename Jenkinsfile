pipeline {
  agent { node { label 'master' } }
  stages {
    stage('Cloning Git') {
      steps {
        git 'https://github.com/bogdan-domanskiy/Ansible-Nginx.git'
        sh "ls -la"
      }
    }
    stage('Get the hosts IP') {
      steps{
        script {
            withCredentials([string(credentialsId: 'DigitalOcean-token', variable:  'DIGI_TOKEN')]) {
            sh ("""
              /var/lib/snapd/snap/bin/doctl auth init --access-token $DIGI_TOKEN > /dev/null 2>&1
              export DIGI_VM_IP=`/var/lib/snapd/snap/bin/doctl compute droplet list | grep ansible | sed -e 's/   //g'| cut -d " " -f 3`      
            """)
            }

        }
      }
    }
    stage('Check ansible syntax') {
      steps{
        script {
        sh "/usr/local/bin/ansible-playbook -i ./hosts/test ansible_playbook.yml --syntax-check -vv"
        }
      }
    }
    stage('Deploy Image') {
      steps{
        script {
          withCredentials([string(credentialsId: 'VMpass', variable: 'ANSIBLE_HOST_PASSWORD')]) {
            sh("""
                /usr/local/bin/ansible-playbook -i ./hosts/test ansible_playbook.yml -e ansible_password=$ANSIBLE_HOST_PASSWORD -vv
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
