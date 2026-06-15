const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const CLOUDFLARE_ACCOUNT_ID = process.env.CLOUDFLARE_ACCOUNT_ID;
const CLOUDFLARE_DATABASE_ID = process.env.CLOUDFLARE_DATABASE_ID;
const CLOUDFLARE_API_TOKEN = process.env.CLOUDFLARE_API_TOKEN;

// دالة العبور الآمن لقاعدة بيانات drasty_db
async function queryDatabase(sql, params = []) {
    const url = `https://cloudflare.com{CLOUDFLARE_ACCOUNT_ID}/d1/database/${CLOUDFLARE_DATABASE_ID}/query`;
    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${CLOUDFLARE_API_TOKEN}`,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ sql, params })
    });
    const data = await response.json();
    if (!data.success) throw new Error('فشل الاتصال ببيانات منصة دراستي');
    return data.result?.results || [];
}

// 🔐 1. واجهة الدخول الموحد لـ drasty.net (Unified Login)
app.post('/api/auth/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const users = await queryDatabase('SELECT * FROM users WHERE email = ? AND password = ?', [email, password]);
        if (users.length === 0) return res.status(401).json({ success: false, message: 'بيانات الدخول خاطئة' });
        
        const user = users[0];
        if (user.status === 'pending') return res.status(403).json({ success: false, message: 'حسابك معلق بانتظار تفعيل الإيصال اليدوي من إدارة منصة دراستي' });
        if (user.status === 'rejected') return res.status(403).json({ success: false, message: 'تم رفض حسابك، يرجى مراجعة المعهد' });

        res.json({ success: true, role: user.role, user: { id: user.id, name: user.full_name, email: user.email } });
    } catch (error) { res.status(500).json({ success: false, error: error.message }); }
});

// ⏰ 2. منطق قفل الوقت الصارم لـ (شيفت الأستاذ) من 10 صباحاً حتى 2 ظهراً
app.get('/api/teacher/monitor-shift', (req, res) => {
    const syriaTime = new Date().toLocaleString("en-US", { timeZone: "Asia/Damascus" });
    const currentHour = new Date(syriaTime).getHours();

    if (currentHour >= 10 && currentHour < 14) {
        return res.json({ shiftActive: true, message: "المنظومة مفتوحة للمراقبة الآن." });
    } else {
        return res.json({ shiftActive: false, message: "الشيفت انتهى / نظام Mراقبة الامتحانات مغلق حالياً. متاح فقط من 10:00 صباحاً حتى 2:00 ظهراً بتوقيت سوريا." });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Drasty Platform Server running on port ${PORT}`));
