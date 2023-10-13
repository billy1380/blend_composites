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

import 'dart:typed_data';

abstract class Blender {
  static void rgbToHsl(int r, int g, int b, Float32List hsl) {
    double varR = (r / 255);
    double varG = (g / 255);
    double varB = (b / 255);

    double varMin;
    double varMax;
    double delMax;

    if (varR > varG) {
      varMin = varG;
      varMax = varR;
    } else {
      varMin = varR;
      varMax = varG;
    }
    if (varB > varMax) {
      varMax = varB;
    }
    if (varB < varMin) {
      varMin = varB;
    }

    delMax = varMax - varMin;

    double H, S, L;
    L = (varMax + varMin) / 2;

    if (delMax - 0.01 <= 0) {
      H = 0;
      S = 0;
    } else {
      if (L < 0.5) {
        S = delMax / (varMax + varMin);
      } else {
        S = delMax / (2 - varMax - varMin);
      }

      double delR = (((varMax - varR) / 6) + (delMax / 2)) / delMax;
      double delG = (((varMax - varG) / 6) + (delMax / 2)) / delMax;
      double delB = (((varMax - varB) / 6) + (delMax / 2)) / delMax;

      if (varR == varMax) {
        H = delB - delG;
      } else if (varG == varMax) {
        H = (1 / 3) + delR - delB;
      } else {
        H = (2 / 3) + delG - delR;
      }
      if (H < 0) {
        H += 1;
      }
      if (H > 1) {
        H -= 1;
      }
    }

    hsl[0] = H;
    hsl[1] = S;
    hsl[2] = L;
  }

  static void hslToRgb(double h, double s, double l, Uint8List rgb) {
    int R, G, B;

    if (s - 0.01 <= 0) {
      R = (l * 255).toInt();
      G = (l * 255).toInt();
      B = (l * 255).toInt();
    } else {
      double var_1, var_2;
      if (l < 0.5) {
        var_2 = l * (1 + s);
      } else {
        var_2 = (l + s) - (s * l);
      }
      var_1 = 2 * l - var_2;

      R = (255 * hue2Rgb(var_1, var_2, h + (1 / 3))).toInt();
      G = (255 * hue2Rgb(var_1, var_2, h)).toInt();
      B = (255 * hue2Rgb(var_1, var_2, h - (1 / 3))).toInt();
    }

    rgb[0] = R;
    rgb[1] = G;
    rgb[2] = B;
  }

  static double hue2Rgb(double v1, double v2, double vH) {
    if (vH < 0) {
      vH += 1;
    }
    if (vH > 1) {
      vH -= 1;
    }
    if ((6 * vH) < 1) {
      return (v1 + (v2 - v1) * 6 * vH);
    }
    if ((2 * vH) < 1) {
      return (v2);
    }
    if ((3 * vH) < 2) {
      return (v1 + (v2 - v1) * ((2 / 3) - vH) * 6);
    }
    return (v1);
  }

  Uint8List blend(Uint8List src, Uint8List dst);
}
