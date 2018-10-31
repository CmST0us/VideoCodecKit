# VideoDecoderKit

https://github.com/CmST0us/VideoPreviewer 的重构版

# How to use
1. clone ffmpeg ios build script

run `git clone https://gitlab.com/eric3u/FFmpeg-iOS-build-script`

2. build fat library

run `./build-ffmpeg.sh lipo` in FFmpeg-iOS-build-script directory

3. copy fat library to Vendor

after finish build fat ffmpeg directory you should copy ffmpeg library and header to vendor directory

4. add `-ObjC` link flag to other link flag

5. add linked Frameworks and Libraries:
    * AVFoundation.framework
    * libz
    * AudioToolbox.framework
    * CoreMedia.framework
    * VideoToolbox.framework
    * libiconv
    

* or you can just setup 1-3 and run demo app.*

# Feature

- [x] ffmpeg parse h264 raw data
- [x] ffmpeg decode h264
- [x] multi-thread decode preview component
- [x] hardware-decode support
- [ ] metal render `Next Ver`
- [ ] rtmp publish
- [ ] audio support
- [x] hardware-encode support
- [ ] ffmpeg encode support
- [ ] GPUImage support
- [x] build as framework

# Release Note
## 0.3
- refactor demo app
- fix encoder release bug

## 0.2
- support h264 videotoolbox encode
- add camera capture demo
- frame reorder bugfix
- thread sync bugfix
- API change

## 0.1
- support h264 videotoolbox decode
- support h264 ffmpeg decode
- add multi-thread h264 preview object VCPreviewer
- build as framework, easy to use
