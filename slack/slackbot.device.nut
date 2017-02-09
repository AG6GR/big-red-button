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