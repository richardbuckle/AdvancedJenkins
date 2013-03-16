/*
     File: CalculatorLogicTests.m
 Abstract: This file implements the logic-test suite for the Calculator class.
  Version: 2.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import <SenTestingKit/SenTestingKit.h>

#import "Calculator.h"


@interface CalculatorLogicTests : SenTestCase {
@private
   Calculator *calculator;
}

@end

@implementation CalculatorLogicTests

/* The setUp method is called automatically before each test-case method (methods whose name starts with 'test').
 */
- (void) setUp {
   calculator = [[Calculator alloc] init];
   STAssertNotNil(calculator, @"Cannot create Calculator instance");
}


/* The tearDown method is called automatically after each test-case method (methods whose name starts with 'test').
 */
- (void) tearDown {
   [calculator release];
}

- (void)testNoInput {
    STAssertTrue([[calculator displayValue] isEqualToString:@"0"], @"No input should produce 0, got [%@]", [calculator displayValue]);
}

- (void)testDeleteNonexistentChar {
    [calculator input:@"D"];
    STAssertTrue([[calculator displayValue] isEqualToString:@"0"], @"Initial delete of nonexistent char should produce 0, got [%@]", [calculator displayValue]);
}

- (void)testInputAndDeleteOneChar {
    [calculator input:@"6"];
    [calculator input:@"D"];
    STAssertTrue([[calculator displayValue] isEqualToString:@"0"], @"Input and delete of one char should produce 0, got [%@]", [calculator displayValue]);
}

- (void)testInputTwoCharsAndDeleteOneChar {
    [calculator input:@"6"];
    [calculator input:@"7"];
    [calculator input:@"D"];
    STAssertTrue([[calculator displayValue] isEqualToString:@"6"], @"Input 67 then delete should produce 6, got [%@]", [calculator displayValue]);
}

- (void)testDecimalInput {
    [calculator input:@"6"];
    [calculator input:@"."];
    [calculator input:@"7"];
    STAssertTrue([[calculator displayValue] isEqualToString:@"6.7"], @"Input 6.7 should produce 6.7, got [%@]", [calculator displayValue]);
}

- (void)testDecimalInputWithTwoPoints {
    [calculator input:@"6"];
    [calculator input:@"."];
    [calculator input:@"."];
    [calculator input:@"7"];
    STAssertTrue([[calculator displayValue] isEqualToString:@"6.7"], @"Input 6..7 should produce 6.7, got [%@]", [calculator displayValue]);
}

/* testAddition performs a simple addition test: 6 + 2 = 8.
 * The test has two parts:
 * 1. Through the input: method, feed the calculator the characters 6, +, 2, and =.
 * 2. Confirm that displayValue is 8.
 */
- (void) testAddition {
   [calculator input:@"6"];
   [calculator input:@"+"];
   [calculator input:@"2"];
   [calculator input:@"="];
   STAssertTrue([[calculator displayValue] isEqualToString:@"8"], @"'6+2=' should give 8, got %@", [calculator displayValue]);
}

/* testSubtraction performs a simple subtraction test: 19 - 2 = 17.
 * The test has two parts:
 * 1. Through the input: method, feed the calculator the characters 1, 9, -, 2, and =.
 * 2. Confirm that displayValue is 17.
 */
- (void) testSubtraction {
   [calculator input:@"1"];
   [calculator input:@"9"];
   [calculator input:@"-"];
   [calculator input:@"2"];
   [calculator input:@"="];
   STAssertTrue([[calculator displayValue] isEqualToString:@"17"], @"'19-2=' should give 17, got %@", [calculator displayValue]);
}

/* testDivision performs a simple division test: 19 / 8 = 2.375.
 * The test has two parts:
 * 1. Through the input: method, feed the calculator the characters 1, 9, /, 8, and =.
 * 2. Confirm that displayValue is 2.375.
 */
- (void) testDivision {
   [calculator input:@"1"];
   [calculator input:@"9"];
   [calculator input:@"/"];
   [calculator input:@"8"];
   [calculator input:@"="];
   STAssertTrue([[calculator displayValue] isEqualToString:@"2.375"], @"'19/8=' should give 2.375, got %@", [calculator displayValue]);
}

