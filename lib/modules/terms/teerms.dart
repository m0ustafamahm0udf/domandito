// import 'package:flutter/material.dart';

// class TermsScreen extends StatelessWidget {
//   const TermsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'الشروط والأحكام',
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 'مرحبًا بك في تطبيق "Domandito". يرجى قراءة الشروط والأحكام التالية بعناية قبل استخدام التطبيق. '
//                 'باستخدامك للتطبيق، فإنك توافق على الالتزام بجميع الشروط والأحكام الواردة هنا:',
//               ),
//               const SizedBox(height: 20),

//               _buildSection(
//                 '1. المحتوى:',
//                 '• جميع المحتويات المقدمة في تطبيق "Domandito" هي لأغراض معلوماتية وترفيهية وتعليمية فقط.\n'
//                 '• لا يجوز لأي فرد أو جهة استخدام أو نسخ أو نشر أو توزيع أو تعديل المحتوى دون إذن خطي صريح من إدارة التطبيق.',
//               ),

//               _buildSection(
//                 '2. الحسابات الشخصية:',
//                 '• عند إنشاء حساب شخصي في تطبيق "Domandito"، يجب تقديم معلومات دقيقة وصحيحة.\n'
//                 '• يُحظر تمامًا إنشاء حسابات وهمية أو استخدام حسابات الآخرين دون إذن مسبق.',
//               ),

//               _buildSection(
//                 '3. حقوق النشر:',
//                 '• جميع حقوق الملكية الفكرية للمحتوى الموجود في تطبيق "Domandito" تعود لإدارة التطبيق أو للجهات المرخصة لها.\n'
//                 '• لا يُسمح بنسخ أو نقل أو توزيع أو إعادة نشر المحتوى دون إذن مسبق من إدارة التطبيق.',
//               ),

//               _buildSection(
//                 '4. الاستخدام الشخصي:',
//                 '• يُسمح للأصدقاء باستخدام تطبيق "Domandito" لأغراض شخصية وغير تجارية فقط.\n'
//                 '• لا يجوز استخدام التطبيق بأي طريقة تنتهك القوانين المحلية أو الدولية.',
//               ),

//               _buildSection(
//                 '5. المسؤولية:',
//                 '• لا نتحمل أي مسؤولية عن الأضرار المباشرة أو غير المباشرة الناتجة عن استخدام تطبيق "Domandito".\n'
//                 '• ننصح بتوخي الحذر عند التعامل مع أي بيانات متعلقة بالحجوزات أو عمليات الدفع داخل التطبيق.',
//               ),

//               _buildSection(
//                 '6. التحديثات والتعديلات:',
//                 '• نحتفظ بالحق في تغيير أو تحديث الشروط والأحكام دون إشعار مسبق.\n'
//                 '• يرجى مراجعة هذه الصفحة بانتظام للبقاء على اطلاع بأحدث التحديثات.',
//               ),

//               _buildSection(
//                 '7. المحتوى والتعليقات التي ينشئها المستخدمون:',
//                 '• نشجع الأصدقاء على مشاركة محتوى أصلي وإبداعي عبر التطبيق، ويتحمل المستخدم المسؤولية الكاملة عن محتواه.\n'
//                 '• تحتفظ إدارة التطبيق بالحق في حذف أو تعديل أي تعليقات أو محتوى يُعتبر غير مناسب أو مخالف لسياسات التطبيق.',
//               ),

//               _buildSection(
//                 '8. الحسابات والأمان:',
//                 '• يتحمل المستخدمون مسؤولية الحفاظ على سرية بيانات حساباتهم وعدم مشاركتها مع الآخرين.\n'
//                 '• في حال الاشتباه في اختراق الحساب، يجب إخطار إدارة التطبيق فورًا.',
//               ),

//               _buildSection(
//                 '9. إلغاء الحساب:',
//                 '• يحق للأصدقاء إلغاء حساباتهم في أي وقت ودون إبداء الأسباب.\n'
//                 '• عند إلغاء الحساب، يتم حذف جميع البيانات المرتبطة به من قاعدة بياناتنا.',
//               ),

//               _buildSection(
//                 '10. التحديثات وإخلاء المسؤولية:',
//                 '• نحتفظ بالحق في تحديث التطبيق أو إيقافه في أي وقت دون إشعار مسبق.\n'
//                 '• في حالة إيقاف التطبيق، فإننا غير مسؤولين عن أي خسائر أو أضرار قد تلحق بالأصدقاء.',
//               ),

//               _buildSection(
//                 '11. القانون والاختصاص القضائي:',
//                 '• تخضع الشروط والأحكام الخاصة بالتطبيق لقوانين وأنظمة جمهورية مصر العربية.\n'
//                 '• في حالة وجود أي نزاعات قانونية أو خلافات، فإن الاختصاص القضائي سيكون لدى المحاكم المصرية.',
//               ),

