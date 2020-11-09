pipeline {
  agent { node { label 'master' } }
/*  environment {
    DIGI_TOKEN = "767cd6e019aa59861af0cef253adcb3dface98928c6bb6d8d77d92c0b5d668a5"
  }*/
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
              sh get_vm_ip.sh

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
