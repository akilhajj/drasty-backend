export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    
    // إعدادات جدار حماية الـ CORS لضمان تواصل الواجهات بمرونة تامة داخل سوريا دون حجب
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, HEAD, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
    };

    // 🌐 التوجيه الإمبراطوري التلقائي لمنع ظهور الصفحة البيضاء وتحويل الزائر للموقع الرئيسي
    if (url.pathname === "/" || url.pathname === "/index.html") {
      return Response.redirect("https://drasty-backend.akilhajj00.workers.dev", 301);
    }

    // الاستجابة الفورية لطلبات التحقق الأولية من المتصفحات
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    // 🔒 دالة حماية داخلية للتحقق الصارم من التوكنات والرتب البرمجية قبل منح البيانات
    async function checkAuth(req, allowedRoles = []) {
      const authHeader = req.headers.get("Authorization");
      if (!authHeader) return { authorized: false, error: "لم يتم تزويد رمز الترخيص الرقمي، يرجى تسجيل الدخول أولاً." };

      const session = await env.DB.prepare(
        "SELECT users.id, users.name, users.role, users.grade, users.branch, users.subscription_expires_at, users.created_at FROM sessions JOIN users ON sessions.user_id = users.id WHERE sessions.token = ? AND sessions.expires_at > datetime('now')"
      ).bind(authHeader).first();

      if (!session) {
        return { authorized: false, error: "انتهت صلاحية جلستك الرقمية الآمنة، يرجى إعادة تسجيل الدخول." };
      }

      if (allowedRoles.length > 0 && !allowedRoles.includes(session.role)) {
        return { authorized: false, error: "خطأ بالأمان: غير مصرح لرتبتك الحالية بالوصول لهذه البيانات." };
      }

      return { authorized: true, user: session };
    }
    // 1️⃣ بوابة إنشاء حساب طالب جديد (Registration)
    if (url.pathname === "/api/register" && request.method === "POST") {
      try {
        const { name, phone, email, password, role, grade, branch, allowed_days } = await request.json();
        const userId = crypto.randomUUID();
        
        const existingUser = await env.DB.prepare("SELECT id FROM users WHERE email = ?").bind(email).first();
        if (existingUser) {
          return new Response(JSON.stringify({ error: "البريد الإلكتروني مسجل مسبقاً في الأكاديمية!" }), { status: 400, headers: corsHeaders });
        }

        const days = allowed_days ? parseInt(allowed_days) : 30;
        const expirationDate = new Date(Date.now() + days * 24 * 60 * 60 * 1000).toISOString();

        await env.DB.prepare(
          "INSERT INTO users (id, name, phone, email, password_hash, role, grade, branch, status, allowed_days, subscription_expires_at) VALUES (?, ?, ?, ?, ?, 'student', ?, ?, 'pending', ?, ?)"
        ).bind(userId, name, phone, email, password, grade, branch, days, expirationDate).run();

        return new Response(JSON.stringify({ success: true, message: "تم إرسال طلب الانضمام بنجاح! يرجى انتظار تفعيل حسابك من قبل الإدارة السحابية." }), { status: 201, headers: corsHeaders });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
      }
    }

    // 2️⃣ بوابة تسجيل الدخول (Login) والتحقق من الصلاحية الإدارية والزمنية
    if (url.pathname === "/api/login" && request.method === "POST") {
      try {
        const { email, password } = await request.json();
        const user = await env.DB.prepare("SELECT * FROM users WHERE email = ? AND password_hash = ?").bind(email, password).first();
        
        if (!user) {
          return new Response(JSON.stringify({ error: "معلومات تسجيل الدخول الرقمية غير صحيحة!" }), { status: 401, headers: corsHeaders });
        }

        if (user.status !== "approved") {
          return new Response(JSON.stringify({ error: "حسابك الدراسي مسجل ولكن قيد المراجعة الإدارية، يرجى الانتظار لحين تفعيله." }), { status: 403, headers: corsHeaders });
        }

        const now = new Date().toISOString();
        if (user.subscription_expires_at < now) {
          return new Response(JSON.stringify({ error: "انتهت أيام صلاحية اشتراكك الممنوحة، يرجى مراجعة إدارة الأكاديمية." }), { status: 403, headers: corsHeaders });
        }

        const token = crypto.randomUUID();
        const sessionExpires = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
        
        await env.DB.prepare("INSERT INTO sessions (token, user_id, expires_at) VALUES (?, ?, ?)").bind(token, user.id, sessionExpires).run();

        return new Response(JSON.stringify({ 
          success: true, token, role: user.role, name: user.name, grade: user.grade, branch: user.branch 
        }), { status: 200, headers: corsHeaders });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
      }
    }

    // 3️⃣ مسار الأستاذ: جلب قائمة الطلاب لإدارتهم وتفعيلهم
    if (url.pathname === "/api/admin/students" && request.method === "GET") {
      const auth = await checkAuth(request, ["teacher", "admin"]);
      if (!auth.authorized) return new Response(JSON.stringify({ error: auth.error }), { status: 403, headers: corsHeaders });

      try {
        const students = await env.DB.prepare("SELECT id, name, phone, email, grade, branch, status, subscription_expires_at FROM users WHERE role = 'student' ORDER BY created_at DESC").all();
        return new Response(JSON.stringify(students.results), { status: 200, headers: corsHeaders });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: headers });
      }
    }

    // 4️⃣ مسار الأستاذ: الموافقة على الحسابات أو حظرها
    if (url.pathname === "/api/admin/approve" && request.method === "POST") {
      const auth = await checkAuth(request, ["teacher", "admin"]);
      if (!auth.authorized) return new Response(JSON.stringify({ error: auth.error }), { status: 403, headers: corsHeaders });

      try {
        const { userId, targetStatus } = await request.json();
        await env.DB.prepare("UPDATE users SET status = ? WHERE id = ?").bind(targetStatus, userId).run();
        return new Response(JSON.stringify({ success: true, message: "تم تحديث حالة حساب الطالب بنجاح" }), { status: 200, headers: corsHeaders });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
      }
    }

    // 5️⃣ مسار الأستاذ: تمديد الصلاحية الزمنية بـ 30 يوماً
    if (url.pathname === "/api/admin/extend" && request.method === "POST") {
      const auth = await checkAuth(request, ["teacher", "admin"]);
      if (!auth.authorized) return new Response(JSON.stringify({ error: auth.error }), { status: 403, headers: corsHeaders });

      try {
        const { userId, daysToAdd } = await request.json();
        const days = daysToAdd ? parseInt(daysToAdd) : 30;
        await env.DB.prepare(
          "UPDATE users SET subscription_expires_at = datetime(max(subscription_expires_at, datetime('now')), '+' || ? || ' days') WHERE id = ?"
        ).bind(days, userId).run();
        return new Response(JSON.stringify({ success: true, message: "تم تمديد صلاحية اشتراك الطالب بنجاح" }), { status: 200, headers: corsHeaders });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
      }
    }
    // 6️⃣ مسار الأستاذ: حقن نص السكان وتوليد الشرح بالـ AI وحفظه جاهزاً فوراً (Pre-generation فائقة السرعة)
    if (url.pathname === "/api/courses/inject" && request.method === "POST") {
      const auth = await checkAuth(request, ["teacher", "admin"]);
      if (!auth.authorized) return new Response(JSON.stringify({ error: auth.error }), { status: 403, headers: corsHeaders });

      try {
        const { subject_name, grade_target, branch_target, title, lesson_order, book_raw_text } = await request.json();
        
        await env.DB.prepare(
          "INSERT INTO syrian_curriculum (subject_name, grade_target, branch_target, lesson_order, lesson_title, book_raw_text) VALUES (?, ?, ?, ?, ?, ?)"
        ).bind(subject_name, grade_target, branch_target, lesson_order, title, book_raw_text).run();

        const aiPrompt = "أنت أستاذ بكالوريا سوري عبقري. صمم لي حصة دراسية نموذجية مدتها 60 دقيقة في مادة " + subject_name + " لدرس بعنوان " + title + ". استند بشكل صارم على معلومات الكتاب التالية المستخلصة من الماسح الضوئي: " + book_raw_text + " المطلوب: تلخيص مكثف، القوانين الأساسية للامتحان المؤتمت 2026، وشرح مبسط بنقاط واضحة بالفصحى وبدون مقدمات.";

        const aiResponse = await env.AI.run("@cf/meta/llama-3-8b-instruct", {
          messages: [{ role: "user", content: aiPrompt }]
        });

        await env.DB.prepare(
          "INSERT INTO generated_lessons (subject_name, grade_target, branch_target, lesson_order, lesson_title, text_content) VALUES (?, ?, ?, ?, ?, ?)"
        ).bind(subject_name, grade_target, branch_target, lesson_order, title, aiResponse.response).run();

        return new Response(JSON.stringify({ success: true, message: "تم حقن وتوليد الحصة مسبقاً بنجاح وهي جاهزة للعرض الفوري للطلاب." }), { status: 201, headers: corsHeaders });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
      }
    }

    // 7️⃣ مسار الطالب: العرض الفوري فائق السرعة ⚡ (دون أي جمل انتظار للـ AI)
    if (url.pathname === "/api/courses" && request.method === "GET") {
      const auth = await checkAuth(request, ["student", "admin"]);
      if (!auth.authorized) return new Response(JSON.stringify({ error: auth.error }), { status: 403, headers: corsHeaders });

      try {
        const grade = url.searchParams.get("grade") || auth.user.grade;
        const branch = url.searchParams.get("branch") || auth.user.branch;

        const dateCreated = new Date(auth.user.created_at || Date.now());
        const dateNow = new Date();
        const diffTime = Math.abs(dateNow - dateCreated);
        const currentLessonOrder = Math.max(1, Math.ceil(diffTime / (1000 * 60 * 60 * 24)));

        const readyLessons = await env.DB.prepare(
          "SELECT id, subject_name, lesson_title as title, text_content FROM generated_lessons WHERE grade_target = ? AND (branch_target = ? OR branch_target = 'general') AND lesson_order = ?"
        ).bind(grade, branch, currentLessonOrder).all();

        const readyExams = await env.DB.prepare(
          "SELECT id, subject_name, question, option_a, option_b, option_c, option_d, correct_option FROM exams WHERE grade_target = ? AND (branch_target = ? OR branch_target = 'general')"
        ).bind(grade, branch).all();

        const responseData = readyLessons.results.map(lesson => {
          const associatedExam = readyExams.results.find(e => e.subject_name === lesson.subject_name) || null;
          return {
            ...lesson,
            duration_minutes: 60,
            generated_day: currentLessonOrder,
            exam: associatedExam
          };
        });

        return new Response(JSON.stringify(responseData), { status: 200, headers: corsHeaders });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
      }
    }

    // 🤖 محرك الرادار الذكي والسيادي المعتمد على المناهج حياً بالـ D1
    if (url.pathname === "/api/radar-chat" && request.method === "POST") {
      const auth = await checkAuth(request, ["student", "admin"]);
      if (!auth.authorized) return new Response(JSON.stringify({ error: auth.error }), { status: 403, headers: corsHeaders });

      try {
        const { question, grade, branch } = await request.json();

        const fetchedLessons = await env.DB.prepare(
          "SELECT subject_name, lesson_title, book_raw_text FROM syrian_curriculum WHERE grade_target = ? AND (branch_target = ? OR branch_target = 'general') LIMIT 3"
        ).bind(grade || auth.user.grade, branch || auth.user.branch).all();

        let curriculumContext = fetchedLessons.results.map(l => "المادة: " + l.subject_name + " - الدرس: " + l.lesson_title + " - النص المعرفي: " + l.book_raw_text).join("\n");
        if (!curriculumContext) curriculumContext = "اعتمد على الهيكل العام لمنهاج سوريا بكالوريا 2026.";

        const systemPrompt = "أنت رادار المحادثة الصوتي الذكي لأكاديمية دراستي لطلاب سوريا 2026. أجب بناءً على الكتب السورية الممسوحة سكان المتوفرة هنا:\n" + curriculumContext + "\nشروطك: فصحى فاخرة، مشجعة، إجابة قصيرة ومختصرة (لا تتجاوز 3 أسطر) لتناسب النطق الصوتي الفوري للطالب السوري وتوفر استهلاك الإنترنت داخل سوريا.";

        const aiResponse = await env.AI.run("@cf/meta/llama-3-8b-instruct", {
          messages: [
            { role: "system", content: systemPrompt },
            { role: "user", content: question }
          ]
        });

        return new Response(JSON.stringify({ answer: aiResponse.response }), { status: 200, headers: corsHeaders });
      } catch (err) {
        return new Response(JSON.stringify({ error: "فشل محرك الرادار: " + err.message }), { status: 500, headers: corsHeaders });
      }
    }

    return new Response(JSON.stringify({ error: "المسار السحابي المطلوب غير موجود بالمنصة." }), { status: 404, headers: corsHeaders });
  }
};
