﻿#if !defined(RANDOM)
#define RANDOM

float2 _Pixel;
float _Seed = 78;

float rand()
{
    float result = frac(sin(_Seed / 100.0f * dot(_Pixel, float2(12.9898f, 78.233f))) * 43758.5453f);
    _Seed += 1.0f;
    return result;
}
#endif