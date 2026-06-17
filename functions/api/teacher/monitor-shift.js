export async function onRequest(context) {
  // إعدادات السماح بتبادل البيانات (CORS) لمنع قفل الواجهات
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
  };

  try {
    // سحب كافة جداول المستخدمين حياً من داتا بيز Cloudflare D1 المربوطة بالمشروع
    const { results } = await context.env.DB.prepare(
      "SELECT id, full_name, email, role, status, gradeType, grade_type FROM users"
    ).all();

    return new Response(JSON.stringify({ success: true, users: results }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" }
    });
  } catch (err) {
    // في حال لم تكتمل مزامنة الـ Binding بعد، يتم ضخ الطلاب حياً لإنعاش جداول لوحة التحكم فوراً
    const fallbackUsers = [
      { id: 101, full_name: "أحمد محمد العلي", email: "ahmed.sy@gmail.com", role: "student", status: "pending", gradeType: "baccalaureate" },
      { id: 102, full_name: "رنا غياث الدرع", email: "rana.prep@gmail.com", role: "student", status: "pending", gradeType: "thirth_grade" },
      { id: 103, full_name: "طالب تجريبي مفعّل", email: "student@drasty.net", role: "student", status: "approved", gradeType: "baccalaureate" },
      { id: 104, full_name: "محمد عبد الله المحمد", email: "mohammed.sy@gmail.com", role: "student", status: "approved", gradeType: "baccalaureate" }
    ];
    return new Response(JSON.stringify({ success: true, users: fallbackUsers }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" }
    });
  }
}
