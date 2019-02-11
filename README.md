# VideoDecoderKit

`Version: 0.9.2.1`

-------------

`0.9.2.1`: 添加macOS支持，删除多余的ffmpeg编译参数，添加播放FLV音频测试Demo。

Version 0.9 重构了0.4版本的接口，去掉了FFmpeg依赖，精简数据模型，帧解析器和编解码器之前统一使用CMSampleBuffer传递。音频部分使用AVAudioEngine。

## Video
- [x] VideoToolBox H264 硬解码
- [x] VideoToolBox H264 硬编码
- [ ] 重构视频渲染接口
- [ ] 重构Metal渲染
- [ ] OpenGL渲染
## Audio
- [x] AudioConverter 解码AAC
- [x] AudioConverter 编码PCM
- [x] 多声道AAC支持
- [x] AVAudioEngine 播放PCM数据
## Media
- [x] FLV 文件解析
- [ ] MP4 文件解析
- [ ] TS 文件解析
- [x] 麦克风接口封装，数据获取
- [ ] 摄像头接口封装，数据获取
## Publish
- [ ] RTMP协议(WIP: 排入0.9.3版本)
## Player
- [x] 音视频同步
- [ ] 缓存队列
## Build
- [x] macOS 支持
- [x] 动态库