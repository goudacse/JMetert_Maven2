@echo off
REM File: run-parallel.bat
REM Purpose: Run multiple JMeter tests in parallel using Maven

REM Start all tests in parallel
start "End-to-End Test" cmd /c mvn clean verify -P end-to-end
start "Add Products Test" cmd /c mvn clean verify -P add-products
start "Add Pet Test" cmd /c mvn clean verify -P add-pet
start "Add User Test" cmd /c mvn clean verify -P add-user

REM Wait for all processes to complete
echo Running tests in parallel...
echo Wait for all Maven windows to complete...
pause
