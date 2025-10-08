import requests
import json

# 测试视频BV1joHwzBEJK的播放信息
bvid = "BV1joHwzBEJK"
cid = 0  # 我们需要先获取CID

# B站API基础URL
api_base = "https://api.bilibili.com"

# 获取视频基本信息
def get_video_info(bvid):
    url = f"{api_base}/x/web-interface/view?bvid={bvid}"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        "Referer": "https://www.bilibili.com/"
    }
    
    response = requests.get(url, headers=headers)
    data = response.json()
    
    if data["code"] == 0:
        print("视频信息获取成功:")
        print(f"标题: {data['data']['title']}")
        print(f"CID: {data['data']['cid']}")
        print(f"分P数量: {len(data['data']['pages'])}")
        return data['data']['cid']
    else:
        print(f"获取视频信息失败: {data}")
        return None

# 获取视频播放信息
def get_video_play_info(bvid, cid):
    url = f"{api_base}/x/player/playurl"
    params = {
        "bvid": bvid,
        "cid": cid,
        "fnver": 0,
        "fnval": 4048,  # 支持所有格式
        "fourk": 1,
        "force_host": 2,
        "try_look": 1  # 免登录查看
    }
    
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        "Referer": "https://www.bilibili.com/"
    }
    
    response = requests.get(url, params=params, headers=headers)
    data = response.json()
    
    if data["code"] == 0:
        print("\n播放信息获取成功:")
        play_data = data["data"]
        print(f"视频质量数量: {len(play_data.get('accept_quality', []))}")
        print(f"支持的格式: {play_data.get('accept_format', '未知')}")
        
        # 检查DASH信息
        if "dash" in play_data:
            dash = play_data["dash"]
            print(f"DASH时长: {dash.get('duration', '未知')}秒")
            print(f"视频流数量: {len(dash.get('video', []))}")
            print(f"音频流数量: {len(dash.get('audio', []))}")
            
            # 显示前几个视频流
            for i, video in enumerate(dash.get('video', [])[:3]):
                print(f"视频流 {i+1}:")
                print(f"  质量: {video.get('id', '未知')}")
                print(f"  编码: {video.get('codecs', '未知')}")
                print(f"  带宽: {video.get('bandwidth', '未知')}")
                print(f"  URL: {video.get('baseUrl', '无')[:100]}...")
                
            # 显示前几个音频流
            for i, audio in enumerate(dash.get('audio', [])[:3]):
                print(f"音频流 {i+1}:")
                print(f"  质量: {audio.get('id', '未知')}")
                print(f"  编码: {audio.get('codecs', '未知')}")
                print(f"  带宽: {audio.get('bandwidth', '未知')}")
                print(f"  URL: {audio.get('baseUrl', '无')[:100]}...")
        else:
            print("无DASH信息")
            
        return play_data
    else:
        print(f"获取播放信息失败: {data}")
        return None

# 测试URL可访问性
def test_url_accessibility(url):
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        "Referer": "https://www.bilibili.com/"
    }
    
    try:
        response = requests.head(url, headers=headers, timeout=10)
        print(f"URL状态码: {response.status_code}")
        print(f"Content-Type: {response.headers.get('content-type', '未知')}")
        print(f"Content-Length: {response.headers.get('content-length', '未知')}")
        return response.status_code == 200
    except Exception as e:
        print(f"访问URL失败: {e}")
        return False

if __name__ == "__main__":
    print(f"测试视频: {bvid}")
    
    # 获取视频CID
    cid = get_video_info(bvid)
    if cid:
        # 获取播放信息
        play_info = get_video_play_info(bvid, cid)
        if play_info and "dash" in play_info:
            # 测试第一个视频URL
            if play_info["dash"].get("video", []):
                video_url = play_info["dash"]["video"][0].get("baseUrl", "")
                if video_url:
                    print(f"\n测试视频URL: {video_url[:100]}...")
                    test_url_accessibility(video_url)
            
            # 测试第一个音频URL
            if play_info["dash"].get("audio", []):
                audio_url = play_info["dash"]["audio"][0].get("baseUrl", "")
                if audio_url:
                    print(f"\n测试音频URL: {audio_url[:100]}...")
                    test_url_accessibility(audio_url)