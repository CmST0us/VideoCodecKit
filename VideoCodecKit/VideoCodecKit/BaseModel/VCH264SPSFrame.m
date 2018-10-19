//
//  VCH264SPSFrame.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/3.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCH264SPSFrame.h"

#define INFO(fmt, ...) //NSLog(fmt, ##__VA_ARGS__)
#define ERROR(fmt, ...) NSLog(fmt, ##__VA_ARGS__)

#define MAXN (200)

#define MAX_SPS_COUNT          32
#define MIN_LOG2_MAX_FRAME_NUM    4
#define MAX_LOG2_MAX_FRAME_NUM    (12 + 4)

#define FF_ARRAY_ELEMS(a) (sizeof(a) / sizeof((a)[0]))

#define EXTENDED_SAR       255

static const unsigned char default_scaling4[2][16] = {
    {  6, 13, 20, 28, 13, 20, 28, 32,
        20, 28, 32, 37, 28, 32, 37, 42 },
    { 10, 14, 20, 24, 14, 20, 24, 27,
        20, 24, 27, 30, 24, 27, 30, 34 }
};

static const unsigned char default_scaling8[2][64] = {
    {  6, 10, 13, 16, 18, 23, 25, 27,
        10, 11, 16, 18, 23, 25, 27, 29,
        13, 16, 18, 23, 25, 27, 29, 31,
        16, 18, 23, 25, 27, 29, 31, 33,
        18, 23, 25, 27, 29, 31, 33, 36,
        23, 25, 27, 29, 31, 33, 36, 38,
        25, 27, 29, 31, 33, 36, 38, 40,
        27, 29, 31, 33, 36, 38, 40, 42 },
    {  9, 13, 15, 17, 19, 21, 22, 24,
        13, 13, 17, 19, 21, 22, 24, 25,
        15, 17, 19, 21, 22, 24, 25, 27,
        17, 19, 21, 22, 24, 25, 27, 28,
        19, 21, 22, 24, 25, 27, 28, 30,
        21, 22, 24, 25, 27, 28, 30, 32,
        22, 24, 25, 27, 28, 30, 32, 33,
        24, 25, 27, 28, 30, 32, 33, 35 }
};

static const unsigned char zigzag_scan[16+1] = {
    0 + 0 * 4, 1 + 0 * 4, 0 + 1 * 4, 0 + 2 * 4,
    1 + 1 * 4, 2 + 0 * 4, 3 + 0 * 4, 2 + 1 * 4,
    1 + 2 * 4, 0 + 3 * 4, 1 + 3 * 4, 2 + 2 * 4,
    3 + 1 * 4, 3 + 2 * 4, 2 + 3 * 4, 3 + 3 * 4,
};

static const unsigned char ff_zigzag_direct[64] = {
    0,   1,  8, 16,  9,  2,  3, 10,
    17, 24, 32, 25, 18, 11,  4,  5,
    12, 19, 26, 33, 40, 48, 41, 34,
    27, 20, 13,  6,  7, 14, 21, 28,
    35, 42, 49, 56, 57, 50, 43, 36,
    29, 22, 15, 23, 30, 37, 44, 51,
    58, 59, 52, 45, 38, 31, 39, 46,
    53, 60, 61, 54, 47, 55, 62, 63
};


static unsigned int Ue(unsigned char *pBuff, unsigned int nLen, unsigned int *nStartBit)
{
    unsigned int nZeroNum = 0;
    while (*nStartBit < nLen * 8)
    {
        if (pBuff[*nStartBit / 8] & (0x80 >> (*nStartBit % 8)))
        {
            break;
        }
        nZeroNum++;
        (*nStartBit)++;
    }
    (*nStartBit)++;
    
    unsigned long dwRet = 0;
    unsigned int i;
    for (i=0; i<nZeroNum; i++)
    {
        dwRet <<= 1;
        if (pBuff[*nStartBit / 8] & (0x80 >> (*nStartBit % 8)))
        {
            dwRet += 1;
        }
        (*nStartBit)++;
    }
    
    return (unsigned int)((1 << nZeroNum) - 1 + dwRet);
}


static int Se(unsigned char *pBuff, unsigned int nLen, unsigned int *nStartBit)
{
    int UeVal=Ue(pBuff,nLen,nStartBit);
    double k=UeVal;
    int nValue=ceil(k/2);
    if (UeVal % 2==0)
    {
        nValue=-nValue;
    }
    
    return nValue;
}


