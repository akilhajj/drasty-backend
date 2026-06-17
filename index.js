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

    // مسار رصد وجلب الطلاب الفوري للوحة الإدارة حياً
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

    return new Response("drasty.net edge engine active.", { headers: corsHeaders });
  }
};
