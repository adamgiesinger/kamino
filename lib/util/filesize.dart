/*

Copyright (c) 2012 erdbeerschnitzel, All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/
library filesize;

/// Method returns a human readable string representing a file size.
///
/// size can be passed as number or as string
///
/// the optional parameter 'count' specifies the number of numbers after comma/point (default is 2)
///
/// the optional boolean parameter 'decimal' specifies if the decimal system should be used, e.g. 1KB = 1000B (default is false)
String formatFilesize(size, {int round = 2, bool decimal = false}){

  int divider = 1024;

  size = int.parse(size.toString());

  if(decimal) divider = 1000;

  if(size < divider) return "$size B";

  if(size < divider*divider && size % divider == 0) return "${(size/divider).toStringAsFixed(0)} KB";

  if(size < divider*divider) return "${(size/divider).toStringAsFixed(round)} KB";

  if(size < divider*divider*divider && size % divider == 0) return "${(size/(divider*divider)).toStringAsFixed(0)} MB";

  if(size < divider*divider*divider) return "${(size/divider/divider).toStringAsFixed(round)} MB";

  if(size < divider*divider*divider*divider && size % divider == 0) return "${(size/(divider*divider*divider)).toStringAsFixed(0)} GB";

  if(size < divider*divider*divider*divider) return "${(size/divider/divider/divider).toStringAsFixed(1)} GB";

  if(size < divider*divider*divider*divider*divider && size % divider == 0)  return "${(size/divider/divider/divider/divider).toStringAsFixed(0)} TB" ;

  if(size < divider*divider*divider*divider*divider)  return "${(size/divider/divider/divider/divider).toStringAsFixed(2)} TB" ;

  if(size < divider*divider*divider*divider*divider*divider && size % divider == 0) {  return "${(size/divider/divider/divider/divider/divider).toStringAsFixed(0)} PB" ;

  } else { return "${(size/divider/divider/divider/divider/divider).toStringAsFixed(3)} PB";
  }

}