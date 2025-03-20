#import "ScreenSaverCountdownView.h"

@implementation ScreenSaverCountdownView {
    NSInteger countdown; // Total seconds
    NSInteger initialCountdown; // Minutes * 60

    // Preview config related
    IBOutlet NSWindow *configSheet; 
    IBOutlet NSTextField *countdownInput;
    IBOutlet NSPopUpButton *messageSelect;
    IBOutlet NSTextField *customMessageInput;

    NSImage *backgroundImage;
    NSString *currentMessage;
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
        currentMessage = [defaults stringForKey:@"currentMessage"];

        if (initialCountdown == 0) {
            initialCountdown = 60 * 60; // Default to 60 mins
        }
        if (!currentMessage) {
            currentMessage = @"I will be back in ";
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

        // Setup popup button
        [messageSelect removeAllItems];
        [messageSelect addItemsWithTitles:@[
            @"I will be back in",
            @"Venturing into the MK for a snack quest. Back in ",
            @"Heading to the gym to make today awesome! Back in ",
            @"Following my nose to yummy-land! Back in ",
            @"Refreshing in the restroom Back in ",
            @"Custom message..."
        ]];

        // Add target action connection
        [messageSelect setTarget:self];
        [messageSelect setAction:@selector(messageSelectionChanged:)];

        // Show minutes in config
        [countdownInput setIntegerValue:initialCountdown / 60]; 

        // Configure for saved message
        NSInteger index = [messageSelect indexOfItemWithTitle:currentMessage];
        if (index != NSNotFound) {
            [messageSelect selectItemAtIndex:index];
        } else {
            // If saved message isn't in preset list, select "Custom message..."
            [messageSelect selectItemWithTitle:@"Custom message..."];
            [customMessageInput setStringValue:currentMessage];
        }
        
        // Setup initial custom message field visibility
        [self updateCustomMessageVisibility:nil];
    }
    return configSheet;
}

- (IBAction)messageSelectionChanged:(id)sender {
    [self updateCustomMessageVisibility:sender];
}

- (void)updateCustomMessageVisibility:(id)sender {
    BOOL isCustom = [[messageSelect selectedItem].title isEqualToString:@"Custom message..."];
    [customMessageInput setHidden:!isCustom];
}

- (IBAction)closeConfigureSheet:(id)sender {
    // Convert minutes to seconds when saving
    initialCountdown = [countdownInput integerValue] * 60;
    countdown = initialCountdown;
    
    // Save the message
    if ([[messageSelect selectedItem].title isEqualToString:@"Custom message..."]) {
        currentMessage = [customMessageInput stringValue];
    } else {
        currentMessage = [messageSelect selectedItem].title;
    }

    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"ScreenSaverCountdown"];
    [defaults setInteger:initialCountdown / 60 forKey:@"initialCountdown"];
    [defaults setObject:currentMessage forKey:@"currentMessage"];
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
    CGFloat fontSize = rect.size.height * 0.07; 
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
    NSString *timeString = [NSString stringWithFormat:@"%ld:%02ld", minutes, seconds];
    NSSize textSize = [timeString sizeWithAttributes:attrs];
    
    // Combine message with time
    NSString *text = [NSString stringWithFormat:@"%@ : %@", currentMessage, timeString];

    // Line style to wrap into two lines
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];    
    NSMutableDictionary *mutableAttrs = [attrs mutableCopy];
    [mutableAttrs setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    NSRect textRect = NSMakeRect(
        20,  // Left margin
        rect.size.height - fontSize * 5,  // Top position
        rect.size.width - 40,  // Width minus margins
        fontSize * 3  // Height for multiple lines
    );
    
    [text drawInRect:textRect withAttributes:mutableAttrs];
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
