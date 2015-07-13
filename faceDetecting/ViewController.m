//
//  ViewController.m
//  faceDetecting
//
//  Created by phuoc-de on 10/14/14.
//  Copyright (c) 2014 LeHaiNam. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
UIImageView* image;
-(UIImage *)resizedImageWithImage:(NSString *)imageName{
    NSString *imageName1=[NSString stringWithFormat:@"2.jpg"];
    UIImage *image=[UIImage imageNamed:imageName];
//    float a=400/image.size.height;
    CGSize size=CGSizeMake(image.size.width*(400/image.size.height), 400);
    UIGraphicsBeginImageContext(size);
    
    // Draw the scaled image in the current context
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // Create a new image from current context
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Pop the current context from the stack
    UIGraphicsEndImageContext();
    return scaledImage;
}
-(void)faceDetectorWithImageName:(NSString *)imageName
{
   
    // Load the picture for face detection
   image = [[UIImageView alloc] initWithImage:[self resizedImageWithImage:imageName]];
    
    // Draw the face detection image
    [self.view addSubview:image];

    // Execute the method used to markFaces in background
//    NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
//    [myQueue addOperationWithBlock:^{
    
        // Background work
        [self markFaces:image];
        
//            }];
    
    // flip image on y-axis to match coordinate system used by core image
//    [image setTransform:CGAffineTransformMakeScale(1, -1)];
    
    // flip the entire window to make everything right side up
//    [self.view setTransform:CGAffineTransformMakeScale(1, -1)];
}
int count=17;
- (IBAction)face:(id)sender {
    count++;
    if(count>20) count=1;
    
    [self faceDetectorWithImageName:[NSString stringWithFormat:@"%i.jpeg",count]];
}
- (IBAction)groupFaces:(id)sender {
     count++;
    if(count>4) count=1;
   
    [self faceDetectorWithImageName:[NSString stringWithFormat:@"g%i.jpeg",count]];

}

-(void)markFaces:(UIImageView *)facePicture
{
    UIView *marks=[[UIView alloc] initWithFrame:facePicture.bounds];
   
    // draw a CI image with the previously loaded face detection picture
    CIImage* image = [CIImage imageWithCGImage:facePicture.image.CGImage];
    
    // create a face detector - since speed is not an issue we'll use a high accuracy
    // detector
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    
    // create an array containing all the detected faces from the detector
    NSArray* features = [detector featuresInImage:image];
    // we'll iterate through every detected face. CIFaceFeature provides us
    // with the width for the entire face, and the coordinates of each eye
    // and the mouth if detected. Also provided are BOOL's for the eye's and
    // mouth so we can check if they already exist.
    for(CIFaceFeature* faceFeature in features)
    {
      
        // get the width of the face
        CGFloat faceWidth = faceFeature.bounds.size.width;
        
        // create a UIView using the bounds of the face
        UIView* faceView = [[UIView alloc] initWithFrame:faceFeature.bounds];
        
        // add a border around the newly created UIView
        faceView.layer.borderWidth = 1;
        faceView.layer.borderColor = [[UIColor redColor] CGColor];
        if(faceFeature.hasFaceAngle)
        {
            CIFaceFeature *_selectedFace = faceFeature;// the face feature
            float _rotationAngle = 0.f;
            if (_selectedFace.leftEyePosition.x != _selectedFace.rightEyePosition.x) {
                _rotationAngle = atan((_selectedFace.leftEyePosition.y - _selectedFace.rightEyePosition.y) / (_selectedFace.leftEyePosition.x - _selectedFace.rightEyePosition.x));
            }
            
            faceView.layer.transform=CATransform3DMakeRotation(_rotationAngle, 0, 0, 1);
        }
        // add the new view to create a box around the face
        [marks addSubview:faceView];
        
        if(faceFeature.hasLeftEyePosition)
        {
            // create a UIView with a size based on the width of the face
            UIView* leftEyeView = [[UIView alloc] initWithFrame:CGRectMake(faceFeature.leftEyePosition.x-faceWidth*0.15, faceFeature.leftEyePosition.y-faceWidth*0.15, faceWidth*0.3, faceWidth*0.3)];
            // change the background color of the eye view
            [leftEyeView setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            // set the position of the leftEyeView based on the face
            [leftEyeView setCenter:faceFeature.leftEyePosition];
            // round the corners
            leftEyeView.layer.cornerRadius = faceWidth*0.15;
            // add the view to the window
            [marks addSubview:leftEyeView];
        }
        
        if(faceFeature.hasRightEyePosition)
        {
            // create a UIView with a size based on the width of the face
            UIView* leftEye = [[UIView alloc] initWithFrame:CGRectMake(faceFeature.rightEyePosition.x-faceWidth*0.15, faceFeature.rightEyePosition.y-faceWidth*0.15, faceWidth*0.3, faceWidth*0.3)];
            // change the background color of the eye view
            [leftEye setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            // set the position of the rightEyeView based on the face
            [leftEye setCenter:faceFeature.rightEyePosition];
            // round the corners
            leftEye.layer.cornerRadius = faceWidth*0.15;
            // add the new view to the window
            [marks addSubview:leftEye];
        }
        
        if(faceFeature.hasMouthPosition)
        {
            // create a UIView with a size based on the width of the face
            UIView* mouth = [[UIView alloc] initWithFrame:CGRectMake(faceFeature.mouthPosition.x-faceWidth*0.2, faceFeature.mouthPosition.y-faceWidth*0.2, faceWidth*0.4, faceWidth*0.4)];
            // change the background color for the mouth to green
            [mouth setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.3]];
            // set the position of the mouthView based on the face
            [mouth setCenter:faceFeature.mouthPosition];
            // round the corners
            mouth.layer.cornerRadius = faceWidth*0.2;
            // add the new view to the window
            [marks addSubview:mouth];
        }
        
        if(faceFeature.hasSmile){
            _label.text=@"Có đứa đang cười";
        }
        else _label.text=@"Éo cười";
        if(faceFeature.leftEyeClosed||faceFeature.rightEyeClosed)
        {
            _label.text=@"nham mat";
        }
    }
    [self.view addSubview:marks];
    [marks setTransform:CGAffineTransformMakeScale(1, -1)];

//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        // Main thread work (UI usually)
//        [indicator stopAnimating];
//        indicator.hidden=YES;
//    }];

}
@end
