#import <ApplicationServices/ApplicationServices.h>

#define SIGN(x) (((x) > 0) - ((x) < 0))
#define LINES -3

const CGKeyCode RIGHT_CMD_CODE = (CGKeyCode) 0x36;
const CGKeyCode RIGHT_SHIFT_CODE = (CGKeyCode) 0x3C;
const CGKeyCode RIGHT_ALT_CODE = (CGKeyCode) 0x3D;
const CGKeyCode RIGHT_CTRL_CODE = (CGKeyCode) 0x3E;

const CGKeyCode LEFT_ARROW_CODE = (CGKeyCode) 0x7B;
const CGKeyCode RIGHT_ARROW_CODE = (CGKeyCode) 0x7C;
const CGKeyCode DOWN_ARROW_CODE = (CGKeyCode) 0x7D;
const CGKeyCode UP_ARROW_CODE = (CGKeyCode) 0x7E;

static bool previousKeyDownWasShift = false;
static bool previousKeyDownWasCommand = false;

CGEventRef cgEventCallback(CGEventTapProxy proxy, CGEventType type,
                           CGEventRef event, void *refcon)
{
    if (!CGEventGetIntegerValueField(event, kCGScrollWheelEventIsContinuous)) {
        int64_t delta = CGEventGetIntegerValueField(event, kCGScrollWheelEventPointDeltaAxis1);
        
        CGEventSetIntegerValueField(event, kCGScrollWheelEventDeltaAxis1, SIGN(delta) * LINES);
    }
    
    return event;
}

void pressKey(CGKeyCode code, CGEventFlags modifiers, CGEventTapProxy proxy)
{
    CGEventRef e = CGEventCreateKeyboardEvent(NULL, code, true);
    CGEventSetFlags(e, modifiers);
    CGEventTapPostEvent(proxy, e);
    CGEventSetType(e, kCGEventKeyUp);
    CGEventTapPostEvent(proxy, e);
}

// Returns true if cmd, ctrl, alt, or shift are in the down position.
bool modifierKeysAreDown(CGEventFlags modifiers)
{
    return (modifiers & kCGEventFlagMaskCommand)
        || (modifiers & kCGEventFlagMaskShift)
        || (modifiers & kCGEventFlagMaskControl)
        || (modifiers & kCGEventFlagMaskAlternate);
}

CGEventRef cgEventKeyCallback(CGEventTapProxy proxy, CGEventType type,
                              CGEventRef event, void *refcon)
{
    CGKeyCode keycode = (CGKeyCode)CGEventGetIntegerValueField(
                           event, kCGKeyboardEventKeycode);
    CGEventFlags modifiers = CGEventGetFlags(event);
    
    if (keycode == RIGHT_SHIFT_CODE) {
        if (!(modifiers & kCGEventFlagMaskShift) && previousKeyDownWasShift) {
            pressKey(UP_ARROW_CODE, modifiers, proxy);
        }
    } else if (keycode == RIGHT_CMD_CODE) {
        if (!(modifiers & kCGEventFlagMaskCommand) && previousKeyDownWasCommand) {
            pressKey(DOWN_ARROW_CODE, modifiers, proxy);
        }
    } /*else if (keycode == RIGHT_CTRL_CODE) {
        if (modifiers & kCGEventFlagMaskControl) {
            pressKey(RIGHT_ARROW_CODE, modifiers, proxy);
        }
    }*/
    
    previousKeyDownWasShift = keycode == RIGHT_SHIFT_CODE && (modifiers & kCGEventFlagMaskShift);
    previousKeyDownWasCommand = keycode == RIGHT_CMD_CODE && (modifiers & kCGEventFlagMaskCommand);
    
    return event;
}

int main(void)
{
    
    // Add event tap for mouse events (scroll wheel only).
    CFMachPortRef eventTap;
    CFRunLoopSourceRef runLoopSource;
    
    eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0,
                                1 << kCGEventScrollWheel, cgEventCallback, NULL);
    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(eventTap, true);
    
    // Add event tap for keyboard events.
    
    CFMachPortRef eventTapKey;
    CFRunLoopSourceRef runLoopSourceKey;
    
    eventTapKey = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0,
                                   (1 << kCGEventKeyUp) | (1 << kCGEventKeyDown) | (1 << kCGEventFlagsChanged), cgEventKeyCallback, NULL);
    if (!eventTapKey) {
        fprintf(stderr, "failed to create event tap\n");
        exit(1);
    }
    runLoopSourceKey = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTapKey, 0);
    
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSourceKey, kCFRunLoopCommonModes);
    CGEventTapEnable(eventTapKey, true);
    
    //
    
    CFRunLoopRun();
    
    //
    
    CFRelease(eventTap);
    CFRelease(runLoopSource);
    
    CFRelease(eventTapKey);
    CFRelease(runLoopSourceKey);
    
    return 0;
}
