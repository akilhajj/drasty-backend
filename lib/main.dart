import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const DrastyApp());

class DrastyApp extends StatelessWidget {
  const DrastyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منصة دراستي التعليمية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0B0C), // أسود مطفي فاخر لـ drasty.net
        primaryColor: const Color(0xFFD4AF37), // ذهبي ملكي ناصع
      ),
      home: const UnifiedLoginScreen(),
    );
  }
}

// 🔐 واجهة الدخول الموحدة الفاخرة لـ drasty.net (توجيه تلقائي للأدوار بـ API حقيقي)
class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({Key? key}) : super(key: key);

  @override
  _UnifiedLoginScreenState createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // دالة تسجيل الدخول الآمنة المتصلة حياً برابط سيرفر Render الخاص بك
  void _executeSecureAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse('https://onrender.com'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        // فحص دور المستخدم القادم من قاعدة بيانات كلواد فلير وتوجيهه تلقائياً لشاشته الفاخرة
        if (data['role'] == 'teacher') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TeacherDashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentDashboard()));
        }
      } else {
        _showSnackBar(data['message'] ?? 'خطأ في عملية الدخول');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('تأكد من اتصال السيرفر بالإنترنت السحابي السوري');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: Colors.redAccent.withOpacity(0.85)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: const Color(0xFF19191B), // كرت زجاجي داكن
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)), // حواف ذهبية نحيفة ونظيفة
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('drasty.net', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37), letterSpacing: 1.5)),
                const SizedBox(height: 5),
                const Text('بوابة التعليم الذكي والأمان الصارم', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 35),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني الموحد',
                    labelStyle: TextStyle(color: Color(0xFFD4AF37)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور المشفرة',
                    labelStyle: TextStyle(color: Color(0xFFD4AF37)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                  ),
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)))
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _executeSecureAuth,
                        child: const Text('تسجيل الدخول الموحد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// 📚 2. واجهة خريطة مسار الطالب المتسلسلة والذكاء الاصطناعي الصوتي الهجين (RAG)
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final List<String> subjects = const [
    'العلوم العامة (الفيزياء والكيمياء والعلوم)',
    'اللغة العربية',
    'اللغة الفرنسية',
    'الرياضيات',
    'اللغة الإنكليزية',
    'الاجتماعيات (التاريخ والجغرافيا)',
    'التربية الدينية (تفتح بعد التفعيل اليدوي)'
  ];

  String _aiResponseText = "اضغط على الميكروفون الذهبي بالأسفل واسألني أي سؤال في مناهج سوريا الـ PDF!";
  bool _isListening = false;

  // دالة إرسال السؤال الصوتي والنصي الهجين إلى سيرفر Render حياً بدون VPN
  void _askHybridAI(String studentQuestion) async {
    setState(() => _isListening = true);
    try {
      final response = await http.post(
        Uri.parse('https://onrender.com'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': studentQuestion,
          'isVoice': true // طلب النطق الصوتي التلقائي والرد الصوتي (Voice-to-Voice)
        }),
      );

      final data = jsonDecode(response.body);
      setState(() {
        _aiResponseText = data['answerText'] ?? "عذراً يا بطل، لم أستطع معالجة السؤال حالياً.";
        _isListening = false;
      });

      if (data['success'] == true && data['mode'] == 'voice') {
        _showNotificationToast("جاري تشغيل الإجابة الصوتية الملكية عبر مكبر الهاتف... 🔊");
      }
    } catch (e) {
      setState(() => _isListening = false);
      _showNotificationToast("خطأ في الاتصال بمحرك الذكاء الاصطناعي السحابي لمنصة دراستي");
    }
  }

  void _showNotificationToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 3)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دراستي - المسار الأكاديمي الملكي', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0B0B0C),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🤖 كرت المساعد الأكاديمي الصوتي المدمج (Ultra-Premium Card)
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF19191B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.25)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 24),
                    const SizedBox(width: 10),
                    Text(_isListening ? "جاري قراءة المناهج والتحليل ضوئياً... 🧠" : "روبوت المحادثة الصوتي المباشر (RAG AI)", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                  ],
                ),
                const SizedBox(height: 15),
                Text(_aiResponseText, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white70), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                // زر الميكروفون الذهبي التفاعلي المشابه لأسلوب دولينجو في نطق البصمات الصوتية
                GestureDetector(
                  onTap: () => _askHybridAI("ما هي وظيفة الجسيمات الطرفية في درس مادة العلوم للبكالوريا؟"),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: _isListening ? Colors.redAccent : const Color(0xFFD4AF37),
                    child: Icon(_isListening ? Icons.graphic_eq : Icons.keyboard_voice, color: Colors.black, size: 26),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [Text("خريطة المناهج السبعة المتسلسلة (التلعيب الصارم):", style: TextStyle(fontSize: 12, color: Colors.grey))]),
          ),
          // 📚 قائمة المواد السبعة بالتتابع الخطي لدولينجو
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                bool isLocked = index > 0; // محاكاة فتح المادة الأولى فقط (العلوم) بقفل صلب لحين إنهاء الاختبارات
                return Container(
                  margin: const EdgeInsets.bottom(12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isLocked ? const Color(0xFF19191B).withOpacity(0.4) : const Color(0xFF19191B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isLocked ? Colors.transparent : const Color(0xFFD4AF37).withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('المادة 0${index + 1}', style: TextStyle(color: isLocked ? Colors.grey : const Color(0xFFD4AF37), fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(subjects[index], style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isLocked ? Colors.grey : Colors.white)),
                        ],
                      ),
                      Icon(isLocked ? Icons.lock_outline : Icons.play_arrow_sharp, color: isLocked ? Colors.grey : const Color(0xFFD4AF37), size: 24)
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
// 👨‍🏫 3. واجهة الأستاذ المساعد وجدول المراقبة وقفل الوقت الصارم لـ drasty.net
class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة المعلم والمراقب الأكاديمي', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: const Color(0xFF0B0B0C),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تذاكر الطلاب النشطة للدعم البشري (24/7)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: const Color(0xFF19191B), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.15))),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الطالبة رنا: أحتاج لتوضيح في قاعدة فرنسي صـ 12', style: TextStyle(fontSize: 13, color: Colors.white70)),
                  Text('دخول الغرفة 💬', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text('نظام تتبع الغش والامتحانات (موقوت وصارم)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.04), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.25))),
              child: const Column(
                children: [
                  Icon(Icons.lock_clock, color: Colors.red, size: 38),
                  SizedBox(height: 12),
                  Text('الشيفت مغلق / نظام المراقبة مقفل تلقائياً', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15)),
                  SizedBox(height: 6),
                  Text('لا يمكنك دخول لوحة تتبع الطلاب خارج أوقات الدوام الرسمي المحددة من 10:00 صباحاً وحتى 2:00 ظهراً بتوقيت سوريا.', style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
