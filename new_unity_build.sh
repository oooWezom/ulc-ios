unityBuildDirPath="ulc-ios-games/buildGame/"
tmpDitPath="ulc-ios-games/tmp"
classesDirName="Classes"
librariesDirName="Libraries"
dataDirName="Data"

if [ -d "$unityBuildDirPath" ] && [ -d "$unityBuildDirPath/$classesDirName" ] && [ -d "$unityBuildDirPath/$librariesDirName" ] && [ -d "$unityBuildDirPath/$dataDirName" ]
then 
	if [ -d "$tmpDitPath" ] && [ -d "$tmpDitPath/$classesDirName" ] && [ -d "$tmpDitPath/$librariesDirName" ] && [ -d "$tmpDitPath/$dataDirName" ]
		then
			rm -rf "$unityBuildDirPath" && mkdir "$unityBuildDirPath"
			mv "$tmpDitPath/$classesDirName" "$unityBuildDirPath"
			mv "$tmpDitPath/$librariesDirName" "$unityBuildDirPath"
			mv "$tmpDitPath/$dataDirName" "$unityBuildDirPath"
			rm "$tmpDitPath"
		else
			mkdir "$tmpDitPath"
			mv "$unityBuildDirPath/$classesDirName" "$tmpDitPath"
			mv "$unityBuildDirPath/$librariesDirName" "$tmpDitPath"
			mv "$unityBuildDirPath/$dataDirName" "$tmpDitPath"
			rm -rf "$unityBuildDirPath" && mkdir "$unityBuildDirPath"
			mv "$tmpDitPath/$classesDirName" "$unityBuildDirPath"
			mv "$tmpDitPath/$librariesDirName" "$unityBuildDirPath"
			mv "$tmpDitPath/$dataDirName" "$unityBuildDirPath"
			rm "$tmpDitPath"
	fi
		if [ -d "$tmpDitPath" ]
			then
				rm -rf "$tmpDitPath"		
			else
				echo "$tmpDitPath not exist"
			fi
	./FixUnityBuildScript.sh
else
	echo "$unityBuildDirPath or $unityBuildDirPath/$classesDirName or $unityBuildDirPath/$librariesDirName or $unityBuildDirPath/$dataDirName not found!"
fi