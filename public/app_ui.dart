import 'package:flutter/material.dart';

void main() => runApp(const DrastyApp());

class DrastyApp extends StatelessWidget {
  const DrastyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دراستي.نت',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0XXB0B0C), // أسود مطفي عميق
        primaryColor: const Color(0XFFD4AF37), // ذهبي ملكي
      ),
      home: const UnifiedLoginScreen(),
    );
  }
}

// 🔐 1. واجهة الدخول الموحدة الفاخرة لـ drasty.net (أسود x ذهبي)
class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({Key? key}) : super(key: key);

  @override
  _UnifiedLoginScreenState createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: const Color(0XFF19191B).withOpacity(0.85), // كرت زجاجي داكن
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0XFFD4AF37).withOpacity(0.2), width: 1), // حواف ذهبية نحيفة
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'drasty.net',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFFD4AF37), // نص ذهبي
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'منصة دراستي التعليمية الموحدة',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // حقل البريد الإلكتروني
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    labelStyle: TextStyle(color: Color(0XFFD4AF37)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0XFFD4AF37))),
                  ),
                ),
                const SizedBox(height: 20),
                // حقل كلمة المرور
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    labelStyle: TextStyle(color: Color(0XFFD4AF37)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0XFFD4AF37))),
                  ),
                ),
                const SizedBox(height: 35),
                // زر الدخول الملكي بنظام التوجيه التلقائي للأدوار
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFFD4AF37), // لون ذهبي
                    foregroundColor: Colors.black, // نص أسود ملكي
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // نظام فحص الأدوار التلقائي سيوجه المستخدم فوراً للشاشة المناسبة له
                    if (_emailController.text == 'teacher@drasty.net') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherDashboard()));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentDashboard()));
                    }
                  },
                  child: const Text('تسجيل الدخول الآمن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 📚 2. واجهة خريطة مسار الطالب المتسلسلة (7 مواد بالترتيب)
class StudentDashboard extends StatelessWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  final List<String> subjects = const [
    'العلوم العامة (الفيزياء والكيمياء)',
    'اللغة العربية',
    'اللغة الفرنسية',
    'الرياضيات',
    'اللغة الإنكليزية',
    'الاجتماعيات (التاريخ والجغرافيا)',
    'التربية الدينية (تفتح يدويًا)'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مساري التعليمي - دراستي', style: TextStyle(color: Color(0XFFD4AF37))),
        backgroundColor: const Color(0XXB0B0C),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          bool isLocked = index > 0; // محاكاة قفل المواد المتسلسلة (العلوم فقط مفتوحة في البداية)
          return Container(
            margin: const EdgeInsets.bottom(15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isLocked ? const Color(0XFF19191B).withOpacity(0.4) : const Color(0XFF19191B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLocked ? Colors.grey.withOpacity(0.1) : const Color(0XFFD4AF37).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('المادة 0${index + 1}', style: TextStyle(color: isLocked ? Colors.grey : const Color(0XFFD4AF37), fontSize: 12)),
                    const SizedBox(height: 5),
                    Text(subjects[index], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isLocked ? Colors.grey : Colors.white)),
                  ],
                ),
                Icon(
                  isLocked ? Icons.lock_outline : Icons.play_circle_fill_outlined,
                  color: isLocked ? Colors.grey : const Color(0XFFD4AF37),
                  size: 28,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// 👨‍🏫 3. واجهة الأستاذ وجدول المراقبة وقفل الوقت الصارم
class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة المعلم والمراقب المساعد', style: TextStyle(color: Color(0XFFD4AF37))),
        backgroundColor: const Color(0XXB0B0C),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // تذاكر الدعم الأكاديمي المتاحة دائماً 24/7
            const Text('تذاكر مساعدة الطلاب النشطة (24/7)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0XFF19191B), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0XFFD4AF37).withOpacity(0.2))),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الطالب أحمد: سؤال في مسألة الرياضيات صـ 40', style: TextStyle(fontSize: 14)),
                  Text('رد الآن 💬', style: TextStyle(color: Color(0XFFD4AF37), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // قسم مراقبة الامتحانات الخاضع لقفل الوقت الصارم من السيرفر
            const Text('نظام مراقبة الامتحانات السري (موقوت)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.lock_clock, color: Colors.red, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'الشيفت مغلق حالياً / ميزة المراقبة مقفلة',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'نظام كشف غش الطلاب يفتح صارماً فقط من الساعة 10:00 صباحاً وحتى 2:00 ظهراً بتوقيت سوريا.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
