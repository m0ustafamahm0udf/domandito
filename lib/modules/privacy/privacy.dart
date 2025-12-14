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
                'سياسة الخصوصية',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'شكرًا لاستخدامك تطبيق "Domandito". نحن نقدر خصوصيتك وملتزمون بحماية معلوماتك الشخصية. يُرجى قراءة سياسة الخصوصية التالية لفهم كيفية جمع واستخدام المعلومات التي تقدمها لنا.',
              ),
              SizedBox(height: 20),
              _buildSection('1. جمع المعلومات:',
                  '• نقوم بجمع المعلومات الشخصية التي تقدمها طواعية عند إنشاء حساب شخصي، وهي تقتصر على الاسم ورقم الهاتف والبريد الإلكتروني.'),
              _buildSection('2. استخدام المعلومات:',
                  '• قد نستخدم معلوماتك للتواصل معك بخصوص العروض الخاصة والتحديثات.'),
              _buildSection(
                  '3. حماية المعلومات:',
                  '• نتخذ التدابير الأمنية المناسبة لحماية معلوماتك الشخصية من الوصول غير المصرح به أو الاستخدام غير المقصود.'
                      '\n• نستخدم التشفير والتدابير الأمنية لحماية معلوماتك أثناء الإرسال والتخزين.'),
              _buildSection(
                  '4. مشاركة المعلومات:',
                  '• لا نقوم ببيع أو تداول معلوماتك الشخصية مع أطراف ثالثة دون موافقتك.'
                      '\n• قد نشارك المعلومات الشخصية مع مزودي الخدمات الذين يساعدوننا في تشغيل التطبيق والموقع الإلكتروني، لكننا ملتزمون بحماية خصوصية المعلومات وعدم استخدامها لأغراض أخرى.'),
              _buildSection('5. ملفات تعريف الارتباط (Cookies):',
                  '• لا نستخدم ملفات تعريف الارتباط لتحسين تجربتك أو تخصيص المحتوى.'),
              _buildSection(
                  '6. حقوق الوصول والتعديل:',
                  '• لديك الحق في الوصول إلى معلوماتك الشخصية التي بحوزتنا وطلب تحديثها أو حذفها عند الضرورة.'
                      '\n• يمكنك التواصل معنا عبر البريد الإلكتروني لطلب الوصول إلى معلوماتك أو تعديلها.'),
              _buildSection(
                  '7. تحديثات السياسة:',
                  '• نحتفظ بالحق في تحديث سياسة الخصوصية هذه بشكل دوري وفقًا للاحتياجات والتطورات.'
                      '\n• يُنصح بمراجعة سياسة الخصوصية بانتظام للبقاء على اطلاع على أحدث التحديثات.'),
              SizedBox(height: 20),
              Text(
                'إذا كان لديك أي أسئلة أو استفسارات بخصوص سياسة الخصوصية، يُرجى التواصل معنا عبر وسائل الاتصال المتاحة في التطبيق.',
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
