# Big Red IoT Button

<center><img src='doc/Icon.JPG' alt='Big Red Button'/></center>

Taking root from an impulse buy of a 10 cm large red arcade button during a clearance sale, this project is a simple Electric Imp-powered IoT button that posts to popular messaging platforms like Slack and GroupMe. The first iteration was thrown together during HackPrinceton Fall 2016, and posted messages to the "random" channel of the HackPrinceton Slack group. After the hackathon, the button was repurposed to serve as a kind of IoT dinner bell for the Brown Co-op at Princeton University, sending a message to the co-op GroupMe when dinner was ready.

## Hardware
The hardware for the button centered around an Electric Imp <a target="_blank" href="https://electricimp.com/docs/hardware/resources/reference-designs/april/"> April development board</a> and a 10 cm illuminated red arcade button from <a target="_blank" href="https://www.adafruit.com/product/1185">Adafruit</a>. The setup was powered from a single 9V battery, with a NPN transistor used to control the button's light. 

Taking a conservative estimate of 50mA at 3.3V for the imp001's power usage, the majority of the power consumed by the device comes from the LED in the button, which draws about 10mA at 9V. Thus, with a 600mAh 9V battery, the button could run continuously for well over 20 hours on a single 9V battery. In practice, code was added to place the imp in sleep mode after a certain run time, and the button is unlikely to be used for more than a few seconds every day. If we assume the device is run for a minute per day every day, the battery would need to be changed about once every 1200 days or 3 and a quarter years. 

## Slack

<center><img src='doc/SlackMessage.png' alt='Slack Message'/></center>

The most basic form of the device code used during the hackathon simply sent a message to the server-side agent whenever the imp detected a transition on the pin connected to the button's microswitch. Then the agent would make a HTTP POST request to <a target="_blank" href="https://api.slack.com/incoming-webhooks">Slack's Incomming Webhook API</a> with a predefinied message.

In practice, the code is exceedingly simple, just 10 lines including comments! Here's the complete agent code:

```squirrel
// Slack Webhook URL
slack_url <- "https://hooks.slack.com/services/..."
// Text to be posted
bodytext <- "The Big Red Electric Imp Button has been pressed!";

device.on("Button Pressed", function(data) {
    server.log("Button Pressed");
    http.post(groupme_url, {"Content-type": "application/json"}, 
        http.jsonencode({"text":bodytext})).sendsync();
});
```

Here's the first revision of the device code, which had a basic timeout functionality built in to prevent people from spamming the list by mashing the button.

```squirrel
server.log("Starting...")

// Timeout to prevent button spaming within an interval of SLEEP_TIME seconds 
const SLEEP_TIME = 2;
isActive <- true;

pin_button <- hardware.pin1;
pin_light <- hardware.pin8;

pin_light.configure(DIGITAL_OUT, 1);


function resetActive() {
    isActive = true;
}
function buttonPressed() {
    if (isActive) {
        isActive = false;
        agent.send("Button Pressed", null);
        imp.wakeup(SLEEP_TIME, resetActive);
    }
}
pin_button.configure(DIGITAL_IN_WAKEUP, buttonPressed);
```

## GroupMe

<center><img src='doc/GroupMeMessage.png' alt='Slack Message'/></center>

After the Hackathon the button was adapted to work with <a target="_blank" href=" https://dev.groupme.com/tutorials/bots">GroupMe's Bot API</a>. Creating a bot with the online form gives a Bot ID and Group ID which can then be used to post messages using HTTP POST requests. The same device code can be used, and the agent is practically identical.

```squirrel
// GroupMe post endpoint
groupme_url <- "https://api.groupme.com/v3/bots/post"
// Text to be posted
bodytext <- "The Big Red Electric Imp Button has been pressed!";
// Bot ID
botid <- "pasteyouridhere"
groupid <- "pasteyourgroupidhere"

device.on("Button Pressed", function(data) {
    server.log("Button Pressed");
    http.post(groupme_url, {"Content-type": "application/json"}, 
        http.jsonencode({"text":bodytext, "bot_id":botid})).sendsync();
});
```

## Deployment

<center><img src='doc/HackPrincetonDeploy.png' alt='HackPrinceton Deployment'/></center>

The button was remarkably succesful, and attracted a lot of attention wherever it went. The Electric Imp platform and chat services' APIs worked very quickly, such that someone could press the button and get a push notification on their phone without perceptible delay. 

<center><img src='doc/HackPrincetonReaction.png' alt='HackPrinceton Reactions'/></center>

The best part of this project was watching people's reactions. The physicality of pressing the button combined with the quick response and complete lack of wires made for a really compelling experience. Furthermore, the public visibility of the messages really helped to draw attention to the button and served as a subtle form of advertising for the Electric Imp platform. I think it played no small part in ensuring my Electric Imp workshop later that night was well attended. 