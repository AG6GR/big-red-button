#require "Firebase.class.nut:2.0.1"

// ----- FIREBASE SETUP ----- //

const FIREBASE_NAME = "firebaseid";
const FIREBASE_AUTH_KEY = "firebaseauthkey";

firebase <- Firebase(FIREBASE_NAME, FIREBASE_AUTH_KEY);

// ----- GROUPME SETUP ----- //
const groupme_url = "https://api.groupme.com/v3/bots/post"

const debugbotid = "debugid"
const debuggroupid = "debuggroupid"

const brownbotid = "messageid";
const groupid = "messagegroupid";

bodytext <- "The Big Red Electric Imp Button has been pressed.";

// ----- SCHEDULING CONSTANTS ----- //

const TIMEZONE = -5;
const DAY_SUNDAY = 0;
const DAY_FRIDAY = 5;

savedData <- server.load();
if (!("pressCount" in savedData)){
    server.log("Initing pressCount to 0")
    savedData.pressCount <- 0;
} else {
    server.log("Restored pressCount = " + savedData.pressCount)
}

http.post(groupme_url, {"Content-type": "application/json"}, 
    http.jsonencode({"text":"Agent restarted. pressCount = " + savedData.pressCount, "bot_id":debugbotid})).sendsync();

device.on("Button Pressed", function(data) {
    // Record button press
    server.log("Button Pressed");
    savedData.pressCount++;
    server.save(savedData);
    
    local uploaddata = {};
    uploaddata.count <- savedData.pressCount;
    
    firebase.write("/presses/" + time(), uploaddata, function (error, response) {
        if (error != null) {
            server.error(error)
            http.post(groupme_url, {"Content-type": "application/json"}, 
                http.jsonencode({"text":"Firebase server error! " + error, "bot_id":debugbotid})).sendsync();
        } else {
            //server.log(response)
        }
    });
    
    /*
    http.post(groupme_url, {"Content-type": "application/json"}, 
        http.jsonencode({"text":"Button has been pressed for the " + savedData.pressCount + " th time", "bot_id":debugbotid})).sendsync();
    */
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

device.onconnect(function() {
    http.post(groupme_url, {"Content-type": "application/json"}, 
        http.jsonencode({"text":"Device connected", "bot_id":debugbotid})).sendsync();
});