//
//  ViewController.m
//  TinyUSDTester
//
//  Created by Aaron Hilton on 2019-11-05.
//  Copyright © 2019 Steampunk Digital, Co. Ltd. All rights reserved.
//

#import "ViewController.h"

#import "SceneProxy.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)testHit:(id)sender {
    // NOTE: [wip]  Need to figure out how to initialize the static linked plugins.
    
    SceneProxy scene;

    // == Test writing a Scene ==
    // Documents Path
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, NO).firstObject;
    
    NSString *testFilePath = [docPath stringByAppendingPathComponent:@"test.usda"];
    
    NSLog(@"Writing to documents: %@\nTest File Path: %@", docPath, testFilePath);
    
    scene.create_new_stage(testFilePath.UTF8String);
    scene.save_stage();
    
    SceneProxy scene2;
    scene2.load_stage(testFilePath.UTF8String);
}

@end
