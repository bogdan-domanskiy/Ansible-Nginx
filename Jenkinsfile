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
          sh "chmod +x get_vm_ip.sh | sh get_vm_ip.sh"
      }
      }
    }
    stage('Check ansible syntax') {
      steps{
        script {
        sh" cd Ansible-Nginx | ansible-playbook -i ./hosts/test ansible_playbook.yml --syntax-check -vv"
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
