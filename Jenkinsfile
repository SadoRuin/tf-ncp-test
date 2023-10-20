pipeline {
  agent { label 'linux'}
  environment {
    def dockerHome = tool 'myDocker'
    PATH = "${dockerHome}/bin:${env.PATH}"
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
    stage('tfsec') {
      failFast true
      steps {
        echo "=========== Execute tfsec ================="
        sh 'chmod 755 ./tfsecw.sh'
        sh './tfsecw.sh'
      }

      post {
        always { 
          echo "========= Check tfsec test results ========="
          junit allowEmptyResults: true, testResults: 'tfsec_results.xml', skipPublishingChecks: true
        }
        success {
          echo "Tfsec passed" 
        }
        unstable {
          error "TfSec Unstable"
        }
        failure {
          error "Tfsec failed"
        }
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