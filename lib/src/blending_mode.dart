/*
 * Copyright (c) 2006 Romain Guy <romain.guy@mac.com>
 * Copyright © 2017 WillShex Limited.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import 'dart:math';
import 'dart:typed_data';

import 'package:blend_composites/src/blender.dart';

class _NormalBlender implements Blender {
  const _NormalBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => src;
}

class _AverageBlender implements Blender {
  const _AverageBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        (src[0] + dst[0]) >> 1,
        (src[1] + dst[1]) >> 1,
        (src[2] + dst[2]) >> 1,
        min(255, src[3] + dst[3]),
      ]);
}

class _MultiplyBlender implements Blender {
  const _MultiplyBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        (src[0] * dst[0]) >> 8,
        (src[1] * dst[1]) >> 8,
        (src[2] * dst[2]) >> 8,
        min(255, src[3] + dst[3])
      ]);
}

class _ScreenBlender implements Blender {
  const _ScreenBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        255 - ((255 - src[0]) * (255 - dst[0]) >> 8),
        255 - ((255 - src[1]) * (255 - dst[1]) >> 8),
        255 - ((255 - src[2]) * (255 - dst[2]) >> 8),
        min(255, src[3] + dst[3])
      ]);
}

class _DarkenBlender implements Blender {
  const _DarkenBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        min(src[0], dst[0]),
        min(src[1], dst[1]),
        min(src[2], dst[2]),
        min(255, src[3] + dst[3])
      ]);
}

class _LightenBlender implements Blender {
  const _LightenBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        max(src[0], dst[0]),
        max(src[1], dst[1]),
        max(src[2], dst[2]),
        min(255, src[3] + dst[3])
      ]);
}

class _OverlayBlender implements Blender {
  const _OverlayBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        dst[0] < 128
            ? dst[0] * src[0] >> 7
            : 255 - ((255 - dst[0]) * (255 - src[0]) >> 7),
        dst[1] < 128
            ? dst[1] * src[1] >> 7
            : 255 - ((255 - dst[1]) * (255 - src[1]) >> 7),
        dst[2] < 128
            ? dst[2] * src[2] >> 7
            : 255 - ((255 - dst[2]) * (255 - src[2]) >> 7),
        min(255, src[3] + dst[3])
      ]);
}

class _HardLightBlender implements Blender {
  const _HardLightBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        src[0] < 128
            ? dst[0] * src[0] >> 7
            : 255 - ((255 - src[0]) * (255 - dst[0]) >> 7),
        src[1] < 128
            ? dst[1] * src[1] >> 7
            : 255 - ((255 - src[1]) * (255 - dst[1]) >> 7),
        src[2] < 128
            ? dst[2] * src[2] >> 7
            : 255 - ((255 - src[2]) * (255 - dst[2]) >> 7),
        min(255, src[3] + dst[3]),
      ]);
}

class _SoftLightBlender implements Blender {
  const _SoftLightBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) =>
      throw Exception("IllegalArgument: Blender not implemented for SoftLight");
}

class _DifferenceBlender implements Blender {
  const _DifferenceBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        (dst[0] - src[0]).abs(),
        (dst[1] - src[1]).abs(),
        (dst[2] - src[2]).abs(),
        min(255, src[3] + dst[3])
      ]);
}

class _NegationBlender implements Blender {
  const _NegationBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        255 - (255 - dst[0] - src[0]).abs(),
        255 - (255 - dst[1] - src[1]).abs(),
        255 - (255 - dst[2] - src[2]).abs(),
        min(255, src[3] + dst[3])
      ]);
}

class _ExclusionBlender implements Blender {
  const _ExclusionBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        dst[0] + src[0] - (dst[0] * src[0] >> 7),
        dst[1] + src[1] - (dst[1] * src[1] >> 7),
        dst[2] + src[2] - (dst[2] * src[2] >> 7),
        min(255, src[3] + dst[3])
      ]);
}

class _ColorDodgeBlender implements Blender {
  const _ColorDodgeBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        src[0] == 255 ? 255 : min((dst[0] << 8) ~/ (255 - src[0]), 255),
        src[1] == 255 ? 255 : min((dst[1] << 8) ~/ (255 - src[1]), 255),
        src[2] == 255 ? 255 : min((dst[2] << 8) ~/ (255 - src[2]), 255),
        min(255, src[3] + dst[3])
      ]);
}

class _InverseColorDodgeBlender implements Blender {
  const _InverseColorDodgeBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        dst[0] == 255 ? 255 : min((src[0] << 8) ~/ (255 - dst[0]), 255),
        dst[1] == 255 ? 255 : min((src[1] << 8) ~/ (255 - dst[1]), 255),
        dst[2] == 255 ? 255 : min((src[2] << 8) ~/ (255 - dst[2]), 255),
        min(255, src[3] + dst[3])
      ]);
}

class _SoftDodgeBlender implements Blender {
  const _SoftDodgeBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        dst[0] + src[0] < 256
            ? (src[0] == 255 ? 255 : min(255, (dst[0] << 7) ~/ (255 - src[0])))
            : max(0, (255 - (((255 - src[0]) << 7) / dst[0]))).toInt(),
        dst[1] + src[1] < 256
            ? (src[1] == 255 ? 255 : min(255, (dst[1] << 7) ~/ (255 - src[1])))
            : max(0, (255 - (((255 - src[1]) << 7) / dst[1]))).toInt(),
        dst[2] + src[2] < 256
            ? (src[2] == 255 ? 255 : min(255, (dst[2] << 7) ~/ (255 - src[2])))
            : max(0, (255 - (((255 - src[2]) << 7) / dst[2]))).toInt(),
        min(255, src[3] + dst[3])
      ]);
}

class _ColorBurnBlender implements Blender {
  const _ColorBurnBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        src[0] == 0
            ? 0
            : max(0, (255 - (((255 - dst[0]) << 8) / src[0])).toInt()),
        src[1] == 0
            ? 0
            : max(0, (255 - (((255 - dst[1]) << 8) / src[1])).toInt()),
        src[2] == 0
            ? 0
            : max(0, (255 - (((255 - dst[2]) << 8) / src[2])).toInt()),
        min(255, src[3] + dst[3])
      ]);
}

class _InverseColorBurnBlender implements Blender {
  const _InverseColorBurnBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        dst[0] == 0
            ? 0
            : max(0, (255 - (((255 - src[0]) << 8) / dst[0]))).toInt(),
        dst[1] == 0
            ? 0
            : max(0, (255 - (((255 - src[1]) << 8) / dst[1]))).toInt(),
        dst[2] == 0
            ? 0
            : max(0, (255 - (((255 - src[2]) << 8) / dst[2]))).toInt(),
        min(255, src[3] + dst[3])
      ]);
}

class _SoftBurnBlender implements Blender {
  const _SoftBurnBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        dst[0] + src[0] < 256
            ? (dst[0] == 255 ? 255 : min(255, (src[0] << 7) ~/ (255 - dst[0])))
            : max(0, (255 - (((255 - dst[0]) << 7) / src[0]))).toInt(),
        dst[1] + src[1] < 256
            ? (dst[1] == 255 ? 255 : min(255, (src[1] << 7) ~/ (255 - dst[1])))
            : max(0, (255 - (((255 - dst[1]) << 7) / src[1]))).toInt(),
        dst[2] + src[2] < 256
            ? (dst[2] == 255 ? 255 : min(255, (src[2] << 7) ~/ (255 - dst[2])))
            : max(0, (255 - (((255 - dst[2]) << 7) / src[2]))).toInt(),
        min(255, src[3] + dst[3])
      ]);
}

class _ReflectBlender implements Blender {
  const _ReflectBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        src[0] == 255
            ? 255
            : min(255, (dst[0] * dst[0] / (255 - src[0]))).toInt(),
        src[1] == 255
            ? 255
            : min(255, (dst[1] * dst[1] / (255 - src[1]))).toInt(),
        src[2] == 255
            ? 255
            : min(255, (dst[2] * dst[2] / (255 - src[2]))).toInt(),
        min(255, src[3] + dst[3])
      ]);
}

class _GlowBlender implements Blender {
  const _GlowBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        dst[0] == 255
            ? 255
            : min(255, (src[0] * src[0] / (255 - dst[0]))).toInt(),
        dst[1] == 255
            ? 255
            : min(255, (src[1] * src[1] / (255 - dst[1]))).toInt(),
        dst[2] == 255
            ? 255
            : min(255, (src[2] * src[2] / (255 - dst[2]))).toInt(),
        min(255, src[3] + dst[3])
      ]);
}

class _FreezeBlender implements Blender {
  const _FreezeBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        src[0] == 0
            ? 0
            : max(0, (255 - (255 - dst[0]) * (255 - dst[0]) / src[0])).toInt(),
        src[1] == 0
            ? 0
            : max(0, (255 - (255 - dst[1]) * (255 - dst[1]) / src[1])).toInt(),
        src[2] == 0
            ? 0
            : max(0, (255 - (255 - dst[2]) * (255 - dst[2]) / src[2])).toInt(),
        min(255, src[3] + dst[3])
      ]);
}

class _HeatBlender implements Blender {
  const _HeatBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        dst[0] == 0
            ? 0
            : max(0, (255 - (255 - src[0]) * (255 - src[0]) / dst[0])).toInt(),
        dst[1] == 0
            ? 0
            : max(0, (255 - (255 - src[1]) * (255 - src[1]) / dst[1])).toInt(),
        dst[2] == 0
            ? 0
            : max(0, (255 - (255 - src[2]) * (255 - src[2]) / dst[2])).toInt(),
        min(255, src[3] + dst[3])
      ]);
}

class _AddBlender implements Blender {
  const _AddBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        min(255, src[0] + dst[0]),
        min(255, src[1] + dst[1]),
        min(255, src[2] + dst[2]),
        min(255, src[3] + dst[3])
      ]);
}

class _SubtractBlender implements Blender {
  const _SubtractBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        max(0, src[0] + dst[0] - 256),
        max(0, src[1] + dst[1] - 256),
        max(0, src[2] + dst[2] - 256),
        min(255, src[3] + dst[3])
      ]);
}

class _StampBlender implements Blender {
  const _StampBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        max(0, min(255, dst[0] + 2 * src[0] - 256)),
        max(0, min(255, dst[1] + 2 * src[1] - 256)),
        max(0, min(255, dst[2] + 2 * src[2] - 256)),
        min(255, src[3] + dst[3])
      ]);
}

class _RedBlender implements Blender {
  const _RedBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        src[0],
        dst[1],
        dst[2],
        min(255, src[3] + dst[3]),
      ]);
}

class _GreenBlender implements Blender {
  const _GreenBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        dst[0],
        dst[1],
        src[2],
        min(255, src[3] + dst[3]),
      ]);
}

class _BlueBlender implements Blender {
  const _BlueBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => Uint8List.fromList(<int>[
        dst[0],
        src[1],
        dst[2],
        min(255, src[3] + dst[3]),
      ]);
}

class _HueBlender implements Blender {
  const _HueBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) {
    Float32List srcHsl = Float32List(3);
    Blender.rgbToHsl(src[0], src[1], src[2], srcHsl);
    Float32List dstHsl = Float32List(3);
    Blender.rgbToHsl(dst[0], dst[1], dst[2], dstHsl);

    Uint8List result = Uint8List(4);
    Blender.hslToRgb(srcHsl[0], dstHsl[1], dstHsl[2], result);
    result[3] = min(255, src[3] + dst[3]);

    return result;
  }
}

class _SaturationBlender implements Blender {
  const _SaturationBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) {
    Float32List srcHsl = Float32List(3);
    Blender.rgbToHsl(src[0], src[1], src[2], srcHsl);
    Float32List dstHsl = Float32List(3);
    Blender.rgbToHsl(dst[0], dst[1], dst[2], dstHsl);

    Uint8List result = Uint8List(4);
    Blender.hslToRgb(dstHsl[0], srcHsl[1], dstHsl[2], result);
    result[3] = min(255, src[3] + dst[3]);

    return result;
  }
}

class _ColorBlender implements Blender {
  const _ColorBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) {
    Float32List srcHsl = Float32List(3);
    Blender.rgbToHsl(src[0], src[1], src[2], srcHsl);
    Float32List dstHsl = Float32List(3);
    Blender.rgbToHsl(dst[0], dst[1], dst[2], dstHsl);

    Uint8List result = Uint8List(4);
    Blender.hslToRgb(srcHsl[0], srcHsl[1], dstHsl[2], result);
    result[3] = min(255, src[3] + dst[3]);

    return result;
  }
}

class _LuminosityBlender implements Blender {
  const _LuminosityBlender();

  @override
  Uint8List blend(Uint8List src, Uint8List dst) {
    Float32List srcHsl = Float32List(3);
    Blender.rgbToHsl(src[0], src[1], src[2], srcHsl);
    Float32List dstHsl = Float32List(3);
    Blender.rgbToHsl(dst[0], dst[1], dst[2], dstHsl);

    Uint8List result = Uint8List(4);
    Blender.hslToRgb(dstHsl[0], dstHsl[1], srcHsl[2], result);
    result[3] = min(255, src[3] + dst[3]);

    return result;
  }
}

enum BlendingMode implements Blender {
  normal(_NormalBlender()),
  average(_AverageBlender()),
  multiply(_MultiplyBlender()),
  screen(_ScreenBlender()),
  darken(_DarkenBlender()),
  lighten(_LightenBlender()),
  overlay(_OverlayBlender()),
  hardLight(_HardLightBlender()),
  softLight(_SoftLightBlender()),
  difference(_DifferenceBlender()),
  negation(_NegationBlender()),
  exclusion(_ExclusionBlender()),
  colorDodge(_ColorDodgeBlender()),
  inverseColorDodge(_InverseColorDodgeBlender()),
  softDodge(_SoftDodgeBlender()),
  colorBurn(_ColorBurnBlender()),
  inverseColorBurn(_InverseColorBurnBlender()),
  softBurn(_SoftBurnBlender()),
  reflect(_ReflectBlender()),
  glow(_GlowBlender()),
  freeze(_FreezeBlender()),
  heat(_HeatBlender()),
  add(_AddBlender()),
  subtract(_SubtractBlender()),
  stamp(_StampBlender()),
  red(_RedBlender()),
  green(_GreenBlender()),
  blue(_BlueBlender()),
  hue(_HueBlender()),
  saturation(_SaturationBlender()),
  color(_ColorBlender()),
  luminosity(_LuminosityBlender()),
  ;

  final Blender _blender;

  const BlendingMode(this._blender);

  @override
  Uint8List blend(Uint8List src, Uint8List dst) => _blender.blend(src, dst);
}
