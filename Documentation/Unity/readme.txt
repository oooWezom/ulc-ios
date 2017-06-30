Import Unity project documentation
1) Drag and drop following folders from Unity project to Swift project:
	1.1) <path to unity build>/Classes (Create group)
	1.2) <path to unity build>/Libraries (Create group)
	1.3) <path to unity build>/Data (Create folder reference)
2) Remove folder reference Libraries/libl2cpp/
3) Add the objc folder
4) Create following files: UnityUtils.h/mm (see https://github.com/blitzagency/ios-unity5/tree/master/objc)
5) Rename main in main.mm to anything else (int main_unity_default(int argc, char* argv[]))
6) Remove @UIApplicationMain from AppDelegate file
7) Change UnityAppController.h file 

See more: 