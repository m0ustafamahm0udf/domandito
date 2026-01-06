import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/core/utils/utils.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/modules/profile/view/profile_screen.dart';
import 'package:domandito/modules/question/views/question_screen.dart';
import 'package:domandito/modules/answer/views/answer_question_screen.dart';
import 'package:domandito/shared/models/like_model.dart';
import 'package:domandito/shared/services/like_service.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:svg_flutter/svg_flutter.dart';
import 'package:domandito/shared/services/question_service.dart';
import 'package:domandito/shared/widgets/time_ago_widget.dart';

class QuestionCard extends StatefulWidget {
  final QuestionModel question;
  final String receiverImage;
  final String receiverToken;

  final bool isInProfileScreen;
  final String currentProfileUserId;
  final Function(bool isPinned)? onPinToggle;
  final Function()? afterBack;

  final bool Function()? canPin;

  const QuestionCard({
    super.key,
    required this.question,
    required this.receiverImage,
    this.isInProfileScreen = true,
    required this.receiverToken,
    this.afterBack,
    required this.currentProfileUserId,
    this.onPinToggle,
    this.canPin,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard>
    with AutomaticKeepAliveClientMixin {
  bool isLiked = false;
  bool isPinned = false;
  int likesCount = 0;
  bool isProcessing = false;
  late QuestionModel question;
  // bool isVerified = false;

  @override
  void initState() {
    super.initState();
    initializeState();
  }

  @override
  void didUpdateWidget(covariant QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always sync state if the model changes or if the ID changes
    // Since QuestionModel is mutable, we should refresh if the parent rebuilds
    initializeState();
  }

  void initializeState() {
    question = widget.question;
    likesCount = question.likesCount;
    isLiked = question.isLiked;
    // Ensure local isPinned syncs with model
    isPinned = question.isPinned;
  }

  Future<void> toggleLike() async {
    if (!MySharedPreferences.isLoggedIn) {
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'Please log in'
            : 'يرجى تسجيل الدخول',
        isLogin: true,
      );
      return;
    }
    if (!await hasInternetConnection()) {
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'No internet connection'
            : 'لا يوجد اتصال بالانترنت',
      );
      return;
    }
    if (isProcessing) return; // لو فيه عملية شغالة ارجع

    // Use the passed receiverToken directly
    String usertokenIfisNotMe = widget.receiverToken;

    setState(() => isProcessing = true);

    final result = await LikeService.toggleLike(
      context: context,
      questionId: question.id,
      user: LikeUser(
        token: usertokenIfisNotMe,
        id: MySharedPreferences.userId,
        name: MySharedPreferences.userName,
        userName: MySharedPreferences.userUserName,
        image: MySharedPreferences.image,
      ),
    );

    setState(() {
      isLiked = result;
      likesCount += isLiked ? 1 : -1;
      question.likesCount += isLiked ? 1 : -1;
      question.isLiked = isLiked; // FIX: Update the model!
      isProcessing = false;
    });
  }

  Future<void> togglePin() async {
    if (!MySharedPreferences.isLoggedIn) return;
    if (!await hasInternetConnection()) {
      AppConstance().showInfoToast(
        context,
        msg: !context.isCurrentLanguageAr()
            ? 'No internet connection'
            : 'لا يوجد اتصال بالانترنت',
      );
      return;
    }

    final newStatus = !isPinned;

    if (newStatus && widget.canPin != null && !widget.canPin!()) {
      return;
    }

    // Optimistic update
    setState(() {
      isPinned = newStatus;
    });

    // Show toast immediately before potentially unmounting
    if (mounted) {
      AppConstance().showSuccesToast(
        context,
        msg: newStatus
            ? (!context.isCurrentLanguageAr()
                  ? 'Pinned successfully'
                  : 'تم التثبيت')
            : (!context.isCurrentLanguageAr()
                  ? 'Unpinned successfully'
                  : 'تم إلغاء التثبيت'),
      );
    }

    // Notify parent immediately for instant UI update
    // This might cause the widget to be removed from the tree
    widget.onPinToggle?.call(newStatus);

    try {
      // Pass the NEW status (which is isPinned now) to toggle it
      await QuestionService().togglePin(question.id, newStatus);
    } catch (e) {
      // Notify parent to revert
      widget.onPinToggle?.call(!newStatus);

      if (mounted) {
        // Revert on error
        setState(() {
          isPinned = !newStatus;
        });

        AppConstance().showErrorToast(
          context,
          msg: !context.isCurrentLanguageAr() ? 'Error' : 'حدث خطأ',
        );
      }
      debugPrint("Error toggling pin: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // log('build');
    super.build(context);
    final displayName = question.isAnonymous
        ? !context.isCurrentLanguageAr()
              ? "Anonymous"
              : "مجهول"
        : question.sender.name;

    return PopScope(
      canPop: !isProcessing,
      child: Hero(
        tag: 'question_${question.id}',
        child: GestureDetector(
          onTap: () {
            if (isProcessing) {
              AppConstance().showInfoToast(
                context,
                msg: !context.isCurrentLanguageAr()
                    ? 'Please wait'
                    : 'يرجى الانتظار',
              );
              return;
            }

            pushScreen(
              context,
              screen: QuestionScreen(
                isVerified: question.sender.isVerified,

                currentProfileUserId: widget.currentProfileUserId,
                onBack: (q) async {},
                question: question,
                receiverImage: widget.receiverImage,
              ),
            );
          },
          child: Card(
            color: AppColors.white,
            elevation: 8,
            shadowColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstance.hPadding,
                vertical: AppConstance.vPaddingTiny,
              ),
              child: SizedBox(
                height: widget.isInProfileScreen && isPinned ? 170 : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header ---
                    GestureDetector(
                      onTap: () {
                        final isMe =
                            MySharedPreferences.userId == question.sender.id;
                        final isSameProfile =
                            widget.isInProfileScreen &&
                            widget.currentProfileUserId == question.sender.id;

                        if (!question.isAnonymous &&
                            !isProcessing &&
                            !isMe &&
                            !isSameProfile) {
                          pushScreen(
                            context,
                            screen: ProfileScreen(userId: question.sender.id),
                          );
                        }
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            if (question.isAnonymous)
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: AppColors.primary,
                                child: SvgPicture.asset(
                                  AppIcons.anonymous,
                                  height: 21,
                                  width: 21,
                                  color: AppColors.white,
                                ),
                              )
                            else
                              CustomNetworkImage(
                                url: question.sender.image.toString(),
                                radius: 999,
                                height: 30,
                                width: 30,
                              ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        displayName,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 1),
                                      if (!question.isAnonymous &&
                                          question.sender.isVerified)
                                        SvgPicture.asset(
                                          AppIcons.verified,
                                          height: 15,
                                          width: 15,
                                          color: AppColors.primary,
                                        ),
                                    ],
                                  ),
                                  Text(
                                    question.isAnonymous
                                        ? "@x"
                                        : "@${question.sender.userName}",
                                    maxLines: 1,
                                    textDirection: TextDirection.ltr,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TimeAgoWidget(
                                  date:
                                      question.answeredAt ?? question.createdAt,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (MySharedPreferences.userId ==
                                    question.receiver.id &&
                                widget.isInProfileScreen) ...[
                              const SizedBox(width: 10),
                              GestureDetector(
                                child: SvgPicture.asset(
                                  AppIcons.pin,
                                  color: isPinned
                                      ? AppColors.primary
                                      : Colors.grey,
                                  height: 20,
                                  width: 20,
                                ),
                                onTap: () {
                                  togglePin();
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    // --- Question title ---
                    if (question.title.isNotEmpty)
                      GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(
                            ClipboardData(text: question.title),
                          ).then((value) {
                            AppConstance().showInfoToast(
                              context,
                              msg: !context.isCurrentLanguageAr()
                                  ? 'Question copied'
                                  : 'تم نسخ السؤال',
                            );
                          });
                        },
                        child: Align(
                          alignment: isArabic(question.title)
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(
                            question.title,
                            textDirection: isArabic(question.title)
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            textAlign: isArabic(question.title)
                                ? TextAlign.right
                                : TextAlign.left,
                            overflow: !widget.isInProfileScreen
                                ? null
                                : TextOverflow.ellipsis,
                            maxLines: !widget.isInProfileScreen ? null : 6,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 5),

                    // --- Answer row ---
                    if (question.answerText != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: InkWell(
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  overlayColor: WidgetStatePropertyAll(
                                    Colors.transparent,
                                  ),
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    if (isProcessing) {
                                      AppConstance().showInfoToast(
                                        context,
                                        msg: !context.isCurrentLanguageAr()
                                            ? 'Please wait'
                                            : 'يرجى الانتظار',
                                      );
                                      return;
                                    }

                                    pushScreen(
                                      context,
                                      screen: QuestionScreen(
                                        isVerified: question.sender.isVerified,
                                        currentProfileUserId:
                                            widget.currentProfileUserId,
                                        onBack: (q) async {},
                                        question: question,
                                        receiverImage: widget.receiverImage,
                                      ),
                                    );
                                  },
                                  onLongPress: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: question.answerText.toString(),
                                      ),
                                    ).then((value) {
                                      AppConstance().showInfoToast(
                                        context,
                                        msg: !context.isCurrentLanguageAr()
                                            ? 'Answer copied'
                                            : 'تم نسخ الإجابة',
                                      );
                                    });
                                  },
                                  child: isPinned && widget.isInProfileScreen
                                      ? Text(
                                          question.answerText.toString(),
                                          textAlign:
                                              isArabic(
                                                question.answerText ?? '',
                                              )
                                              ? TextAlign.right
                                              : TextAlign.left,
                                          textDirection:
                                              isArabic(
                                                question.answerText ?? '',
                                              )
                                              ? TextDirection.rtl
                                              : TextDirection.ltr,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: const TextStyle(fontSize: 16),
                                        )
                                      : linkifyText(
                                          context: context,
                                          text: question.answerText.toString(),
                                          isInProfileScreen:
                                              widget.isInProfileScreen,
                                        ),
                                ),
                              ),
                            ],
                          ),
                          if (question.isEdited && !isPinned)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                !context.isCurrentLanguageAr()
                                    ? 'Edited'
                                    : 'تم تعديله',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    // Media display (Images/Video)
                    ...mediaDisplay(context),

                    // Spacer for pinned questions to push bottom row down
                    if (widget.isInProfileScreen && isPinned) const Spacer(),

                    // --- Like Button row ---
                    if (question.answerText != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomNetworkImage(
                            url: widget.receiverImage,
                            radius: 999,
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(width: 5),
                          if (question.receiver.userName.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                final isMe =
                                    MySharedPreferences.userId ==
                                    question.receiver.id;
                                final isSameProfile =
                                    widget.isInProfileScreen &&
                                    widget.currentProfileUserId ==
                                        question.receiver.id;

                                if (!isProcessing && !isMe && !isSameProfile) {
                                  pushScreen(
                                    context,
                                    screen: ProfileScreen(
                                      userId: question.receiver.id,
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                "@${question.receiver.userName}",
                                maxLines: 1,
                                textDirection: TextDirection.ltr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          else
                            Spacer(),
                          Spacer(),

                          Row(
                            children: [
                              Text(
                                likesCount < 1 ? '0' : formatNumber(likesCount),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 4),

                              GestureDetector(
                                onTap: toggleLike,
                                child: isProcessing
                                    ? Column(
                                        children: [
                                          const SizedBox(height: 10.5),

                                          SizedBox(
                                            width: 22,
                                            height: 1,
                                            child: LinearProgressIndicator(),
                                          ),
                                          // if (isProcessing)
                                          const SizedBox(height: 10.5),
                                        ],
                                      )
                                    : SvgPicture.asset(
                                        AppIcons.heart,
                                        color: isLiked
                                            ? AppColors.primary
                                            : Colors.grey.shade300,
                                        height: 22,
                                      ),
                              ),
                            ],
                          ),
                          // Edit Button for Owner
                          if (MySharedPreferences.userId ==
                                  question.receiver.id &&
                              widget.isInProfileScreen) ...[
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () async {
                                // Navigate to Answer Screen with current answer
                                final updatedQuestion = await pushScreen(
                                  context,
                                  screen: AnswerQuestionScreen(
                                    question: question,
                                    answerText:
                                        question.answerText, // Enable Edit Mode
                                  ),
                                );

                                if (updatedQuestion != null &&
                                    updatedQuestion is QuestionModel) {
                                  setState(() {
                                    question = updatedQuestion;
                                    // Sync local state variables with the updated model
                                    likesCount = question.likesCount;
                                    isLiked = question.isLiked;
                                    isPinned = question.isPinned;
                                  });
                                }
                              },
                              child: SvgPicture.asset(
                                AppIcons.edit,
                                color: Colors.grey,
                                height: 20,
                              ),
                            ),
                          ],
                        ],
                      ),
                    if (isPinned) const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> mediaDisplay(BuildContext context) {
    return [
      // If pinned and in profile screen, show only icon
      if (isPinned && widget.isInProfileScreen) ...[
        if ((question.mediaType == 'image' ||
                (question.mediaType == null && question.videoUrl == null)) &&
            question.images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.image, size: 16, color: AppColors.primary),
                // const SizedBox(width: 4),
                // Text(
                //   !context.isCurrentLanguageAr() ? 'Image' : 'صورة',
                //   style: TextStyle(fontSize: 12, color: AppColors.primary),
                // ),
              ],
            ),
          ),
        if ((question.mediaType == 'video' ||
                (question.mediaType != 'image' && question.videoUrl != null)) &&
            question.videoUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.videocam, size: 16, color: AppColors.primary),
                // const SizedBox(width: 4),
                // Text(
                //   !context.isCurrentLanguageAr() ? 'Video' : 'فيديو',
                //   style: TextStyle(fontSize: 12, color: AppColors.primary),
                // ),
              ],
            ),
          ),
      ] else ...[
        // Normal display (Video/Images)
        // Show images only if mediaType is 'image' or if there are images and no video
        if ((question.mediaType == 'image' ||
                (question.mediaType == null && question.videoUrl == null)) &&
            question.images.isNotEmpty)
          const SizedBox(height: 5),
        if ((question.mediaType == 'image' ||
                (question.mediaType == null && question.videoUrl == null)) &&
            question.images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: buildImages(question.images),
          ),

        // Video display - show if mediaType is 'video' OR if videoUrl exists
        if ((question.mediaType == 'video' ||
                (question.mediaType != 'image' && question.videoUrl != null)) &&
            question.videoUrl != null)
          Column(
            children: [
              const SizedBox(height: 5),
              Stack(
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          question.thumbnailUrl != null &&
                              question.thumbnailUrl!.isNotEmpty
                          ? CustomNetworkImage(
                              url: question.thumbnailUrl!,
                              boxFit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              radius: 0,
                            )
                          : Icon(
                              Icons.videocam,
                              size: 20,
                              color: AppColors.primary,
                            ),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        const SizedBox(height: 8),
      ],
    ];
  }

  onImageTapped(int index, List<String> images) {
    if (isProcessing) {
      return;
    }
    // if (!widget.isInProfileScreen) {
    //   pushScreen(
    //     context,
    //     screen: ImageViewScreen(
    //       images: images,
    //       initialIndex: index,
    //       // title: '',
    //       onBack: (index) {},
    //     ),
    //   );
    // } else
    // {
    pushScreen(
      context,
      screen: QuestionScreen(
        isVerified: question.sender.isVerified,

        currentProfileUserId: widget.currentProfileUserId,

        onBack: (q) async {
          // setState(() {
          //   log('back');

          //   question = q;
          //   isLiked = question.isLiked;
          //   likesCount = question.likesCount;
          // });
          // await checkIfLiked();
        },
        question: question,
        receiverImage: widget.receiverImage,
      ),
    );
    // }
  }

  Widget buildImages(List<String> images) {
    if (images.isEmpty) return const SizedBox();

    // صورة واحدة
    if (images.length == 1) {
      return GestureDetector(
        onTap: () {
          // هنا تحط أي حدث عايز تنفذه عند الضغط
          print("Tapped image 0");
          onImageTapped(0, images);
        },
        child: CustomNetworkImage(
          radius: 12,
          boxFit: BoxFit.cover,
          url: images[0],
          height: 300,
          width: double.infinity,
        ),
      );
    }

    // صورتين
    if (images.length == 2) {
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onImageTapped(0, images),

              child: CustomNetworkImage(
                radius: 18,
                boxFit: BoxFit.cover,
                url: images[0],
                height: 180,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => onImageTapped(1, images),
              child: CustomNetworkImage(
                radius: 18,
                boxFit: BoxFit.cover,
                url: images[1],
                height: 180,
              ),
            ),
          ),
        ],
      );
    }

    // أكثر من صورتين
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onImageTapped(index, images),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CustomNetworkImage(
                  url: images[index],
                  height: 180,
                  width: 140,
                  radius: 18,
                  boxFit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
