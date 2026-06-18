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

    // 🔐 1. مسار تحقق وتسجيل دخول الطلاب والأدمن من نموذج الويب الحالي
    if (url.pathname === "/api/auth/login" && request.method === "POST") {
      try {
        const { email, password } = await request.json();
        
        // استعلام فوري وصارم داخل قاعدة بيانات كلاود فلير D1
        const user = await env.DB.prepare(
          "SELECT id, full_name, email, role, status FROM users WHERE email = ? AND password = ?"
        ).bind(email, password).first();

        if (!user) {
          return new Response(JSON.stringify({ success: false, message: "بيانات الدخول غير صحيحة" }), {
            headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 401
          });
        }

        return new Response(JSON.stringify({ success: true, user }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });
      } catch (err) {
        return new Response(JSON.stringify({ success: false, error: err.message }), { headers: corsHeaders, status: 500 });
      }
    }

    // 👤 2. مسار جلب وتسييل داتا الطلاب حياً للوحة التحكم
    if (url.pathname === "/api/teacher/monitor-shift") {
      try {
        const { results } = await env.DB.prepare("SELECT id, full_name, email, role, status FROM users").all();
        return new Response(JSON.stringify({ success: true, users: results }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });
      } catch (err) {
        return new Response(JSON.stringify({ success: false, error: err.message }), { headers: corsHeaders });
      }
    }

    // 💳 3. مسار الموافقة وتفعيل الحسابات وحقن الأيام من اللوحة حياً
    if (url.pathname === "/api/teacher/approve-student" && request.method === "POST") {
      try {
        const { id } = await request.json();
        await env.DB.prepare("UPDATE users SET status = 'approved' WHERE id = ?").bind(id).run();
        return new Response(JSON.stringify({ success: true }), { headers: { ...corsHeaders, "Content-Type": "application/json" } });
      } catch (err) {
        return new Response(JSON.stringify({ success: false, error: err.message }), { headers: corsHeaders, status: 500 });
      }
    }

    // تمرير وقراءة واجهات ومجلد الـ public تلقائياً عند تصفح صفحة اللوجن أو الداشبورد
    return env.ASSETS ? await env.ASSETS.fetch(request) : new Response("drasty active core.");
  }
};