static unsigned long u(unsigned int BitCount,unsigned char * buf,unsigned int *nStartBit)
{
    unsigned long dwRet = 0;
    unsigned int i;
    for (i=0; i<BitCount; i++)
    {
        dwRet <<= 1;
        if (buf[*nStartBit / 8] & (0x80 >> (*nStartBit % 8)))
        {
            dwRet += 1;
        }
        (*nStartBit)++;
    }
    return dwRet;
}

#pragma mark frame

static void decode_scaling_list(
                                unsigned char * buf,
                                unsigned int nLen,
                                unsigned int *StartBit,
                                unsigned char *factors,
                                int size,
                                const unsigned char *jvt_list,
                                const unsigned char *fallback_list)
{
    int i, last = 8, next = 8;
    const unsigned char *scan = size == 16 ? zigzag_scan : ff_zigzag_direct;
    if (!u(1,buf,StartBit))
    {
        /* matrix not written, we use the predicted one */
        memcpy(factors, fallback_list, size * sizeof(unsigned char));
    }
    else
    {
        for (i = 0; i < size; i++)
        {
            if (next)
            {
                next = (last + Se(buf,nLen,StartBit)) & 0xff;
            }
            if (!i && !next)
            {
                /* matrix not written, we use the preset one */
                memcpy(factors, jvt_list, size * sizeof(unsigned char));
                break;
            }
            last = factors[scan[i]] = next ? next : last;
        }
    }
}


