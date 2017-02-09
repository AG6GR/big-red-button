// GroupMe post endpoint
groupme_url <- "https://api.groupme.com/v3/bots/post"
// Text to be posted
bodytext <- "The Big Red Electric Imp Button has been pressed. Someone needs help in the hardware lab!";
// Bot ID
botid <- "pasteyouridhere"
groupid <- "pasteyourgroupidhere"

device.on("Button Pressed", function(data) {
    server.log("Button Pressed");
    http.post(groupme_url, {"Content-type": "application/json"}, 
        http.jsonencode({"text":bodytext, "bot_id":botid})).sendsync();
});