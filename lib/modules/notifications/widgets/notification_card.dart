import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/answer/views/answer_question_screen.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/modules/notifications/models/notification_model.dart';
import 'package:domandito/modules/notifications/repositories/notifications_repository.dart';
import 'package:domandito/modules/question/views/question_screen.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:svg_flutter/svg_flutter.dart';
import 'package:domandito/core/services/badge_service.dart';

class NotificationCard extends StatefulWidget {
  final NotificationModel notificationsData;
  final VoidCallback? onRemove;

  const NotificationCard({
    super.key,
    required this.notificationsData,
    this.onRemove,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard>
    with AutomaticKeepAliveClientMixin {
  late bool _isRead;
  bool _isProcessing = false; // Prevent multiple taps

  @override
  void initState() {
    super.initState();
    _isRead = widget.notificationsData.isRead;
  }

  Future<void> _handleTap(BuildContext context) async {
    // Prevent multiple taps
    if (_isProcessing) return;
    _isProcessing = true;
    bool shouldUpdateReadStatus = false;

    if (widget.notificationsData.entityId != null) {
      // Fetch question details if needed to navigate
      try {
        final response = await Supabase.instance.client
            .from('questions')
            .select('*, sender:sender_id(*), receiver:receiver_id(*)')
            .eq('id', widget.notificationsData.entityId!)
            .maybeSingle();

        if (response != null && context.mounted) {
          final question = QuestionModel.fromJson(response);

          if (widget.notificationsData.type == AppConstance.answer) {
            // Go to Question Screen (which shows the answer)
            await pushScreen(
              context,
              screen: QuestionScreen(
                question: question,
                receiverImage: question.receiver.image,
                currentProfileUserId: question.receiver.id,
                isVerified: question.receiver.isVerified,
                onBack: (q) {},
              ),
            );
            shouldUpdateReadStatus = true;
          } else if (widget.notificationsData.type == AppConstance.question) {
            // Go to Answer Screen
            final result = await pushScreen(
              context,
              screen: AnswerQuestionScreen(question: question),
            );
            shouldUpdateReadStatus = true;
            if (result == true) {
              widget.onRemove?.call();
            }
          } else if (widget.notificationsData.type == AppConstance.like) {
            await pushScreen(
              context,
              screen: QuestionScreen(
                question: question,
                receiverImage: question.receiver.image,
                currentProfileUserId: question.receiver.id,
                isVerified: question.receiver.isVerified,
                onBack: (q) {},
              ),
            );
            shouldUpdateReadStatus = true;
          }
        }
      } catch (e) {
        // Handle error or show toast
      }
    } else {
      // For notifications without entityId like follow, just mark as read immediately if that's the desired behavior,
      // or if there is no navigation involved.
      shouldUpdateReadStatus = true;
    }

    // Mark as read after return if not already read
    if (shouldUpdateReadStatus && !_isRead) {
      if (mounted) {
        setState(() {
          _isRead = true;
        });
      }
      // Fire and forget usually, or await if critical
      NotificationsRepository().markAsRead(widget.notificationsData.id);
      BadgeService.updateBadgeCount();
    }

    // Reset processing flag
    _isProcessing = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Card(
        color: _isRead ? AppColors.white : AppColors.primary.withOpacity(0.1),
        elevation: 8,
        shadowColor: _isRead
            ? AppColors.white
            : AppColors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstance.hPadding,
            vertical: AppConstance.vPaddingTiny,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child:
                              widget.notificationsData.title == 'Anonymous' ||
                                  widget.notificationsData.title == 'مجهول' ||
                                  widget.notificationsData.type ==
                                      AppConstance.follow ||
                                  widget.notificationsData.type ==
                                      AppConstance.like
                              ? CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primary,
                                  child: SvgPicture.asset(
                                    AppIcons.anonymous,
                                    height: 24,
                                    width: 24,
                                    color: AppColors.white,
                                  ),
                                )
                              : widget.notificationsData.sender?.image != null
                              ? CustomNetworkImage(
                                  url: widget.notificationsData.sender!.image,
                                  height: 40,
                                  width: 40,
                                  radius: 999,
                                )
                              : Container(
                                  height: 40,
                                  width: 40,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.person),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.notificationsData.title ?? 'Domandito',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              if (widget.notificationsData.body != null)
                                Text(
                                  getTranslatedContent(
                                    widget.notificationsData.body!,
                                    context,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        timeAgo(widget.notificationsData.createdAt, context),

                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      // const SizedBox(width: 15),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
              // if (!_isRead)
              //   Positioned(
              //     top: 0,
              //     right: 0,
              //     child: Container(
              //       height: 5,
              //       width: 5,
              //       decoration: const BoxDecoration(
              //         shape: BoxShape.circle,
              //         color: AppColors.primary,
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
