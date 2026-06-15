const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static('public')); // فتح لوحة التحكم التلقائية

const CLOUDFLARE_ACCOUNT_ID = process.env.CLOUDFLARE_ACCOUNT_ID;
const CLOUDFLARE_DATABASE_ID = process.env.CLOUDFLARE_DATABASE_ID;
const CLOUDFLARE_API_TOKEN = process.env.CLOUDFLARE_API_TOKEN;

// 💾 دالة الاتصال بقاعدة بيانات Cloudflare D1
async function queryDatabase(sql, params = []) {
    const url = `https://cloudflare.com{CLOUDFLARE_ACCOUNT_ID}/d1/database/${CLOUDFLARE_DATABASE_ID}/query`;
    const response = await fetch(url, {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${CLOUDFLARE_API_TOKEN}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ sql, params })
    });
    const data = await response.json();
    return data.result?.results || [];
}

// 🔐 واجهة الدخول الموحد لـ drasty.net مع فحص الصلاحية التلقائية بالأيام
app.post('/api/auth/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const users = await queryDatabase('SELECT * FROM users WHERE email = ? AND password = ?', [email, password]);
        if (users.length === 0) return res.status(401).json({ success: false, message: 'بيانات الدخول خاطئة' });
        
        const user = users[0];
        if (user.status === 'pending') return res.status(403).json({ success: false, message: 'حسابك معلق بانتظار تفعيل إيصال الدفع اليدوي من الإدارة' });
        if (user.status === 'rejected') return res.status(403).json({ success: false, message: 'تم رفض حسابك، يرجى مراجعة المعهد لشراء بطاقة جديدة' });

        // فحص قفل انتهاء الاشتراك التلقائي للطالب
        if (user.role === 'student' && user.expires_at) {
            const now = new Date();
            const expiryDate = new Date(user.expires_at);
            if (now > expiryDate) {
                return res.status(402).json({ success: false, expired: true, message: 'عذراً، انتهت صلاحية اشتراكك! يرجى رفع إيصال الدفع الجديد للتفعيل.' });
            }
        }
        res.json({ success: true, role: user.role, user: { id: user.id, name: user.full_name, email: user.email } });
    } catch (error) { res.status(500).json({ success: false, error: error.message }); }
});
// ⏰ منطق قفل الوقت الصارم لـ (شيفت الأستاذ) من 10 صباحاً حتى 2 ظهراً بتوقيت سوريا
app.get('/api/teacher/monitor-shift', (req, res) => {
    const syriaTime = new Date().toLocaleString("en-US", { timeZone: "Asia/Damascus" });
    const currentHour = new Date(syriaTime).getHours();
    if (currentHour >= 10 && currentHour < 14) {
        return res.json({ shiftActive: true, message: "المنظومة مفتوحة للمراقبة الآن." });
    } else {
        return res.json({ shiftActive: false, message: "الشيفت انتهى / نظام المراقبة مغلق حالياً. يفتح فقط من 10:00 صباحاً حتى 2:00 ظهراً بتوقيت سوريا." });
    }
});

// 🤖 محرك الذكاء الاصطناعي الهجين (Text & Voice AI Chat Engine via Cloudflare AI)
// يعمل داخل سوريا 100% بدون حظر وبدون باقات VPN مدفوعة وبأقل حجم بيانات
app.post('/api/ai/chat', async (req, res) => {
    const { question, isVoice } = req.body; // استقبال نص السؤال أو البصمة ونوع الطلب
    try {
        // استدعاء الموديل العالمي المفتوح Llama-3 المثبت سحابياً في حساب Cloudflare الخاص بك مجاناً
        const aiUrl = `https://cloudflare.com{CLOUDFLARE_ACCOUNT_ID}/ai/run/@cf/meta/llama-3-8b-instruct`;
        
        const aiResponse = await fetch(aiUrl, {
            method: 'POST',
            headers: { 'Authorization': `Bearer ${CLOUDFLARE_API_TOKEN}`, 'Content-Type': 'application/json' },
            body: JSON.stringify({
                messages: [
                    { 
                        role: "system", 
                        content: "أنت المساعد الأكاديمي المعتمد والموجه الذكي لمنصة دراستي drasty.net. مهمتك الإجابة على أسئلة الطلاب السوريين بدقة ومطابقة تامة مع كتب المنهاج السوري الرسمي والوزاري الصارم للشهادات والصفوف (تاسع وبكالوريا)، وتتحدث مع الطالب بنفس لغة سؤاله (العربية الفصحى المبسطة أو الإنجليزية النظيفة)." 
                    },
                    { role: "user", content: question }
                ]
            })
        });

        const aiData = await aiResponse.json();
        let textAnswer = aiData.result?.response || "عذراً يا بطل، لم أتمكن من معالجة سؤالك الأكاديمي حالياً، يرجى تكرار بصمتك الصوتية أو كتابتك مجدداً.";

        // 🎙️ MODE 2: إذا قام الطالب بضغط المايك وطلب الإجابة بالصوت (Voice-to-Voice AI)
        if (isVoice) {
            // توليد رابط النطق الصوتي الفوري عبر محرك خفيف لا يثقل الـ APK ولا يستهلك معالج الهاتف
            return res.json({
                success: true,
                mode: "voice",
                answerText: textAnswer,
                audioUrl: `https://google.com{encodeURIComponent(textAnswer.substring(0, 220))}`
            });
        }

        // 💬 MODE 1: إذا كان الطلب محادثة نصية كتابية عادية
        res.json({ success: true, mode: "text", answerText: textAnswer });

    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Drasty Platform Server running on port ${PORT}`));
