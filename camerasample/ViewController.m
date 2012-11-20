//
//  ViewController.m
//  camerasample
//
//  Created by Kanchan on 10/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define LIBRARY_CACHES_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"]

@interface ViewController()
static UIImage *shrinkImage(UIImage *original, CGSize size);
- (void)updateDisplay;
- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType;
@end

@implementation ViewController
@synthesize imageView;
@synthesize takePictureButton;
@synthesize moviePlayerController;
@synthesize image;
@synthesize movieURL;
@synthesize lastChosenMediaType;
@synthesize imageFrame;
@synthesize imageToDisplay;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    if (![UIImagePickerController isSourceTypeAvailable:
//          UIImagePickerControllerSourceTypeCamera]) {
//        takePictureButton.hidden = YES;
//    }
    imageFrame = imageView.frame;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.imageView = nil;
    self.takePictureButton = nil;
    self.moviePlayerController = nil;
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateDisplay];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)shootPicture:(id)sender{
    UIActionSheet *popUpActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
    popUpActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [popUpActionSheet showInView:self.view];

}
- (IBAction)shootVideo:(id)sender{
    isvediomode=TRUE;
    [self getMediaFromSource:UIImagePickerControllerCameraCaptureModeVideo];
    
}


- (IBAction)selectExistingPictureOrVideo:(id)sender {
    [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (IBAction)SavedButtonClicked:(id)sender {
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    
}
#pragma Mark - UIActionSheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if (buttonIndex == 0) {//Shows The Camera View
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
           
            [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
            isCamera=TRUE;
           
        }
        else {
            UIAlertView *showAlrt = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Sorry, Camera is not supported by this device" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil ];
            [showAlrt show];
            showAlrt = nil;
        }
    } 
    else if (buttonIndex == 1) {// Shows The Photo Library of Phone
        [self presentModalViewController:imagePicker animated:YES];
    } 
   
}

#pragma mark UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.lastChosenMediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSLog(@"last mode%@",self.lastChosenMediaType);
    if ([lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
        UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *shrunkenImage = shrinkImage(chosenImage, imageFrame.size);
        self.image = shrunkenImage;
        if (isCamera==TRUE) {
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            imageToDisplay = [UIImage imageWithCGImage:[image CGImage]
                                                 scale:1.0
                                           orientation: UIImageOrientationRight];
            self.image = self.imageToDisplay;
            

        }
        isCamera=FALSE;
        
    } 
    else if ([lastChosenMediaType isEqual:(NSString *)kUTTypeMovie]) {
        self.movieURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        NSData *videoData = [NSData dataWithContentsOfURL:self.movieURL];
        
        
        NSString *filePath = [NSString stringWithFormat:@"%@/Documents/%f.mp4", LIBRARY_CACHES_FOLDER,[[NSDate date] timeIntervalSince1970]];
       // UISaveVideoAtPathToSavedPhotosAlbum(filePath,nil,nil,nil);
        
        [videoData writeToFile:filePath atomically:YES];
        
         // [videoData release];
        
        NSLog(@"LOCAL VIDEO LINK %@",filePath);    
    }
    [picker dismissModalViewControllerAnimated:YES];
    
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {    
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark  -
static UIImage *shrinkImage(UIImage *original, CGSize size) {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, size.width * scale,
                                                 size.height * scale, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context,
                       CGRectMake(0, 0, size.width * scale, size.height * scale),
                       original.CGImage);
    CGImageRef shrunken = CGBitmapContextCreateImage(context);
    UIImage *final = [UIImage imageWithCGImage:shrunken];
    
    CGContextRelease(context);
    CGImageRelease(shrunken);	
    
    return final;
}
- (void)updateDisplay {
    if ([lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
               
        imageView.image = image;
        imageView.hidden = NO;
        
        moviePlayerController.view.hidden = YES;
            } 
    else if ([lastChosenMediaType isEqual:(NSString *)kUTTypeMovie]) {
        [self.moviePlayerController.view removeFromSuperview];
        self.moviePlayerController = [[MPMoviePlayerController alloc]
                                      initWithContentURL:movieURL];
        moviePlayerController.view.frame = imageFrame;
        moviePlayerController.view.clipsToBounds = YES;
        [self.view addSubview:moviePlayerController.view];
        [self.moviePlayerController play];
        imageView.hidden = YES;
    }
}

- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType {
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:
         sourceType] && [mediaTypes count] > 0) {
        NSArray *mediaTypes = [UIImagePickerController
                               availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *picker =
        [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        if (isvediomode==TRUE) {
            picker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;
        }
        else{
            picker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
        }
        
        [self presentModalViewController:picker animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Error accessing media" 
                              message:@"Device doesn’t support that media source." 
                              delegate:nil 
                              cancelButtonTitle:@"Drat!" 
                              otherButtonTitles:nil];
        [alert show];
    }
    isvediomode=FALSE;
}

@end

