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
        scaffoldBackgroundColor: const Color(0xFF0B0B0C), // أسود مطفي فاخر
        primaryColor: const Color(0xFFD4AF37), // ذهبي ملكي
      ),
      home: const UnifiedLoginScreen(),
    );
  }
}

// 🔐 واجهة الدخول الموحدة الفاخرة لـ drasty.net (توجيه تلقائي للأدوار)
class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({Key? key}) : super(key: key);

  @override
  _UnifiedLoginScreenState createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // دالة تسجيل الدخول المتصلة حياً بسيرفر Render الخاص بك
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
        // فحص الدور القادم من قاعدة بيانات كلواد فلير وتوجيهه تلقائياً لشاشته الملكية
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
      _showSnackBar('تأكد من اتصال السيرفر بالإنترنت السحابي');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red.withOpacity(0.8)));
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
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)), // حواف ذهبية نحيفة
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
                    focusedBorder: UnderlineInputBorder(borde// 📚 2. واجهة خريطة مسار الطالب المتسلسلة والذكاء الاصطناعي الصوتي الهجين (RAG)
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final List<String> subjects = const [
    'العلوم العامة (الفيزياء والكيمياء)',
    'اللغة العربية',
    'اللغة الفرنسية',
    'الرياضيات',
    'اللغة الإنكليزية',
    'الاجتماعيات (التاريخ والجغرافيا)',
    'التربية الدينية (تفتح يدويًا)'
  ];

  String _aiResponseText = "اضغط على الميكروفون بالأسفل واسألني أي سؤال في المنهج السوري!";
  bool _isListening = false;

  // دالة إرسال السؤال الصوتي والنصي إلى محرك الـ AI وسيرفر Render حياً
  void _askHybridAI(String studentQuestion) async {
    setState(() => _isListening = true);
    try {
      final response = await http.post(
        Uri.parse('https://onrender.com'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': studentQuestion,
          'isVoice': true // تفعيل النطق الصوتي التلقائي والرد الصوتي
        }),
      );

      final data = jsonDecode(response.body);
      setState(() {
        _aiResponseText = data['answerText'] ?? "عذراً يا بطل، تكرر المحاولة.";
        _isListening = false;
      });

      // تنبيه الطالب بنجاح نطق الإجابة صوتياً عبر التطبيق
      if (data['success'] == true && data['mode'] == 'voice') {
        _showNativeToast("جاري تشغيل الإجابة الصوتية الفاخرة... 🔊");
      }
    } catch (e) {
      setState(() => _isListening = false);
      _showNativeToast("خطأ في الاتصال بمحرك الذكاء الاصطناعي السحابي");
    }
  }

  void _showNativeToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('منصة دراستي - المسار الملكي', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0B0B0C),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🤖 نافذة المساعد الأكاديمي الصوتي المدمجة (Ultra-Premium Card)
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF19191B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: Color(0xFFD4AF37), size: 28),
                    const SizedBox(width: 10),
                    Text(_isListening ? "جاري التفكير وقراءة كتب المنهج... 🧠" : "مساعدك الصوتي الذكي (RAG AI)", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                  ],
                ),
                const SizedBox(height: 15),
                Text(_aiResponseText, style: const TextStyle(fontSize: 14, height: 1.5), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                // زر الميكروفون الذهبي التفاعلي المشابه لدولينجو الفاخر
                GestureDetector(
                  onTap: () => _askHybridAI("اشرح لي أهمية درس العصبونات في كتاب العلوم للثالث الثانوي العلمي"),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: _isListening ? Colors.red : const Color(0xFFD4AF37),
                    child: Icon(_isListening ? Icons.graphic_eq : Icons.mic, color: Colors.black, size: 28),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10),
          // 📚 قائمة المواد السبعة المتسلسلة تتابعياً بدقة
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                bool isLocked = index > 0; // محاكاة تفعيل المادة الأولى فقط (العلوم) بقفل 3D صلب
                return Container(
                  margin: const EdgeInsets.bottom(15),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isLocked ? const Color(0xFF19191B).withOpacity(0.4) : const Color(0xFF19191B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isLocked ? Colors.transparent : const Color(0xFFD4AF37).withOpacity(0.4)),
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
                      Icon(isLocked ? Icons.lock_clock_outlined : Icons.play_circle_filled, color: isLocked ? Colors.grey : const Color(0xFFD4AF37), size: 26)
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
rSide: BorderSide(color: Color(0xFFD4AF37))),
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
