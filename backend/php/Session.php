<?php
    ini_set('display_errors', 0);
    ini_set('log_errors', 1);
    ini_set('error_log', '/var/www/html/php_errors.log');
    ob_start();

    include 'Connect.php';

    function print_response($datasize, $dictionary = [], $error = "none") {
        ob_end_clean();
        header('Content-Type: application/json');
        $string = "{\"error\" : \"$error\",
                    \"command\" : \"{$_REQUEST['command']}\",
                    \"datasize\" : $datasize, 
                    \"response\" :" . json_encode($dictionary) . "}";    
        echo $string;
    }

    function validate_command() {
        $error_message = "";
        $data = null;
        if (!isset($_REQUEST['command']) || $_REQUEST['command'] === null) {
            $error_message = "missing_command";
        }
        if (!isset($_REQUEST['data']) || $_REQUEST['data'] === null) {
            $error_message = "missing_data";
        }
        try {
            $data = json_decode($_REQUEST['data'], true);
        } catch(Exception $e) {
            $error_message = "mangled_json";
        }
        return [$error_message, $data];
    }

    $conn = OpenConnection();
    if ($conn->connect_error) {
        ob_end_clean();
        print_response(0, [], "db_login_error");
        die();
    }

    [$error_message, $data] = validate_command();
    if ($error_message !== "") {
        ob_end_clean();
        print_response(0, [], $error_message);
        die();
    }
    
    switch ($_REQUEST['command']) {
        case "something":
            ob_end_clean();
            print_response(0, []);
            break;
        default:
            ob_end_clean();
            print_response(0, [], "invalid_command");
            break;
    }
    ob_end_clean();
?>
