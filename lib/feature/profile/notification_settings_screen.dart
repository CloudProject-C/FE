import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool allNoti = true;
  bool pushNoti = true;
  bool commentNoti = true;
  bool likeNoti = false;
  bool emailNoti = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey_1,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.grey_7,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '알림 설정',
          style: AppTextStyles.pretendard_bold.copyWith(
            fontSize: 18,
            color: AppColors.grey_8,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.grey_2,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 8),
            _NotiTile(
              title: '전체 알림',
              subtitle: '모든 알림을 받습니다',
              value: allNoti,
              onChanged: (v) {
                setState(() {
                  allNoti = v;
                  if (!allNoti) {
                    pushNoti = false;
                    commentNoti = false;
                    likeNoti = false;
                    emailNoti = false;
                  }
                });
              },
            ),
            _NotiTile(
              title: '푸시 알림',
              subtitle: '앱 푸시 알림을 받습니다',
              value: pushNoti,
              enabled: allNoti,
              onChanged: (v) {
                setState(() {
                  pushNoti = v;
                });
              },
            ),
            _NotiTile(
              title: '댓글 알림',
              subtitle: '내 게시물에 댓글이 달리면 알립니다',
              value: commentNoti,
              enabled: allNoti,
              onChanged: (v) {
                setState(() {
                  commentNoti = v;
                });
              },
            ),
            _NotiTile(
              title: '좋아요 알림',
              subtitle: '내 게시물에 좋아요가 달리면 알립니다',
              value: likeNoti,
              enabled: allNoti,
              onChanged: (v) {
                setState(() {
                  likeNoti = v;
                });
              },
            ),
            _NotiTile(
              title: '이메일 알림',
              subtitle: '이메일로 알림을 받습니다',
              value: emailNoti,
              enabled: allNoti,
              onChanged: (v) {
                setState(() {
                  emailNoti = v;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NotiTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _NotiTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = enabled ? AppColors.grey_8 : AppColors.grey_4;
    final subColor = enabled ? AppColors.grey_5 : AppColors.grey_3;

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.pretendard_medium.copyWith(
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.pretendard_regular.copyWith(
                    fontSize: 12,
                    color: subColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.main,
            activeTrackColor: AppColors.main_30per,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.grey_3,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
