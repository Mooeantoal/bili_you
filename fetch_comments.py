import requests
import json

# 获取B站视频信息
video_url = "https://uapis.cn/api/v1/social/bilibili/videoinfo?bvid=BV1GJ411x7h7"
response = requests.get(video_url)
video_data = response.json()

print("视频信息:")
print(json.dumps(video_data, indent=2, ensure_ascii=False))

# 获取视频的aid
aid = video_data['data']['aid']
print(f"\n视频aid: {aid}")

# 获取评论数据
comments_url = f"https://uapis.cn/api/v1/social/bilibili/replies?oid={aid}&ps=10&pn=1"
response = requests.get(comments_url)
comments_data = response.json()

print("\n评论数据:")
print(json.dumps(comments_data, indent=2, ensure_ascii=False))