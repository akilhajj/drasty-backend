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
        scaffoldBackgroundColor: const Color(0xFF0B0B0C), // أسود ملكي مطفي
        primaryColor: const Color(0xFFD4AF37), // التوهج الذهبي
      ),
      home: const UnifiedLoginScreen(),
    );
  }
}

class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({Key? key}) : super(key: key);

  @override
  _UnifiedLoginScreenState createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedGrade = 'baccalaureate'; // الخيار الافتراضي: بكالوريا
  bool _isLoading = false;

  void _executeSecureAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse('https://onrender.com'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
          'gradeType': _selectedGrade, // إرسال نوع الشهادة المحددة للسيرفر لفرز المناهج
        }),
      );

      final data = jsonDecode(response.body);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        if (data['role'] == 'teacher') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TeacherDashboard()));
        } else {
          // تمرير نوع الشهادة المحددة لواجهة الطالب لتبديل المواد السبعة تلقائياً
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => StudentDashboard(gradeType: _selectedGrade)));
        }
      } else {
        _showSnackBar(data['message'] ?? 'خطأ في عملية الدخول');
      }
    } catch (e) {
      if (!mounted) return;
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
              color: const Color(0xFF19191B), 
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)), 
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
                const SizedBox(height: 25),
                // 🎓 خيار تحديد المرحلة التعليمية الجديد والفاخر (تاسع / بكالوريا)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('المرحلة الدراسية:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    DropdownButton<String>(
                      value: _selectedGrade,
                      dropdownColor: const Color(0xFF19191B),
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
                      underline: Container(height: 1, color: const Color(0xFFD4AF37)),
                      items: const [
                        DropdownMenuItem(value: 'thirth_grade', child: Text('شهادة التعليم الأساسي (التاسع)', style: TextStyle(fontSize: 13, color: Colors.white))),
                        DropdownMenuItem(value: 'baccalaureate', child: Text('شهادة الثانوية العامة (البكالوريا)', style: TextStyle(fontSize: 13, color: Colors.white))),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedGrade = value!);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 35),
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
class StudentDashboard extends StatefulWidget {
  final String gradeType; // استقبال نوع الشهادة المحددة من شاشة الدخول
  const StudentDashboard({Key? key, required this.gradeType}) : super(key: key);

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  // فصل مواد التاسع عن البكالوريا بدقة طبقاً للمنهج السوري الوزاري
  final List<String> baccalaureateSubjects = const [
    'العلوم العامة (الفيزياء والكيمياء والعلوم للثانوية)',
    'اللغة العربية (البكالوريا)',
    'اللغة الفرنسية',
    'الرياضيات (الجبر والتحليل الهندسي)',
    'اللغة الإنكليزية',
    'الاجتماعيات (التاريخ والجغرافيا للثانوية)',
    'التربية الدينية (تفتح بعد التفعيل اليدوي)'
  ];

  final List<String> thirthGradeSubjects = const [
    'العلوم العامة والفيزياء (للتاسع الإعدادي)',
    'اللغة العربية (قواعد وإعراب التاسع)',
    'اللغة الفرنسية الإعدادية',
    'الرياضيات (الهندسة والجبر المطور)',
    'اللغة الإنكليزية',
    'الاجتماعيات (التاريخ والجغرافيا للتاسع)',
    'التربية الدينية الإسلامية / المسيحية'
  ];

  List<String> activeSubjects = [];
  String _aiResponseText = "اضغط على الميكروفون الذهبي بالأسفل واسألني أي سؤال في مناهج سوريا الـ PDF!";
  bool _isListening = false;
  bool _isLiveClassTime = false;
  bool _hasPostponedClass = false; 
  String _liveClassTopic = "";
  String _liveClassDuration = "";

  @override
  void initState() {
    super.initState();
    // عرض المواد المناسبة تلقائياً فور فتح حساب الطالب بناءً على شهادته
    if (widget.gradeType == 'thirth_grade') {
      activeSubjects = thirthGradeSubjects;
    } else {
      activeSubjects = baccalaureateSubjects;
    }
    _checkScheduledLiveClass(); 
  }

  void _checkScheduledLiveClass() async {
    if (_hasPostponedClass) return; 
    try {
      final response = await http.get(Uri.parse('https://onrender.com{widget.gradeType}'));
      final data = jsonDecode(response.body);
      if (data['classActive'] == true) {
        setState(() {
          _isLiveClassTime = true;
          _liveClassTopic = data['topic'];
          _liveClassDuration = data['duration'];
        });
      }
    } catch (e) {
      print("مزامنة الجدول...");
    }
  }

