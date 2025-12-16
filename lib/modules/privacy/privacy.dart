// import 'package:flutter/material.dart';

// class PrivacyPolicyScreen extends StatelessWidget {
//   const PrivacyPolicyScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'سياسة الخصوصية',
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 'شكرًا لاستخدامك تطبيق "Domandito". نحن نقدر خصوصيتك وملتزمون بحماية معلوماتك الشخصية. يُرجى قراءة سياسة الخصوصية التالية لفهم كيفية جمع واستخدام المعلومات التي تقدمها لنا.',
//               ),
//               SizedBox(height: 20),
//               _buildSection('1. جمع المعلومات:',
//                   '• نقوم بجمع المعلومات الشخصية التي تقدمها طواعية عند إنشاء حساب شخصي، وهي تقتصر على الاسم ورقم الهاتف والبريد الإلكتروني.'),
//               _buildSection('2. استخدام المعلومات:',
//                   '• قد نستخدم معلوماتك للتواصل معك بخصوص العروض الخاصة والتحديثات.'),
//               _buildSection(
//                   '3. حماية المعلومات:',
//                   '• نتخذ التدابير الأمنية المناسبة لحماية معلوماتك الشخصية من الوصول غير المصرح به أو الاستخدام غير المقصود.'
//                       '\n• نستخدم التشفير والتدابير الأمنية لحماية معلوماتك أثناء الإرسال والتخزين.'),
//               _buildSection(
//                   '4. مشاركة المعلومات:',
//                   '• لا نقوم ببيع أو تداول معلوماتك الشخصية مع أطراف ثالثة دون موافقتك.'
//                       '\n• قد نشارك المعلومات الشخصية مع مزودي الخدمات الذين يساعدوننا في تشغيل التطبيق والموقع الإلكتروني، لكننا ملتزمون بحماية خصوصية المعلومات وعدم استخدامها لأغراض أخرى.'),
//               _buildSection('5. ملفات تعريف الارتباط (Cookies):',
//                   '• لا نستخدم ملفات تعريف الارتباط لتحسين تجربتك أو تخصيص المحتوى.'),
//               _buildSection(
//                   '6. حقوق الوصول والتعديل:',
//                   '• لديك الحق في الوصول إلى معلوماتك الشخصية التي بحوزتنا وطلب تحديثها أو حذفها عند الضرورة.'
//                       '\n• يمكنك التواصل معنا عبر البريد الإلكتروني لطلب الوصول إلى معلوماتك أو تعديلها.'),
//               _buildSection(
//                   '7. تحديثات السياسة:',
//                   '• نحتفظ بالحق في تحديث سياسة الخصوصية هذه بشكل دوري وفقًا للاحتياجات والتطورات.'
//                       '\n• يُنصح بمراجعة سياسة الخصوصية بانتظام للبقاء على اطلاع على أحدث التحديثات.'),
//               SizedBox(height: 20),
//               Text(
//                 'إذا كان لديك أي أسئلة أو استفسارات بخصوص سياسة الخصوصية، يُرجى التواصل معنا عبر وسائل الاتصال المتاحة في التطبيق.',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSection(String title, String content) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 5),
//           Text(content),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Thank you for using the "Domandito" application. We value your privacy and are committed to protecting your personal information. Please read the following Privacy Policy to understand how we collect and use the information you provide to us.',
              ),
              SizedBox(height: 20),
              _buildSection(
                '1. Information Collection:',
                '• We collect personal information that you voluntarily provide when creating a personal account, limited to your name, phone number, and email address.',
              ),
              _buildSection(
                '2. Use of Information:',
                '• We may use your information to contact you regarding special offers and updates.',
              ),
              _buildSection(
                '3. Information Protection:',
                '• We take appropriate security measures to protect your personal information from unauthorized access or unintended use.'
                '\n• We use encryption and security measures to protect your information during transmission and storage.',
              ),
              _buildSection(
                '4. Information Sharing:',
                '• We do not sell or trade your personal information with third parties without your consent.'
                '\n• We may share personal information with service providers who help us operate the application and website, and we are committed to protecting the privacy of such information and not using it for other purposes.',
              ),
              _buildSection(
                '5. Cookies:',
                '• We do not use cookies to improve your experience or personalize content.',
              ),
              _buildSection(
                '6. Access and Modification Rights:',
                '• You have the right to access the personal information we hold about you and request updates or deletion when necessary.'
                '\n• You may contact us via email to request access to or modification of your information.',
              ),
              _buildSection(
                '7. Policy Updates:',
                '• We reserve the right to update this Privacy Policy periodically in accordance with needs and developments.'
                '\n• We recommend reviewing the Privacy Policy regularly to stay informed of the latest updates.',
              ),
              SizedBox(height: 20),
              Text(
                'If you have any questions or inquiries regarding this Privacy Policy, please contact us through the contact methods available in the application.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(content),
        ],
      ),
    );
  }
}
