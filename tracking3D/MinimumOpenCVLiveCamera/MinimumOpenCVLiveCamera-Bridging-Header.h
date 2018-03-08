//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

//这里是swift和oc和c++混编，需要在这个文件中添加混用c++的oc文件，不然会有以下的报错
/*
 Undefined symbols for architecture arm64:
 "_AudioUnitRender", referenced from:
 performRender(void*, unsigned int*, AudioTimeStamp const*, unsigned int, unsigned int, AudioBufferList*) in AudioController.o
 "_AudioComponentInstanceNew", referenced from:
 -[AudioController setupIOUnit] in AudioController.o
 */
#import "Wrapper.h"
#import "AudioController.h"
