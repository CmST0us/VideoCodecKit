# VideoDecoderKit

`Version: 0.9.5`

-------------

`0.9.5`: 修复推流音频问题。重构了一堆接口。封装了推流器VCRTMPPublish,可以方便推流RTMP了。优化了H264编码器，加入参数修改接口，便于推流时修改参数。简化删除了不同的Demo，去掉了Masonry依赖。同时提供静态Framework和动态Framework两种连接方式（考虑到苹果在iOS 13.3.1 中关闭了免费正式对动态库的签名，Demo使用静态连接）。

`0.9.4`: 实现RTMP，可以推流FLVTag了

`0.9.3`: 添加H265硬解码支持，支持播放H264 H265裸流

`0.9.2.1`: 添加macOS支持，删除多余的ffmpeg编译参数，添加播放FLV音频测试Demo。

## Video
- [x] VideoToolBox H264 硬解码
- [x] VideoToolBox H264 硬编码
- [x] VideoToolBox H265 硬解码
- [ ] VideoToolBox H265 硬编码
- [ ] 重构视频渲染接口
- [ ] 重构Metal渲染
- [ ] OpenGL渲染
## Audio
- [x] AudioConverter 解码AAC
- [x] AudioConverter 编码PCM
- [x] 多声道AAC支持
- [x] AVAudioEngine 播放PCM数据
## Media
- [x] H264 裸流解析
- [x] H265 裸流解析
- [x] FLV 文件解析
- [ ] MP4 文件解析
- [ ] TS 文件解析
- [ ] FLV 文件写入
- [x] 麦克风接口封装，数据获取
## Publish
- [x] RTMP协议
- [x] RTMP推流器
## Player
- [x] 音视频同步
- [ ] 缓存队列
## Build
- [x] macOS 支持
- [x] 动态库
- [x] 静态库
