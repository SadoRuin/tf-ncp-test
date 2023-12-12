pipeline {
  agent { label 'linux'}
  environment {
    TF_TOKEN_app_terraform_io = credentials('tfcToken')
    TF_VAR_access_key = credentials('ncpAccessKey')
    TF_VAR_secret_key = credentials('ncpSecretKey')
    TF_VAR_region = "KR"
    TF_VAR_site = "public"
    TF_VAR_support_vpc = "true"
    GIT_SSH_COMMAND = "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
  }
  options {
    skipDefaultCheckout(true)
  }
  stages{
    stage('Checkout') {
      steps {
        cleanWs()
        checkout scm
      }
    }
    stage('Install Terraform') {
      steps {
        // tfswitch가 설치 되어 있는 경우
        sh 'tfswitch -b $(pwd)/terraform'
        /* tfswitch 설치 포함
        sh '''
          echo "--------------------- Installing tfswitch locally for running terraform"
          curl -O  https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh
          chmod 755 install.sh
          ./install.sh -b $(pwd)/.bin
          CUSTOMBIN=$(pwd)/.bin
          $CUSTOMBIN/tfswitch -b $(pwd)/terraform
        '''
        */
      }
    }
    stage('Terraform Init') {
      steps {
        sshagent (credentials: ['githubSSH']) {
          sh './terraform init -no-color'
        }
      }
    }
    stage('Terraform Validate') {
      steps {
        sh './terraform validate -no-color'
      }
    }
    stage('Terraform Plan') {
      steps {
        script {
          def exitCode = sh(script: './terraform plan -out=tfplan -detailed-exitcode -no-color', returnStatus: true)
          env.TF_EXIT_CODE = "${exitCode}"
          if (exitCode == 0) {
            echo "ExitCode $exitCode: No changes in plan, exiting"
          } else if (exitCode == 2) {
            echo "ExitCode $exitCode: Plan contains changes, proceeding"
          } else {
            echo "ExitCode $exitCode: Error running terraform plan, exiting"
            currentBuild.result = 'FAILURE'
          }
        }
      }
    }
    stage('Terraform Apply') {
      when {
        expression { env.TF_EXIT_CODE == "2" }
      }
      steps {
        sh './terraform apply tfplan -no-color'
      }
    }
  }
  post {
    success {
      cleanWs()
    }
  }
}