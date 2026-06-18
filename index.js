export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    };

    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    // 🔐 1. مسار تحقق وتسجيل دخول الطلاب الحقيقي والمطور (Login API)
    if (url.pathname === "/api/auth/login" && request.method === "POST") {
      try {
        const { email, password } = await request.json();
        
        // استعلام فوري وصارم داخل داتا بيز كلاود فلير D1
        const user = await env.DB.prepare(
          "SELECT id, full_name, email, role, status, expires_at FROM users WHERE email = ? AND password = ?"
        ).bind(email.trim(), password).first();

        if (!user) {
          return new Response(JSON.stringify({ success: false, message: "بيانات الدخول غير صحيحة" }), {
            headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 401
          });
        }

        // 🧠 شرط العبور التلقائي الذكي والمعدل: التمرير الفوري لكل طالب حالته ليست معلقة بصراحة
        if (user.status === "pending" || user.status === "Pending") {
          return new Response(JSON.stringify({ success: false, message: "حسابك قيد المراجعة، يرجى الانتظار لحين تأكيد إيصال الدفع اليدوي من الإدارة." }), {
            headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 403
          });
        }

        return new Response(JSON.stringify({ success: true, user }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });
      } catch (err) {
        return new Response(JSON.stringify({ success: false, error: err.message }), { headers: corsHeaders, status: 500 });
      }
    }

    // 👤 2. مسار جلب وتسييل داتا الطلاب حياً للوحة التحكم والجدول الظاهر أمامك
    if (url.pathname === "/api/teacher/monitor-shift") {
      try {
        const { results } = await env.DB.prepare("SELECT id, full_name, email, role, status, expires_at FROM users").all();
        return new Response(JSON.stringify({ success: true, users: results }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });
      } catch (err) {
        return new Response(JSON.stringify({ success: false, error: err.message }), { headers: corsHeaders });
      }
    }

    // 💳 3. مسار تفعيل واشتراك وتحديث حالة الطلاب من اللوحة حياً
    if (url.pathname === "/api/teacher/approve-student" && request.method === "POST") {
      try {
        const { id, days } = await request.json();
        let finalDays = days ? days : "365";
        
        // تعديل الحالة وحقنها بقوة لتفادي أي تضارب برمجائي مستقبلي
        await env.DB.prepare(
          "UPDATE users SET status = 'approved', expires_at = ? WHERE id = ?"
        ).bind(finalDays.toString(), id).run();
        
        return new Response(JSON.stringify({ success: true }), { headers: { ...corsHeaders, "Content-Type": "application/json" } });
      } catch (err) {
        return new Response(JSON.stringify({ success: false, error: err.message }), { headers: corsHeaders, status: 500 });
      }
    }

    // تمرير وقراءة واجهات ومجلد الـ public تلقائياً عند تصفح صفحة اللوجن أو الداشبورد
    return env.ASSETS ? await env.ASSETS.fetch(request) : new Response("drasty active core.");
  }
};
