#import "ScreenSaverCountdownView.h"

@implementation ScreenSaverCountdownView {
    NSInteger countdown;
    NSInteger initialCountdown;
    IBOutlet NSWindow *configSheet; 
    IBOutlet NSTextField *countdownInput;
}

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1]; // 1 second per frame.

        ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"ScreenSaverCountdown"];
        initialCountdown = [defaults integerForKey:@"initialCountdown"];
        if (initialCountdown == 0) {
            initialCountdown = 60;
        }
        countdown = initialCountdown;
    }
    return self;
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    if (!configSheet) {
        [[NSBundle bundleForClass:[self class]] loadNibNamed:@"ConfigureSheet" owner:self topLevelObjects:nil];
        [countdownInput setIntegerValue:initialCountdown];
    }
    return configSheet;
}

- (IBAction)closeConfigureSheet:(id)sender
{
    initialCountdown = [countdownInput integerValue];
    countdown = initialCountdown;
    
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"ScreenSaverCountdown"];
    [defaults setInteger:initialCountdown forKey:@"initialCountdown"];
    [defaults synchronize];
    
    [[NSApplication sharedApplication] endSheet:configSheet];
}

- (void)drawRect:(NSRect)rect {
    // Background
    [[NSColor blackColor] setFill];
    NSRectFill(rect);
    [[NSColor whiteColor] setFill];
    
    // Text
    NSFont *font = [NSFont fontWithName:@"Helvetica" size:72.0];
    NSDictionary *attrs = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: [NSColor whiteColor]
    };
    NSString *text = [NSString stringWithFormat:@"%ld", countdown];
    NSSize textSize = [text sizeWithAttributes:attrs];
    
    // Text position
    NSPoint textPoint = NSMakePoint(
        (rect.size.width - textSize.width) / 2,
        (rect.size.height - textSize.height) / 2
    );
    
    [text drawAtPoint:textPoint withAttributes:attrs];
}

- (void)animateOneFrame {
     if (countdown > 0) {
        countdown--;
    } else {
        countdown = initialCountdown;
    }
    [self setNeedsDisplay:YES];
}


@end