int h264_decode_seq_parameter_set_out(IN unsigned char * buf,
                                      IN unsigned int nLen,
                                      OUT int * out_width,
                                      OUT int * out_height,
                                      OUT int *framerate,
                                      OUT VCH264SPS* out_sps)
{
    unsigned int StartBit=0;
    int profile_idc, level_idc, constraint_set_flags = 0;
    unsigned int sps_id;
    int i, log2_max_frame_num_minus4;
    VCH264SPS    tSPS;
    VCH264SPS    *sps=&tSPS;
    
    //skip 0x67
    u(8,buf,&StartBit);
    
    profile_idc           = (int)u(8,buf,&StartBit);
    constraint_set_flags |= u(1,buf,&StartBit) << 0;   // constraint_set0_flag
    constraint_set_flags |= u(1,buf,&StartBit) << 1;   // constraint_set1_flag
    constraint_set_flags |= u(1,buf,&StartBit) << 2;   // constraint_set2_flag
    constraint_set_flags |= u(1,buf,&StartBit) << 3;   // constraint_set3_flag
    constraint_set_flags |= u(1,buf,&StartBit) << 4;   // constraint_set4_flag
    constraint_set_flags |= u(1,buf,&StartBit) << 5;   // constraint_set5_flag
    u(2,buf,&StartBit);
    level_idc = (int)u(8,buf,&StartBit);
    sps_id    = Ue(buf,nLen,&StartBit);
    if (sps_id >= MAX_SPS_COUNT)
    {
        printf("sps_id error\n");
        return -1;
    }
    
    sps->sps_id               = sps_id;
    sps->time_offset_length   = 24;
    sps->profile_idc          = profile_idc;
    sps->constraint_set_flags = constraint_set_flags;
    sps->level_idc            = level_idc;
    sps->full_range           = -1;
    memset(sps->scaling_matrix4, 16, sizeof(sps->scaling_matrix4));
    memset((void *)sps->scaling_matrix8, 16, sizeof(sps->scaling_matrix8));
    sps->scaling_matrix_present = 0;
    sps->colorspace = 2; //AVCOL_SPC_UNSPECIFIED;
    
    if ( (sps->profile_idc == 100)
        || (sps->profile_idc == 110)
        || (sps->profile_idc == 122)
        || (sps->profile_idc == 244)
        || (sps->profile_idc ==  44)
        || (sps->profile_idc ==  83)
        || (sps->profile_idc ==  86)
        || (sps->profile_idc == 118)
        || (sps->profile_idc == 128)
        || (sps->profile_idc == 144) )
    {
        sps->chroma_format_idc = Ue(buf,nLen,&StartBit);
        if (sps->chroma_format_idc > 3U)
        {
            printf("chroma_format_idc error\n");
            return -1;
        }
        else if (sps->chroma_format_idc == 3)
        {
            sps->residual_color_transform_flag = (int)u(1,buf,&StartBit);
            if (sps->residual_color_transform_flag)
            {
                printf("residual_color_transform_flag error\n");
                return -1;
            }
        }
        sps->bit_depth_luma   = Ue(buf,nLen,&StartBit) + 8;
        sps->bit_depth_chroma = Ue(buf,nLen,&StartBit) + 8;
        if (sps->bit_depth_chroma != sps->bit_depth_luma)
        {
            printf("bit_depth_chroma1 error\n");
            return -1;
        }
        if (sps->bit_depth_luma > 14U || sps->bit_depth_chroma > 14U)
        {
            printf("bit_depth_chroma2 error\n");
            return -1;
        }
        sps->transform_bypass = (int)u(1,buf,&StartBit);
        
        int is_sps=1;
        int fallback_sps = !is_sps && sps->scaling_matrix_present;
        const unsigned char *fallback[4] =
        {
            fallback_sps ? sps->scaling_matrix4[0] : default_scaling4[0],
            fallback_sps ? sps->scaling_matrix4[3] : default_scaling4[1],
            fallback_sps ? sps->scaling_matrix8[0] : default_scaling8[0],
            fallback_sps ? sps->scaling_matrix8[3] : default_scaling8[1]
        };
        
        if ( u(1,buf,&StartBit) )
        {
            sps->scaling_matrix_present |= is_sps;
            decode_scaling_list(buf, nLen, &StartBit, sps->scaling_matrix4[0], 16, default_scaling4[0], fallback[0]);        // Intra, Y
            decode_scaling_list(buf, nLen, &StartBit, sps->scaling_matrix4[1], 16, default_scaling4[0], sps->scaling_matrix4[0]); // Intra, Cr
            decode_scaling_list(buf, nLen, &StartBit, sps->scaling_matrix4[2], 16, default_scaling4[0], sps->scaling_matrix4[1]); // Intra, Cb
            decode_scaling_list(buf, nLen, &StartBit, sps->scaling_matrix4[3], 16, default_scaling4[1], fallback[1]);        // Inter, Y
            decode_scaling_list(buf, nLen, &StartBit, sps->scaling_matrix4[4], 16, default_scaling4[1], sps->scaling_matrix4[3]); // Inter, Cr
            decode_scaling_list(buf, nLen, &StartBit, sps->scaling_matrix4[5], 16, default_scaling4[1], sps->scaling_matrix4[4]); // Inter, Cb
            if (is_sps)
            {
                decode_scaling_list(buf, nLen, &StartBit, sps->scaling_matrix8[0], 64, default_scaling8[0], fallback[2]); // Intra, Y
                decode_scaling_list(buf, nLen, &StartBit, sps->scaling_matrix8[3], 64, default_scaling8[1], fallback[3]); // Inter, Y
                if (sps->chroma_format_idc == 3)
                {
                    decode_scaling_list(buf, nLen, &StartBit, sps->scaling_matrix8[1], 64, default_scaling8[0], sps->scaling_matrix8[0]); // Intra, Cr
                    decode_scaling_list(buf, nLen, &StartBit, sps->scaling_matrix8[4], 64, default_scaling8[1], sps->scaling_matrix8[3]); // Inter, Cr
                    decode_scaling_list(buf, nLen, &StartBit, sps->scaling_matrix8[2], 64, default_scaling8[0], sps->scaling_matrix8[1]); // Intra, Cb
                    decode_scaling_list(buf, nLen, &StartBit, sps->scaling_matrix8[5], 64, default_scaling8[1], sps->scaling_matrix8[4]); // Inter, Cb
                }
            }
        }
    }
    else
    {
        sps->chroma_format_idc = 1;
        sps->bit_depth_luma    = 8;
        sps->bit_depth_chroma  = 8;
    }
    
    log2_max_frame_num_minus4 = Ue(buf,nLen,&StartBit);
    if ( (log2_max_frame_num_minus4 < MIN_LOG2_MAX_FRAME_NUM - 4)
        ||(log2_max_frame_num_minus4 > MAX_LOG2_MAX_FRAME_NUM - 4) )
    {
        printf("log2_max_frame_num_minus4 error\n");
        return -1;
    }
    sps->log2_max_frame_num = log2_max_frame_num_minus4 + 4;
    
    sps->poc_type = Ue(buf,nLen,&StartBit);
    
    if (sps->poc_type == 0)
    {
        // FIXME #define
        unsigned t = Ue(buf,nLen,&StartBit);
        if (t>12)
        {
            printf("t error\n");
            return -1;
        }
        sps->log2_max_poc_lsb = t + 4;
    }
    else if (sps->poc_type == 1)
    {
        // FIXME #define
        sps->delta_pic_order_always_zero_flag = (int)u(1,buf,&StartBit);
        sps->offset_for_non_ref_pic           = Se(buf,nLen,&StartBit);
        sps->offset_for_top_to_bottom_field   = Se(buf,nLen,&StartBit);
        sps->poc_cycle_length                 = Ue(buf,nLen,&StartBit);
        
        if ((unsigned)sps->poc_cycle_length >=FF_ARRAY_ELEMS(sps->offset_for_ref_frame))
        {
            printf("poc_cycle_length error\n");
            return -1;
        }
        
        for (i = 0; i < sps->poc_cycle_length; i++)
        {
            sps->offset_for_ref_frame[i] = Se(buf,nLen,&StartBit);
        }
        
    }
    else if (sps->poc_type != 2)
    {
        printf("poc_type error\n");
        return -1;
    }
    
    sps->ref_frame_count = Ue(buf,nLen,&StartBit);
    sps->gaps_in_frame_num_allowed_flag = (int)u(1,buf,&StartBit);
    sps->mb_width                       = Ue(buf,nLen,&StartBit);
    sps->mb_height                      = Ue(buf,nLen,&StartBit);
    
    *out_width=(sps->mb_width+1)*16;
    *out_height=(sps->mb_height+1)*16;
    
    sps->frame_mbs_only_flag = (int)u(1,buf,&StartBit);
    if (!sps->frame_mbs_only_flag)
    {
        sps->mb_aff = (int)u(1,buf,&StartBit);
    }
    
    sps->direct_8x8_inference_flag = (int)u(1,buf,&StartBit);
    
    sps->crop = (int)u(1,buf,&StartBit);
    if (sps->crop)
    {
        //crop_left
        Ue(buf,nLen,&StartBit);
        //crop_right
        Ue(buf,nLen,&StartBit);
        //crop_top
        Ue(buf,nLen,&StartBit);
        //crop_bottom
        Ue(buf,nLen,&StartBit);
    }
    
    sps->vui_parameters_present_flag = (int)u(1,buf,&StartBit);
    if (sps->vui_parameters_present_flag)
    {
        int aspect_ratio_info_present_flag;
        unsigned int aspect_ratio_idc;
        
        aspect_ratio_info_present_flag = (int)u(1,buf,&StartBit);
        
        if (aspect_ratio_info_present_flag)
        {
            aspect_ratio_idc = (int)u(8,buf,&StartBit);
            if (aspect_ratio_idc == EXTENDED_SAR)
            {
                sps->sar.num = (int)u(16,buf,&StartBit);
                sps->sar.den = (int)u(16,buf,&StartBit);
            }
        }
        
        if (u(1,buf,&StartBit))
        {
            u(1,buf,&StartBit);
        }
        
        sps->video_signal_type_present_flag = (int)u(1,buf,&StartBit);
        if (sps->video_signal_type_present_flag)
        {
            u(3,buf,&StartBit);                 /* video_format */
            sps->full_range = (int)u(1,buf,&StartBit); /* video_full_range_flag */
            
            sps->colour_description_present_flag = (int)u(1,buf,&StartBit);
            if (sps->colour_description_present_flag)
            {
                sps->color_primaries = (int)u(8,buf,&StartBit); /* colour_primaries */
                sps->color_trc       = (int)u(8,buf,&StartBit); /* transfer_characteristics */
                sps->colorspace      = (int)u(8,buf,&StartBit); /* matrix_coefficients */
            }
        }
        
        /* chroma_location_info_present_flag */
        if (u(1,buf,&StartBit))
        {
            /* chroma_sample_location_type_top_field */
            Ue(buf,nLen,&StartBit);
            Ue(buf,nLen,&StartBit);
        }
        
        sps->timing_info_present_flag = (int)u(1,buf,&StartBit);
        if (sps->timing_info_present_flag)
        {
            sps->num_units_in_tick = (int)u(32,buf,&StartBit);
            sps->time_scale        = (int)u(32,buf,&StartBit);
            sps->fixed_frame_rate_flag = (int)u(1,buf,&StartBit);
            /**
             *  Identification codeing: time_scale == 6001 -> Smooth mode
             */
            if (sps->time_scale & 0x01) {
                sps->time_scale -= 1;
            }
            
            if (sps->time_scale==120000 ) {
                *framerate = 60;
            }
            else if ( sps->time_scale==60000 )
            {
                *framerate = 30;
            }
            else if ( sps->time_scale==50000 )
            {
                *framerate = 25;
            }
            else if ( sps->time_scale==40000 )
            {
                *framerate = 20;
            }
            else{
                //dafeult to 30
                *framerate = 30;
            }
        }
        else
        {
            *framerate = 30;
        }
        
        
    }
    
    if (out_sps) {
        //copy out
        *out_sps = *sps;
    }
    return 0;
}
#pragma mark - slice header decode

