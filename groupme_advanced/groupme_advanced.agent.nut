//slack_url <- "https://hooks.slack.com/services/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"
groupme_url <- "https://api.groupme.com/v3/bots/post"
bodytext <- "The Big Red Electric Imp Button has been pressed.";

// Add API secrets here
botid <- "debugbotid"
groupid <- "debugchannelid"

brownbotid <-"publicbotid";
groupid <- "publicgroupid";

const TIMEZONE = -5; // Hours before or behind UTC
const DAY_SUNDAY = 0;
const DAY_FRIDAY = 5;

savedData <- server.load();
if (!("pressCount" in savedData)){
    server.log("Initing pressCount to 0")
    savedData.pressCount <- 0;
} else {
    server.log("Restored pressCount = " + savedData.pressCount)
}

device.on("Button Pressed", function(data) {
    // Record button press
    server.log("Button Pressed");
    savedData.pressCount++;
    server.save(savedData);
    
    http.post(groupme_url, {"Content-type": "application/json"}, 
        http.jsonencode({"text":"Button has been pressed for the " + savedData.pressCount + " th time", "bot_id":botid})).sendsync();
})

device.on("Broadcast Groupme", function(data) {
    server.log("Broadcast Groupme");
    savedData.pressCount++;
    server.save(savedData);
    
    local bodytext = "Button has been pressed!"
    local currentdate = date();
    currentdate.hour = (currentdate.hour + TIMEZONE + 24) % 24;
    if (currentdate.hour <= 13 && currentdate.hour >= 7) {
        // Morning
        if (currentdate.wday == DAY_SUNDAY) {
            bodytext = "Brunch is ready!";
        } else if(currentdate.wday == DAY_FRIDAY) {
            bodytext = "Groceries are here. Thanks unloading team!";
        }
    } else if (currentdate.hour <= 19 && currentdate.hour >= 16) {
        bodytext = "Dinner is ready!";
    }
    
    if (bodytext != "") {
        server.log("Posting: " + bodytext);
        http.post(groupme_url, {"Content-type": "application/json"}, 
            http.jsonencode({"text":bodytext, "bot_id":brownbotid})).sendsync();
    }
});