  void _askHybridAI(String studentQuestion) async {
    setState(() => _isListening = true);
    try {
      final response = await http.post(
        Uri.parse('https://onrender.com'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': studentQuestion, 
          'isVoice': true,
          'gradeType': widget.gradeType // الذكاء الاصطناعي يجيب بناءً على المنهج المختار
        }),
      );

      final data = jsonDecode(response.body);
      setState(() {
        _aiResponseText = data['answerText'] ?? "عذراً يا بطل، لم أستطع معالجة السؤال حالياً.";
        _isListening = false;
      });
    } catch (e) {
      setState(() => _isListening = false);
      _showNotificationToast("خطأ في الاتصال بمحرك الذكاء الاصطناعي");
    }
  }

  void _showNotificationToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 3)));
  }
  @override
  Widget build(BuildContext context) {
    if (_isLiveClassTime && !_hasPostponedClass) {
      return Scaffold(
        body: Container(
          padding: const EdgeInsets.all(24),
          color: const Color(0xFF0B0B0C),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cast_for_education, color: Color(0xFFD4AF37), size: 64),
              const SizedBox(height: 15),
              Text(widget.gradeType == 'thirth_grade' ? "🔴 حصة التاسع المجدولة حية الآن" : "🔴 حصة البكالوريا المجدولة حية الآن", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent)),
              const SizedBox(height: 5),
              Text(_liveClassDuration, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13)),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF19191B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.25))),
                child: Column(
                  children: [
                    const Row(children: [Icon(Icons.person, color: Color(0xFFD4AF37)), SizedBox(width: 8), Text("الأستاذ الروبوتي لمنصة دراستي", style: TextStyle(fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 12),
                    Text(_liveClassTopic, style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.white70), textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () {
                  setState(() => _isLiveClassTime = false); 
                  _askHybridAI("ابدأ بشرح درس اليوم المنهجي المخصص لشهادة ${widget.gradeType == 'thirth_grade' ? 'التاسع أساسي' : 'البكالوريا ثانوية'}");
                },
                child: const Text('🟢 دخول الحصة الآن', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD4AF37)), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () {
                  setState(() => _hasPostponedClass = true); 
                  _showNotificationToast("🔔 تم تأجيل الإشعار، تذكير بالحصة بعد 30 دقيقة.");
                },
                child: const Text('⏳ تأجيل الدرس لـ 30 دقيقة', style: TextStyle(fontSize: 14, color: Color(0xFFD4AF37))),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gradeType == 'thirth_grade' ? 'دراستي - مسار التاسع الإعدادي الملكي' : 'دراستي - مسار البكالوريا الملكي', style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF0B0B0C),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF19191B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.25))),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 24),
                    const SizedBox(width: 10),
                    Text(_isListening ? "جاري قراءة المناهج والتحليل ضوئياً... 🧠" : "مساعد الذكاء الاصطناعي للشهادات (RAG AI)", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                  ],
                ),
                const SizedBox(height: 15),
                Text(_aiResponseText, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white70), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _askHybridAI(widget.gradeType == 'thirth_grade' ? "ما هي الأيونات وكيف تتشكل في منهج الكيمياء للتاسع؟" : "ما هي وظيفة الجسيمات الطرفية in درس مادة العلوم للبكالوريا؟"),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: _isListening ? Colors.redAccent : const Color(0xFFD4AF37),
                    child: Icon(_isListening ? Icons.graphic_eq : Icons.keyboard_voice, color: Colors.black, size: 26),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: activeSubjects.length,
              itemBuilder: (context, index) {
                bool isLocked = index > 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isLocked ? const Color(0xFF19191B).withOpacity(0.4) : const Color(0xFF19191B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isLocked ? Colors.transparent : const Color(0xFFD4AF37).withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('المادة 0${index + 1}', style: TextStyle(color: isLocked ? Colors.grey : const Color(0xFFD4AF37), fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(activeSubjects[index], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isLocked ? Colors.grey : Colors.white), overflow: TextOverflow.ellipsis),
                          ],
                        ),
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
            const Text('نظام تتبع الغش والامتحانات (موقوت وصارم)', style: TextStyle(fontSize: 17, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold)),
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
