
#import <SenTestingKit/SenTestingKit.h>

#import <UIKit/UIKit.h>

// Test-subject headers.
#import "iOS_CalcAppDelegate.h"
#import "iOS_CalcViewController.h"


@interface CalcApplicationTests : SenTestCase {
@private
    CalcAppDelegate    *app_delegate;
    CalcViewController *calc_view_controller;
    UIView             *calc_view;
    NSDictionary       *keystrokesToViewTags;
}

@end


@implementation CalcApplicationTests

- (void) setUp {
    app_delegate         = [[UIApplication sharedApplication] delegate];
    calc_view_controller = app_delegate.calcViewController;
    calc_view            = calc_view_controller.view;
    keystrokesToViewTags = @{
                             // digits
                             @"1": @1,
                             @"2": @2,
                             @"3": @3,
                             @"4": @4,
                             @"5": @5,
                             @"6": @6,
                             @"7": @7,
                             @"8": @8,
                             @"9": @9,
                             @"0": @10,
                             
                             // operators
                             @"+": @13,
                             @"-": @14,
                             @"*": @15,
                             @"/": @16,
                             
                             // commands
                             @"C": @11,
                             @"=": @12,
                             @"D": @19,
                             
                             // decimal point
                             @".": @30,
                             };
}

- (void) tearDown {
};

- (UIView *) viewForKeystroke:(NSString *)keyStroke {
    NSInteger tag = [keystrokesToViewTags[keyStroke] intValue];
    return [calc_view viewWithTag:tag];
}

- (void) pressViewForKeystroke:(NSString *)keyStroke {
    UIView * view = [self viewForKeystroke:keyStroke];
    [calc_view_controller press:view];
}

- (void) expectDisplayFieldToBe:(NSString *)expected {
    NSString *actual = [calc_view_controller.displayField text];
    STAssertTrue([actual isEqualToString:expected], @"Expected displayField to be %@, got %@.", expected, actual);
}

- (void) expectTitle:(NSString *)expectedTitle forView:(UIView *)view {
    STAssertTrue([view respondsToSelector:@selector(titleForState:)], @"View %@ doesn't respond to titleForState:", [view description]);
    NSString *actualTitle = [(id)view titleForState:UIControlStateNormal];
    STAssertTrue([actualTitle isEqualToString:expectedTitle], @"Expected title %@ for view with tag %i, got %@", expectedTitle, [view tag], actualTitle);
}

- (void) testAppDelegate {
   STAssertNotNil(app_delegate, @"Cannot find the application delegate");
}

- (void) testIsPortraitOnly {
    STAssertTrue([calc_view_controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait], @"Should support portrait");
    STAssertFalse([calc_view_controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft], @"Should not support landscape left");
    STAssertFalse([calc_view_controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight], @"Should not support landscape right");
    STAssertFalse([calc_view_controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown], @"Should not support portrait upside down");
}

/* testAddition performs a chained addition test.
 * The test has two parts:
 * 1. Check: 6 + 2 = 8.
 * 2. Check: display + 2 = 10.
 */
- (void) testAddition {
    [self pressViewForKeystroke:@"6"];
    [self pressViewForKeystroke:@"+"];
    [self pressViewForKeystroke:@"2"];
    [self pressViewForKeystroke:@"="];
    [self expectDisplayFieldToBe:@"8"];

    [self pressViewForKeystroke:@"+"];
    [self pressViewForKeystroke:@"2"];
    [self pressViewForKeystroke:@"="];
    [self expectDisplayFieldToBe:@"10"];
}

/* testSubtraction performs a simple subtraction test.
 * Check: 6 - 2 = 4.
 */
- (void) testSubtraction {
    [self pressViewForKeystroke:@"6"];
    [self pressViewForKeystroke:@"-"];
    [self pressViewForKeystroke:@"2"];
    [self pressViewForKeystroke:@"="];
    [self expectDisplayFieldToBe:@"4"];
}

/* testDivision performs a simple division test.
 * Check: 25 / 4 = 6.25.
 */
