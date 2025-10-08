  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频播放'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('加载失败: $_errorMessage'),
                      ElevatedButton(
                        onPressed: _loadVideoData,
                        child: const Text('重新加载'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // 视频播放器
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 9 / 16,
                      child: BiliVideoPlayer(
                        bvid: widget.bvid,
                        cid: widget.cid,
                      ),
                    ),
                    // 标题和标签
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _videoDetail.title ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 视频信息
                          Row(
                            children: [
                              Text(
                                '${_videoDetail.playNum} 播放',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_videoDetail.danmaukuNum} 弹幕',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_videoDetail.likeNum} 点赞',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Tab栏
                    Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: '简介'),
                          Tab(text: '评论'),
                          Tab(text: '推荐'),
                        ],
                      ),
                    ),
                    // 内容区域
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // 简介页面
                          VideoIntroPanel(
                            bvid: widget.bvid,
                            cid: widget.cid,
                          ),
                          // 评论页面
                          VideoReplyPanel(
                            bvid: widget.bvid,
                            oid: _videoDetail.ownerMid,
                          ),
                          // 推荐页面（暂时为空）
                          const Center(
                            child: Text('推荐内容'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }