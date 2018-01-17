//
//  ViewController.m
//  ExampleObjC
//
//  Created by Krzysztof Zablocki on 17/01/2018.
//  Copyright © 2018 Pixle. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, retain) NSMutableArray* leakStorage;
@end

@implementation ViewController
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.leakStorage = [NSMutableArray new];
    }

    [self trackLifetime];
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leakStorage = [NSMutableArray new];
    }
    [self trackLifetime];
    return self;
}

+ (LifetimeConfiguration *)lifetimeConfiguration {
    return [[LifetimeConfiguration alloc] initWithMaxCount:1 groupName:@"VC"];
}

- (IBAction)createLeaks:(id)sender {
    [self.leakStorage addObject:[ViewController new]];
    [self.leakStorage addObject:[ViewController new]];
}

- (IBAction)removeLeaks:(id)sender {
    [self.leakStorage removeAllObjects];
}

@end
