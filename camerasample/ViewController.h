//
//  ViewController.h
//  camerasample
//
//  Created by Kanchan on 10/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


@interface ViewController : UIViewController  <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate>{

    BOOL isvediomode;
    BOOL isCamera;   
    UIImage *imageToDisplay ;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *takePictureButton;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayerController;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSURL *movieURL;
@property (copy, nonatomic) NSString *lastChosenMediaType;
@property (assign, nonatomic) CGRect imageFrame;
@property(nonatomic,assign) UIImage *imageToDisplay ;

- (IBAction)shootPicture:(id)sender;
- (IBAction)shootVideo:(id)sender;
- (IBAction)selectExistingPictureOrVideo:(id)sender;


@end
