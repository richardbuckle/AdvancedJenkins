
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
    
}

@end


@implementation CalcApplicationTests

/* The setUp method is called automatically for each test-case method (methods whose name starts with 'test').
 */
- (void) setUp {
   app_delegate         = [[[UIApplication sharedApplication] delegate] retain];
   calc_view_controller = app_delegate.calcViewController;
   calc_view            = calc_view_controller.view;
}

- (void) tearDown {
    [app_delegate release];
}


- (void) testAppDelegate {
   STAssertNotNil(app_delegate, @"Cannot find the application delegate");
}

- (void) testIsPortraitOnly {
    STAssertTrue([calc_view_controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait], @"Supports portrait");
    STAssertFalse([calc_view_controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft], @"Doesn't support landscape left");
    STAssertFalse([calc_view_controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight], @"Doesn't support landscape right");
    STAssertFalse([calc_view_controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown], @"Doesn't support portrait upside down");
}

/* testAddition performs a chained addition test.
 * The test has two parts:
 * 1. Check: 6 + 2 = 8.
 * 2. Check: display + 2 = 10.
 */
- (void) testAddition {
   [calc_view_controller press:[calc_view viewWithTag: 6]];  // 6
   [calc_view_controller press:[calc_view viewWithTag:13]];  // +
   [calc_view_controller press:[calc_view viewWithTag: 2]];  // 2
   [calc_view_controller press:[calc_view viewWithTag:12]];  // =   
   STAssertTrue([[calc_view_controller.displayField text] isEqualToString:@"8"], @"Part 1 failed.");
   
   [calc_view_controller press:[calc_view viewWithTag:13]];  // +
   [calc_view_controller press:[calc_view viewWithTag: 2]];  // 2
   [calc_view_controller press:[calc_view viewWithTag:12]];  // =      
   STAssertTrue([[calc_view_controller.displayField text] isEqualToString:@"10"], @"Part 2 failed.");
}

/* testSubtraction performs a simple subtraction test.
 * Check: 6 - 2 = 4.
 */
- (void) testSubtraction {
   [calc_view_controller press:[calc_view viewWithTag: 6]];  // 6
   [calc_view_controller press:[calc_view viewWithTag:14]];  // -
   [calc_view_controller press:[calc_view viewWithTag: 2]];  // 2
   [calc_view_controller press:[calc_view viewWithTag:12]];  // =   
   STAssertTrue([[calc_view_controller.displayField text] isEqualToString:@"4"], @"");
}

/* testDivision performs a simple division test.
 * Check: 25 / 4 = 6.25.
 */
- (void) testDivision {
   [calc_view_controller press:[calc_view viewWithTag: 2]];  // 2
   [calc_view_controller press:[calc_view viewWithTag: 5]];  // 5
   [calc_view_controller press:[calc_view viewWithTag:16]];  // /
   [calc_view_controller press:[calc_view viewWithTag: 4]];  // 4
   [calc_view_controller press:[calc_view viewWithTag:12]];  // =   
   STAssertTrue([[calc_view_controller.displayField text] isEqualToString:@"6.25"], @"");
}

/* testMultiplication performs a simple multiplication test.
 * Check: 19 x 8 = 152.
 */
- (void) testMultiplication {
   [calc_view_controller press:[calc_view viewWithTag: 1]];  // 1
   [calc_view_controller press:[calc_view viewWithTag: 9]];  // 9
   [calc_view_controller press:[calc_view viewWithTag:15]];  // *
   [calc_view_controller press:[calc_view viewWithTag: 8]];  // 8
   [calc_view_controller press:[calc_view viewWithTag:12]];  // =
   STAssertTrue([[calc_view_controller.displayField text] isEqualToString:@"152"], @"");
}

/* testDelete tests the functionality of the D (Delete) key.
 * 1. Enter the number 1987 into the calculator.
 * 2. Delete each digit, and test the display to ensure
 *    the correct display contains the expected value after each D press.
 */
