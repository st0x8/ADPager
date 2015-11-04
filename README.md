### ADPager

This is a custom view that can auto scroll, most like gallery .

### Feartures

- A gallery that can scroll yourself or auto.
- Can load local images.
- Can load network images.
- Can display dividual title.


### How to use

Download and drag the ```ADView``` folder into your Xcode project. 
 Then``` #import "ADView.h"```. 

```
ADView *adView = [ADView getADViewWithFrame:CGRectMake(0, 55, windowFrame.size.width, windowFrame.size.height * 0.35) localImageURLs:localImages adTitles:titles dotsShowStyle:DotsShowStyleCenter];
[self.view addSubview:adView];
adView.scrollInterval = 3;
adView.tapCallBack = ^ (NSInteger currentIndex, NSURL *imageURL) {
        NSLog(@"%ld %@", (long)currentIndex, imageURL);
 };

```


### License

ADPager is available under the MIT license. See the LICENSE file for more info.
