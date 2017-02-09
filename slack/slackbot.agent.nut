// Slack Webhook URL
slack_url <- "https://hooks.slack.com/services/..."
// Text to be posted
bodytext <- "The Big Red Electric Imp Button has been pressed. Someone needs help in the hardware lab!";

device.on("Button Pressed", function(data) {
    server.log("Button Pressed");
    http.post(groupme_url, {"Content-type": "application/json"}, 
        http.jsonencode({"text":bodytext})).sendsync();
});