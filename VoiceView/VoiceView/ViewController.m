//
//  ViewController.m
//  VoiceView
//
//  Created by 刘俊 on 14-8-1.
//  Copyright (c) 2014年 yunzhisheng. All rights reserved.
//

#define isiPhone5 [UIScreen mainScreen].bounds.size.height>480

#import "ViewController.h"
#import "InputView.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
{
    IBOutlet InputView *_inputView;
    AVAudioRecorder *recorder;
}

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addInputView];
    
    [self initRecorder];
}

-(void)addInputView
{
    _inputView.delegate=self;
    _inputView.superView=self.view;
    _inputView.noKeyboard=YES;
    [_inputView setContolMode:CONTROL_TOUCH];
    //[_inputView setContolMode:CONTROL_CLIP];
    _inputView.backgroundColor=[UIColor colorWithRed:(CGFloat)242/255 green:(CGFloat)242/255 blue:(CGFloat)242/255 alpha:1];
    _inputView.layer.shadowColor=[UIColor grayColor].CGColor;
    _inputView.layer.shadowOffset=CGSizeMake(0, 0.6);
    _inputView.layer.shadowOpacity=.2;
    [_inputView addWidget];
    
    //键盘高度
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

-(void)initRecorder
{
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
	NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat: 44100.0],
                               AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
                               AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
                               AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};
    
	NSError *error;
	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if(error) {
        NSLog(@"Ups, could not create recorder %@", error);
        return;
    }
    
    [recorder prepareToRecord];
    [recorder setMeteringEnabled:YES];
    [recorder record];
    
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateMeters
{
	[recorder updateMeters];
    
    CGFloat normalizedValue = pow (10, [recorder averagePowerForChannel:0] / 20);
    
    [_inputView updateVolume:(int)(normalizedValue*1000)];
    
    //NSLog(@"%d",(int)(normalizedValue*1000));
}

#pragma mark -
#pragma mark - InputViewDelegate

-(void)inputStart
{
    NSLog(@"inputStart");
}

-(void)inputWillCancle
{
    NSLog(@"inputWillCancle");
}

-(void)inputDidCancle
{
   NSLog(@"inputDidCancle");
}

-(void)inputDidLoading
{
    NSLog(@"inputDidLoading");
}

-(void)inputDidStop
{
    NSLog(@"inputDidStop");
    //[_inputView setMicBtnEnable:NO];
}

#pragma mark -
#pragma mark - KVO

-(void)inputUpAnimation:(float)height
{
    if (isiPhone5)
    {
        if (height>568)
        {
            return;
        }
    }
    else
    {
        if (height>480)
        {
            return;
        }
    }
    
    CGRect inputFrame=_inputView.frame;
    inputFrame.origin.y=height-inputFrame.size.height-64;
    //[_inputView setFrame:inputFrame];
    
    [UIView animateWithDuration:0.25 animations:^{
        [_inputView setFrame:inputFrame];
    }];
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    CGRect rect=[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float height = [self.view convertRect:rect toView:self.view].origin.y;
    
    [self inputUpAnimation:height];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect rect=[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float height = [self.view convertRect:rect toView:self.view].origin.y;
    
    [self inputUpAnimation:height];
}

@end
