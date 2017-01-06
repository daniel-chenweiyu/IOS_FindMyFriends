//
//  HistoryRecordTableViewCell.h
//  FindMyFriends
//
//  Created by Daniel on 2017/1/5.
//  Copyright © 2017年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryRecordTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;

@end
