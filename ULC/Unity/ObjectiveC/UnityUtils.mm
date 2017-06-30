//
//  UnityUtils.m
//  ULC
//
//  Created by Alexey on 7/5/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

#include <csignal>
#include "RegisterFeatures.h"
#include "RegisterMonoModules.h"
#include "UnityEngine_UnityEngine_JsonUtility653638946MethodDeclarations.h"
#include "AssemblyU2DCSharp_MessageRouter20369006MethodDeclarations.h"
#include <iostream>
#include "UnityEngine_UnityEngine_Behaviour955675639.h"
#include "UnityEngine_UnityEngine_MonoBehaviour1158329972.h"

#include "AssemblyU2DCSharp_RockSpockMessageRouter3162988383.h"

#include "AssemblyU2DCSharp_SpinTheDisksMessageRouter3151325885.h"

static const int constsection = 0;

void UnityInitTrampoline();

// System.Void MessageRouter::SendAndroidMessage(UnityMessage)
//extern "C"  void MessageRouter_SendAndroidMessage_m2015982491 (MessageRouter_t20369006 * __this, UnityMessage_t3458754356 * ___message0, const MethodInfo* method)
//{
//	String_t* V_0 = NULL;
//	{
//		UnityMessage_t3458754356 * L_0 = ___message0;
//		String_t* L_1 = JsonUtility_ToJson_m1232500921(NULL /*static, unused*/, L_0, /*hidden argument*/NULL);
//		V_0 = L_1;
//		return;
//	}
//}



//MARK FEATURE
//extern "C"  void MessageRouter_SendAndroidMessage_m2015982491 (MessageRouter_t20369006 * __this, UnityMessage_t3458754356 * ___message0, const MethodInfo* method)
//{
//	String_t* V_0 = NULL;
//	{
//		UnityMessage_t3458754356 * L_0 = ___message0;
//		String_t* L_1 = JsonUtility_ToJson_m1232500921(NULL /*static, unused*/, L_0, /*hidden argument*/NULL);
//		V_0 = L_1;
//		return;
//	}
//}


// MARK: MessageRouter
extern "C" void MessageRouter_SendAndroidMessage_m2015982491 (MessageRouter_t20369006 * __this, UnityMessage_t3458754356 * ___message0, const MethodInfo* method)
{
	String_t* V_0 = NULL;
	{
		UnityMessage_t3458754356 * L_0 = ___message0;
		String_t* L_1 = JsonUtility_ToJson_m1232500921(NULL, L_0, NULL);
		//V_0 = L_1;
		uint16_t charArray[L_1->get_length_0()];
		char tmpch[2];
		std::string tmpS = "";

		for(int i=0; i<L_1->get_length_0();i++){
			memcpy(tmpch, (char*)(L_1->get_address_of_start_char_1() + i), 2);
			tmpS.append(&tmpch[0]);
			tmpS.append(&tmpch[1]);
		}

		NSString *message22 = [[NSString alloc] initWithUTF8String:tmpS.c_str()];

		[[NSNotificationCenter defaultCenter] postNotificationName:@"UnityGameMessageNotification" object:message22];

		return;
	}
}

extern "C"  void MessageRouter_ObtainActivity_m2313509753 (MessageRouter_t20369006 * __this, const MethodInfo* method)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageRouterObtainActivity" object:nil];
}

// MARK: Rock Spock Message Router
extern "C"  void RockSpockMessageRouter_SendAndroidMessage_m1404804042 (RockSpockMessageRouter_t3162988383 * __this, UnityMessage_t3458754356 * ___message0, const MethodInfo* method)
{
    String_t* V_0 = NULL;
    {
        UnityMessage_t3458754356 * L_0 = ___message0;
        String_t* L_1 = JsonUtility_ToJson_m1232500921(NULL, L_0, NULL);
        //V_0 = L_1;
        uint16_t charArray[L_1->get_length_0()];
        char tmpch[2];
        std::string tmpS = "";
        
        for(int i=0; i<L_1->get_length_0();i++){
            memcpy(tmpch, (char*)(L_1->get_address_of_start_char_1() + i), 2);
            tmpS.append(&tmpch[0]);
            tmpS.append(&tmpch[1]);
        }
        
        NSString *message22 = [[NSString alloc] initWithUTF8String:tmpS.c_str()];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RockSpockMessageNotification" object:message22];
        
        return;
    }
}

extern "C"  void RockSpockMessageRouter_ObtainActivity_m2870627026 (RockSpockMessageRouter_t3162988383 * __this, const MethodInfo* method)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RockSpockMessageRouterObtainActivity" object:nil];
}

extern "C"  void SpinTheDisksMessageRouter_ObtainActivity_m2528348968 (SpinTheDisksMessageRouter_t3151325885 * __this, const MethodInfo* method)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SpinTheDisksMessageRouterObtainActivity" object:nil];
}

// MARK Spin The Disks Message Router
extern "C"  void SpinTheDisksMessageRouter_SendAndroidMessage_m819764748 (SpinTheDisksMessageRouter_t3151325885 * __this, UnityMessage_t3458754356 * ___message0, const MethodInfo* method)
{
    
    String_t* V_0 = NULL;
    {
        UnityMessage_t3458754356 * L_0 = ___message0;
        String_t* L_1 = JsonUtility_ToJson_m1232500921(NULL, L_0, NULL);
        //V_0 = L_1;
        uint16_t charArray[L_1->get_length_0()];
        char tmpch[2];
        std::string tmpS = "";
        
        for(int i=0; i<L_1->get_length_0();i++){
            memcpy(tmpch, (char*)(L_1->get_address_of_start_char_1() + i), 2);
            tmpS.append(&tmpch[0]);
            tmpS.append(&tmpch[1]);
        }
        
        NSString *message22 = [[NSString alloc] initWithUTF8String:tmpS.c_str()];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SpinTheDisksMessageNotification" object:message22];
        
        return;
    }
}
//[[NSNotificationCenter defaultCenter] postNotificationName:@"MessageRouterObtainController" object:nil];
//[[NSNotificationCenter defaultCenter] postNotificationName:@"RockSpockMessageRouterObtainController" object:nil];

extern "C" {
    extern UIView* UnityGetGLView();
}

extern "C" {
    extern UIViewController* UnityGetGLViewController();
}

extern "C" void custom_unity_init(int argc, char* argv[]) {
  extern UIViewController* UnityGetGLViewController();
  extern UIView* UnityGetGLView();
    UnityInitTrampoline();
	UnityInitRuntime(argc, argv);

  RegisterMonoModules();
  NSLog(@"-> registered mono modules %p\n", &constsection);
  RegisterFeatures();

  // iOS terminates open sockets when an application enters background mode.
  // The next write to any of such socket causes SIGPIPE signal being raised,
  // even if the request has been done from scripting side. This disables the
  // signal and allows Mono to throw a proper C# exception.
  std::signal(SIGPIPE, SIG_IGN);
}

