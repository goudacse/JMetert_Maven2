pipeline {
    agent any
    tools {
        maven 'Maven 3.9.11'   // Must match the name in Jenkins config
    }

    stages {
        stage('Build & Run JMeter Tests') {
            steps {
                script {
                    // Run Maven tests (executes jmeter-maven-plugin)
                    bat "mvn clean verify -U"
                }
            }
        }

        stage('Archive Results') {
            steps {
                script {
                    // Archive JMeter results (.jtl and HTML report)
                    archiveArtifacts artifacts: 'target/jmeter/results/*.jtl', allowEmptyArchive: true
                    publishHTML(target: [
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'target/jmeter/reports',
                        reportFiles: 'index.html',
                        reportName: 'JMeter HTML Report'
                    ])
                }
            }
        }
    }

    post {
        always {
            echo "Collecting test artifacts and reports..."
        }
    }
}
