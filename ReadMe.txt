iPhoneUnitTests illustrates the use of unit tests to ensure that an application’s functionality does not degrade as its source code undergoes changes to improve the application or to fix bugs. The project showcases two types of unit tests: logic and application. Logic unit tests allow for stress-testing source code. Application unit tests help ensure the correct linkage between user-interface controls, controller objects, and model objects.

Minimum Buildtime Requirements:
- iOS SDK 4.3

Minimum Runtime Requirements:
- Simulator: iPhone/iPad 4.1 simulator
- Device:    iOS 4.1

The iPhoneUnitTests project defines two schemes:
- iOS_Calc.       Runs the Calc application, and performs application unit tests on it.
- Calculator-iOS. Performs logic unit tests on the Calculator class.

The project contains four targets:
- iOS_Calc.                  Builds the Calc application.
- iOS_Calc_ApplicationTests. Implements the application unit-test suite for the Calc application. 
- Calculator-iOS.            Builds the Calculator-iOS static library.
- Calculator-iOS_LogicTests. Implements the logic unit-test suite for the Calculator class.

--------------------------------------------------------------------------------------
iOS_Calc Target
- This target builds an iPhone application (Calc) that implements a simple 
arithmetic calculator.

iOS_Calc_ApplicationTests Target
- This target builds a unit-test bundle containing an application unit-test
suite (CalcApplicationTests) for the Calc application.

Calculator-iOS Target
- This target builds the static library that the Calc application uses to process its input and generate output to display to the user.
- The calculating engine is implemented in the Calculator class,
which has two main methods: input: and displayValue:
- The input: method accepts a one-character string as input, which represents a key press.
- The displayValue method provides the value representing the calculator’s output: As each key is pressed, the display value changes, as it would on a hardware-based calculator.

Calculator-iOS_LogicTests Target
- This target builds a unit-test bundle containing logic tests for the Calculator class.

--------------------------------------------------------------------------------------
Running Logic Tests on Calculator-iOS
- To run the logic tests:
  1. From the scheme toolbar menu, choose Calculator-iOS > iPhone 4.3 Simulator.
  2. Choose Product > Test. Xcode runs the test cases implemented in the CalculatorLogicTests.m file.
  3. Choose View > Navigators > Log to open the log navigator, containing the tests results.
  4. In the list on the left, select the Test Calculator-iOS_LogicTests session to view the test session log. 

The results of the tests look similar to this:

GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)
Copyright 2004 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
...
Test Suite 'CalculatorLogicTests' started at 2011-08-05 00:46:04 +0000
Test Case '-[CalculatorLogicTests testAddition]' started.
2011-08-04 17:46:04.333 otest[3858:903] -[CalculatorLogicTests testAddition] setUp
2011-08-04 17:46:04.334 otest[3858:903] -[CalculatorLogicTests testAddition] start
2011-08-04 17:46:04.337 otest[3858:903] -[CalculatorLogicTests testAddition] end
2011-08-04 17:46:04.338 otest[3858:903] -[CalculatorLogicTests testAddition] tearDown
Test Case '-[CalculatorLogicTests testAddition]' passed (0.005 seconds).
Test Case '-[CalculatorLogicTests testClearComputation]' started.
2011-08-04 17:46:04.338 otest[3858:903] -[CalculatorLogicTests testClearComputation] setUp
2011-08-04 17:46:04.339 otest[3858:903] -[CalculatorLogicTests testClearComputation] start
2011-08-04 17:46:04.340 otest[3858:903] -[CalculatorLogicTests testClearComputation] end
2011-08-04 17:46:04.340 otest[3858:903] -[CalculatorLogicTests testClearComputation] tearDown
Test Case '-[CalculatorLogicTests testClearComputation]' passed (0.002 seconds).
Test Case '-[CalculatorLogicTests testClearLastEntry]' started.
2011-08-04 17:46:04.341 otest[3858:903] -[CalculatorLogicTests testClearLastEntry] setUp
2011-08-04 17:46:04.341 otest[3858:903] -[CalculatorLogicTests testClearLastEntry] start
2011-08-04 17:46:04.342 otest[3858:903] -[CalculatorLogicTests testClearLastEntry] end
2011-08-04 17:46:04.342 otest[3858:903] -[CalculatorLogicTests testClearLastEntry] tearDown
Test Case '-[CalculatorLogicTests testClearLastEntry]' passed (0.002 seconds).
...
Test Suite 'CalculatorLogicTests' finished at 2011-08-05 00:46:04 +0000.
Executed 8 tests, with 0 failures (0 unexpected) in 0.033 (0.036) seconds
...
Executed 8 tests, with 0 failures (0 unexpected) in 0.033 (0.063) seconds

