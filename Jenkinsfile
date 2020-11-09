pipeline {
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
