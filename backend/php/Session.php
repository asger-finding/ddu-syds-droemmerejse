<?php
    include 'Connect.php';

	# Returns information and data to Godot
	function print_response($datasize, $dictionary = [], $error = "none"){
		$string = "{\"error\" : \"$error\",
					\"command\" : \"$_REQUEST[command]\",
					\"datasize\" : $datasize, 
					\"response\" :" . json_encode($dictionary) . "}";	
        
		# Print out json to Godot
		echo $string;
	}

    $conn = OpenConnection();
    if ($conn->connect_error) {
        print_response(0, [], "db_login_error");
        die();
    }
?>
