import requests
import json

# 测试UAPI的视频信息接口
def test_video_info_api():
    # 使用一个常见的BV号进行测试
    bvid = "BV1GJ411x7h7"
    url = f"https://uapis.cn/api/v1/social/bilibili/videoinfo?bvid={bvid}"
    
    print(f"正在测试URL: {url}")
    
    try:
        response = requests.get(url, timeout=10)
        print(f"响应状态码: {response.status_code}")
        print(f"响应头: {dict(response.headers)}")
        
        # 尝试解析JSON
        try:
            data = response.json()
            print("响应JSON数据:")
            print(json.dumps(data, indent=2, ensure_ascii=False))
        except json.JSONDecodeError:
            print("响应不是有效的JSON格式")
            print("响应文本:")
            print(response.text[:500])  # 只打印前500个字符
    except Exception as e:
        print(f"请求失败: {e}")

# 测试UAPI的评论接口
def test_comments_api():
    # 使用一个已知的视频aid进行测试
    aid = 123456  # 这是一个示例aid，实际使用时需要替换为真实的aid
    url = f"https://uapis.cn/api/v1/social/bilibili/replies?oid={aid}&ps=10&pn=1"
    
    print(f"正在测试评论API URL: {url}")
    
    try:
        response = requests.get(url, timeout=10)
        print(f"响应状态码: {response.status_code}")
        print(f"响应头: {dict(response.headers)}")
        
        # 尝试解析JSON
        try:
            data = response.json()
            print("响应JSON数据:")
            print(json.dumps(data, indent=2, ensure_ascii=False))
        except json.JSONDecodeError:
            print("响应不是有效的JSON格式")
            print("响应文本:")
            print(response.text[:500])  # 只打印前500个字符
    except Exception as e:
        print(f"请求失败: {e}")

if __name__ == "__main__":
    print("=== 测试视频信息API ===")
    test_video_info_api()
    
    print("\n=== 测试评论API ===")
    test_comments_api()