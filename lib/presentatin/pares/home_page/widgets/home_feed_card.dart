import 'package:flutter/material.dart';

class HomeFeedCard extends StatelessWidget {
  const HomeFeedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================== 작성자 영역 ==================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  /// 프로필 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Image.network(
                      'https://picsum.photos/200/300',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '현더',
                        style: TextStyle(
                          color: Color(0xFFF1F5F9),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '1분 전',
                        style: TextStyle(
                          color: Color(0xFF8B99AE),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              /// 옵션 버튼 자리
              const Icon(Icons.more_vert, size: 16, color: Color(0xFF94A3B8)),
            ],
          ),

          const SizedBox(height: 12),

          /// ================== 음악/콘텐츠 카드 ==================
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF101022),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.network(
                        'https://picsum.photos/200/300',
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '춘몽',
                          style: TextStyle(
                            color: Color(0xFFF1F5F9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '현서 (HYUNSEO)',
                          style: TextStyle(
                            color: Color(0xFF8B99AE),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Icon(Icons.play_arrow, color: Color(0xFF94A3B8)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// ================== 이미지 ==================
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://picsum.photos/200/300',
              width: double.infinity,
              height: 199,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 12),

          /// ================== 감정 + 내용 ==================
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 감정 태그
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x7FFCE48A),
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(color: const Color(0xFFCBB254)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('😊'),
                    SizedBox(width: 6),
                    Text(
                      '행복',
                      style: TextStyle(color: Color(0xFFF8FAFF), fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// 내용
              const Text(
                '오늘 저 기분이 그지같아요',
                style: TextStyle(color: Color(0xFFF1F5F9), fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// ================== 좋아요 / 댓글 ==================
          Row(
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '12',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(width: 25),

              Row(
                children: const [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '12',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
