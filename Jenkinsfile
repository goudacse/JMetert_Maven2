    pipeline {
    agent any
    
    tools {
        maven 'Maven 3.9.11'  // Make sure you have Maven configured in Jenkins
    }
    
    parameters {
        choice(
            name: 'TEST_PROFILE',
            choices: ['all-tests', 'parallel', 'end-to-end', 'add-products', 'add-pet', 'add-user'],
            description: 'Select which test profile to run'
        )
    }
    
    environment {
        REPORT_DIR = "${WORKSPACE}/target/jmeter/reports"
        RESULTS_DIR = "${WORKSPACE}/target/jmeter/results"
        // Set performance thresholds
        ERROR_THRESHOLD = '5'        // Fail if error % exceeds this value
        RESPONSE_TIME_THRESHOLD = '2000' // Fail if avg response time exceeds this value (ms)
    }
    
    options {
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Clean workspace before checkout
                cleanWs()
                checkout scm
                
                // Create necessary directories
                bat 'IF NOT EXIST "Test Plans" mkdir "Test Plans"'
                bat 'dir "Test Plans"'
            }
        }
        
        stage('Verify Tools') {
            steps {
                bat 'mvn -version'
                bat 'echo %JAVA_HOME%'
                bat 'java -version'
            }
        }
        
        stage('Prepare Test Environment') {
            steps {
                script {
                    // Create run-parallel.bat script if it doesn't exist
                    if (params.TEST_PROFILE == 'parallel') {
                        writeFile file: 'run-parallel.bat', text: '''@echo off
REM File: run-parallel.bat
REM Purpose: Run multiple JMeter tests in parallel using Maven

REM Start all tests in parallel
start "End-to-End Test" cmd /c mvn clean verify -P end-to-end -DskipConfiguration=true
start "Add Products Test" cmd /c mvn clean verify -P add-products -DskipConfiguration=true
start "Add Pet Test" cmd /c mvn clean verify -P add-pet -DskipConfiguration=true
start "Add User Test" cmd /c mvn clean verify -P add-user -DskipConfiguration=true

REM Wait for all processes to complete
echo Running tests in parallel...
echo Wait for all Maven windows to complete...
timeout /t 3600
'''
                    }
                }
            }
        }
        
        stage('Run JMeter Tests') {
            steps {
                script {
                    def skipReportOption = params.SKIP_REPORT ? '-DgenerateReports=false' : ''
                    
                    if (params.TEST_PROFILE == 'parallel') {
                        echo "Running parallel tests with multiple Maven processes"
                        bat "run-parallel.bat"
                    } else {
                        echo "Running profile: ${params.TEST_PROFILE}"
                        bat "mvn clean verify -P${params.TEST_PROFILE} ${skipReportOption} -DjmeterTestDuration=${params.TEST_DURATION}"
                    }
                }
            }
            post {
                failure {
                    echo "Test execution failed. Check the logs for details."
                }
            }
        }
        
        stage('Verify Test Results') {
            when {
                expression { return fileExists(env.RESULTS_DIR) }
            }
            steps {
                script {
                    echo "Analyzing test results..."
                    
                    // Check for JTL files
                    def jtlFiles = findFiles(glob: "${env.RESULTS_DIR}/**/*.jtl")
                    if (jtlFiles.length == 0) {
                        error "No JTL result files found. Tests may have failed to execute."
                    }
                    
                    echo "Found ${jtlFiles.length} JTL result files"
                    
                    // Optional: Add result analysis here
                    // You could parse JTL files to extract error rates, response times, etc.
                    // and fail the build if thresholds are exceeded
                }
            }
        }
    }
    
    post {
        always {
            echo "Collecting test artifacts and reports..."
            
            // Archive JTL and HTML reports
            archiveArtifacts(
                artifacts: 'target/jmeter/**/*',
                fingerprint: true,
                allowEmptyArchive: true
            )
            
            // Publish HTML reports if they exist
            script {
                if (fileExists(env.REPORT_DIR)) {
                    publishHTML(target: [
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: env.REPORT_DIR,
                        reportFiles: 'index.html',
                        reportName: 'JMeter HTML Report'
                    ])
                }
            }
            
            
            // Clean workspace to save disk space (optional)
            // cleanWs(patterns: [[pattern: 'target/jmeter/bin/**', type: 'EXCLUDE']])
        }
        
        success {
            echo "JMeter tests completed successfully!"
        }
        
        failure {
            echo "JMeter tests failed! Check the logs and reports for details."
        }
        
        unstable {
            echo "Build is unstable. Performance thresholds may have been exceeded."
        }
    }
}
