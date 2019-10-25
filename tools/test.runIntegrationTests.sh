#!/bin/bash

LOG_FOLDER=test_driver/logs
LOG_FILE=${LOG_FOLDER}/log.txt
success=0
failed=0

cd ..
if [[ ! -d "$LOG_FOLDER" ]]; then
    mkdir ${LOG_FOLDER}
fi
if [[ -f "$LOG_FILE" ]]; then
    rm ${LOG_FILE}
fi
touch ${LOG_FILE}

for test in test_driver/*
do
    if [[ -f "$test" ]]; then
        echo "### Running test: $test"
        flutter drive --target=test_driver/setup/app.dart --driver=${test} --flavor development >> ${LOG_FILE} 2>&1
        if [[ $? -eq 0 ]]; then
            echo "  [OK] $test"
            ((success++))
        else
            echo "  [FAIL] $test - See (test_driver/log.txt)"
            ((failed++))
        fi
    fi
done

echo
testCount=$((success + failed))
echo "### Test suite finished"
echo "  [All]: $testCount"
echo "  [OK]: $success successfully finished"
echo "  [FAIL]: $failed errors occurred"
