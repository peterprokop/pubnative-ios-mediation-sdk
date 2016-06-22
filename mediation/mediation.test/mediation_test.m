//
//  mediation_test.m
//  mediation.test
//
//  Created by David Martin on 22/06/2016.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "mediation.h"

@interface mediation_test : XCTestCase

@end

@implementation mediation_test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    assertThatBool(3==3, isTrue());
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
//    mediation *myMediation = mock([mediation class]);
//    assertThat(myMediation, instanceOf([mediation class]));
//    assertThat(myMediation).
}

@end
