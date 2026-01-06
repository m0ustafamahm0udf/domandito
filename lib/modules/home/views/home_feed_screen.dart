import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/constants/app_icons.dart';
import 'package:domandito/core/services/launch_urls.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/core/utils/shared_prefrences.dart';
import 'package:domandito/modules/ask/models/q_model.dart';
import 'package:domandito/modules/search/search.dart';
import 'package:domandito/modules/signin/signin_screen.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/logo_widg.dart';
import 'package:domandito/shared/widgets/q_card.dart';
// import 'package:domandito/shared/models/follow_model.dart';
// import 'package:animate_do/animate_do.dart';
// import 'package:domandito/modules/profile/view/profile_screen.dart';
// import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:svg_flutter/svg_flutter.dart';
import 'package:domandito/shared/helpers/scroll_to_top_helper.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  // State for Questions
  final List<QuestionModel> _questions = [];
  bool _isLoading = true;
  bool _isMoreLoading = false;
  bool _hasMore = true;
  int _pageOffset = 0;
  final int _pageSize = 10;

  // Scroll to top helper
  late ScrollToTopHelper _scrollHelper;

  @override
  void initState() {
    super.initState();
    _scrollHelper = ScrollToTopHelper(onScrollComplete: () {});
    if (MySharedPreferences.isLoggedIn) {
      _initFeed();
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollHelper.dispose();
    super.dispose();
  }

  Future<void> _initFeed() async {
    setState(() => _isLoading = true);
    await _fetchQuestions();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchQuestions() async {
    if (_isMoreLoading) return;

    if (mounted) setState(() => _isMoreLoading = true);

    try {
      // 3. Fetch Questions using RPC (Server-side optimization)
      final List<dynamic> data = await Supabase.instance.client.rpc(
        'get_home_feed',
        params: {
          'p_user_id': MySharedPreferences.userId,
          'p_limit': _pageSize,
          'p_offset': _pageOffset,
        },
      );

      if (!mounted) return;

      if (data.isEmpty) {
        setState(() {
          _hasMore = false;
          _isMoreLoading = false;
        });
        return;
      }

      final newQuestions = data.map((e) => QuestionModel.fromJson(e)).toList();

      // Note: isLiked is already calculated by the RPC!

      setState(() {
        _questions.addAll(newQuestions);
        _pageOffset += newQuestions.length;
        _hasMore = data.length == _pageSize;
        _isMoreLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching questions: $e");
      if (mounted) {
        setState(() => _isMoreLoading = false);
        AppConstance().showErrorToast(
          context,
          msg: !context.isCurrentLanguageAr()
              ? 'Error loading feed'
              : 'خطأ في تحميل المحتوى',
        );
      }
    }
  }

  Future<void> _refresh() async {
    _questions.clear();
    _pageOffset = 0;
    _hasMore = true;

    await _initFeed();
  }

  @override
  Widget build(BuildContext context) {
    // log('build');
    return Scaffold(
      appBar: _buildAppBar(context),
      floatingActionButton: _scrollHelper.buildButton(),
      body: RefreshIndicator.adaptive(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: _scrollHelper.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 2. Empty State
            if (!_isLoading && _questions.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState()),

            // 3. Loading Indicator (Initial)
            if (_isLoading)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: context.h * 0.7,
                  child: const Center(
                    child: CupertinoActivityIndicator(color: AppColors.primary),
                  ),
                ),
              ),

            SliverToBoxAdapter(child: SizedBox(height: 10)),
            // 4. Questions List (The Infinite List)
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  child: Column(
                    children: [
                      QuestionCard(
                        question: _questions[index],
                        receiverImage: _questions[index].receiver.image,
                        receiverToken: _questions[index].receiver.token,
                        currentProfileUserId: _questions[index].receiver.id,
                        isInProfileScreen: false,
                      ),
                      // Separator logic inside builder
                      const SizedBox(height: 0),
                    ],
                  ),
                );
              }, childCount: _questions.length),
            ),

            // 5. Load More Button
            if (_hasMore && !_isLoading && _questions.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Center(
                    child: _isMoreLoading
                        ? const CupertinoActivityIndicator(
                            color: AppColors.primary,
                          )
                        : ElevatedButton(
                            onPressed: _fetchQuestions,
                            child: Text(
                              !context.isCurrentLanguageAr()
                                  ? "Load more"
                                  : "المزيد",
                            ),
                          ),
                  ),
                ),
              ),

            // 6. Download App Section (Web)
            if (kIsWeb) SliverToBoxAdapter(child: _buildDownloadAppSection()),

            // Bottom Padding
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Domandito',
        style: TextStyle(fontSize: 32, fontFamily: 'Dancing_Script'),
      ),
      // centerTitle: false,
      leading: !MySharedPreferences.isLoggedIn
          ? IconButton.filled(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(AppColors.white),
              ),
              onPressed: () {
                pushReplacementWithoutNavBar(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              icon: Directionality(
                textDirection: TextDirection.rtl,
                child: SvgPicture.asset(
                  AppIcons.logout,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
      actions: _questions.isNotEmpty
          ? [
              IconButton.filled(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(AppColors.white),
                ),
                onPressed: () =>
                    pushScreen(context, screen: const SearchUsersScreen()),
                icon: SvgPicture.asset(
                  AppIcons.searchIcon,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
            ]
          : null,
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LogoWidg(),
            const SizedBox(height: 16),
            if (MySharedPreferences.isLoggedIn)
              Text(
                !context.isCurrentLanguageAr()
                    ? 'Follow people to see their answers here'
                    : 'تابع المزيد من الأشخاص لرؤية إجاباتهم هنا',
                style: const TextStyle(color: AppColors.black, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            TextButton.icon(
              iconAlignment: IconAlignment.end,
              onPressed: () =>
                  pushScreen(context, screen: const SearchUsersScreen()),
              icon: SvgPicture.asset(
                AppIcons.searchIcon,
                color: AppColors.primary,
              ),
              label: Text(
                !context.isCurrentLanguageAr()
                    ? 'Find people to follow'
                    : 'ابحث عن أشخاص لمتابعتهم',
                style: const TextStyle(color: AppColors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadAppSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          !context.isCurrentLanguageAr() ? 'Download the app' : 'تحميل التطبيق',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () {
                LaunchUrlsService().launchBrowesr(
                  uri: AppConstance.appStoreUrl,
                  context: context,
                );
              },
              label: const Text('App Store'),
              icon: SvgPicture.asset(AppIcons.appstore, height: 25, width: 25),
            ),
            TextButton.icon(
              onPressed: () {
                LaunchUrlsService().launchBrowesr(
                  uri: AppConstance.googleplayUrl,
                  context: context,
                );
              },
              label: const Text('Google Play'),
              icon: SvgPicture.asset(
                AppIcons.googleplay,
                height: 25,
                width: 25,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
