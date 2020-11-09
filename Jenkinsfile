pipeline {
  environment {
    DIGI_TOKEN = 'DigitalOcean-token'
    ANSIBLE_HOST_PASSWORD = 'VMpass'
  }
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
        sh("""
                /var/lib/snapd/snap/bin/doctl auth init --access-token $DIGI_TOKEN > /dev/null 2>&1 | sleep 30

                export DIGI_VM_IP=`/var/lib/snapd/snap/bin/doctl compute droplet list | grep ansible | awk '{print \$3}'`
        """)
        }
      }
    }
    stage('Check ansible syntax') {
      steps{
        script {
        sh" cd Ansible-Nginx | ansible-playbook -i ./hosts ansible_playbook.yml --syntax-check -vv"
        }
      }
    }
    stage('Deploy Image') {
      steps{
        script {
            sh "ansible-playbook -i ./hosts/test ansible_playbook.yml -e ansible_password=$ANSIBLE_HOST_PASSWORD -vv"
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
