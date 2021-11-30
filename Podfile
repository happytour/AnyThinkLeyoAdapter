# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
# 添加LYSpecs私库
source 'https://gitee.com/happytour/LYSpecs.git'

platform :ios, '9.0'

workspace 'AnyThinkLeyoAdapter'
project '../AnyThinkLeyoAdapterDemo/AnyThinkLeyoAdapterDemo'

target 'AnyThinkLeyoAdapterDemo' do
  pod 'AnyThinkiOS', '5.7.81'
  
  pod 'Ads-CN', '4.0.0.5'
  pod 'GDTMobSDK', '4.13.22'
  pod 'SigmobAd-iOS', '3.4.3'
  pod 'BaiduMobAdSDK', '4.81'
  pod 'WechatOpenSDK', '1.8.7.1'
  # KSAdSDKFull、QySdk、JADYun、KlevinAdSDK，没有提交到官方库，需要引入LYSpecs私库拉取
  pod 'fork-KSAdSDKFull', '3.3.23'
  pod 'fork-QySdk', '1.3.2'
  pod 'fork-JADYun' , '1.3.4'
  pod 'fork-KlevinAdSDK', '2.3.0.222'

  pod 'LYAdSDK', '2.3.4'
  pod 'LYAdSDKAdapterForCSJ', '2.3.4'
  pod 'LYAdSDKAdapterForGDT', '2.3.3'
  pod 'LYAdSDKAdapterForKS', '2.3.0'
  pod 'LYAdSDKAdapterForSIG', '2.3.0'
  pod 'LYAdSDKAdapterForIQY', '2.3.0'
  pod 'LYAdSDKAdapterForBD', '2.3.0'
  pod 'LYAdSDKAdapterForJD', '2.3.0'
  pod 'LYAdSDKAdapterForKLN', '2.3.2'

  project '../AnyThinkLeyoAdapterDemo/AnyThinkLeyoAdapterDemo'
end

target 'AnyThinkLeyoAdapter' do
  pod 'AnyThinkiOS', '5.7.81'
  pod 'LYAdSDK', '2.3.4'
  project 'AnyThinkLeyoAdapter'
end
