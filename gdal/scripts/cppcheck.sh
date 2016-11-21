#!/bin/bash
# Note: tested with cppcheck 1.72 as shipped with Ubuntu 16.04
# as well as with cppcheck 1.76.1

LOG_FILE=/tmp/cppcheck_gdal.txt
echo "" > ${LOG_FILE}
for dirname in alg port gcore ogr frmts gnm; do
    echo "Running cppcheck on $dirname... (can be long)"
    cppcheck --inline-suppr --template='{file}:{line},{severity},{id},{message}' \
        --enable=all --inconclusive --std=posix -UAFL_FRIENDLY -UANDROID \
        -UCOMPAT_WITH_ICC_CONVERSION_CHECK -DDEBUG -UDEBUG_BOOL -DHAVE_CXX11=1 \
        -DGBool=int -DHAVE_GEOS -DHAVE_EXPAT -DHAVE_XERCES -DCOMPILATION_ALLOWED -DHAVE_SPATIALITE \
        -DPTHREAD_MUTEX_RECURSIVE -DCPU_LITTLE_ENDIAN -DCPL_IS_LSB=1 \
        -DKDU_MAJOR_VERSION=7 -DKDU_MINOR_VERSION=5 \
        -Dva_copy=va_start \
        -D__cplusplus \
        -DVSIRealloc=realloc \
        -DCPPCHECK \
        --include=port/cpl_config.h \
        --include=port/cpl_port.h \
        -I port -I gcore -I ogr -I ogr/ogrsf_frmts \
        $dirname \
        -j 8 >>${LOG_FILE} 2>&1
    if [[ $? -ne 0 ]] ; then
        echo "cppcheck failed"
        exit 1
    fi
done

cat ${LOG_FILE} | grep -v "unmatchedSuppression" > ${LOG_FILE}.tmp
mv ${LOG_FILE}.tmp ${LOG_FILE}

grep "null pointer" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "Null pointer check failed"
    exit 1
fi

grep "duplicateBreak" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "duplicateBreak check failed"
    exit 1
fi

grep "duplicateBranch" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "duplicateBranch check failed"
    exit 1
fi

grep "uninitMemberVar" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "uninitMemberVar check failed"
    exit 1
fi

grep "useInitializationList" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "uninitMemberVar check failed"
    exit 1
fi

grep "clarifyCalculation" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "clarifyCalculation check failed"
    exit 1
fi

grep "invalidPrintfArgType_uint" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "invalidPrintfArgType_uint check failed"
    exit 1
fi

grep "catchExceptionByValue" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "catchExceptionByValue check failed"
    exit 1
fi

grep "memleakOnRealloc" ${LOG_FILE} | grep frmts/hdf4/hdf-eos > /dev/null && echo "memleakOnRealloc issues in frmts/hdf4/hdf-eos ignored"
grep "memleakOnRealloc" ${LOG_FILE} | grep frmts/grib/degrib18 > /dev/null && echo "memleakOnRealloc issues in frmts/grib/degrib18 ignored"
grep "memleakOnRealloc" ${LOG_FILE} | grep -v frmts/hdf4/hdf-eos | grep -v frmts/grib/degrib18
if [[ $? -eq 0 ]] ; then
    echo "memleakOnRealloc check failed"
    exit 1
fi

# Those warnings in libjpeg seems to be false positives
#grep "arrayIndexOutOfBoundsCond" ${LOG_FILE} | grep frmts/jpeg/libjpeg > /dev/null && echo "arrayIndexOutOfBoundsCond issues in frmts/jpeg/libjpeg ignored"
grep "arrayIndexOutOfBoundsCond" ${LOG_FILE} | grep -v frmts/jpeg/libjpeg
if [[ $? -eq 0 ]] ; then
    echo "arrayIndexOutOfBoundsCond check failed"
    exit 1
fi

grep "arrayIndexOutOfBounds," ${LOG_FILE} | grep frmts/hdf4/hdf-eos > /dev/null && echo "arrayIndexOutOfBounds issues in frmts/hdf4/hdf-eos ignored"
grep "arrayIndexOutOfBounds," ${LOG_FILE} | grep -v frmts/hdf4/hdf-eos
if [[ $? -eq 0 ]] ; then
    echo "arrayIndexOutOfBounds check failed"
    exit 1
