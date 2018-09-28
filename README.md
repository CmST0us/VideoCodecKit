# VideoDecoderKit

https://github.com/CmST0us/VideoPreviewer 的重构版

# How to use
1. clone ffmpeg ios build script

run `git clone https://gitlab.com/eric3u/FFmpeg-iOS-build-script`

2. build fat library

run `./build-ffmpeg.sh lipo` in FFmpeg-iOS-build-script directory

3. copy fat library to Vendor

after finish build fat ffmpeg directory you should copy ffmpeg library and header to vendor directory

4. run Demo app

# feature

- [x] ffmpeg parse h264 raw data
- [x] ffmpeg decode h264
- [x] multi-thread decode preview component
- [x] hardware-decode support
- [ ] metal render `WIP`
- [ ] rtmp publish
- [ ] audio support
- [ ] encode support
- [ ] GPUImage support
- [ ] build as framework