//               const SizedBox(height: 20),
//               const Text(
//                 'باستخدامك لتطبيق "Domandito" بعد قراءة هذه الشروط والأحكام، فإنك توافق على جميع البنود المذكورة. '
//                 'نحن نحترم خصوصية أصدقاءا ونسعى دائمًا لتعزيز تجربتهم داخل التطبيق. شكرًا لثقتكم بنا.',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   static Widget _buildSection(String title, String content) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 5),
//           Text(content),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms and Conditions',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Welcome to the "Domandito" application. Please read the following Terms and Conditions carefully before using the app. '
                'By using the application, you agree to comply with and be bound by all the terms and conditions stated below:',
              ),
              const SizedBox(height: 20),

              _buildSection(
                '1. Content:',
                '• All content provided in the "Domandito" application is for informational, entertainment, and educational purposes only.\n'
                    '• No individual or entity may use, copy, publish, distribute, modify, or reproduce any content without explicit written permission from the app administration.',
              ),

              _buildSection(
                '2. Personal Accounts:',
                '• When creating a personal account on the "Domandito" application, you must provide accurate and truthful information.\n'
                    '• Creating fake accounts or using other users’ accounts without prior permission is strictly prohibited.',
              ),

              _buildSection(
                '3. Intellectual Property Rights:',
                '• All intellectual property rights related to the content available in the "Domandito" application belong to the app administration or its licensed partners.\n'
                    '• Copying, transferring, distributing, or republishing any content without prior permission from the app administration is not allowed.',
              ),

              _buildSection(
                '4. Personal Use:',
                '• Users are allowed to use the "Domandito" application for personal and non-commercial purposes only.\n'
                    '• The application may not be used in any way that violates local or international laws.',
              ),

              _buildSection(
                '5. Liability:',
                '• We are not responsible for any direct or indirect damages resulting from the use of the "Domandito" application.\n'
                    '• Users are advised to exercise caution when dealing with any data related to reservations or payment processes within the application.',
              ),

              _buildSection(
                '6. Updates and Modifications:',
                '• We reserve the right to modify or update these Terms and Conditions at any time without prior notice.\n'
                    '• Please review this page regularly to stay informed of the latest updates.',
              ),

              _buildSection(
                '7. User-Generated Content and Comments:',
                '• Users are fully responsible for any content they submit through the application.\n'
                    '• Submitting abusive, offensive, or objectionable content is strictly prohibited.\n'
                    '• The app administration reserves the right to remove any content that violates community guidelines without prior notice.\n'
                    '• Repeated violations may result in temporary or permanent account suspension.',
              ),

              _buildSection(
                '8. Community Guidelines and Safety:',
                '• Domandito has a zero-tolerance policy for objectionable or abusive content.\n'
                    '• The following content is strictly prohibited:\n'
                    '  - Harassment or bullying\n'
                    '  - Hate speech or discrimination\n'
                    '  - Sexual, violent, or explicit content\n'
                    '  - Threats or encouragement of self-harm\n'
                    '• Users may report any content or user they find inappropriate directly within the app.\n'
                    '• Users may block other users. Blocking immediately removes the blocked user’s content from the feed.\n'
                    '• All reports are reviewed by the app administration within 24 hours.\n'
                    '• Content that violates these guidelines will be removed immediately, and the offending user may be suspended or permanently banned.',
              ),

              _buildSection(
                '9. Accounts and Security:',
                '• Users are responsible for maintaining the confidentiality of their account information and must not share it with others.\n'
                    '• If account security is suspected to be compromised, the app administration must be notified immediately.',
              ),

              _buildSection(
                '10. Account Termination:',
                '• Users have the right to delete their accounts at any time without providing a reason.\n'
                    '• Upon account deletion, all associated data will be removed from our database.',
              ),

              _buildSection(
                '11. Updates and Disclaimer:',
                '• We reserve the right to update or discontinue the application at any time without prior notice.\n'
                    '• In the event of application discontinuation, we shall not be liable for any losses or damages incurred by users.',
              ),

              _buildSection(
                '12. Governing Law and Jurisdiction:',
                '• These Terms and Conditions are governed by the laws and regulations of the Arab Republic of Egypt.\n'
                    '• Any legal disputes or claims shall fall under the exclusive jurisdiction of the Egyptian courts.',
              ),

              const SizedBox(height: 20),
              const Text(
                'By using the "Domandito" application after reading these Terms and Conditions, you agree to all the terms stated above. '
                'We respect our users’ privacy and always strive to enhance their experience within the application. Thank you for your trust.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(content),
        ],
      ),
    );
  }
}
