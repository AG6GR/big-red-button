// Timeout to prevent button spaming within an interval of TIMEOUT_TIME seconds 
const TIMEOUT_TIME = 3;
const SLEEP_DELAY = 30;
const SLEEP_DURATION = 600;
isActive <- true;

pin_button <- hardware.pin1;
pin_light <- hardware.pin8;
pin_light.configure(PWM_OUT, 0.0001, 1);

function prepareSleep() {
    pin_light.write(0);
    imp.onidle(function(){
        server.sleepfor(SLEEP_DURATION);
    });
}
function resetActive() {
    server.log("Button Reenabled")
    isActive = true;
    pin_light.write(1);
}
function buttonPressed() {
    if (isActive) {
        isActive = false;
        agent.send("Button Pressed", null);
        pin_light.write(0.2);
        imp.wakeup(TIMEOUT_TIME, resetActive);
    }
    if (sleepTimer != null) {
        imp.cancelwakeup(sleepTimer);
    }
    sleepTimer <- imp.wakeup(SLEEP_DELAY, prepareSleep);
}

pin_button.configure(DIGITAL_IN_WAKEUP, buttonPressed);

// Setup sleep timer
sleepTimer <- imp.wakeup(SLEEP_DELAY, prepareSleep);

switch(hardware.wakereason()) {
    case WAKEREASON_PIN:
        server.log("Wakeup from sleep");
        buttonPressed();
        break;
    default:
        server.log("Power on");
        break;
}