--------------------------------------------------------------------------------------
Running Application Tests
- To run the application tests:
  1. From the scheme toolbar menu, choose iOS_Calc > <your_device>.
  2. Choose Product > Test. Xcode runs the test cases implemented in the iOS_CalcApplicationTests.m file.
  3. Choose View > Navigators > Log to open the log navigator.
  4. In the list on the left, select the Test iOS_Calc_ApplicationTests session to view the test session log.

- The results of the tests look similar to this:

GNU gdb 6.3.50-20050815 (Apple version gdb-1705) (Fri Jul  1 10:47:25 UTC 2011)
Copyright 2004 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
...
Test Suite 'All tests' started at 2011-08-05 02:02:50 +0000
Test Suite '/Developer/Library/Frameworks/SenTestingKit.framework(Tests)' started at 2011-08-05 02:02:50 +0000
Test Suite 'SenInterfaceTestCase' started at 2011-08-05 02:02:50 +0000
Test Suite 'SenInterfaceTestCase' finished at 2011-08-05 02:02:50 +0000.
Executed 0 tests, with 0 failures (0 unexpected) in 0.000 (0.002) seconds

Test Suite '/Developer/Library/Frameworks/SenTestingKit.framework(Tests)' finished at 2011-08-05 02:02:50 +0000.
Executed 0 tests, with 0 failures (0 unexpected) in 0.000 (0.009) seconds

Test Suite '/var/mobile/Applications/C3898898-E45A-437E-B41C-122A91075031/iOS_Calc_ApplicationTests.octest(Tests)' started at 2011-08-05 02:02:50 +0000
Test Suite 'CalcApplicationTests' started at 2011-08-05 02:02:50 +0000
Test Case '-[CalcApplicationTests testAddition]' started.
Test Case '-[CalcApplicationTests testAddition]' passed (0.007 seconds).
Test Case '-[CalcApplicationTests testAppDelegate]' started.
Test Case '-[CalcApplicationTests testAppDelegate]' passed (0.001 seconds).
Test Case '-[CalcApplicationTests testClear]' started.
Test Case '-[CalcApplicationTests testClear]' passed (0.004 seconds).
Test Case '-[CalcApplicationTests testDelete]' started.
Test Case '-[CalcApplicationTests testDelete]' passed (0.002 seconds).
Test Case '-[CalcApplicationTests testDivision]' started.
Test Case '-[CalcApplicationTests testDivision]' passed (0.003 seconds).
Test Case '-[CalcApplicationTests testMultiplication]' started.
Test Case '-[CalcApplicationTests testMultiplication]' passed (0.002 seconds).
Test Case '-[CalcApplicationTests testSubtraction]' started.
Test Case '-[CalcApplicationTests testSubtraction]' passed (0.002 seconds).
Test Suite 'CalcApplicationTests' finished at 2011-08-05 02:02:50 +0000.
Executed 7 tests, with 0 failures (0 unexpected) in 0.020 (0.031) seconds

Test Suite '/var/mobile/Applications/C3898898-E45A-437E-B41C-122A91075031/iOS_Calc_ApplicationTests.octest(Tests)' finished at 2011-08-05 02:02:50 +0000.
Executed 7 tests, with 0 failures (0 unexpected) in 0.020 (0.037) seconds

Test Suite 'All tests' finished at 2011-08-05 02:02:50 +0000.
Executed 7 tests, with 0 failures (0 unexpected) in 0.020 (0.061) seconds

--------------------------------------------------------------------------------------
Related Information
- For more information, see the “Unit Testing Applications” chapter in the iOS Development Workflow Guide.

Version 2.0
- Updated for Xcode 4.0.2 and iOS SDK 4.3. 

Version 1.2
- Fixed bugs. Added workaround for running unit tests against the iPhone Simulator in Xcode 3.2.4 with iOS SDK 4.1.

Version 1.1
- Upgraded project to build with the iOS 4 SDK.

Version 1.0
- First Version

Copyright © 2011 Apple Inc. All rights reserved.
