export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, HEAD, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
    };

    // 🌐 التوجيه التلقائي للموقع الرئيسي ومنع الصفحة البيضاء
    if (url.pathname === "/" || url.pathname === "/index.html") {
      return Response.redirect("https://drasty-backend.akilhajj00.workers.dev", 301);
    }

    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    // 🔒 جدار حماية الجلسات والتحقق الصارم من التوكنات قبل منح البيانات
    async function checkAuth(req, allowedRoles = []) {
      const authHeader = req.headers.get("Authorization");
      if (!authHeader) return { authorized: false, error: "لم يتم تزويد رمز الترخيص الرقمي." };
      const session = await env.DB.prepare("SELECT users.id, users.name, users.role, users.grade, users.branch, users.subscription_expires_at, users.created_at FROM sessions JOIN users ON sessions.user_id = users.id WHERE sessions.token = ? AND sessions.expires_at > datetime('now')").bind(authHeader).first();
      if (!session) return { authorized: false, error: "انتهت صلاحية جلستك الرقمية." };
      if (allowedRoles.length > 0 && !allowedRoles.includes(session.role)) return { authorized: false, error: "غير مصرح لرتبتك الحالية بالوصول." };
      return { authorized: true, user: session };
    }

    // 📝 1️⃣ بوابة إنشاء حساب طالب جديد (Registration)
    if (url.pathname === "/api/register" && request.method === "POST") {
      try {
        const { name, phone, email, password, grade, branch } = await request.json();
        const userId = crypto.randomUUID();
        const existingUser = await env.DB.prepare("SELECT id FROM users WHERE email = ?").bind(email).first();
        if (existingUser) return new Response(JSON.stringify({ error: "البريد مسجل مسبقاً!" }), { status: 400, headers: corsHeaders });
        const expirationDate = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString();
        await env.DB.prepare("INSERT INTO users (id, name, phone, email, password_hash, role, grade, branch, status, allowed_days, subscription_expires_at) VALUES (?, ?, ?, ?, ?, 'student', ?, ?, 'pending', 30, ?)").bind(userId, name, phone, email, password, grade, branch, expirationDate).run();
        return new Response(JSON.stringify({ success: true, message: "تم إرسال طلب الانضمام بنجاح!" }), { status: 201, headers: corsHeaders });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
      }
    }
    // 🔑 2️⃣ بوابة تسجيل الدخول والتحقق من التفعيل والصلاحية الزمنية
    if (url.pathname === "/api/login" && request.method === "POST") {
      try {
        const { email, password } = await request.json();
        const user = await env.DB.prepare("SELECT * FROM users WHERE email = ? AND password_hash = ?").bind(email, password).first();
        if (!user) return new Response(JSON.stringify({ error: "معلومات تسجيل الدخول غير صحيحة!" }), { status: 401, headers: corsHeaders });
        if (user.status !== "approved") return new Response(JSON.stringify({ error: "حسابك قيد المراجعة الإدارية." }), { status: 403, headers: corsHeaders });
        if (user.subscription_expires_at < new Date().toISOString()) return new Response(JSON.stringify({ error: "انتهت أيام صلاحية اشتراكك الدراسي." }), { status: 403, headers: corsHeaders });
        
        const token = crypto.randomUUID();
        const sessionExpires = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
        await env.DB.prepare("INSERT INTO sessions (token, user_id, expires_at) VALUES (?, ?, ?)").bind(token, user.id, sessionExpires).run();
        return new Response(JSON.stringify({ success: true, token, role: user.role, name: user.name, grade: user.grade, branch: user.branch }), { status: 200, headers: corsHeaders });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
      }
    }

    // 👥 3️⃣ لوحة المعلم: جلب قائمة الطلاب لإدارتهم واعتمادهم
    if (url.pathname === "/api/admin/students" && request.method === "GET") {
      const auth = await checkAuth(request, ["teacher", "admin"]);
      if (!auth.authorized) return new Response(JSON.stringify({ error: auth.error }), { status: 403, headers: corsHeaders });
      try {
        const students = await env.DB.prepare("SELECT id, name, phone, email, grade, branch, status, subscription_expires_at FROM users WHERE role = 'student' ORDER BY created_at DESC").all();
        return new Response(JSON.stringify(students.results), { status: 200, headers: corsHeaders });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
      }
    }

    // ✅ 4️⃣ لوحة المعلم: الموافقة وتفعيل الحسابات المعلقة أو حظرها
    if (url.pathname === "/api/admin/approve" && request.method === "POST") {
      const auth = await checkAuth(request, ["teacher", "admin"]);
      if (!auth.authorized) return new Response(JSON.stringify({ error: auth.error }), { status: 403, headers: corsHeaders });
      try {
        const { userId, targetStatus } = await request.json();
        await env.DB.prepare("UPDATE users SET status = ? WHERE id = ?").bind(targetStatus, userId).run();
        return new Response(JSON.stringify({ success: true }), { status: 200, headers: corsHeaders });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
      }
    }

    // ⏳ 5️⃣ لوحة المعلم: تمديد فترة صلاحية اشتراك الطلاب بـ 30 يوماً إضافية
    if (url.pathname === "/api/admin/extend" && request.method === "POST") {
      const auth = await checkAuth(request, ["teacher", "admin"]);
      if (!auth.authorized) return new Response(JSON.stringify({ error: auth.error }), { status: 403, headers: corsHeaders });
      try {
        const { userId, daysToAdd } = await request.json();
        await env.DB.prepare("UPDATE users SET subscription_expires_at = datetime(max(subscription_expires_at, datetime('now')), '+' || ? || ' days') WHERE id = ?").bind(daysToAdd || 30, userId).run();
        return new Response(JSON.stringify({ success: true }), { status: 200, headers: corsHeaders });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
      }
    }
    // 📚 6️⃣ مسار الأستاذ: حقن نص السكان وتوليد الشرح بالـ AI وحفظه جاهزاً فوراً (Pre-generation فائقة السرعة)
    if (url.pathname === "/api/courses/inject" && request.method === "POST") {
      const auth = await checkAuth(request, ["teacher", "admin"]);
      if (!auth.authorized) return new Response(JSON.stringify({ error: auth.error }), { status: 403, headers: corsHeaders });
      try {
        const { subject_name, grade_target, branch_target, title, lesson_order, book_raw_text } = await request.json();
        await env.DB.prepare("INSERT INTO syrian_curriculum (subject_name, grade_target, branch_target, lesson_order, lesson_title, book_raw_text) VALUES (?, ?, ?, ?, ?, ?)").bind(subject_name, grade_target, branch_target, lesson_order, title, book_raw_text).run();
        const aiPrompt = "أنت أستاذ بكالوريا سوري عبقري. صمم لي حصة دراسية نموذجية مدتها 60 دقيقة في مادة " + subject_name + " لدرس بعنوان " + title + ". استند بشكل صارم على معلومات الكتاب التالية المستخلصة من الماسح الضوئي: " + book_raw_text + " المطلوب: تلخيص مكثف، القوانين الأساسية للامتحان المؤتمت 2026، وشرح مبسط بنقاط واضحة بالفصحى وبدون مقدمات.";
        const aiResponse = await env.AI.run("@cf/meta/llama-3-8b-instruct", { messages: [{ role: "user", content: aiPrompt }] });
        await env.DB.prepare("INSERT INTO generated_lessons (subject_name, grade_target, branch_target, lesson_order, lesson_title, text_content) VALUES (?, ?, ?, ?, ?, ?)").bind(subject_name, grade_target, branch_target, lesson_order, title, aiResponse.response).run();
        return new Response(JSON.stringify({ success: true }), { status: 201, headers: corsHeaders });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
      }
    }

    // ⚡ 7️⃣ مسار الطالب: العرض الفوري فائق السرعة (دون أي جمل انتظار للـ AI)
    if (url.pathname === "/api/courses" && request.method === "GET") {
      const auth = await checkAuth(request, ["student", "admin"]);
      if (!auth.authorized) return new Response(JSON.stringify({ error: auth.error }), { status: 403, headers: corsHeaders });
      try {
        const grade = url.searchParams.get("grade") || auth.user.grade;
        const branch = url.searchParams.get("branch") || auth.user.branch;
        const dateCreated = new Date(auth.user.created_at || Date.now());
        const currentLessonOrder = Math.max(1, Math.ceil(Math.abs(new Date() - dateCreated) / (1000 * 60 * 60 * 24)));
        const readyLessons = await env.DB.prepare("SELECT id, subject_name, lesson_title as title, text_content FROM generated_lessons WHERE grade_target = ? AND (branch_target = ? OR branch_target = 'general') AND lesson_order = ?").bind(grade, branch, currentLessonOrder).all();
        const result = readyLessons.results.map(l => ({ ...l, duration_minutes: 60, generated_day: currentLessonOrder }));
        return new Response(JSON.stringify(result), { status: 200, headers: corsHeaders });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
      }
    }

    // 🤖 8️⃣ محرك الرادار الذكي والسيادي المعتمد على المناهج حياً بالـ D1
    if (url.pathname === "/api/radar-chat" && request.method === "POST") {
      const auth = await checkAuth(request, ["student", "admin"]);
      if (!auth.authorized) return new Response(JSON.stringify({ error: auth.error }), { status: 403, headers: corsHeaders });
      try {
        const { question, grade, branch } = await request.json();
        const fetchedLessons = await env.DB.prepare("SELECT subject_name, lesson_title, book_raw_text FROM syrian_curriculum WHERE grade_target = ? AND (branch_target = ? OR branch_target = 'general') LIMIT 3").bind(grade || auth.user.grade, branch || auth.user.branch).all();
        let curriculumContext = fetchedLessons.results.map(l => "المادة: " + l.subject_name + " - الدرس: " + l.lesson_title + " - النص: " + l.book_raw_text).join("\n");
        if (!curriculumContext) curriculumContext = "اعتمد على الهيكل العام لمنهاج سوريا بكالوريا 2026.";
        const systemPrompt = "أنت رادار المحادثة الصوتي الذكي لأكاديمية دراستي لطلاب سوريا 2026. أجب بناءً على الكتب التالية:\n" + curriculumContext + "\nشروطك: فصحى فاخرة، مشجعة، إجابة قصيرة ومختصرة (لا تتجاوز 3 أسطر) لتناسب النطق الصوتي الفوري وتوفر البيانات داخل سوريا.";
        const aiResponse = await env.AI.run("@cf/meta/llama-3-8b-instruct", { messages: [{ role: "system", content: systemPrompt }, { role: "user", content: question }] });
        return new Response(JSON.stringify({ answer: aiResponse.response }), { status: 200, headers: corsHeaders });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
      }
    }

    return new Response(JSON.stringify({ error: "المسار السحابي غير موجود." }), { status: 404, headers: corsHeaders });
  }
};
