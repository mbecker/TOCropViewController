//
//  TOCropToolbar.h
//
//  Copyright 2015-2016 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOCropToolbar.h"

#define TOCROPTOOLBAR_DEBUG_SHOWING_BUTTONS_CONTAINER_RECT     0   // convenience debug toggle

@interface TOCropToolbar()

@property (nonatomic, strong, readwrite) UIButton *doneTextButton;
@property (nonatomic, strong, readwrite) UIButton *doneIconButton;

@property (nonatomic, strong, readwrite) UIButton *cancelTextButton;
@property (nonatomic, strong, readwrite) UIButton *cancelIconButton;

@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *clampButton;

@property (nonatomic, strong) UIButton *rotateButton; // defaults to counterclockwise button for legacy compatibility

@property (nonatomic, assign) BOOL reverseContentLayout; // For languages like Arabic where they natively present content flipped from English

- (void)setup;
- (void)buttonTapped:(id)button;

+ (UIImage *)doneImage;
+ (UIImage *)cancelImage;
+ (UIImage *)resetImage;
+ (UIImage *)rotateCCWImage;
+ (UIImage *)rotateCWImage;
+ (UIImage *)clampImage;

@end

@implementation TOCropToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

+(NSBundle *)getResourcesBundle
{
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"Images" withExtension:@"bundle"]];
    return bundle;
}


