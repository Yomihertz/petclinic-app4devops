pipeline {
    agent any
    tools{
        maven 'maven'
    }
    environment {
        NEXUS_USER = credentials('nexus-username')
        NEXUS_PASSWORD = credentials('nexus-password')
        NEXUS_REPO = credentials('nexus-repo')
    }
    stages{
        stage('Code Analysis') {
            steps{
                withSonarQubeEnv('sonarqube') {
                    sh 'mvn sonar:sonar'  
               }
            }
        }
        stage('Quality Gate') {
            steps{
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true  
               }
            }
        }
        stage('Build Artifact') {
            steps{
                sh 'mvn clean install -DskipTests'
            }
        }
        stage('Build Docker Image') {
            steps{
                sh 'docker build -t $NEXUS_REPO/myapp:latest .'
            }
        }
        stage('Log into Nexus Repo') {
            steps{
                sh 'docker login --username $NEXUS_USER --password $NEXUS_PASSWORD $NEXUS_REPO'
            }
        }
        stage('Push to Nexus Repo') {
            steps{
                sh 'docker push $NEXUS_REPO/myapp:latest'
            }
        }
        stage('deploy to stage') {
            steps{
                sshagent(['ansible-key']) {
                    sh 'ssh -t -t ec2-user@10.0.2.205 -o strictHostKeyChecking=no "cd /etc/ansible && ansible-playbook stage-env-playbook.yml"' 
               }
            }
        }
        // stage('slack notification'){
        //    steps{
        //       slackSend channel: 'jenkinsbuild', message: 'successfully deployed to QA sever need approval to deploy PROD Env', teamDomain: 'Codeman-devops', tokenCredentialId: 'slack-cred'
        //    }
        //}
        stage('Request for Approval') {
            steps{
                timeout(activity: true, time: 10) {
                  input message: 'Needs Approval to deploy to production ', submitter: 'admin'
               }
            }
        }
        stage('Deploy to prod') {
            steps{
               sshagent(['ansible-key']) {
                    sh 'ssh -t -t ec2-user@10.0.2.205 -o strictHostKeyChecking=no "cd /etc/ansible && ansible-playbook prod-env-playbook.yml"'
               }  
            }
        }
    }
   //  post {
  // success {
  //      slackSend channel: 'jenkins-pipeline', message: 'successfully deployed to PROD Env ', teamDomain: 'Codeman-devops', tokenCredentialId: 'slack-cred'
  //    }
  //    failure {
  //      slackSend channel: 'jenkins-pipeline', message: 'failed to deploy to PROD Env', teamDomain: 'Codeman-devops', tokenCredentialId: 'slack-cred'
  //    }
 // }

}
