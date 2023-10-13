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

import 'package:blend_composites/blend_composites.dart';

///
/// @author William Shakour (billy1380)
///
abstract class BlendCompositeBase {
  double protectedAlpha;
  final BlendingMode protectedMode;

  BlendCompositeBase deriveFromMode(BlendingMode mode);

  BlendCompositeBase deriveFromAlpha(double alpha);

  BlendCompositeBase(
    this.protectedMode, [
    this.protectedAlpha = 1,
  ]);

  double get alpha {
    return protectedAlpha;
  }

  BlendingMode get mode {
    return protectedMode;
  }

  set alpha(double alpha) {
    if (alpha < 0.0 || alpha > 1.0) {
      throw Exception(
          "IllegalArgument: alpha must be comprised between 0.0 and 1.0");
    }

    protectedAlpha = alpha;
  }

  @override
  int get hashCode {
    return protectedAlpha.toInt() * 31 + protectedMode.index;
  }

  @override
  bool operator ==(Object other) {
    if (other is! BlendCompositeBase) {
      return false;
    }

    BlendCompositeBase bc = other;

    if (protectedMode != bc.protectedMode) {
      return false;
    }

    return protectedAlpha == bc.protectedAlpha;
  }
}