+(UIImage *)loadImageFromResourceBundle:(NSString *)imageName
{
    NSBundle *bundle = [TOCropToolbar getResourcesBundle];
    NSString *imageFileName = [NSString stringWithFormat:@"%@.png",imageName];
    UIImage *image = [UIImage imageNamed:imageFileName inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

- (void)setup {
    // Added by mbecker. Updated background color of bottom container
    self.backgroundColor = [UIColor clearColor];
    //[UIColor colorWithRed:0.09 green:0.10 blue:0.12 alpha:1.00];
    
    _rotateClockwiseButtonHidden = YES;
    
    // On iOS 9, we can use the new layout features to determine whether we're in an 'Arabic' style language mode
    if ([UIView resolveClassMethod:@selector(userInterfaceLayoutDirectionForSemanticContentAttribute:)]) {
        self.reverseContentLayout = ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft);
    }
    else {
        self.reverseContentLayout = [[[NSLocale preferredLanguages] objectAtIndex:0] hasPrefix:@"ar"];
    }
    
    // In CocoaPods, strings are stored in a separate bundle from the main one
    NSBundle *resourceBundle = nil;
    NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
    NSURL *resourceBundleURL = [classBundle URLForResource:@"TOCropViewControllerBundle" withExtension:@"bundle"];
    if (resourceBundleURL) {
        resourceBundle = [[NSBundle alloc] initWithURL:resourceBundleURL];
    }
    else {
        resourceBundle = classBundle;
    }
    
    /*
     * StackView
     */
    
    float bottomViewHeight = 124.0f;
    float textButtonwidth = 100.0f;
    double buttonWidth = 50;
    int numberOfButtons = 3;
    int paddingStackView = 5;
    
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.spacing = (self.bounds.size.width - numberOfButtons * buttonWidth) / (numberOfButtons - 1);
    
    /* Done Text Button */
    NSAttributedString *attributedString =
    [[NSAttributedString alloc]
     initWithString: NSLocalizedStringFromTableInBundle(@"Next", @"TOCropViewControllerLocalizable", resourceBundle, nil)
     attributes:
     @{
       NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:19],
       NSForegroundColorAttributeName : [UIColor whiteColor],
       NSKernAttributeName : @(0.6f)
       }];
    
    NSAttributedString *selectedAttributedString =
    [[NSAttributedString alloc]
     initWithString: NSLocalizedStringFromTableInBundle(@"Next", @"TOCropViewControllerLocalizable", resourceBundle, nil)
     attributes:
     @{
       NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:19],
       NSForegroundColorAttributeName : [UIColor colorWithHue:0.58 saturation:0.27 brightness:0.12 alpha:1.00], // Aztec black
       NSKernAttributeName : @(0.6f)
       }];
    
    _doneTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneTextButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    [_doneTextButton setAttributedTitle:selectedAttributedString forState:UIControlStateSelected];
    [_doneTextButton setBackgroundColor:[UIColor colorWithHue:0.46 saturation:0.85 brightness:0.59 alpha:1.00]];
    _doneTextButton.layer.borderWidth = 1;
    _doneTextButton.layer.borderColor = [UIColor colorWithHue:0.46 saturation:0.85 brightness:0.59 alpha:1.00].CGColor;
    
    CGFloat buttonPaddingBottom = 16;
    CGFloat buttonPaddingWidth = 32;
    CGFloat buttonwidth = 108;
    CGFloat buttonheight = 46.135;
    _doneTextButton.layer.cornerRadius = buttonheight / 2;
    
    CGFloat posy = bottomViewHeight - buttonheight - buttonPaddingBottom;
    CGFloat posx = [UIScreen mainScreen].bounds.size.width - buttonwidth - buttonPaddingWidth;
    
    _doneTextButton.frame = CGRectMake(posx, posy, buttonwidth, buttonheight);
    
    [_doneTextButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_doneTextButton];
    
    /**
     * Cancel Button
     */
    /* Done Text Button */
    NSAttributedString *cancelAttributedString =
    [[NSAttributedString alloc]
     initWithString: NSLocalizedStringFromTableInBundle(@"Back", @"TOCropViewControllerLocalizable", resourceBundle, nil)
     attributes:
     @{
       NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:19],
       NSForegroundColorAttributeName : [UIColor whiteColor],
       NSKernAttributeName : @(0.6f)
       }];
    
    NSAttributedString *cancelSelectedAttributedString =
    [[NSAttributedString alloc]
     initWithString: NSLocalizedStringFromTableInBundle(@"Back", @"TOCropViewControllerLocalizable", resourceBundle, nil)
     attributes:
     @{
       NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:19],
       NSForegroundColorAttributeName : [UIColor colorWithHue:0.58 saturation:0.27 brightness:0.12 alpha:1.00], // Aztec black
       NSKernAttributeName : @(0.6f)
       }];
    
    _cancelTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelTextButton setAttributedTitle:cancelAttributedString forState:UIControlStateNormal];
    [_cancelTextButton setAttributedTitle:cancelSelectedAttributedString forState:UIControlStateSelected];
    [_cancelTextButton setBackgroundColor:[UIColor colorWithHue:0.46 saturation:0.85 brightness:0.59 alpha:1.00]];
    _cancelTextButton.layer.borderWidth = 1;
    _cancelTextButton.layer.borderColor = [UIColor colorWithHue:0.46 saturation:0.85 brightness:0.59 alpha:1.00].CGColor;
    
    _cancelTextButton.layer.cornerRadius = buttonheight / 2;
    
    _cancelTextButton.frame = CGRectMake(buttonPaddingWidth, posy, buttonwidth, buttonheight);
    
    [_cancelTextButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addSubview:_cancelTextButton];

    
    /*
     * Rotate counter clockwise button
     */
    _rotateCounterclockwiseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _rotateCounterclockwiseButton.contentMode = UIViewContentModeCenter;
    [_rotateCounterclockwiseButton setImage:[TOCropToolbar rotateCCWImage] forState:UIControlStateNormal];
    [_rotateCounterclockwiseButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_rotateCounterclockwiseButton setBackgroundColor:[UIColor clearColor]];
    _rotateCounterclockwiseButton.tintColor = [UIColor colorWithHue:0.60 saturation:0.47 brightness:0.35 alpha:1.00];
    
    /*
     * Reset button
     */
    _resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _resetButton.contentMode = UIViewContentModeCenter;
    _resetButton.tintColor = [UIColor yellowColor];
    _resetButton.enabled = NO;
    [_resetButton setImage:[TOCropToolbar resetImage] forState:UIControlStateNormal];
    [_resetButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    _resetButton.tintColor = [UIColor colorWithHue:0.60 saturation:0.47 brightness:0.35 alpha:1.00];
    [_resetButton setBackgroundColor:[UIColor clearColor]];
    
    /*
     * Rotate clockwise button
     */
    _rotateClockwiseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _rotateClockwiseButton.contentMode = UIViewContentModeCenter;
    [_rotateClockwiseButton setImage:[TOCropToolbar rotateCWImage] forState:UIControlStateNormal];
    [_rotateClockwiseButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_rotateClockwiseButton setBackgroundColor:[UIColor clearColor]];
    _rotateClockwiseButton.tintColor = [UIColor colorWithHue:0.60 saturation:0.47 brightness:0.35 alpha:1.00];
    
    /**
    * Stackview
    */
    [stackView addArrangedSubview:_rotateCounterclockwiseButton];
    [stackView addArrangedSubview:_resetButton];
    [stackView addArrangedSubview:_rotateClockwiseButton];
    
    stackView.translatesAutoresizingMaskIntoConstraints = false;
    [stackView setBackgroundColor:[UIColor orangeColor]];
    [self addSubview:stackView];
    
    CGFloat stackViewHeight = bottomViewHeight - buttonheight - buttonPaddingBottom;
    [stackView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-textButtonwidth-paddingStackView].active = true;
    [stackView.topAnchor constraintEqualToAnchor:self.topAnchor].active = true;
    [stackView.heightAnchor constraintEqualToConstant:stackViewHeight].active = true;
    [stackView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:textButtonwidth+paddingStackView].active = true;
    
    [_rotateCounterclockwiseButton.widthAnchor constraintEqualToConstant:buttonWidth].active = true;
    [_rotateCounterclockwiseButton.bottomAnchor constraintEqualToAnchor:stackView.bottomAnchor constant:0].active = true;
    [_rotateCounterclockwiseButton.topAnchor constraintEqualToAnchor:stackView.topAnchor constant:0].active = true;
    
    [_resetButton.widthAnchor constraintEqualToConstant:buttonWidth].active = true;
    [_resetButton.bottomAnchor constraintEqualToAnchor:stackView.bottomAnchor constant:0].active = true;
    [_resetButton.topAnchor constraintEqualToAnchor:stackView.topAnchor constant:0].active = true;
    
    [_rotateClockwiseButton.widthAnchor constraintEqualToConstant:buttonWidth].active = true;
    [_rotateClockwiseButton.bottomAnchor constraintEqualToAnchor:stackView.bottomAnchor constant:0].active = true;
    [_rotateClockwiseButton.topAnchor constraintEqualToAnchor:stackView.topAnchor constant:0].active = true;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    BOOL verticalLayout = (CGRectGetWidth(self.bounds) < CGRectGetHeight(self.bounds));
    CGSize boundsSize = self.bounds.size;
    
    self.cancelIconButton.hidden = (!verticalLayout);
    self.cancelTextButton.hidden = (verticalLayout);
    self.doneIconButton.hidden   = (!verticalLayout);
    self.doneTextButton.hidden   = (verticalLayout);
    
#if TOCROPTOOLBAR_DEBUG_SHOWING_BUTTONS_CONTAINER_RECT
    static UIView *containerView = nil;
    if (!containerView) {
        containerView = [[UIView alloc] initWithFrame:CGRectZero];
        containerView.backgroundColor = [UIColor redColor];
        containerView.alpha = 0.1;
        [self addSubview:containerView];
    }
#endif
    
    if (verticalLayout == NO) {
        // Deleted
    }
    else {
        CGRect frame = CGRectZero;
        frame.size.height = 44.0f;
        frame.size.width = 44.0f;
        frame.origin.y = CGRectGetHeight(self.bounds) - 44.0f;
        self.cancelIconButton.frame = frame;
        
        frame.origin.y = 0.0f;
        frame.size.width = 44.0f;
        frame.size.height = 44.0f;
        self.doneIconButton.frame = frame;
        // Added by mbecker: Updated height from 44.0f to 101.0f
        CGRect containerRect = (CGRect){0,CGRectGetMaxY(self.doneIconButton.frame),101.0f,CGRectGetMinY(self.cancelIconButton.frame)-CGRectGetMaxY(self.doneIconButton.frame)};
        
#if TOCROPTOOLBAR_DEBUG_SHOWING_BUTTONS_CONTAINER_RECT
        containerView.frame = containerRect;
#endif
        
        CGSize buttonSize = (CGSize){44.0f,44.0f};
        
        NSMutableArray *buttonsInOrderVertically = [NSMutableArray new];
        if (!self.rotateCounterclockwiseButtonHidden) {
            [buttonsInOrderVertically addObject:self.rotateCounterclockwiseButton];
        }
        
        [buttonsInOrderVertically addObject:self.resetButton];
        
        if (!self.clampButtonHidden) {
            [buttonsInOrderVertically addObject:self.clampButton];
        }
        
        if (!self.rotateClockwiseButtonHidden) {
            [buttonsInOrderVertically addObject:self.rotateClockwiseButton];
        }
        
        [self layoutToolbarButtons:buttonsInOrderVertically withSameButtonSize:buttonSize inContainerRect:containerRect horizontally:NO];
    }
}