#define MAX_SPS_COUNT          32
#define MAX_PPS_COUNT         256


static const uint8_t golomb_to_pict_type[5] = {
    2, 3, 1,
    6, 5
};

int h264_parse_slice_header2(uint8_t * buf, int nLen, int * sliceType, int * mbLocation, int * frameNum, int log2_max_frame_num)
{
    int i=0, nStartBits=0;
    int pps_id;
    while(1)
    {
        if(i+3>=nLen)//out of boundary
            break;
        if(buf[i]==0 && buf[i+1]==0 && buf[i+2]==1 &&( (buf[i+3]&0x1f)==0x1 ||(buf[i+3]&0x1f)==0x5))
        {
            buf+=i+4;
            nLen-=i+4;
            break;
        }
        i++;
    }
    
    *mbLocation = Ue(buf, nLen, (unsigned int*)&nStartBits);
    *sliceType = Ue(buf, nLen, (unsigned int*)&nStartBits);
    pps_id = Ue(buf, nLen, (unsigned int*)&nStartBits);
    *frameNum = (int)u(log2_max_frame_num, buf, (unsigned int*)&nStartBits);
    return nStartBits+(i+4)*8;
    //        fprintf(stdout, "got new slice: #%d, sliceType: %d\n", *mbLocation, *sliceType);
}


