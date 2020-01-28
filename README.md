# VideoDecoderKit

`Version: 0.9.3`

-------------

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
- [x] 麦克风接口封装，数据获取
- [ ] 摄像头接口封装，数据获取
## Publish
- [ ] RTMP协议(WIP)
## Player
- [x] 音视频同步
- [ ] 缓存队列
## Build
- [x] macOS 支持
- [x] 动态库
