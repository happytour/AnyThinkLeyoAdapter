# Uncomment the next line to define a global platform for your project
#source 'https://github.com/CocoaPods/Specs.git'
# 清华大学镜像库，如果上面库无法加载请使用下面镜像
source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
# 添加LYSpecs私库
source 'https://gitee.com/happytour/LYSpecs.git'

platform :ios, '13.0'

workspace 'AnyThinkLeyoAdapter'
project '../AnyThinkLeyoAdapterDemo/AnyThinkLeyoAdapterDemo'

target 'AnyThinkLeyoAdapterDemo' do
  pod 'AnyThinkiOS','6.3.75'
  
  pod 'Ads-Fusion-CN-Beta','6.4.1.0', :subspecs => ['BUAdSDK', 'CSJMediation'] #不与Ads-CN-Beta同时存在
#  pod 'Ads-Fusion-CN-Beta', :path => '/Users/laole918/workspace/ios/happytour/LYAdSDK3/LYAdSDK/ThirdPartySDK/Ads-Fusion-CN-Beta/6.5.0.0/', :subspecs => ['BUAdSDK', 'CSJMediation']
  pod 'GDTMobSDK', '4.15.02'
  pod 'BaiduMobAdSDK', '5.371'
  pod 'KSAdSDK', '3.3.69'
  # KSAdSDKFull，没有提交到官方库，需要引入LYSpecs私库拉取
#  pod 'fork-KSAdSDKFull', '3.3.32'
  pod 'JADYun', '2.6.4'

  pod 'LYAdSDK', '3.0.5'
  pod 'LYAdSDKAdapterForCSJ', '2.6.5' # 穿山甲支持
  pod 'LYAdSDKAdapterForGDT', '2.6.4' # 广点通支持
  pod 'LYAdSDKAdapterForKS', '2.6.4' # 快手AD支持
#  pod 'LYAdSDKAdapterForKSContent', '2.5.0' # 快手内容支持
  pod 'LYAdSDKAdapterForBD', '2.7.0' # 百度支持
  pod 'LYAdSDKAdapterForJD', '2.6.5' # 京东支持
  pod 'LYAdSDKAdapterForGromore', '2.7.0' # 穿山甲融合支持
  
  pod 'Masonry'
  pod 'SDWebImage'

  project '../AnyThinkLeyoAdapterDemo/AnyThinkLeyoAdapterDemo'
end

target 'AnyThinkLeyoAdapter' do
  pod 'AnyThinkiOS','6.3.75'
  pod 'LYAdSDK', '3.0.5'
  project 'AnyThinkLeyoAdapter'
end
