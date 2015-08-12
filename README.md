### ADPager

This is a custom view that can auto scroll, most like gallery .

### Feartures

- A gallery that can scroll yourself or auto.
- Can load local images.
- Can load network images.
- Can display dividual title.


### How to use

Add the [SDWebImage](https://github.com/rs/SDWebImage) project and my ADView to your project. Then #import "ADView.h". 

```
ADView *adView = [ADView getADViewWithFrame:CGRectMake(0, 55, windowFrame.size.width, windowFrame.size.height * 0.35) localImageURLs:localImages adTitles:titles dotsShowStyle:DotsShowStyleCenter];
[self.view addSubview:adView];
[adView isAutoScroll:YES scrollInterval:3];
```


### License

ADPager is available under the MIT license. See the LICENSE file for more info.
