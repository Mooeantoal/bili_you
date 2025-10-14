import 'package:dio/dio.dart';
import 'package:bili_you/common/models/network/user/user_info.dart';

class UserInfoApi {
  static const String _baseUrl = 'https://uapis.cn/api/v1/social/bilibili';

  // 获取用户信息
  static Future<UserInfoData?> getUserInfo({required String uid}) async {
    // 首先尝试使用UAPI
    final uapiResult = await _getUserInfoFromUAPI(uid);
    if (uapiResult != null) {
      return uapiResult;
    }
    
    // 如果UAPI失败，尝试使用B站官方API
    print('UAPI获取用户信息失败，尝试使用B站官方API');
    final bilibiliResult = await _getUserInfoFromBilibili(uid);
    return bilibiliResult;
  }
  
  // 从UAPI获取用户信息
  static Future<UserInfoData?> _getUserInfoFromUAPI(String uid) async {
    try {
      final url = '$_baseUrl/userinfo?uid=$uid';
      final dio = Dio();
      
      // 添加请求头以避免被阻止
      dio.options.headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Referer': 'https://www.bilibili.com/',
      };
      
      print('正在请求用户信息(UAPI): $url');
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        print('收到响应(UAPI): ${response.data}');
        // 检查响应数据格式
        if (response.data is Map<String, dynamic>) {
          final userInfoResponse = UserInfoResponse.fromJson(response.data);
          
          if (userInfoResponse.code == 0 && userInfoResponse.data != null) {
            print('成功获取用户信息(UAPI): ${userInfoResponse.data?.name}');
            return userInfoResponse.data;
          } else {
            // 如果API返回错误，打印详细信息
            print('UAPI Error: code=${userInfoResponse.code}, message=${userInfoResponse.message}');
            print('完整响应数据: ${response.data}');
          }
        } else {
          print('Invalid response format(UAPI): ${response.data}');
        }
      } else {
        print('HTTP Error(UAPI): ${response.statusCode}');
        print('响应内容: ${response.data}');
      }
    } catch (e, stackTrace) {
      print('Exception occurred while fetching user info from UAPI: $e');
      print('Stack trace: $stackTrace');
    }
    
    return null;
  }
  
  // 从B站官方API获取用户信息
  static Future<UserInfoData?> _getUserInfoFromBilibili(String uid) async {
    try {
      final url = 'https://api.bilibili.com/x/space/acc/info?mid=$uid&jsonp=jsonp';
      final dio = Dio();
      
      // 添加请求头以避免被阻止
      dio.options.headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Referer': 'https://space.bilibili.com/$uid',
      };
      
      print('正在请求用户信息(B站官方API): $url');
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        print('收到响应(B站官方API): ${response.data}');
        // 检查响应数据格式
        if (response.data is Map<String, dynamic>) {
          final data = response.data;
          
          if (data['code'] == 0 && data['data'] != null) {
            // 转换B站官方API的数据格式为我们的数据模型
            final bilibiliData = data['data'];
            
            // 处理VIP信息
            Vip? vipInfo;
            if (bilibiliData['vip'] != null) {
              final vipData = bilibiliData['vip'];
              Label? labelInfo;
              if (vipData['label'] != null) {
                final labelData = vipData['label'];
                labelInfo = Label(
                  path: labelData['path'],
                  text: labelData['text'],
                  labelTheme: labelData['label_theme'],
                  textColor: labelData['text_color'],
                  bgStyle: labelData['bg_style'],
                  bgColor: labelData['bg_color'],
                  borderColor: labelData['border_color'],
                );
              }
              
              vipInfo = Vip(
                type: vipData['type'],
                status: vipData['status'],
                dueDate: vipData['due_date'],
                vipPayType: vipData['vip_pay_type'],
                themeType: vipData['theme_type'],
                label: labelInfo,
                avatarSubscript: vipData['avatar_subscript'],
                nicknameColor: vipData['nickname_color'],
                role: vipData['role'],
                avatarSubscriptUrl: vipData['avatar_subscript_url'],
                tvVipStatus: vipData['tv_vip_status'],
                tvVipPayType: vipData['tv_vip_pay_type'],
                tvDueDate: vipData['tv_due_date'],
              );
            }
            
            // 处理官方认证信息
            Official? officialInfo;
            if (bilibiliData['official'] != null) {
              final officialData = bilibiliData['official'];
              officialInfo = Official(
                role: officialData['role'],
                title: officialData['title'],
                desc: officialData['desc'],
                type: officialData['type'],
              );
            }
            
            // 处理学校信息
            School? schoolInfo;
            if (bilibiliData['school'] != null) {
              final schoolData = bilibiliData['school'];
              schoolInfo = School(
                name: schoolData['name'],
              );
            }
            
            // 处理职业信息
            Profession? professionInfo;
            if (bilibiliData['profession'] != null) {
              final professionData = bilibiliData['profession'];
              professionInfo = Profession(
                name: professionData['name'],
                department: professionData['department'],
                title: professionData['title'],
                isShow: professionData['is_show'],
              );
            }
            
            // 处理系列信息
            Series? seriesInfo;
            if (bilibiliData['series'] != null) {
              final seriesData = bilibiliData['series'];
              seriesInfo = Series(
                userUpgradeStatus: seriesData['user_upgrade_status'],
                showUpgradeWindow: seriesData['show_upgrade_window'],
              );
            }
            
            final userInfo = UserInfoData(
              mid: bilibiliData['mid'],
              name: bilibiliData['name'],
              sex: bilibiliData['sex'],
              face: bilibiliData['face'],
              sign: bilibiliData['sign'],
              rank: bilibiliData['rank'],
              level: bilibiliData['level'],
              jointime: bilibiliData['jointime'],
              moral: bilibiliData['moral'],
              silence: bilibiliData['silence'],
              coins: bilibiliData['coins'],
              fansBadge: bilibiliData['fans_badge'],
              likeNum: bilibiliData['like_num'],
              following: bilibiliData['following']?['following'],
              follower: bilibiliData['follower']?['follower'],
              vip: vipInfo,
              official: officialInfo,
              nameplate: null, // B站官方API可能不包含此信息
              school: schoolInfo,
              profession: professionInfo,
              tags: bilibiliData['tags'],
              series: seriesInfo,
              isSeniorMember: bilibiliData['is_senior_member'],
            );
            
            print('成功获取用户信息(B站官方API): ${userInfo.name}');
            return userInfo;
          } else {
            // 如果API返回错误，打印详细信息
            print('B站官方API Error: code=${data['code']}, message=${data['message']}');
            print('完整响应数据: $data');
          }
        } else {
          print('Invalid response format(B站官方API): ${response.data}');
        }
      } else {
        print('HTTP Error(B站官方API): ${response.statusCode}');
        print('响应内容: ${response.data}');
      }
    } catch (e, stackTrace) {
      print('Exception occurred while fetching user info from B站官方API: $e');
      print('Stack trace: $stackTrace');
    }
    
    return null;
  }
}