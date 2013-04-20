SightResight
============

iOS Photoslider. Shows how simple it is to use UIScrollViews to create a gallery with zooming etc. This is the code for the app Sight Resight in App Store. All rights reserved.

(https://itunes.apple.com/us/app/sight-resight/id637379231?l=da&ls=1&mt=8)[View in app store]

### About Sight Resight

For anyone working with sight-resight, mark-recapture or photo-id in general, this tool can help with matching animals while in the field. 

Side by side view allows you to do regular photo-id, while comparing two images next to each other. Standard swipe and zoom motions makes it quick and easy to compare the images. 

Gallery view allows you to use the full screen to look through your catalogue and identify animals in the field. 

Overlay view allows you to take two images, and put them on top of each other. A simple slider allows you to change opacity of the images, and zooming and moving the images with your fingers is a snap.

### License

Licensed under the Creative Commons 3.0 "BY SA" (http://creativecommons.org/licenses/by-sa/3.0/) license with the following addition:

```
You are not allowed to submit (aka copying the app) this code to the app store under a different name.
```

If you like the code you should donate 1,99$ by buying the App in the AppStore. 

## How to

* Copy AVPhotoSlider folder to your project
* Add AVPhotoController as a subview to your controller
* Create an array of AVPhoto's
* Call loadPhotos on your AVPhotoController instance
* Enjoy

The code is built using ARC.

```objective-c
AVPhotoController *gallery = [[AVPhotoController alloc] initWithFrame:YourFrame];
[self.view addSubview:gallery];

NSMutableArray *photos = [[NSMutableArray alloc] init];

AVPhoto *photo = [[AVPhoto alloc] init];
photo.imagePath = @"image.png";
photo.caption = @"Cool photo";

[photos addObject:photo];
[gallery loadPhotos:photos];

```
