pipeline {
    agent any

    tools {
        maven 'Maven 3.9.11'   // Must match Jenkins Global Tool Configuration
    }

    stages {
        stage('Clean & Build') {
            steps {
                script {
                    // Clean and prepare build
                    bat "mvn clean install -U -DskipTests"
                }
            }
        }

        stage('Run Parallel JMeter Tests') {
            steps {
                script {
                    // Activate the 'parallel' profile, which runs run-parallel.bat via exec-maven-plugin
                    bat "mvn verify -Pparallel -U"
                }
            }
        }

        stage('Archive Results') {
            steps {
                script {
                    // Archive JMeter results (.jtl files) and HTML reports
                    archiveArtifacts artifacts: 'target/jmeter/results/**/*.jtl', allowEmptyArchive: true
                    publishHTML(target: [
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'target/jmeter/reports',
                        reportFiles: 'index.html',
                        reportName: 'JMeter Parallel HTML Report'
                    ])
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Cleaning up workspace after build..."
                cleanWs()
            }
        }
    }
}
