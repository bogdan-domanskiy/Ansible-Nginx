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
              sh get_vm_ip.sh
            """)
            }

        }
      }
    }
    stage('Check ansible syntax') {
      steps{
        script {
        sh "/usr/local/bin/ansible-playbook -i ./hosts/test ansible_playbook.yml --syntax-check"
        }
      }
    }
    stage("Ping the hosts.") {
        steps {
            withCredentials([string(credentialsId: 'VMpass', variable: 'ANSIBLE_HOST_PASSWORD')]) {
               sh("""
                  /usr/local/bin/ansible -m ping -i ./hosts/production nginx -e ansible_password=$ANSIBLE_HOST_PASSWORD
                """)
            }
        }
    }
    stage('Run Ansible playbook') {
      steps{
        script {
          withCredentials([string(credentialsId: 'VMpass', variable: 'ANSIBLE_HOST_PASSWORD')]) {
            sh("""
                /usr/local/bin/ansible-playbook -i ./hosts/test ansible_playbook.yml -e ansible_password=$ANSIBLE_HOST_PASSWORD
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
