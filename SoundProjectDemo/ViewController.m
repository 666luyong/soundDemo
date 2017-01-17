//
//  ViewController.m
//  SoundProjectDemo
//
//  Created by mediawork on 2017/1/16.
//  Copyright © 2017年 BEN. All rights reserved.
//

#import "ViewController.h"
#import "PureToneEngine.h"
#define kFrequency_Ratio 1.05946
#define MIDDLE_C 261.63
@interface ViewController ()

@property (nonatomic, strong)PureToneEngine *engine;

@property (weak, nonatomic) IBOutlet UIButton *refBtn;

@property (weak, nonatomic) IBOutlet UIButton *targetBtn;

@property (weak, nonatomic) IBOutlet UIButton *testBtn;

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UIButton *increaseBtn;

@property (weak, nonatomic) IBOutlet UIButton *reduceBtn;

@property (weak, nonatomic) IBOutlet UIButton *okBtn;

@property(nonatomic, strong)NSArray *noteStrArray;

@property(nonatomic, strong)NSArray *noteHZArray;

@property(nonatomic, strong)NSString *referenceNoteStr;

@property(nonatomic, strong)NSNumber *referenceNoteHZ;

@property(nonatomic, strong)NSString *targetNoteStr;

@property(nonatomic, strong)NSNumber *targetNoteHZ;

@property(nonatomic, strong)NSNumber *blurNoteHZ;

@property(nonatomic, strong)NSNumber *playerNoteHZ;

@property(nonatomic, strong)NSNumber *currDeltaHZ;

@property(nonatomic, assign)BOOL sameTargetFlag;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.noteStrArray = @[@"C",@"C#",@"D",@"D#",@"E",@"F",@"F#",@"G",@"G#",@"A",@"A#",@"B"];
    self.noteHZArray = @[@(MIDDLE_C),//c
                         @(MIDDLE_C * kFrequency_Ratio),//c#
                         @(MIDDLE_C * pow(kFrequency_Ratio, 2)),//d
                         @(MIDDLE_C * pow(kFrequency_Ratio, 3)),//d#
                         @(MIDDLE_C * pow(kFrequency_Ratio, 4)),//e
                         @(MIDDLE_C * pow(kFrequency_Ratio, 5)),//f
                         @(MIDDLE_C * pow(kFrequency_Ratio, 6)),//f#
                         @(MIDDLE_C * pow(kFrequency_Ratio, 7)),//G
                         @(MIDDLE_C * pow(kFrequency_Ratio, 8)),//G#
                         @(MIDDLE_C * pow(kFrequency_Ratio, 9)),//a
                         @(MIDDLE_C * pow(kFrequency_Ratio, 10)),//a#
                         @(MIDDLE_C * pow(kFrequency_Ratio, 11)),//b
                         ];
    
    self.engine = [[PureToneEngine alloc] init];
    [self restart];
    self.targetBtn.enabled = NO;
    self.targetBtn.backgroundColor = [UIColor lightGrayColor];
}

- (IBAction)resetBtnAction:(id)sender
{
    [self restart];

}

- (void)restart
{
    [self reSetReferenceAndTarget];
    [self resetPlayersNote];
    [self.testBtn setTitle:@"listen" forState:UIControlStateNormal];
    self.targetBtn.enabled = NO;
    self.targetBtn.backgroundColor = [UIColor lightGrayColor];
}

- (void)reSetReferenceAndTarget
{
    NSInteger index = random() % 12;
    
    self.referenceNoteStr = self.noteStrArray[index];
    self.referenceNoteHZ = self.noteHZArray[index];
    [self.refBtn setTitle:self.referenceNoteStr forState:UIControlStateNormal];
    
    
    index = random() % 12;
    self.targetNoteStr = self.noteStrArray[index];
    self.targetNoteHZ = self.noteHZArray[index];
    
    if (self.sameTargetFlag)
    {
        self.targetNoteStr = self.referenceNoteStr;
        self.targetNoteHZ = self.referenceNoteHZ;
    }
    [self.targetBtn setTitle:self.targetNoteStr forState:UIControlStateNormal];
    
    CGFloat delta = self.targetNoteHZ.floatValue * (@(kFrequency_Ratio).floatValue - 1);
    self.currDeltaHZ = @(delta);
}

- (void)resetPlayersNote
{
    
    CGFloat randomHZ = (rand() % 100 - 50) / 100.00 * self.currDeltaHZ.floatValue;
    
    self.blurNoteHZ = @(self.targetNoteHZ.floatValue + randomHZ);
    self.playerNoteHZ = [self.blurNoteHZ copy];
}


- (IBAction)sliderAction:(UISlider *)slider {
    CGFloat offset = slider.value;
    CGFloat newPlayerNote;
    if (offset > 0.5)
    {
        newPlayerNote =  self.blurNoteHZ.floatValue + (offset - 0.5)/ 0.5 * self.currDeltaHZ.floatValue;
    }
    else
    {
        newPlayerNote =  self.blurNoteHZ.floatValue - (0.5 - offset)/ 0.5 * self.currDeltaHZ.floatValue;
    }
    self.playerNoteHZ = @(newPlayerNote);
    
    NSLog(@"newPlayerNote : %f  targetNoteHZ :%@",newPlayerNote,self.targetNoteHZ);
}

- (IBAction)increaseBtnAction:(id)sender {
    self.playerNoteHZ = @(self.playerNoteHZ.floatValue + 0.1);
    NSLog(@"playerNoteHZ : %@  targetNoteHZ :%@",self.playerNoteHZ,self.targetNoteHZ);
}


- (IBAction)reduceBtnAction:(id)sender {
    self.playerNoteHZ = @(self.playerNoteHZ.floatValue - 0.1);
    NSLog(@"playerNoteHZ : %@  targetNoteHZ :%@",self.playerNoteHZ,self.targetNoteHZ);
}

- (IBAction)okBtnAction:(id)sender {
    NSString *str = [NSString stringWithFormat:@" %.1f to the Target",self.playerNoteHZ.floatValue - self.targetNoteHZ.floatValue];
    [self.testBtn setTitle:str forState:UIControlStateNormal];
    
    self.targetBtn.enabled = YES;
    self.targetBtn.backgroundColor = self.testBtn.backgroundColor;
}

- (IBAction)listenBtnTouchDown:(id)sender {
    
    NSLog(@"listenBtnTouchDown");
    
    [self.engine playWithfrequency:self.playerNoteHZ.floatValue];
}

- (IBAction)listenBtnTouchUp:(id)sender {
    NSLog(@"listenBtnTouchUp");
    [self.engine stop];
}

- (IBAction)referenceBtnTouchDown:(id)sender {
    NSLog(@"referenceBtnTouchDown");
    [self.engine playWithfrequency:self.referenceNoteHZ.floatValue];
}

- (IBAction)referenceBtnTouchUp:(id)sender {
    NSLog(@"referenceBtnTouchUp");
    [self.engine stop];
}

- (IBAction)sameTargetSwitchAction:(id)sender {
    UISwitch *bbb = sender;
    if (bbb.isOn) {
        self.sameTargetFlag = YES;
    }
    else
    {
        self.sameTargetFlag = NO;
    }
    
}

- (IBAction)targetBtnTouchDown:(id)sender {
    [self.engine playWithfrequency:self.targetNoteHZ.floatValue];
}

- (IBAction)targetBtnTouchUp:(id)sender {
    NSLog(@"targetBtnTouchUp");
    [self.engine stop];
}


@end
