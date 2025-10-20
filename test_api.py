import requests
import json

def test_comment_api():
    """测试评论API"""
    print("开始测试获取评论...")
    
    # 使用UAPI提供的API获取评论
    url = 'https://uapis.cn/api/v1/social/bilibili/replies'
    params = {
        'oid': '1559365249',
        'sort': 1,  # 1=按点赞排序
        'ps': 20,
        'pn': 1
    }
    
    try:
        print(f"发送请求到: {url}")
        print(f"请求参数: {params}")
        
        response = requests.get(url, params=params, timeout=10)
        print(f"收到响应状态码: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"收到评论数据: {list(data.keys())}")
            
            if data.get('code') != 0:
                print(f"API返回错误: code={data.get('code')}, message={data.get('message')}")
                return False
            
            if not data.get('data'):
                print("返回数据为空")
                return True
                
            reply_data = data['data']
            
            # 解析热门评论（仅第一页）
            hot_count = len(reply_data.get('hots', []))
            print(f"热门评论数量: {hot_count}")
            
            # 解析普通评论
            reply_count = len(reply_data.get('replies', []))
            print(f"普通评论数量: {reply_count}")
            
            # 总评论数
            total_count = reply_data.get('page', {}).get('count', 0)
            print(f"总评论数: {total_count}")
            
            print("获取评论成功!")
            return True
        else:
            print(f"HTTP错误: {response.status_code}")
            return False
            
    except requests.exceptions.Timeout:
        print("请求超时，请检查网络连接")
        return False
    except requests.exceptions.RequestException as e:
        print(f"网络请求失败: {e}")
        return False
    except Exception as e:
        print(f"测试过程中出现错误: {e}")
        return False

def test_reply_api():
    """测试楼中楼评论API"""
    print("\n开始测试获取楼中楼评论...")
    
    # 使用UAPI提供的API获取楼中楼评论
    url = 'https://uapis.cn/api/v1/social/bilibili/replies'
    params = {
        'oid': '1559365249',
        'root': 123456,  # 示例rootId，需要替换为实际的评论ID
        'ps': 20,
        'pn': 1
    }
    
    try:
        print(f"发送请求到: {url}")
        print(f"请求参数: {params}")
        
        response = requests.get(url, params=params, timeout=10)
        print(f"收到响应状态码: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"收到楼中楼评论数据: {list(data.keys())}")
            
            if data.get('code') != 0:
                print(f"API返回错误: code={data.get('code')}, message={data.get('message')}")
                return False
            
            print("获取楼中楼评论成功!")
            return True
        else:
            print(f"HTTP错误: {response.status_code}")
            return False
            
    except requests.exceptions.Timeout:
        print("请求超时，请检查网络连接")
        return False
    except requests.exceptions.RequestException as e:
        print(f"网络请求失败: {e}")
        return False
    except Exception as e:
        print(f"测试过程中出现错误: {e}")
        return False

if __name__ == "__main__":
    print("B站评论API测试工具")
    print("=" * 30)
    
    # 测试评论API
    success = test_comment_api()
    
    if success:
        # 测试楼中楼评论API
        test_reply_api()
    
    print("\n测试完成")