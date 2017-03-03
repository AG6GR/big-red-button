#require "Button.class.nut:1.2.0"

// Timeout to prevent button spaming within an interval of TIMEOUT_TIME seconds 
const SLEEP_DELAY = 20;
const SLEEP_DURATION = 600;
const PRESSED_DURATION = 5;
const BRIGHTNESS_DIM = 0.2;

enum STATES {
    IDLE,
    PRESSED,
    HELD,
    HELD_OFF
};

pin_button <- hardware.pin1;
pin_light <- hardware.pin8;
pin_light.configure(PWM_OUT, 0.0001, BRIGHTNESS_DIM);
pressedTimer <- null;
currentState <- STATES.IDLE;

function prepareSleep() {
    pin_light.write(0);
    imp.onidle(function(){
        server.sleepfor(SLEEP_DURATION);
    });
}
function resetSleep() {
    // Reset sleep timer due to activity
    if (sleepTimer != null) {
        imp.cancelwakeup(sleepTimer);
    }
    sleepTimer = imp.wakeup(SLEEP_DELAY, prepareSleep);
}
function buttonHeld() {
    currentState = STATES.HELD;
    pin_light.write(1);
    pressedTimer = imp.wakeup(0.25, buttonHeldOff);
    resetSleep()
}
function buttonHeldOff() {
    currentState = STATES.HELD_OFF;
    pin_light.write(0);
    pressedTimer = imp.wakeup(0.25, buttonHeld);
    resetSleep()
}
function buttonPressed() {
    //server.log("Button Pressed")
    currentState = STATES.PRESSED;
    pin_light.write(BRIGHTNESS_DIM);
    
    if (pressedTimer != null) {
        imp.cancelwakeup(pressedTimer);
    }
    pressedTimer = imp.wakeup(PRESSED_DURATION, buttonHeld);
    
    resetSleep()
}
function buttonReleased() {
    imp.cancelwakeup(pressedTimer);
    //server.log("Button Released")
    switch(currentState) {
        case STATES.HELD:
        case STATES.HELD_OFF:
            agent.send("Broadcast Groupme", null)
            break;
        case STATES.PRESSED:
            agent.send("Button Pressed", null);
            break;
        default:
            server.error("Invalid state: " + currentState);
    }
    currentState = STATES.IDLE;
    pin_light.write(1);
    resetSleep()
}

// Setup sleep timer
sleepTimer <- imp.wakeup(SLEEP_DELAY, prepareSleep);

// Init button object
button <- Button(pin_button, DIGITAL_IN_WAKEUP, Button.NORMALLY_LOW, buttonPressed, buttonReleased)

switch(hardware.wakereason()) {
    case WAKEREASON_PIN:
        server.log("Wakeup from sleep");
        buttonPressed();
        break;
    default:
        server.log("Power on");
        currentState = STATES.IDLE;
        pin_light.write(1);
        break;
}