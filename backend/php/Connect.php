<?php
function OpenConnection() {
    $db_host = "syds-droemmerejse-mysql";
    $db_name = "syds_droemmerejse";
    $db_username = "root";
    $db_password = "SuperSecret";
    
    $conn = new mysqli($db_host, $db_username, $db_password, $db_name, 3306);
    
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
    
    return $conn;
}

function CloseConnection($conn) {
    $conn->close();
}
?>