fi

grep "syntaxError" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "syntaxError check failed"
    exit 1
fi

grep "memleak," ${LOG_FILE} | grep frmts/hdf4/hdf-eos > /dev/null && echo "memleak issues in frmts/hdf4/hdf-eos ignored"
grep "memleak," ${LOG_FILE} | grep frmts/grib/degrib18 > /dev/null && echo "memleak issues in frmts/grib/degrib18 ignored"
grep "memleak," ${LOG_FILE} | grep -v frmts/hdf4/hdf-eos | grep -v frmts/grib/degrib18
if [[ $? -eq 0 ]] ; then
    echo "memleak check failed"
    exit 1
fi

grep "eraseDereference" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "eraseDereference check failed"
    exit 1
fi

grep "memsetClass," ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "memsetClass check failed"
    exit 1
fi

# Most if not all of them are false positives
grep "uninitvar," ${LOG_FILE} | grep frmts/hdf4/hdf-eos > /dev/null && echo "(potential) uninitvar issues in frmts/hdf4/hdf-eos ignored"
grep "uninitvar," ${LOG_FILE} | grep frmts/grib/degrib18 > /dev/null && echo "(potential) uninitvar issues in frmts/grib/degrib18 ignored"
grep "uninitvar," ${LOG_FILE} | grep frmts/gtiff/libtiff > /dev/null && echo "(potential) uninitvar issues in frmts/gtiff/libtiff ignored"
grep "uninitvar," ${LOG_FILE} | grep frmts/gtiff/libgeotiff > /dev/null && echo "(potential) uninitvar issues in frmts/gtiff/libgeotiff ignored"
grep "uninitvar," ${LOG_FILE} | grep frmts/jpeg/libjpeg > /dev/null && echo "(potential) uninitvar issues in frmts/jpeg/libjpeg ignored"
grep "uninitvar," ${LOG_FILE} | grep frmts/gif/giflib > /dev/null && echo "(potential) uninitvar issues in frmts/gif/giflib ignored"
grep "uninitvar," ${LOG_FILE} | grep frmts/png/libpng > /dev/null && echo "(potential) uninitvar issues in frmts/png/libpng ignored"
grep "uninitvar," ${LOG_FILE} | grep frmts/zlib > /dev/null && echo "(potential) uninitvar issues in frmts/zlib ignored"
grep "uninitvar," ${LOG_FILE} | grep ogr/ogrsf_frmts/geojson/libjson > /dev/null && echo "(potential) uninitvar issues in ogr/ogrsf_frmts/geojson/libjson ignored"

grep "uninitvar," ${LOG_FILE} | grep -v frmts/hdf4/hdf-eos | \
                                grep -v frmts/grib/degrib18 | \
                                grep -v frmts/gtiff/libtiff | \
                                grep -v frmts/gtiff/libgeotiff | \
                                grep -v frmts/jpeg/libjpeg | \
                                grep -v frmts/gif/giflib | \
                                grep -v frmts/png/libpng | \
                                grep -v frmts/zlib | \
                                grep -v ogr/ogrsf_frmts/geojson/libjson | \
                                grep -v osr_cs_wkt_parser.c
if [[ $? -eq 0 ]] ; then
    echo "uninitvar check failed"
    exit 1
fi

grep "uninitdata," ${LOG_FILE} | grep "frmts/grib/degrib18/g2clib-1.0.4" > /dev/null && echo "(potential) uninitdata issues in frmts/grib/degrib18/g2clib-1.0.4 ignored"

grep "uninitdata," ${LOG_FILE} | grep -v "frmts/grib/degrib18/g2clib-1.0.4"
if [[ $? -eq 0 ]] ; then
    echo "uninitdata check failed"
    exit 1
fi

grep "va_list_usedBeforeStarted" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "va_list_usedBeforeStarted check failed"
    exit 1
fi

grep "duplInheritedMember" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "duplInheritedMember check failed"
    exit 1
fi