- (void) testDelete {
   [calc_view_controller press:[calc_view viewWithTag: 1]];  // 1
   [calc_view_controller press:[calc_view viewWithTag: 9]];  // 9
   [calc_view_controller press:[calc_view viewWithTag: 8]];  // 8
   [calc_view_controller press:[calc_view viewWithTag: 7]];  // 7
   STAssertTrue([[calc_view_controller.displayField text] isEqualToString:@"1987"], @"Part 1 failed.");
   
   [calc_view_controller press:[calc_view viewWithTag:19]];  // D (delete)
   STAssertTrue([[calc_view_controller.displayField text] isEqualToString:@"198"],  @"Part 2 failed.");      
   
   [calc_view_controller press:[calc_view viewWithTag:19]];  // D (delete)
   STAssertTrue([[calc_view_controller.displayField text] isEqualToString:@"19"],   @"Part 3 failed.");      
   
   [calc_view_controller press:[calc_view viewWithTag:19]];  // D (delete)
   STAssertTrue([[calc_view_controller.displayField text] isEqualToString:@"1"],    @"Part 4 failed.");      
   
   [calc_view_controller press:[calc_view viewWithTag:19]];  // D (delete)
   STAssertTrue([[calc_view_controller.displayField text] isEqualToString:@"0"],    @"Part 5 failed.");
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
   [calc_view_controller press:[calc_view viewWithTag: 2]];  // 2
   [calc_view_controller press:[calc_view viewWithTag: 5]];  // 5
   [calc_view_controller press:[calc_view viewWithTag:16]];  // /
   [calc_view_controller press:[calc_view viewWithTag: 4]];  // 4
   [calc_view_controller press:[calc_view viewWithTag:11]];  // C (clear)
   STAssertTrue([[calc_view_controller.displayField text] isEqualToString:@"0"], @"Part 1 failed.");
   
   [calc_view_controller press:[calc_view viewWithTag: 5]];  // 5
   [calc_view_controller press:[calc_view viewWithTag:12]];  // =
   STAssertTrue([[calc_view_controller.displayField text] isEqualToString:@"5"], @"Part 2 failed.");
   
   [calc_view_controller press:[calc_view viewWithTag: 1]];  // 1
   [calc_view_controller press:[calc_view viewWithTag: 9]];  // 9
   [calc_view_controller press:[calc_view viewWithTag:15]];  // x
   [calc_view_controller press:[calc_view viewWithTag: 8]];  // 8
   [calc_view_controller press:[calc_view viewWithTag:11]];  // C (clear)
   [calc_view_controller press:[calc_view viewWithTag:11]];  // C (all clear)
   [calc_view_controller press:[calc_view viewWithTag:13]];  // +
   [calc_view_controller press:[calc_view viewWithTag: 2]];  // 2
   [calc_view_controller press:[calc_view viewWithTag:12]];  // =   
   STAssertTrue([[calc_view_controller.displayField text] isEqualToString:@"2"], @"Part 3 failed.");
}

- (void) testInitialClear {
    [calc_view_controller press:[calc_view viewWithTag:11]];  // C (clear)
    STAssertTrue([[calc_view_controller.displayField text] isEqualToString:@"0"], @"Initial clear should give 0.");
}

- (void) testNilInputThrows {
    STAssertThrows([calc_view_controller press:nil], @"Press of a nil view should throw.");
}

- (void) testPressingInvalidTagThrows {
    STAssertThrows([calc_view_controller press:[calc_view viewWithTag:-1]], @"Press of a non-existent view tag should throw.");
}

- (void) testNoViewsGiveInvalidInput {
    for (UIView *subview in calc_view_controller.view.subviews) {
        STAssertNoThrow([calc_view_controller press:subview], @"Unexpected exception from pressing subview %@", [subview description]);
    }
}

@end
