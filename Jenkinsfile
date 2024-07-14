pipeline {
    agent any

    environment {
        // Define the version of Terraform you want to use
        TF_VERSION = '1.6.5'
        // Path to install Terraform binary if not already installed
        TF_DIR = "${WORKSPACE}/terraform"
        TF_WORKSPACE = "aws-stag-ci"
    }

    stages {
        stage('Preparation') {
            steps {
                script {
                    // Check if Terraform is installed, if not download and unzip it.
                    if (!fileExists("${TF_DIR}/terraform")) {
                        sh """
                            mkdir -p ${TF_DIR}
                            curl -o ${TF_DIR}/terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
                            unzip ${TF_DIR}/terraform.zip -d ${TF_DIR}
                        """
                    }
                    // Add Terraform to PATH for this job
                    env.PATH = "${env.TF_DIR}:${env.PATH}"
                }
            }
        }

        stage('Set AWS Credentials') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    script {
                        // Set AWS credentials in environment for Terraform
                        env.AWS_ACCESS_KEY_ID = "${AWS_ACCESS_KEY_ID}"
                        env.AWS_SECRET_ACCESS_KEY = "${AWS_SECRET_ACCESS_KEY}"
                    }
                }
            }
        }

        stage('Terraform Init and Plan') {
            steps {
                script {
                    dir('environments/aws-stag') {
                        sh "terraform init"
                        // Run Terraform plan and save the output
                        sh "terraform plan -json -out=tf.plan > plan_log.json && terraform show -json tf.plan > plan_output.json"
                    }
                }
            }
            post {
                always {
                    withCredentials([
                        string(credentialsId: 'FIREFLY_ACCESS_KEY', variable: 'FIREFLY_ACCESS_KEY'),
                        string(credentialsId: 'FIREFLY_SECRET_KEY', variable: 'FIREFLY_SECRET_KEY')
                    ]) {
                        script {
                            docker.image('public.ecr.aws/firefly/fireflyci:latest').inside("-v ${WORKSPACE}:/app/jenkins --entrypoint=''") {
                                sh "/app/fireflyci post-plan -l /app/jenkins/environments/aws-stag/plan_log.json -f /app/jenkins/environments/aws-stag/plan_output.json --workspace ${TF_WORKSPACE}"
                            }
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    dir('environments/aws-stag') {
                    // Apply the Terraform plan
                    sh "terraform apply -auto-approve -json > apply_log.json"
                    }
                }
            }
            post {
                always {
                    withCredentials([
                        string(credentialsId: 'FIREFLY_ACCESS_KEY', variable: 'FIREFLY_ACCESS_KEY'),
                        string(credentialsId: 'FIREFLY_SECRET_KEY', variable: 'FIREFLY_SECRET_KEY')
                    ]) {
                        script {
                            docker.image('public.ecr.aws/firefly/fireflyci:latest').inside("-v ${WORKSPACE}:/app/jenkins --entrypoint=''") {
                                sh "/app/fireflyci post-apply -f /app/jenkins/environments/aws-stag/apply_log.json --workspace ${TF_WORKSPACE}"
                            }
                        }
                    }
                }
            }            
            
        }
        
    }
    post {
        always {
            // Clean up the workspace
            cleanWs()
        }
    }
}
