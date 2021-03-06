/*
 *
 * This source code is available under the "Simplified BSD license".
 *
 * Copyright (c) 2013, J. Kleiner
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, 
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright 
 *    notice, this list of conditions and the following disclaimer in the 
 *    documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the original author nor the names of its contributors 
 *    may be used to endorse or promote products derived from this software 
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY 
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */
#ifndef __SI_CAL_H__
#define __SI_CAL_H__

#include "SiCal.h"

class SiCal {

  private:

    /** Power spectrum estimate to dBm conversion */
    double mAdCalFig;

    /** FE gain conversion */
    double mFeCalFig;

    /** IF gain conversion */
#   define RF_CAL_MAX_IFGAINS 4
    double mIfCalFig[RF_CAL_MAX_IFGAINS];

    /** Down conversion calibration figures */
#   define RF_CAL_MAX_CNV 3
    double mCnvCalFig[RF_CAL_MAX_CNV];

    /** RF input indepdendent calibration figure */
    double mCfgCalFig;

#   define RF_CALBINS_10MHZ 440
    double m10MHzCalFig[ RF_CALBINS_10MHZ ];

    /** String capturing reference level in effect */
    const char *mCalRefStr;

    /** Last bin there is an actual rf cal reference data point for */
    int mLastRefBin;

  public:

    SiCal();
    const char *CalConfigure( int nConversion, int ifGn, double feGain );
    double      CalGet( double fHz );
    int         CalSave( const char *fname );

    void        CalSetAdc(  double dv );
    void        CalSetIf(   int gn, double dv );
    void        CalSetCnv(  int cn, double dv );
    void        CalSetVarReset();
    void        CalSetVarRef( double fMHz, int db );
};

#endif
