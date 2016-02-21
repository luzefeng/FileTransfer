//
//  CocoaWebResourceViewController.m
//  CocoaWebResource
//
//  Created by Robin Lu on 12/1/08.
//  Copyright robinlu.com 2008. All rights reserved.
//

#import "CocoaWebResourceViewController.h"
#import "ASProgressPopUpView.h"
#define DOCPATH "Library/Caches/WHCVideos"
@interface CocoaWebResourceViewController () <ASProgressPopUpViewDataSource>
@property (nonatomic) IBOutlet ASProgressPopUpView *progressView;
@end

@implementation CocoaWebResourceViewController

// load file list
- (void)loadFileList
{
	[fileList removeAllObjects];
	NSString* docDir = [NSString stringWithFormat:@"%@/Library/Caches/WHCVideos", NSHomeDirectory()];
	NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager]
									  enumeratorAtPath:docDir];
	NSString *pname;
	while (pname = [direnum nextObject])
	{
		[fileList addObject:pname];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"WifiBg"]];
	fileList = [[NSMutableArray alloc] init];
	[self loadFileList];
//	[backLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backLabelTap:)]];
//    backLabel.userInteractionEnabled = YES;
//    backLabel.layer.borderWidth = 1.0;
//    backLabel.layer.borderColor =[[UIColor alloc] initWithRed:56/255 green:74/255 blue:96/255 alpha:1.0].CGColor;
//    backLabel.layer.cornerRadius = 5.0;
//    backLabel.textColor = [UIColor whiteColor];
    [backImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backLabelTap:)]];
    backImageView.userInteractionEnabled = YES;
//    backLabel.tintColor = [[UIColor alloc] initWithRed:56/255 green:74/255 blue:96/255 alpha:1.0];
	// set up the http server
	httpServer = [[HTTPServer alloc] init];
	[httpServer setType:@"_http._tcp."];	
	[httpServer setPort:8080];
	[httpServer setName:@"CocoaWebResource"];
	[httpServer setupBuiltInDocroot];
	httpServer.fileResourceDelegate = self;
//    progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(150.0,20.0,130.0,30.0)];
//    progressView.center = self.view.center;
//    progressView.backgroundColor = [UIColor greenColor];
//    [self resetProgress];
//    [self.view addSubview:progressView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadingStart:) name:@"UploadingStarted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadingProgress:) name:@"UploadingProgress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadingFinish:) name:@"UploadingFinished" object:nil];
    NSError *error;

        BOOL serverIsRunning = [httpServer start:&error];
        if(!serverIsRunning)
        {
            NSLog(@"Error starting HTTP Server: %@", error);
        }
        [urlLabel setText:[NSString stringWithFormat:@"http://%@:%d", [httpServer hostName], [httpServer port]]];
    self.progressView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:16];
//    self.progressView.popUpViewAnimatedColors = @[[UIColor redColor], [UIColor orangeColor], [UIColor greenColor]];
    [self.progressView showPopUpViewAnimated:YES];
    self.progressView.progress = 0.0;
//    self.progressView.dataSource = self;
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	httpServer.fileResourceDelegate = nil;
	[httpServer release];
	[fileList release];
    [super dealloc];
}


-(void)backLabelTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark progress
//开始上传

-(void)uploadingStart:(NSNotification *)notification

{
    [self resetProgress];
}

-(void)resetProgress
{
//    progressView.progress = 0.0;
//    [progressLabel setText:[NSString stringWithFormat:@"下载进度: %%0"]];
}
//正在上传

-(void)uploadingProgress:(NSNotification *)notification

{
    
    float newProgress = [[[notification userInfo] objectForKey:@"progress"] floatValue];
    
    newProgress = floor(newProgress*100) / 100;
//    [progressLabel setText:[NSString stringWithFormat:@"下载进度: %f", newProgress*100]];
    float oldProgress = self.progressView.progress;
    oldProgress = floor(oldProgress*100) / 100;
    NSLog(@"progress ----- %f", newProgress);
    if (newProgress > oldProgress) {
        self.progressView.progress = newProgress;
        [self.progressView setProgress:newProgress animated:NO];
    }
}

//上传完成

-(void)uploadingFinish:(NSNotification *)notification

{
//    self.progressView.progress = 1.0;
    
    NSLog(@"上传完成");
    
}

#pragma mark - ASProgressPopUpView dataSource

// <ASProgressPopUpViewDataSource> is entirely optional
// it allows you to supply custom NSStrings to ASProgressPopUpView
- (NSString *)progressView:(ASProgressPopUpView *)progressView stringForProgress:(float)progress
{
    NSString *s;
    if (progress < 0.2) {
        s = @"准备开始";
    } else if (progress > 0.4 && progress < 0.6) {
        s = @"刚到一半";
    } else if (progress > 0.75 && progress < 1.0) {
        s = @"快好啦";
    } else if (progress >= 1.0) {
        s = @"下载完成";
    }
    return s;
}

// by default ASProgressPopUpView precalculates the largest popUpView size needed
// it then uses this size for all values and maintains a consistent size
// if you want the popUpView size to adapt as values change then return 'NO'
- (BOOL)progressViewShouldPreCalculatePopUpViewSize:(ASProgressPopUpView *)progressView;
{
    return NO;
}

#pragma mark actions
- (IBAction)toggleService:(id)sender
{
	NSError *error;
	if ([(UISwitch*)sender isOn])
	{
		BOOL serverIsRunning = [httpServer start:&error];
		if(!serverIsRunning)
		{
			NSLog(@"Error starting HTTP Server: %@", error);
		}		
		[urlLabel setText:[NSString stringWithFormat:@"http://%@:%d", [httpServer hostName], [httpServer port]]];
	}
	else
	{
		[httpServer stop];
		[urlLabel setText:@""];
	}
}

#pragma mark WebFileResourceDelegate
// number of the files
- (NSInteger)numberOfFiles
{
	return [fileList count];
}

// the file name by the index
- (NSString*)fileNameAtIndex:(NSInteger)index
{
	return [fileList objectAtIndex:index];
}

// provide full file path by given file name
- (NSString*)filePathForFileName:(NSString*)filename
{
	NSString* docDir = [NSString stringWithFormat:@"%@/Library/Caches/WHCVideos", NSHomeDirectory()];
	return [NSString stringWithFormat:@"%@/%@", docDir, filename];
}

// handle newly uploaded file. After uploading, the file is stored in
// the temparory directory, you need to implement this method to move
// it to proper location and update the file list.
- (void)newFileDidUpload:(NSString*)name inTempPath:(NSString*)tmpPath
{
	if (name == nil || tmpPath == nil)
		return;
	NSString* docDir = [NSString stringWithFormat:@"%@/Library/Caches/WHCVideos", NSHomeDirectory()];
	NSString *path = [NSString stringWithFormat:@"%@/%@", docDir, name];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	if (![fm moveItemAtPath:tmpPath toPath:path error:&error])
	{
		NSLog(@"can not move %@ to %@ because: %@", tmpPath, path, error );
	}
		
	[self loadFileList];
	
}

// implement this method to delete requested file and update the file list
- (void)fileShouldDelete:(NSString*)fileName
{
	NSString *path = [self filePathForFileName:fileName];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	if(![fm removeItemAtPath:path error:&error])
	{
		NSLog(@"%@ can not be removed because:%@", path, error);
	}
	[self loadFileList];
}

@end