// The convenience method for calculating button's frame inside of the container rect
- (void)layoutToolbarButtons:(NSArray *)buttons withSameButtonSize:(CGSize)size inContainerRect:(CGRect)containerRect horizontally:(BOOL)horizontally
{
    NSInteger count = buttons.count;
    CGFloat fixedSize = horizontally ? size.width : size.height;
    CGFloat maxLength = horizontally ? CGRectGetWidth(containerRect) : CGRectGetHeight(containerRect);
    CGFloat padding = (maxLength - fixedSize * count) / (count + 1);
    
    for (NSInteger i = 0; i < count; i++) {
        UIView *button = buttons[i];
        
        button.backgroundColor = [UIColor greenColor];
        
        button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.height, containerRect.size.height);
        CGRect buttonsbounds = button.bounds;
        CGFloat buttonBoundsheight  = CGRectGetHeight(button.bounds);
        // Added mbecker: Center vertical '- button.frame.size.height / 2'
        CGFloat fabs2 = fabs(CGRectGetHeight(containerRect)-buttonBoundsheight) - 3;
        CGFloat sameOffset = horizontally ? fabs2: fabs(CGRectGetWidth(containerRect)-CGRectGetWidth(button.bounds));
        CGFloat diffOffset = padding + i * (fixedSize + padding);
        CGPoint origin = horizontally ? CGPointMake(diffOffset, sameOffset) : CGPointMake(sameOffset, diffOffset);
        if (horizontally) {
            origin.x += CGRectGetMinX(containerRect);
            origin.y += self.statusBarVisible ? 20.0f : 0.0f;
        } else {
            origin.y += CGRectGetMinY(containerRect);
        }
        button.frame = (CGRect){origin, size};
        NSLog(@"Button X: %f", button.frame.origin.x);
        NSLog(@"Button WIDTH: %f", button.frame.size.width);
    }
}