- (void) testDivision {
    [self pressViewForKeystroke:@"2"];
    [self pressViewForKeystroke:@"5"];
    [self pressViewForKeystroke:@"/"];
    [self pressViewForKeystroke:@"4"];
    [self pressViewForKeystroke:@"="];
    [self expectDisplayFieldToBe:@"6.25"];
}

/* testMultiplication performs a simple multiplication test.
 * Check: 19 x 8 = 152.
 */
- (void) testMultiplication {
    [self pressViewForKeystroke:@"1"];
    [self pressViewForKeystroke:@"9"];
    [self pressViewForKeystroke:@"*"];
    [self pressViewForKeystroke:@"8"];
    [self pressViewForKeystroke:@"="];
    [self expectDisplayFieldToBe:@"152"];
}

/* testDelete tests the functionality of the D (Delete) key.
 * 1. Enter the number 1987 into the calculator.
 * 2. Delete each digit, and test the display to ensure
 *    the correct display contains the expected value after each D press.
 */
- (void) testDelete {
    [self pressViewForKeystroke:@"1"];
    [self pressViewForKeystroke:@"9"];
    [self pressViewForKeystroke:@"8"];
    [self pressViewForKeystroke:@"7"];
    [self expectDisplayFieldToBe:@"1987"];
    
    [self pressViewForKeystroke:@"D"];
    [self expectDisplayFieldToBe:@"198"];
    
    [self pressViewForKeystroke:@"D"];
    [self expectDisplayFieldToBe:@"19"];
    
    [self pressViewForKeystroke:@"D"];
    [self expectDisplayFieldToBe:@"1"];
    
    [self pressViewForKeystroke:@"D"];
    [self expectDisplayFieldToBe:@"0"];
    
    [self pressViewForKeystroke:@"D"];
    [self expectDisplayFieldToBe:@"0"];
}

/* testClear tests the functionality of the C (Clear).
 * 1. Clear the display.
 *  - Enter the calculation 25 / 4.
 *  - Press C.
 *  - Ensure the display contains the value 0.
 * 2. Perform corrected computation.
 *  - Press 5, =.
 *  - Ensure the display contains the value 5.
 * 3. Ensure pressign C twice clears all.
 *  - Enter the calculation 19 x 8.
 *  - Press C (clears the display).
 *  - Press C (clears the operand).
 *  - Press +, 2, =.
 *  - Ensure the display contains the value 2.
 */
- (void) testClear {
    [self pressViewForKeystroke:@"2"];
    [self pressViewForKeystroke:@"5"];
    [self pressViewForKeystroke:@"/"];
    [self pressViewForKeystroke:@"4"];
    [self pressViewForKeystroke:@"C"];
    [self expectDisplayFieldToBe:@"0"];
    
    [self pressViewForKeystroke:@"5"];
    [self pressViewForKeystroke:@"="];
    [self expectDisplayFieldToBe:@"5"];
    
    [self pressViewForKeystroke:@"1"];
    [self pressViewForKeystroke:@"9"];
    [self pressViewForKeystroke:@"*"];
    [self pressViewForKeystroke:@"8"];
    [self pressViewForKeystroke:@"C"];
    [self pressViewForKeystroke:@"C"];
    [self pressViewForKeystroke:@"+"];
    [self pressViewForKeystroke:@"2"];
    [self pressViewForKeystroke:@"="];
    [self expectDisplayFieldToBe:@"2"];
}

- (void) testInitialClear {
    [self pressViewForKeystroke:@"C"];
    [self expectDisplayFieldToBe:@"0"];
}

- (void) testNilInputThrows {
    STAssertThrows([calc_view_controller press:nil], @"Press of a nil view should throw.");
}

- (void) testPressingInvalidTagThrows {
    STAssertThrows([calc_view_controller press:[calc_view viewWithTag:-1]], @"Press of a non-existent view tag should throw.");
}

- (void) testNoViewsGiveInvalidInput {
    for (UIView *subview in calc_view.subviews) {
        STAssertNoThrow([calc_view_controller press:subview], @"Unexpected exception from pressing subview %@", [subview description]);
    }
}

- (void) testSubviewTags {
    for (NSString *keystroke in keystrokesToViewTags) {
        UIView *subview = [self viewForKeystroke:keystroke];
        [self expectTitle:keystroke forView:subview];
    }
}

@end
