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

    // 👤 مسار جلب الطلاب الفوري للوحة الإدارة حياً
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

    // 👑 كود عرض شاشة لوحة تحكم الأدمن الفاخرة والمسؤولة عن العرض حياً
    const htmlPayload = `
    <!DOCTYPE html>
    <html lang="ar" dir="rtl">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>دراستي.نت - لوحة المسؤول الملكية</title>
        <link rel="stylesheet" href="https://googleapis.com">
        <style>
            * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Cairo', sans-serif; }
            body { background-color: #0B0B0C; color: #FFFFFF; min-height: 100vh; display: flex; flex-direction: column; }
            header { background-color: #19191B; padding: 15px 25px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(212, 175, 55, 0.2); position: relative; }
            .logo { font-size: 24px; font-weight: bold; color: #D4AF37; letter-spacing: 1px; }
            .menu-toggle { display: none; background: none; border: none; color: #D4AF37; font-size: 26px; cursor: pointer; }
            nav { display: flex; gap: 15px; }
            nav button { background: none; border: 1px solid transparent; color: #BBBBBB; padding: 8px 16px; border-radius: 6px; cursor: pointer; transition: all 0.3s ease; font-weight: bold; font-size: 13px; }
            nav button:hover, nav button.active { border-color: #D4AF37; color: #D4AF37; background-color: rgba(212, 175, 55, 0.05); }
            .container { flex: 1; padding: 30px 20px; max-width: 1200px; width: 100%; margin: 0 auto; }
            .card { background-color: #19191B; padding: 25px; border-radius: 16px; border: 1px solid rgba(212, 175, 55, 0.15); margin-bottom: 25px; }
            h2 { color: #D4AF37; font-size: 18px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
            .table-responsive { overflow-x: auto; margin-top: 15px; }
            table { width: 100%; border-collapse: collapse; text-align: right; font-size: 13px; }
            th { background-color: rgba(212, 175, 55, 0.1); color: #D4AF37; padding: 12px; border-bottom: 2px solid #D4AF37; }
            td { padding: 14px 12px; border-bottom: 1px solid rgba(255,255,255,0.05); color: #DDDDDD; }
            .badge { padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; }
            .badge-bac { background-color: rgba(212, 175, 55, 0.15); color: #D4AF37; border: 1px solid #D4AF37; }
            .badge-prep { background-color: rgba(0, 123, 255, 0.15); color: #007BFF; border: 1px solid #007BFF; }
            .badge-active { background-color: rgba(40, 167, 69, 0.15); color: #28A745; }
            .badge-pending { background-color: rgba(255, 193, 7, 0.15); color: #FFC107; }
            .btn-action { background-color: #D4AF37; color: #000000; border: none; padding: 6px 14px; border-radius: 6px; cursor: pointer; font-weight: bold; font-size: 12px; transition: 0.2s; }
            .btn-action:hover { background-color: #FFF; }
            @media (max-width: 768px) {
                .menu-toggle { display: block; }
                nav { display: none; flex-direction: column; width: 100%; position: absolute; top: 100%; right: 0; background-color: #19191B; padding: 15px; border-bottom: 1px solid rgba(212, 175, 55, 0.2); z-index: 999; }
                nav.open { display: flex; }
                nav button { width: 100%; text-align: right; padding: 12px; }
                .container { padding: 15px 10px; }
            }
        </style>
    </head>
    <body>
        <header>
            <div class="logo">drasty.net الإدارة</div>
            <button class="menu-toggle" onclick="toggleMenu()">☰</button>
            <nav id="navbar">
                <button class="active" onclick="switchTab('students')">👤 إدارة بيانات الطلاب</button>
                <button onclick="switchTab('curriculum')">📚 مدير المناهج والشهادات</button>
                <button onclick="switchTab('payments')">💳 طلبات الدفع والإيصالات</button>
            </nav>
        </header>
        <div class="container">
            <div id="tab-students" class="card">
                <h2>👤 لوحة التحكم ورصد المسار الأكاديمي للطلاب حياً</h2>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>رقم الطالب</th>
                                <th>الاسم الكامل</th>
                                <th>البريد الموحد</th>
                                <th>المرحلة والشهادة</th>
                                <th>الحالة والاشتراك</th>
                            </tr>
                        </thead>
                        <tbody id="students-data">
                            <tr><td>#01</td><td>المدير العام - دراستي</td><td>admin@drasty.net</td><td><span class="badge badge-bac">كل الصلاحيات</span></td><td><span class="badge badge-active">نشط دائم</span></td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <div id="tab-curriculum" class="card" style="display: none;">
                <h2>📚 توزيع مسار الـ 7 مواد المخططة آلياً للتاسع والبكالوريا</h2>
                <div class="table-responsive">
                    <table>
                        <thead><tr><th>المادة</th><th>اسم المادة</th><th>نوع الشهادة</th></tr></thead>
                        <tbody>
                            <tr><td>المادة 01</td><td>العلوم العامة والفيزياء (للتاسع)</td><td><span class="badge badge-prep">تاسع أساسي</span></td></tr>
                            <tr><td>المادة 01</td><td>العلوم العامة (البكالوريا)</td><td><span class="badge badge-bac">بكالوريا ثانوية</span></td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <div id="tab-payments" class="card" style="display: none;">
                <h2>💳 كشف مبيعات وتدقيق إيصالات الشحن عبر الهواتف حياً</h2>
                <div class="table-responsive">
                    <table>
                        <thead><tr><th>المشترك</th><th>الشهادة</th><th>مستند الدفع</th><th>الحالة</th><th>الإجراء</th></tr></thead>
                        <tbody id="payments-payload"></tbody>
                    </table>
                </div>
            </div>
        </div>
        <script>
            async function fetchLiveDatabasePayload() {
                try {
                    const res = await fetch('/api/teacher/monitor-shift');
                    const data = await res.json();
                    if(data.success) {
                        const tbody = document.getElementById('payments-payload');
                        tbody.innerHTML = '';
                        data.users.forEach(u => {
                            if(u.role === 'student' && u.status === 'pending') {
                                tbody.innerHTML += '<tr><td>'+u.full_name+'</td><td><span class="badge badge-bac">بكالوريا</span></td><td><a href="#" style="color:#D4AF37;">📄 إيصال الشحن.png</a></td><td><span class="badge badge-pending">معلق</span></td><td><button class="btn-action" onclick="alert(\\\'تم تفعيل الحساب وحقن الأيام حياً! 🚀\\\')">✅ تفعيل وحقن</button></td></tr>';
                            }
                        });
                    }
                } catch (e) { console.log(e); }
            }
            function toggleMenu() { document.getElementById('navbar').classList.toggle('open'); }
            function switchTab(tabName) {
                document.getElementById('tab-students').style.display = tabName === 'students' ? 'block' : 'none';
                document.getElementById('tab-curriculum').style.display = tabName === 'curriculum' ? 'block' : 'none';
                document.getElementById('tab-payments').style.display = tabName === 'payments' ? 'block' : 'none';
                fetchLiveDatabasePayload();
            }
            window.onload = fetchLiveDatabasePayload;
        </script>
    </body>
    </html>
    `;

    return new Response(htmlPayload, { headers: { ...corsHeaders, "Content-Type": "text/html" } });
  }
};
