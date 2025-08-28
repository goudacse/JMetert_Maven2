pipeline {
    agent any
    
    tools {
        maven 'Maven 3.9.11'  // Make sure you have Maven configured in Jenkins
    }
    
    parameters {
        choice(
            name: 'TEST_PROFILE',
            choices: ['all-tests', 'end-to-end', 'add-products', 'add-pet', 'add-user'],
            description: 'Select which test(s) to run'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Verify Tools') {
            steps {
                bat 'mvn -version'
                bat 'dir "Test Plans"'
            }
        }
        
        stage('Run JMeter Tests') {
            steps {
                bat "mvn clean verify -P${params.TEST_PROFILE}"
            }
        }
    }
    
    post {
        always {
            // Archive JTL and HTML reports
            archiveArtifacts artifacts: 'target/jmeter/**/*', fingerprint: true
            
            // Publish HTML reports
            publishHTML(target: [
                allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'target/jmeter/reports',
                reportFiles: 'index.html',
                reportName: 'JMeter HTML Report'
            ])
            
            // Performance Plugin integration
            //perfReport sourceDataFiles: 'target/jmeter/results/**/*.jtl'
            perfReport sourceDataFiles: 'target/jmeter/results/*.jtl'
        }
    }
}
