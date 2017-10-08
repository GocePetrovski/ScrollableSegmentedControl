//
//  ObjCTestViewController.m
//  ScrollableSegmentedControlDemo
//
//  Created by Goce Petrovski on 8/10/17.
//  Copyright © 2017 Pomarium. All rights reserved.
//

#import "ObjCTestViewController.h"
@import ScrollableSegmentedControl;

@interface ObjCTestViewController ()

@end

@implementation ObjCTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    ScrollableSegmentedControl *segmentedControl = [[ScrollableSegmentedControl alloc] init];
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.segmentStyle = ScrollableSegmentedControlSegmentStyleTextOnly;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
