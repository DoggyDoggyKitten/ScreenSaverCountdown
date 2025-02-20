#import "ScreenSaverCountdownView.h"

@implementation ScreenSaverCountdownView {
    NSInteger countdown;
}

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1]; // 1 second per frame.
        countdown = 60;
    }
    return self;
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
        countdown = 60; // reset the timer
    }
    [self setNeedsDisplay:YES];
}


@end