- (void)buttonTapped:(id)button
{
    if (button == self.cancelTextButton || button == self.cancelIconButton) {
        if (self.cancelButtonTapped)
            self.cancelButtonTapped();
    }
    else if (button == self.doneTextButton || button == self.doneIconButton) {
        if (self.doneButtonTapped)
            self.doneButtonTapped();
    }
    else if (button == self.resetButton && self.resetButtonTapped) {
        self.resetButtonTapped();
    }
    else if (button == self.rotateCounterclockwiseButton && self.rotateCounterclockwiseButtonTapped) {
        self.rotateCounterclockwiseButtonTapped();
    }
    else if (button == self.rotateClockwiseButton && self.rotateClockwiseButtonTapped) {
        self.rotateClockwiseButtonTapped();
    }
    else if (button == self.clampButton && self.clampButtonTapped) {
        self.clampButtonTapped();
        return;
    }
}

- (CGRect)clampButtonFrame
{
    return self.clampButton.frame;
}

- (void)setClampButtonHidden:(BOOL)clampButtonHidden {
    if (_clampButtonHidden == clampButtonHidden)
        return;
    
    _clampButtonHidden = clampButtonHidden;
    [self setNeedsLayout];
}

- (void)setClampButtonGlowing:(BOOL)clampButtonGlowing
{
    if (_clampButtonGlowing == clampButtonGlowing)
        return;
    
    _clampButtonGlowing = clampButtonGlowing;
    
    if (_clampButtonGlowing)
        self.clampButton.tintColor = nil;
    else
        self.clampButton.tintColor = [UIColor whiteColor];
}

