import requests
import json

def test_video_urls():
    # 测试视频BV1joHwzBEJK
    bvid = "BV1joHwzBEJK"
    cid = "25874011694"
    
    print(f"测试视频 {bvid} 的URL可访问性")
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Referer': 'https://www.bilibili.com/',
    }
    
    # 获取播放信息
    play_url = f'https://api.bilibili.com/x/player/playurl?bvid={bvid}&cid={cid}&fnver=0&fnval=4048&fourk=1&force_host=2&try_look=1'
    
    try:
        print('正在获取播放信息...')
        play_response = requests.get(play_url, headers=headers)
        print(f'播放信息响应状态码: {play_response.status_code}')
        
        if play_response.status_code == 200:
            data = play_response.json()
            if data['code'] == 0 and data['data'] is not None:
                play_data = data['data']
                
                # 检查DASH信息
                if 'dash' in play_data and play_data['dash'] is not None:
                    dash = play_data['dash']
                    print('DASH信息获取成功')
                    print(f'视频流数量: {len(dash.get("video", []))}')
                    print(f'音频流数量: {len(dash.get("audio", []))}')
                    
                    # 测试前几个视频URL
                    if 'video' in dash and dash['video']:
                        for i in range(min(3, len(dash['video']))):
                            video = dash['video'][i]
                            video_url = video.get('baseUrl') or video.get('base_url')
                            if video_url:
                                print(f'\n测试视频流 {i}:')
                                print(f'URL: {video_url[:60]}...')
                                try:
                                    response = requests.head(video_url, headers=headers, timeout=10)
                                    print(f'  状态码: {response.status_code}')
                                    print(f'  Content-Type: {response.headers.get("content-type", "未知")}')
                                    if response.status_code == 200:
                                        print('  √ URL可访问')
                                    else:
                                        print('  × URL不可访问')
                                except Exception as e:
                                    print(f'  × 访问URL时出错: {e}')
                    
                    # 测试前几个音频URL
                    if 'audio' in dash and dash['audio']:
                        for i in range(min(3, len(dash['audio']))):
                            audio = dash['audio'][i]
                            audio_url = audio.get('baseUrl') or audio.get('base_url')
                            if audio_url:
                                print(f'\n测试音频流 {i}:')
                                print(f'URL: {audio_url[:60]}...')
                                try:
                                    response = requests.head(audio_url, headers=headers, timeout=10)
                                    print(f'  状态码: {response.status_code}')
                                    print(f'  Content-Type: {response.headers.get("content-type", "未知")}')
                                    if response.status_code == 200:
                                        print('  √ URL可访问')
                                    else:
                                        print('  × URL不可访问')
                                except Exception as e:
                                    print(f'  × 访问URL时出错: {e}')
                else:
                    print('无DASH信息')
            else:
                print(f'获取播放数据失败: {data.get("message", "未知错误")}')
        else:
            print(f'获取播放信息失败: {play_response.status_code}')
    except Exception as e:
        print(f'测试过程中发生错误: {e}')

if __name__ == "__main__":
    test_video_urls()