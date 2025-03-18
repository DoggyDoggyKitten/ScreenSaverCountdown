#import "ScreenSaverCountdownView.h"

@implementation ScreenSaverCountdownView {
    NSInteger countdown; // Total seconds
    NSInteger initialCountdown; // Minutes * 60
    IBOutlet NSWindow *configSheet; 
    IBOutlet NSTextField *countdownInput;
    NSImage *backgroundImage;
}

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1]; // 1 second per frame.

        // Load the background image
        NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"running_cat" ofType:@"png"];
        backgroundImage = [[NSImage alloc] initWithContentsOfFile:imagePath];

        // Load minutes and convert to seconds
        ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"ScreenSaverCountdown"];
        initialCountdown = [defaults integerForKey:@"initialCountdown"] * 60;
        if (initialCountdown == 0) {
            initialCountdown = 60 * 60; // Default to 60 mins
        }
        countdown = initialCountdown;
    }
    return self;
}

- (BOOL)hasConfigureSheet {
    return YES;
}

- (NSWindow*)configureSheet {
    if (!configSheet) {
        [[NSBundle bundleForClass:[self class]] loadNibNamed:@"ConfigureSheet" owner:self topLevelObjects:nil];
        [countdownInput setIntegerValue:initialCountdown / 60]; // Show minutes in config
    }
    return configSheet;
}

- (IBAction)closeConfigureSheet:(id)sender {
    // Convert minutes to seconds when saving
    initialCountdown = [countdownInput integerValue] * 60;
    countdown = initialCountdown;
    
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"ScreenSaverCountdown"];
    [defaults setInteger:initialCountdown / 60 forKey:@"initialCountdown"];
    [defaults synchronize];
    
    [[NSApplication sharedApplication] endSheet:configSheet];
}

- (void)drawRect:(NSRect)rect {
    if (backgroundImage) {
        NSSize imageSize = [backgroundImage size];
        NSSize viewSize = [self bounds].size;
        
        // Calculate aspect ratio to maintain image proportions
        float widthRatio = viewSize.width / imageSize.width;
        float heightRatio = viewSize.height / imageSize.height;
        float scale = MAX(widthRatio, heightRatio);
        
        NSSize scaledSize = NSMakeSize(imageSize.width * scale, imageSize.height * scale);
        NSRect drawRect = NSMakeRect(
            (viewSize.width - scaledSize.width) / 2,
            (viewSize.height - scaledSize.height) / 2,
            scaledSize.width,
            scaledSize.height
        );
        
        [backgroundImage drawInRect:drawRect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
    }

    // Text styles and positions
    CGFloat fontSize = rect.size.height * 0.1;  // 10% of screen height
    [[NSColor whiteColor] setFill];
    NSFont *font = [NSFont fontWithName:@"Helvetica" size:fontSize];
    NSDictionary *attrs = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: [NSColor blackColor],
        NSShadowAttributeName: ({
           NSShadow *shadow = [[NSShadow alloc] init];
           shadow.shadowColor = [NSColor whiteColor];
           shadow.shadowBlurRadius = 3;
           shadow.shadowOffset = NSMakeSize(2, -2);
           shadow;
       })
    };

    // Format time as minutes:seconds
    NSInteger minutes = countdown / 60;
    NSInteger seconds = countdown % 60;
    NSString *text = [NSString stringWithFormat:@"I will be back in %ld:%02ld", minutes, seconds];
    NSSize textSize = [text sizeWithAttributes:attrs];
    
    NSPoint textPoint = NSMakePoint(
        20,
        rect.size.height - textSize.height - 20
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