- (void)setRotateCounterClockwiseButtonHidden:(BOOL)rotateButtonHidden
{
    if (_rotateCounterclockwiseButtonHidden == rotateButtonHidden)
        return;
    
    _rotateCounterclockwiseButtonHidden = rotateButtonHidden;
    [self setNeedsLayout];
}

- (BOOL)resetButtonEnabled
{
    return self.resetButton.enabled;
}

- (void)setResetButtonEnabled:(BOOL)resetButtonEnabled
{
    self.resetButton.enabled = resetButtonEnabled;
}

- (CGRect)doneButtonFrame
{
    if (self.doneIconButton.hidden == NO)
        return self.doneIconButton.frame;
    
    return self.doneTextButton.frame;
}

#pragma mark - Image Generation -
+ (UIImage *)doneImage
{
    UIImage *doneImage = nil;
    
    UIGraphicsBeginImageContextWithOptions((CGSize){17,14}, NO, 0.0f);
    {
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = UIBezierPath.bezierPath;
        [rectanglePath moveToPoint: CGPointMake(1, 7)];
        [rectanglePath addLineToPoint: CGPointMake(6, 12)];
        [rectanglePath addLineToPoint: CGPointMake(16, 1)];
        [UIColor.whiteColor setStroke];
        rectanglePath.lineWidth = 2;
        [rectanglePath stroke];
        
        
        doneImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return doneImage;
}

+ (UIImage *)cancelImage
{
    UIImage *cancelImage = nil;
    
    UIGraphicsBeginImageContextWithOptions((CGSize){16,16}, NO, 0.0f);
    {
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(15, 15)];
        [bezierPath addLineToPoint: CGPointMake(1, 1)];
        [UIColor.whiteColor setStroke];
        bezierPath.lineWidth = 2;
        [bezierPath stroke];
        
        
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
        [bezier2Path moveToPoint: CGPointMake(1, 15)];
        [bezier2Path addLineToPoint: CGPointMake(15, 1)];
        [UIColor.whiteColor setStroke];
        bezier2Path.lineWidth = 2;
        [bezier2Path stroke];
        
        cancelImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return cancelImage;
}

+ (UIImage *)rotateCCWImage
{
    UIImage *rotateImage = nil;
    
    UIGraphicsBeginImageContextWithOptions((CGSize){18,21}, NO, 0.0f);
    {
        //// Rectangle 2 Drawing
        UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 9, 12, 12)];
        [UIColor.whiteColor setFill];
        [rectangle2Path fill];
        
        
        //// Rectangle 3 Drawing
        UIBezierPath* rectangle3Path = UIBezierPath.bezierPath;
        [rectangle3Path moveToPoint: CGPointMake(5, 3)];
        [rectangle3Path addLineToPoint: CGPointMake(10, 6)];
        [rectangle3Path addLineToPoint: CGPointMake(10, 0)];
        [rectangle3Path addLineToPoint: CGPointMake(5, 3)];
        [rectangle3Path closePath];
        [UIColor.whiteColor setFill];
        [rectangle3Path fill];
        
        
        //// Bezier Drawing
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(10, 3)];
        [bezierPath addCurveToPoint: CGPointMake(17.5, 11) controlPoint1: CGPointMake(15, 3) controlPoint2: CGPointMake(17.5, 5.91)];
        [UIColor.whiteColor setStroke];
        bezierPath.lineWidth = 1;
        [bezierPath stroke];
        rotateImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return rotateImage;
}

+ (UIImage *)rotateCWImage
{
    UIImage *rotateCCWImage = [self.class rotateCCWImage];
    UIGraphicsBeginImageContextWithOptions(rotateCCWImage.size, NO, rotateCCWImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, rotateCCWImage.size.width, rotateCCWImage.size.height);
    CGContextRotateCTM(context, M_PI);
    CGContextDrawImage(context,CGRectMake(0,0,rotateCCWImage.size.width,rotateCCWImage.size.height),rotateCCWImage.CGImage);
    UIImage *rotateCWImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return rotateCWImage;
}

