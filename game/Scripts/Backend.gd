extends Node

const SERVER_URL = "http://localhost:8080/Session.php"
const SERVER_HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Cache-Control: max-age=0"]

var http_request : HTTPRequest = HTTPRequest.new()
var request_queue : Array = []
var is_requesting : bool = false
var current_request : Dictionary = {}

func _ready():
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_http_request_completed"))
	Global.Backend = self

func _process(_delta):
	if is_requesting: return
	if request_queue.is_empty(): return
	
	is_requesting = true
	current_request = request_queue.pop_front()
	_send_request(current_request)
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var result = await Global.Backend.post("update_player", {
			"player_id": Global.User.playerId,
			"filling": Global.Inventory.filling,
			"scrap": Global.Inventory.scrap
		})
		print(Global.Inventory.filling, result)
		get_tree().quit()

func _http_request_completed(result, _response_code, _headers, body):
	is_requesting = false
	var request = current_request
	current_request = {}
	
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("Error with connection: " + str(result))
		if request and request.has("promise"):
			request["promise"].set_result({"error": "connection_failed", "response": null, "datasize": 0})
		return
	
	var response_body = body.get_string_from_utf8()
	var response_parser = JSON.new()
	var parse_error = response_parser.parse(response_body)
	
	if parse_error != OK:
		printerr("JSON parse error: " + response_parser.get_error_message())
		if request and request.has("promise"):
			request["promise"].set_result({"error": "json_parse_error", "response": null, "datasize": 0})
		return
	
	var response = response_parser.get_data()
	if response['error'] != "":
		printerr("Backend returned error: " + response['error'])
		if request and request.has("promise"):
			request["promise"].set_result({"error": response['error'], "response": null, "datasize": 0})
		return
	
	var response_data = response['response']
	var data_size = int(response['datasize'])
	
	if request and request.has("promise"):
		request["promise"].set_result({"error": "", "response": response_data, "datasize": data_size})
	else:
		print(response_data, data_size)

func _send_request(request: Dictionary):
	var client = HTTPClient.new()
	var data = client.query_string_from_dict({
		"data": JSON.stringify(request['data'])
	})
	var body = "command=" + request['command'] + "&" + data
	var err = http_request.request(SERVER_URL, SERVER_HEADERS, HTTPClient.METHOD_POST, body)
	
	if err != OK:
		printerr("HTTPRequest error: " + str(err))
		if request.has("promise"):
			request["promise"].set_result({"error": "request_error", "response": null, "datasize": 0})
		return
	
	print("Requesting...\n\tCommand: " + request['command'] + "\n\tBody: " + body)

func post(method: String, data: Dictionary) -> Dictionary:
	var promise = Promise.new()
	request_queue.append({"command": method, "data": data, "promise": promise})
	return await promise.async()