/* testMultiplication performs a simple multiplication test: 6 * 2 = 12.
 * The test has two parts:
 * 1. Through the input: method, feed the calculator the characters 6, *, 2, and =.
 * 2. Confirm that displayValue is 12.
 */
- (void) testMultiplication {
   [calculator input:@"6"];
   [calculator input:@"*"];
   [calculator input:@"2"];
   [calculator input:@"="];
   STAssertTrue([[calculator displayValue] isEqualToString:@"12"], @"'6*2=' should give 12, got %@", [calculator displayValue]);
}

/* testSubtractionNegativeResult performs a simple subtraction test with a negative result: 6 - 24 = -18.
 * The test has two parts:
 * 1. Through the input: method, feed the calculator the characters 6, -, 2, 4, and =.
 * 2. Confirm that displayValue is -18.
 */
- (void) testSubtractionNegativeResult {
   [calculator input:@"6"];
   [calculator input:@"-"];
   [calculator input:@"2"];
   [calculator input:@"4"];
   [calculator input:@"="];
   STAssertTrue([[calculator displayValue] isEqualToString:@"-18"], @"'6-24=' should give -18, got %@", [calculator displayValue]);
}

/* testClearLastEntry ensures that the clear (C) key clears the last entry when used once.
 */
- (void) testClearLastEntry {
   [calculator input:@"7"];
   [calculator input:@"+"];
   [calculator input:@"3"];
   [calculator input:@"C"];
   [calculator input:@"4"];
   [calculator input:@"="];   
   STAssertTrue([[calculator displayValue] isEqualToString:@"11"], @"'7+3C4= should give 11, got %@", [calculator displayValue]);
}

/* testClearComputation ensures that the clear (C) key clears the computation when used twice.
 */
- (void) testClearComputation {
   [calculator input:@"C"];
   [calculator input:@"7"];
   [calculator input:@"*"];
   [calculator input:@"3"];
   [calculator input:@"C"];
   [calculator input:@"C"];
   STAssertTrue([[calculator displayValue] isEqualToString:@"0"], @"CC at the end of a computation should clear it, got %@", [calculator displayValue]);   
}

- (void) testExplicitChainedComputation {
    [calculator input:@"C"];
    [calculator input:@"2"];
    [calculator input:@"+"];
    [calculator input:@"3"];
    [calculator input:@"="];
    [calculator input:@"*"];
    [calculator input:@"5"];
    [calculator input:@"="];
    STAssertTrue([[calculator displayValue] isEqualToString:@"25"], @"'2*3=*5' should be 25, got %@", [calculator displayValue]);
}

- (void) testChainedComputation {
    [calculator input:@"C"];
    [calculator input:@"2"];
    [calculator input:@"+"];
    [calculator input:@"3"];
    [calculator input:@"*"];
    [calculator input:@"5"];
    [calculator input:@"="];
    STAssertTrue([[calculator displayValue] isEqualToString:@"25"], @"'2+3*5' should be 25, got %@", [calculator displayValue]);
}

- (void) testOperatorChange {
    // wierd, the first plus adds 5 to itself, assuming per spec
    [calculator input:@"C"];
    [calculator input:@"5"];
    [calculator input:@"+"];
    [calculator input:@"-"];
    [calculator input:@"3"];
    [calculator input:@"="];
    STAssertTrue([[calculator displayValue] isEqualToString:@"7"], @"'5+-3' should be 7, got %@", [calculator displayValue]);
}

- (void) testDoublePunchEquals {
    [calculator input:@"C"];
    [calculator input:@"5"];
    [calculator input:@"="];
    [calculator input:@"="];
    STAssertTrue([[calculator displayValue] isEqualToString:@"5"], @"'5==' should be 5, got %@", [calculator displayValue]);
}

- (void) testInputExceptionMultiChar {
    STAssertThrows([calculator input:@"67"], @"Multicharacter input should raise an exception.");
}

- (void) testInputExceptionInvalidCar {
    STAssertThrows([calculator input:@"j"], @"Invalid input should raise an exception.");
}

- (void) testInputExceptionNilInput {
    STAssertThrows([calculator input:nil],   @"Nil input should raise an exception.");
}

@end