grep "terminateStrncpy" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "terminateStrncpy check failed"
    exit 1
fi

grep "operatorEqVarError" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "operatorEqVarError check failed"
    exit 1
fi

grep "uselessAssignmentPtrArg" ${LOG_FILE} | grep -v swq_parser.cpp | grep -v osr_cs_wkt_parser.c | grep -v ods_formula_parser.cpp
if [[ $? -eq 0 ]] ; then
    echo "uselessAssignmentPtrArg check failed"
    exit 1
fi

grep "bufferNotZeroTerminated" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "bufferNotZeroTerminated check failed"
    exit 1
fi

grep "sizeofDivisionMemfunc" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "sizeofDivisionMemfunc check failed"
    exit 1
fi

grep "selfAssignment" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "selfAssignment check failed"
    exit 1
fi

grep "invalidPrintfArgType_sint" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "invalidPrintfArgType_sint check failed"
    exit 1
fi

grep "redundantAssignInSwitch" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "redundantAssignInSwitch check failed"
    exit 1
fi

grep "publicAllocationError" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "publicAllocationError check failed"
    exit 1
fi

grep "invalidScanfArgType_int" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "invalidScanfArgType_int check failed"
    exit 1
fi

grep "invalidscanf," ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "invalidscanf check failed"
    exit 1
fi

grep "moduloAlwaysTrueFalse" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "moduloAlwaysTrueFalse check failed"
    exit 1
fi

grep "charLiteralWithCharPtrCompare" ${LOG_FILE}
if [[ $? -eq 0 ]] ; then
    echo "charLiteralWithCharPtrCompare check failed"
    exit 1
fi

# Check any remaining errors
grep "error," ${LOG_FILE} | grep -v "uninitvar" | \
    grep -v "memleak," | grep -v "memleakOnRealloc" | \
    grep -v "frmts/jpeg/libjpeg/jdphuff.c:493,error,shiftNegative,Shifting a negative value is undefined behaviour" | \
    grep -v "ogr/ogrsf_frmts/avc/avc_bin.c:1866,error,bufferAccessOutOfBounds,Buffer is accessed out of bounds" | \
    grep -v "frmts/hdf4/hdf-eos/EHapi.c:1890,error,bufferAccessOutOfBounds,Buffer is accessed out of bounds." | \
    grep -v "frmts/hdf4/hdf-eos/EHapi.c:1920,error,bufferAccessOutOfBounds,Buffer is accessed out of bounds." | \
    grep -v "frmts/hdf4/hdf-eos/EHapi.c:1958,error,bufferAccessOutOfBounds,Buffer is accessed out of bounds." | \
    grep -v "frmts/hdf4/hdf-eos/EHapi.c:1994,error,bufferAccessOutOfBounds,Buffer is accessed out of bounds." | \
    grep -v "frmts/hdf4/hdf-eos/EHapi.c:2056,error,bufferAccessOutOfBounds,Buffer is accessed out of bounds." | \
    grep -v "frmts/hdf4/hdf-eos/EHapi.c:2118,error,bufferAccessOutOfBounds,Buffer is accessed out of bounds." | \
    grep -v "frmts/hdf4/hdf-eos/EHapi.c:2159,error,bufferAccessOutOfBounds,Buffer is accessed out of bounds." | \
    grep -v "frmts/hdf4/hdf-eos/EHapi.c:2208,error,bufferAccessOutOfBounds,Buffer is accessed out of bounds." | \
    grep -v "frmts/hdf4/hdf-eos/EHapi.c:2227,error,bufferAccessOutOfBounds,Buffer is accessed out of bounds." | \
    grep -v "frmts/grib/degrib18/g2clib-1.0.4"

if [[ $? -eq 0 ]] ; then
    echo "Errors check failed"
    exit 1
fi

# Check any remaining warnings
grep "warning," ${LOG_FILE} | grep -v "ods_formula_parser" | \
    grep -v "osr_cs_wkt_parser" | grep -v "swq_parser" | \
    grep -v "frmts/jpeg/libjpeg"
if [[ $? -eq 0 ]] ; then
    echo "Warnings check failed"
    exit 1
fi

echo "cppcheck succeeded"


