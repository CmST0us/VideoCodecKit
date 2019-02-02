# VideoDecoderKit

`Version: 0.9.1`

此版本重构了0.4版本的接口，去掉了FFmpegy依赖，精简数据模型，帧解析器和编解码器之前统一使用CMSampleBuffer传递。

## Video
- [x] VideoToolBox H264 硬解码
- [ ] VideoToolBox H264 硬编码
- [ ] 重构视频渲染接口
- [ ] 重构Metal渲染
- [ ] OpenGL渲染
## Audio
- [x] AudioConverter 解码AAC
- [x] 多声道AAC支持
- [x] AVAudioEngine 播放PCM数据
- [ ] AudioConverter 编码PCM
## Media File
- [x] FLV 文件解析
- [ ] MP4 文件解析
- [ ] TS 文件解析
## Publish
- [ ] RTMP协议
## Player
- [x] 音视频同步
- [ ] 缓存队列