+ (UIImage *)resetImage
{
    UIImage *resetImage = nil;
    
    UIGraphicsBeginImageContextWithOptions((CGSize){22,18}, NO, 0.0f);
    {
        
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
        [bezier2Path moveToPoint: CGPointMake(22, 9)];
        [bezier2Path addCurveToPoint: CGPointMake(13, 18) controlPoint1: CGPointMake(22, 13.97) controlPoint2: CGPointMake(17.97, 18)];
        [bezier2Path addCurveToPoint: CGPointMake(13, 16) controlPoint1: CGPointMake(13, 17.35) controlPoint2: CGPointMake(13, 16.68)];
        [bezier2Path addCurveToPoint: CGPointMake(20, 9) controlPoint1: CGPointMake(16.87, 16) controlPoint2: CGPointMake(20, 12.87)];
        [bezier2Path addCurveToPoint: CGPointMake(13, 2) controlPoint1: CGPointMake(20, 5.13) controlPoint2: CGPointMake(16.87, 2)];
        [bezier2Path addCurveToPoint: CGPointMake(6.55, 6.27) controlPoint1: CGPointMake(10.1, 2) controlPoint2: CGPointMake(7.62, 3.76)];
        [bezier2Path addCurveToPoint: CGPointMake(6, 9) controlPoint1: CGPointMake(6.2, 7.11) controlPoint2: CGPointMake(6, 8.03)];
        [bezier2Path addLineToPoint: CGPointMake(4, 9)];
        [bezier2Path addCurveToPoint: CGPointMake(4.65, 5.63) controlPoint1: CGPointMake(4, 7.81) controlPoint2: CGPointMake(4.23, 6.67)];
        [bezier2Path addCurveToPoint: CGPointMake(7.65, 1.76) controlPoint1: CGPointMake(5.28, 4.08) controlPoint2: CGPointMake(6.32, 2.74)];
        [bezier2Path addCurveToPoint: CGPointMake(13, 0) controlPoint1: CGPointMake(9.15, 0.65) controlPoint2: CGPointMake(11, 0)];
        [bezier2Path addCurveToPoint: CGPointMake(22, 9) controlPoint1: CGPointMake(17.97, 0) controlPoint2: CGPointMake(22, 4.03)];
        [bezier2Path closePath];
        [UIColor.whiteColor setFill];
        [bezier2Path fill];
        
        
        //// Polygon Drawing
        UIBezierPath* polygonPath = UIBezierPath.bezierPath;
        [polygonPath moveToPoint: CGPointMake(5, 15)];
        [polygonPath addLineToPoint: CGPointMake(10, 9)];
        [polygonPath addLineToPoint: CGPointMake(0, 9)];
        [polygonPath addLineToPoint: CGPointMake(5, 15)];
        [polygonPath closePath];
        [UIColor.whiteColor setFill];
        [polygonPath fill];


        resetImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    return resetImage;
}

+ (UIImage *)clampImage
{
    UIImage *clampImage = nil;
    
    UIGraphicsBeginImageContextWithOptions((CGSize){22,16}, NO, 0.0f);
    {
        //// Color Declarations
        UIColor* outerBox = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.553];
        UIColor* innerBox = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.773];
        
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 3, 13, 13)];
        [UIColor.whiteColor setFill];
        [rectanglePath fill];
        
        
        //// Outer
        {
            //// Top Drawing
            UIBezierPath* topPath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 22, 2)];
            [outerBox setFill];
            [topPath fill];
            
            
            //// Side Drawing
            UIBezierPath* sidePath = [UIBezierPath bezierPathWithRect: CGRectMake(19, 2, 3, 14)];
            [outerBox setFill];
            [sidePath fill];
        }
        
        
        //// Rectangle 2 Drawing
        UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(14, 3, 4, 13)];
        [innerBox setFill];
        [rectangle2Path fill];
        
        
        clampImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return clampImage;
}

#pragma mark - Accessors -

- (void)setRotateClockwiseButtonHidden:(BOOL)rotateClockwiseButtonHidden
{
    // Deleted
}

- (UIButton *)rotateButton
{
    return self.rotateCounterclockwiseButton;
}

@end
