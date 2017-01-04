//
//  EditViewController.m
//  FindMyFriends
//
//  Created by Daniel on 2016/12/26.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "EditViewController.h"



@interface EditViewController (){
    NSUserDefaults * userDefaults;
    NSMutableArray * thisAppEdit;
}
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *updateSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *downloadSwitch;
@property (weak, nonatomic) IBOutlet UILabel *secLabel;
@property (weak, nonatomic) IBOutlet UISwitch *showFriendsLocationSwitch;
@property (weak, nonatomic) IBOutlet UISlider *frequencySetSlider;

@end

@implementation EditViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self thisAppEditSetting];
}
- (void) thisAppEditSetting {
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    thisAppEdit = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"findMyFriendsEdit"]];
    self.userNameTextField.text = thisAppEdit[0];
    [self.updateSwitch setOn: [thisAppEdit[1] boolValue]];
    [self.downloadSwitch setOn:[thisAppEdit[2] boolValue]];
    self.secLabel.text = thisAppEdit[3];
    self.frequencySetSlider.value = [thisAppEdit[3] floatValue];
    [self.showFriendsLocationSwitch setOn:[thisAppEdit[4] boolValue]];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backBtn:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)saveEditBtn:(UIBarButtonItem *)sender {
    
    thisAppEdit[0] = [NSString stringWithFormat:@"%@",self.userNameTextField.text];
    thisAppEdit[1] = [NSString stringWithFormat:@"%d",self.updateSwitch.on];
    thisAppEdit[2] = [NSString stringWithFormat:@"%d",self.downloadSwitch.on];
    thisAppEdit[3] = self.secLabel.text;
    thisAppEdit[4] = [NSString stringWithFormat:@"%d",self.showFriendsLocationSwitch.on];
    [userDefaults setObject:thisAppEdit forKey:@"findMyFriendsEdit"];
    [userDefaults synchronize];
    [self showOrHideAnnotationWithMapView:nil];
    // set alert to show save success
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"訊息" message:@"儲存成功" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:true completion:nil];
}
- (void)showOrHideAnnotationWithMapView:(MKMapView*)mainMapView {
    // check for other controller use thie method
    if (thisAppEdit[4] == nil) {
        [self thisAppEditSetting];
        self.mainMapView = mainMapView;
    }
    for (id annotation in self.mainMapView.annotations) {
        if (annotation != self.mainMapView.userLocation) {
        if ([thisAppEdit[4]  isEqual: @"1"]) {
            [[self.mainMapView viewForAnnotation:annotation] setHidden:NO];
        } else {
            [[self.mainMapView viewForAnnotation:annotation] setHidden:YES];
        }
    }
    }
}
- (IBAction)frequencyChange:(UISlider *)sender {
    
    self.secLabel.text = [NSString  stringWithFormat:@"%0.0f",self.frequencySetSlider.value];
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
