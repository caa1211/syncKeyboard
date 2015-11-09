//
//  KeyboardViewController.m
//  syncKeyboard
//
//  Created by caa on 11/9/15.
//  Copyright © 2015 yahoo. All rights reserved.
//

#import "KeyboardViewController.h"
#import <SocketIO.h>
#import <SocketIOPacket.h>

@interface KeyboardViewController () <SocketIODelegate>
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property (nonatomic, strong) SocketIO *socketIO;
@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Perform custom UI setup here
    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [self.nextKeyboardButton setTitle:NSLocalizedString(@"Next 4", @"Title for 'Next Keyboard' button") forState:UIControlStateNormal];
    [self.nextKeyboardButton sizeToFit];
    self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.nextKeyboardButton addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.nextKeyboardButton];
    
    NSLayoutConstraint *nextKeyboardButtonLeftSideConstraint = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    NSLayoutConstraint *nextKeyboardButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraints:@[nextKeyboardButtonLeftSideConstraint, nextKeyboardButtonBottomConstraint]];
    
    [self setupSocketio];
}

- (void) setupSocketio {
    NSString *socketServer = @"believeweave.corp.gq1.yahoo.com";
    self.socketIO = [[SocketIO alloc] initWithDelegate:self];
    self.socketIO.delegate = self;
    //[socketIO connectToHost:@"believeweave.corp.gq1.yahoo.com" onPort:3000 withParams:@{@"auth_token":@"1234"}];
    [self.socketIO connectToHost:socketServer onPort:3001];
    //self.debugLabel.text = @"00";
}

- (IBAction)onBtnClick:(id)sender {
    [self.socketIO sendEvent:@"sendMsg" withData:@{@"room": @"my room", @"data": @"ooo"}];
}


- (void) socketIODidConnect:(SocketIO *)socket{
    self.debugLabel.text = @"a"; //v
    
    [self.socketIO sendEvent:@"joinRoom" withData:@"my room"];
}
- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error{
    self.debugLabel.text = @"b";
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet{
    self.debugLabel.text = @"c";
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet{
    //self.debugLabel.text = @"d"; //v
    
}
- (void) socketIO:(SocketIO *)socket onError:(NSError *)error{
    self.debugLabel.text = @"e"; //v
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
    NSLog(@"didReceiveMessage >>> data: %@", packet.data);
    self.debugLabel.text = @"11";
}


- (NSString *)getLastWordBeforeInput {
    //get last word before input. if last character is a space, the return value will be an empty string
    NSString *context = [self.textDocumentProxy documentContextBeforeInput];
    context = [context stringByReplacingOccurrencesOfString:@"[^a-zA-Z]" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, context.length)];
    NSArray *listItems = [context componentsSeparatedByString:@" "];
    if (listItems.lastObject == nil) {
        return @"";
    }
    return listItems.lastObject;
}

// event delegate
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    while (self.textDocumentProxy.hasText==YES)
    {
        [self.textDocumentProxy deleteBackward];
    }
    
    NSString *remoteInput = packet.args[0][@"data"];
    self.debugLabel.text = remoteInput;
    NSLog(@"didReceiveEvent >>> data: %@", packet.data);
    
   
    [self.textDocumentProxy insertText:remoteInput];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
}

@end
