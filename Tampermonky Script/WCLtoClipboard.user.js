// ==UserScript==
// @name         WCLtoClipboard
// @namespace    jabberie
// @version      1.0
// @description  Capture table headers and contents and copy them to the clipboard on Warcraft Logs
// @author       jabberie
// @match        https://www.warcraftlogs.com/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    function createTable(headers, data) {
        console.log(headers);
        var table = headers[0] + ' | Percentage | ' + headers[1] + ' | ' + headers[2]  + ' | \n';
        for (var i = 0; i < data.length; i++) {
            var rowData = [];
            for (var j = 0; j < headers.length-1; j++) {
                console.log("i= " + i + " j= " + j + " data= " + data[i][j]);
                if (j === 0) {
                    rowData.push(data[i][j]);
                } else if (j === 1) {
                    var values = data[i][j].split(/\$|%|m/).filter(Boolean);
                    console.log(values);
                    rowData.push(values[1] + '% | ' + values[2] + 'm ');
                } else {
                    var values = data[i][j].split(/\$|%|m/).filter(Boolean);
                    console.log(values);
                    if (values.length > 1) {
                        rowData.push(values[0] + ' | ' + values[1]);
                    } else {
                        rowData.push(values[0]);
                    }
                }
            }
            table += rowData.join(' | ');
            table += ' | \n';
        }

        // Add a final line to the clipboard table
        table += 'Data from Warcraft Logs';

        return table;
    }

    // Function to copy text to clipboard
    function copyTextToClipboard(text) {
        var dummy = document.createElement('textarea');
        document.body.appendChild(dummy);
        dummy.value = text;
        dummy.select();
        document.execCommand('copy');
        document.body.removeChild(dummy);
    }

    // Function to extract table data
    function extractTableData() {
        var headers = [];
        var data = [];

        var headerRows = document.querySelectorAll('#summary-damage-done-0 thead th');
        headerRows.forEach(function(row) {
            headers.push(row.textContent.trim());
        });

        var rows = document.querySelectorAll('#summary-damage-done-0 tbody tr');
        rows.forEach(function(row) {
            var rowData = [];
            var columns = row.querySelectorAll('td');
            columns.forEach(function(column, index) {
                rowData.push(column.textContent.trim());
            });
            data.push(rowData);
        });

        return [headers, ...data];
    }

    // Check for any error or undefined values in the table data
    function hasErrorOrUndefined(tableData) {
        return tableData.some(function(row) {
            return row.some(function(value) {
                return value === null || value === 'undefined';
            });
        });
    }

    // Function to check and change page type to "summary" if needed
    function checkAndChangePage() {
        const currentPageURL = window.location.href;
        const typeParam = "type=summary";

        console.log(currentPageURL);

        // Check if the type parameter is not already "summary"
        if (!currentPageURL.includes(typeParam)) {
            // Replace the type parameter with "summary"
            const newURL = currentPageURL.replace(/type=[^&]+/, typeParam);
            // Redirect to the new URL
            window.location.href = newURL;
        }
    }

    // Create a button to trigger data extraction and copy to clipboard
    var button = document.createElement('button');
    button.textContent = 'Copy Damage Done';
    button.style.position = 'fixed';
    button.style.top = '90px';
    button.style.left = '50px';
    button.style.zIndex = '9999'; // Ensure the button appears above other elements
    button.addEventListener('click', function() {
        checkAndChangePage(); // Check and change page type if needed
        var [headers, ...tableData] = extractTableData();
        var tableText = createTable(headers, tableData);
        copyTextToClipboard(tableText);
        if (headers.length === 0) {
            showAlertUnderButton('Change to the Summary Tab!', 250); // Show for 5 seconds
        } else {
            showAlertUnderButton('Table headers and contents copied to clipboard:\n' + tableText, 2000); // Show for 5 seconds
        }
    });

    document.body.appendChild(button);

    // Function to display an alert message under the Copy Damage Done button
    function showAlertUnderButton(message, timeout) {
        var alertDiv = document.createElement('div');
        alertDiv.innerHTML = message.replace(/\n/g, '<br>'); // Replace newline characters with HTML line breaks
        alertDiv.style.position = 'fixed';
        alertDiv.style.top = 'calc(90px + 40px)'; // Adjust the top position to be below the button (90px + button height)
        alertDiv.style.left = '90px';
        alertDiv.style.transform = 'translate(0, 0)';
        alertDiv.style.zIndex = '10000';
        alertDiv.style.backgroundColor = 'black';
        alertDiv.style.padding = '10px';
        alertDiv.style.border = '1px solid #ddd';
        document.body.appendChild(alertDiv);

        // Automatically close the alert after the specified timeout
        setTimeout(function() {
            document.body.removeChild(alertDiv);
            if (message.includes('Change to the Summary Tab!')) {
                // If the message was about changing to the summary tab, run the button click again.
                button.click();
            }
        }, timeout);
    }
})();
