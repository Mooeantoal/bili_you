import requests

try:
    print("测试API连接...")
    response = requests.get("https://uapis.cn/api/v1/social/bilibili/replies?oid=1559365249&ps=10&pn=1", timeout=5)
    print(f"状态码: {response.status_code}")
    print(f"响应: {response.text[:200]}...")
except Exception as e:
    print(f"错误: {e}")