pipeline {
  agent { label 'linux'}
  environment {
    TF_VARS = credentials('tfvars')
    TFC_TOKEN = credentials('tfcToken')
  }
  options {
    skipDefaultCheckout(true)
  }
  stages{
    stage('clean workspace') {
      steps {
        cleanWs()
      }
    }
    stage('Initialize') {
      steps {
        echo "env ${env.PATH}"
      }
    }
    stage('checkout') {
      steps {
        checkout scm
      }
    }
    stage('terraform') {
      failFast true
      steps {
        sh 'cp $TFC_TOKEN .'
        sh 'cp $TF_VARS .'
        sh 'ls .'
        sh 'chmod 755 ./terraformw.sh'
        sh './terraformw.sh'
      }
    }
  }
  post {
    always {
      cleanWs()
    }
  }
}