pipeline {
    agent any

    tools {
        maven 'Maven 3.9.11'
    }

    stages {
        stage('Parallel JMeter Tests') {
            parallel {
                stage('End-to-End') {
                    steps {
                        bat "mvn verify -P end-to-end -DskipConfiguration=true"
                    }
                }
                stage('Add Products') {
                    steps {
                        bat "mvn verify -P add-products -DskipConfiguration=true"
                    }
                }
                stage('Add Pet') {
                    steps {
                        bat "mvn verify -P add-pet -DskipConfiguration=true"
                    }
                }
                stage('Add User') {
                    steps {
                        bat "mvn verify -P add-user -DskipConfiguration=true"
                    }
                }
            }
        }

        stage('Archive Results') {
            steps {
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
