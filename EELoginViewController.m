// Copyright 2004-present Facebook. All Rights Reserved.

#import "EELoginViewController.h"

#import "EECommunications.h"
#import "EEHomeViewController.h"

@interface EELoginViewController ()

@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation EELoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      _loginButton = [[UIButton alloc] init];
      self.navigationItem.title = @"Stalkr";
      self.navigationItem.hidesBackButton = YES;
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  UIGraphicsBeginImageContext(self.view.frame.size);
  [[UIImage imageNamed:@"login"] drawInRect:self.view.bounds];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  self.view.backgroundColor = [UIColor colorWithPatternImage:image];
  self.navigationController.navigationBar.hidden = YES;

  _titleLabel.frame = CGRectMake(0, 0, 320, 30);

  CGRect buttonFrame = CGRectMake(59, 436, 202, 44);
  _loginButton.frame = buttonFrame;
  CGPoint center = self.view.center;
  center.y += 200;
  _loginButton.center = center;
  [_loginButton addTarget:self action:@selector(loginPressed:) forControlEvents:UIControlEventTouchUpInside];
  UIImage *loginButtonImage = [UIImage imageNamed:@"FBLogin@2x"];
  [_loginButton setImage:loginButtonImage forState:UIControlStateNormal];
  [self.view addSubview:_loginButton];
}

- (IBAction)loginPressed:(id)sender
{
  [_loginButton setEnabled:NO];
  EECommunicationsCompleteBlock callback = ^(BOOL succeeded) {
    [_loginButton setEnabled:YES];
    if(succeeded) {
      EEHomeViewController *hvc = [[EEHomeViewController alloc] init];
      self.navigationController.delegate = hvc;
      [self.navigationController pushViewController:hvc animated:YES];
    } else {
      [[[UIAlertView alloc] initWithTitle:@"Login Failed"
                                  message:@"Facebook Login failed. Please try again"
                                 delegate:nil
                        cancelButtonTitle:@"Ok"
                        otherButtonTitles:nil] show];
    }
  };
  [EECommunications loginWithCallback:callback];
}

@end