int h264_decode_slice_header(IN unsigned char * buf,
                             IN unsigned int nLen,
                             OUT VCH264SPS *out_sps,
                             OUT VCH264SliceHeaderSimpleInfo* out_info)
{
    //reader count
    unsigned int StartBit=0;
    if (!out_sps) {
        return -1;
    }
    
    unsigned int first_mb_in_slice;
    unsigned int pps_id;
    unsigned int slice_type;
    first_mb_in_slice = Ue(buf, nLen, &StartBit);
    
    slice_type = Ue(buf, nLen, &StartBit);
    if (slice_type > 9) {
        INFO(@"slice type too large (%d)", slice_type);
        return -1;
    }
    
    int slice_type_fixed = 0;
    if (slice_type > 4) {
        slice_type -= 5;
        slice_type_fixed = 1;
    } else
        slice_type_fixed = 0;
    
    slice_type = golomb_to_pict_type[slice_type];
    pps_id = Ue(buf,nLen,&StartBit);
    
    if (pps_id >= MAX_PPS_COUNT) {
        INFO(@"pps_id %d out of range\n", pps_id);
        return -1;
    }
    int frame_num = (int)u(out_sps->log2_max_frame_num, buf, &StartBit);
    
    //we just need frame_num, first_mb_in_slice, slice_type;
    if (out_info) {
        out_info->first_mb_in_slice = first_mb_in_slice;
        out_info->slice_type = slice_type;
        out_info->frame_num = frame_num;
    }
    return 0;
}

@implementation VCH264SPSFrame
@synthesize sps = _sps;
@synthesize fps = _fps;
@synthesize outputHeight = _outputHeight;
@synthesize outputWidth = _outputWidth;

- (instancetype)init {
    self = [super init];
    if (self) {
        _sps = NULL;
        _outputHeight = 0;
        _outputWidth = 0;
        _fps = 0;
    }
    return self;
}

- (VCH264SPS *)sps {
    if (_sps != NULL) {
        return _sps;
    }
    
    // init sps
    _sps = (VCH264SPS *)malloc(sizeof(VCH264SPS));
    memset(_sps, 0, sizeof(VCH264SPS));
    
    int outputWidth = 0;
    int outputHeight = 0;
    int outputFramerate = 0;
    
    int ret = h264_decode_seq_parameter_set_out(self.parseData + self.startCodeSize,
                                                (int)self.parseSize - self.startCodeSize,
                                                &outputWidth,
                                                &outputHeight,
                                                &outputFramerate,
                                                _sps);
    if (ret != 0) {
        memset(_sps, 0, sizeof(VCH264SPS));
    }
    
    _fps = outputFramerate;
    _outputWidth = outputWidth;
    _outputHeight = outputHeight;
    
    return _sps;
}

- (NSInteger)fps {
    if (_sps == NULL) {
        [self sps];
    }
    return _fps;
}

- (NSInteger)outputWidth {
    if (_sps == NULL) {
        [self sps];
    }
    return _outputWidth;
}

- (NSInteger)outputHeight {
    if (_sps == NULL) {
        [self sps];
    }
    return _outputHeight;
}


- (void)dealloc {
    if (_sps != NULL) {
        free(_sps);
        _sps = NULL;
    }
}
@end
