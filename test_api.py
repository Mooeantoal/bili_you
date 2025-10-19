import requests
import json

def test_api():
    try:
        print('测试评论API连接...')
        
        # 测试评论API
        url = "https://uapis.cn/api/v1/social/bilibili/replies?oid=1559365249&ps=10&pn=1"
        print(f'请求URL: {url}')
        
        response = requests.get(url, timeout=10)
        print(f'响应状态码: {response.status_code}')
        print(f'响应数据: {response.json()}')
        
    except Exception as e:
        print(f'错误: {e}')

if __name__ == "__main__":
    test_api()