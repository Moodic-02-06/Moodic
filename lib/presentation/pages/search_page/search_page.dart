import 'package:flutter/material.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';
import 'package:flutter_moodic/presentation/provider/music_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  MoodType? selectedMood;

  final List<String> recentKeywords = ['NewJeans', '재즈 플레이리스트', '비오는 날 노래'];

  @override
  Widget build(BuildContext context) {
    final musicState = ref.watch(musicProvider);

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverAppBar(
                pinned: true,
                expandedHeight: 150,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,

                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        /// 타이틀 + 알림
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            const Text(
                              '검색',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            IconButton(
                              icon: const Icon(Icons.notifications),
                              onPressed: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// 검색창
                        TextField(
                          controller: _controller,

                          decoration: InputDecoration(
                            hintText: '음악이나 감정 키워드를 검색해보세요',

                            prefixIcon: const Icon(Icons.search),

                            suffixIcon: IconButton(
                              icon: const Icon(Icons.mic),
                              onPressed: () {},
                            ),

                            filled: true,

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),

                          onSubmitted: (_) => _search(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },

          /// 메인 Body
          body: ListView(
            padding: const EdgeInsets.only(bottom: 100),

            children: [
              /// ================= 인기 감정 =================
              Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      '🔥 인기 있는 감정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 40,

                      child: ListView(
                        scrollDirection: Axis.horizontal,

                        children: MoodType.values.map((mood) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),

                            child: ChoiceChip(
                              label: Text(mood.label),

                              selected: selectedMood == mood,

                              onSelected: (value) {
                                setState(() {
                                  selectedMood = value ? mood : null;
                                });

                                _search();
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= 최근 검색어 =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          '최근 검색어',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            setState(() {
                              recentKeywords.clear();
                            });
                          },

                          child: const Text('모두 지우기'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    ...recentKeywords.map(
                      (e) => ListTile(
                        leading: const Icon(Icons.history),

                        title: Text(e),

                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              recentKeywords.remove(e);
                            });
                          },
                        ),

                        onTap: () {
                          _controller.text = e;
                          _search();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= 추천 음악 =================
              Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      '회원님을 위한 추천 음악',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    musicState.when(
                      data: (list) {
                        if (list.isEmpty) {
                          return const Center(child: Text('검색 결과 없음'));
                        }

                        return Column(
                          children: list.map((music) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),

                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),

                                  child: Image.network(
                                    music.artwork,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                title: Text(music.title),

                                subtitle: Text(music.artist),

                                trailing: const Icon(Icons.add),

                                onTap: () {
                                  /// TODO: 게시물 검색 연결
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },

                      loading: () =>
                          const Center(child: CircularProgressIndicator()),

                      error: (e, _) => Center(child: Text('에러: $e')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 검색 실행
  void _search() {
    final keyword = _controller.text.trim();

    if (keyword.isEmpty) return;

    if (!recentKeywords.contains(keyword)) {
      setState(() {
        recentKeywords.insert(0, keyword);
      });
    }

    ref.read(musicProvider.notifier).search(keyword);
  }
}
